---
layout: post
title: "State of Packaging in ROS2 and how I fixed it"
categories:
- software
tags:
- "ROS2"
- packaging
- docker
- conan
- uv

---

* content
{:toc}

## Background

What made me always wonder, why robotics folks, especially ROS ones, are tend to reinvent things.
Builds systems, packaging, distribution, communication layers.

Though, there are usually production grade components, we're still make something brand new (and not really compatible).

And today we'll be talking about packaging in ROS2.

## Status quo

ROS2 shipped with two languages support: C++ and Python.

The main way of distribution of the installation of the packages is rolling `deb` packages. Even if you're not using ros-rolling, you're still receiving all the new versions, without explicit way to specify version of the packages.

If you want to use a package, that is not available as a `deb` package you'd need to figure out your own way of installing an using it.

By default, ROS2 nd `aptitude`.

By default, ROS2 propose you to create a separate directory on your filesystem to be so called "ros workspace".

## It's broken

You've got a quick gleam into the state of the art ROS2 packaging and if you worked with it in the production, you've like faced these issues:

* No ways to specify version of the packages, not for C++ nor for Python and the update breaks your code.
* Python packages, available in ROS apt repository are older then you and there is no obvious way to update it.
* No way to cache `rosdep` installation in Docker.
* Installation of Python packages through `deb` is slow then staying still.
* C++ package that is not available via `apt install` requires sophisticated way to build.
* No ways to use lockfiles
* No ways to make reproducible builds

## Taking the control back

ROS2 building system, [colcon](https://pypi.org/project/colcon-core/), is a python module. Moreover, colcon made in the way so it introspects python environment it was executed from. Therefore, we can start utilizing it from our virtual env created by [uv](https://docs.astral.sh/uv/guides/install-python/#getting-started):
```bash
uv venv --python=3.12 .env
source .env/bin/activate
python3 -m colcon build
source install/setup.sh
```

_voilà!_

Now, our ROS2 setup is using python created from with virtualenv.

The side-effect of this installation that we have to install all python packages that are included by default with ROS2 installation into our setup, but now we can specify it in the `pyproject.toml` with versions and lockfile.
```
requires-python = ">=3.12"
dependencies = [
    "catkin-pkg>=1.0.0",
    "colcon-argcomplete>=0.3.3",
    "colcon-bash>=0.5.0",
    "colcon-cd>=0.1.1",
    "colcon-cmake>=0.2.29",
    "colcon-common-extensions>=0.3.0",
    "colcon-core>=0.19.0",
    "colcon-defaults>=0.2.9",
    "colcon-devtools>=0.3.0",
    "colcon-library-path>=0.2.1",
    "colcon-metadata>=0.2.5",
    "colcon-notification>=0.3.0",
    "colcon-output>=0.2.13",
    "colcon-package-information>=0.4.0",
    "colcon-package-selection>=0.2.10",
    "colcon-parallel-executor>=0.3.0",
    "colcon-python-setup-py>=0.2.9",
    "colcon-ros>=0.5.0",
    "lark>=1.2.2",
    "numpy>=2.3.1",
    "rospkg>=1.6.0",
    "setuptools==75.8.0",
]
```

That means that we can specify other packages we want to make available in our system:
```
uv add conan opentelemetry-sdk opencv-headless
```

By these steps we already solved a few issues:

> Python packages, available in ROS apt repository are older then you and there is no obvious way to update it.
> Installation of Python packages through `deb` is slow then staying still.
and half of
> No ways to specify version of the packages, not for C++ nor for Python and the update breaks your code
> No ways to use lockfiles
> No ways to make reproducible builds

You should notice that I installed [conan](https://conan.io) -- software package manager for C and C++.
We can now add `conanfile.txt` into our packages:
```
[requires]
opentelemetry-cpp/1.21.0
grpc/1.67.1

[generators]
CMakeDeps
CMakeToolchain
ROSEnv

[options]
opentelemetry-cpp/*:with_otlp_grpc=True
```
and update our `CMakeLists.txt` files.

But now the question, how you orchestrate these dependencies.

This is not a part of `colcon`/`rosdep` setup, so we have to integrate into our build system.

Lucky you I already made a setup that can serve these needs.
There is a [build-locally.bash](https://github.com/szobov/ros-opentelemetry/blob/0bba194815a331722e9aa4e0b1b7f406d2be8cc9/bin/build-locally.bash) script I'm using in [ros-telemetry](https://github.com/szobov/ros-opentelemetry) library.

Under the hood it traverse your ROS2 package directories that includes `pyproject.toml` or `conanfile.txt` and execute either `uv sync --inexact` or `conan install`.

By this we finished the second halves of the mentioned issues.

## Bringing caching home (docker)

If you're using Docker to build your ROS2 environment and you followed ROS2 [tutorials](https://docs.ros.org/en/foxy/Tutorials/Intermediate/Rosdep.html), likely you have in your ROS2 Dockerfile code is:
```
rosdep install --from-paths src -y --ignore-src
```
This code is traversing all available packages from you `src` directory and dynamically installing all `deb` available packages.

All good, except that it works terribly for the layer-caching and it is likely executed every time you run `docker build`.

To solve this I use this trick -- generate a `rosdep-deps.txt`:
```just
generate-ros-dep-txt:
    @echo "Generating rosdep dependency list..."
    @temp_file="rosdep-deps.txt.tmp" && \
    docker run --rm -v "$PWD/src:/src" ros:jazzy bash -c "\
        rosdep update >/dev/null 2>&1 && \
        rosdep keys --from-path /src | xargs rosdep resolve | grep -v '^#' | grep -v 'ERROR' | sort" > $$temp_file && \
    if ! cmp -s $$temp_file rosdep-deps.txt; then \
        mv $$temp_file rosdep-deps.txt && echo "Updated rosdep-deps.txt"; \
    else \
        rm $$temp_file && echo "No changes to rosdep-deps.txt"; \
    fi
```

The resulting file looks like this:
```
python3-pytest
ros-jazzy-action-msgs
ros-jazzy-ament-cmake
ros-jazzy-ament-copyright
ros-jazzy-ament-flake8
```
Now you update your `Dockerfile` to include the following:
```
COPY ./rosdep-deps.txt ./rosdep-deps.txt

RUN apt-get update && \
    xargs apt-get install -y < ./rosdep-deps.txt && \
    rm -rf /var/lib/apt/lists/*
```
So if there is no updates of `rosdep-deps.txt` this part of the image will be cached and reused on every build.

## Nexus

...
