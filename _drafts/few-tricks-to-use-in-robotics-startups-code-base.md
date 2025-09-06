---
layout: post
title: "Monorepo and functions: make your robotics startup advance"
categories:
- management
tags:
- "code organization"
- ci
- monorepo
- knowledge
---

* content
{:toc}

## Background

Over decade I worked in the different small high-tech, robotics startups that often shared the same patterns: tons of repositories resembling "micro-services" architecture, OOP and classes here and there.

None of these things are bad per se, but they bring unneccesery complexity, that slows small teams down.

Bellow you'll find a couple of low hanging fruits that will make you advance your team advance.

## Monorepo

"Microservices" became a trend when I was a juniour developer. Almost every company I know brought because it's "cool". For some reasons, people consider a term "microservices" complited only if these "microservices" are split in the different repositories. Additionally, people put mobile or frontend applications separately.

Cool, yes, but only if you're a big company with many teams working on the same system.

If you're not, monorepo is should be your go-to solution.
Here is why:

### Re-usage of packages

Suppose you have several private repositories and you want to re-use the code between them.

What are your options?

Setup [Nexus](https://web.archive.org/web/20250814042034/https://www.sonatype.com/products/sonatype-nexus-repository)/[PyPI](https://web.archive.org/web/20250904182025/https://pypi.org/)/[npm](https://web.archive.org/web/20250904154814/https://www.npmjs.com/)/etc. Then you have to build your package and upload them to the local registry. Are you done? Not yet: now you need to configure package managers everywhere to point to your local registry. Do not forget, that you can f*ck up [configuration](https://web.archive.org/web/20250901190557/https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610). Finally done? Not yet, because now you also need to figure out versioning.

The other option is using submodules, but you can easily find on internet, why it's not the [best idea](https://web.archive.org/web/20250205194457/https://news.ycombinator.com/item?id=31792303).

Finally, you can use monorepo!

Literally every package manager supports local imports. No more need to copy constants across several modules, just put them in the module and export everywhere.
Do you want something fancier or you codebase consist of too many different languages? Well, use [buck2](https://web.archive.org/web/20250901201054/https://buck2.build/) or [bazel](https://web.archive.org/web/20250904083730/https://bazel.build/) (but more likely a few bash scripts will be enough in your case).

### Re-usage of static files

Remember I mentioned robotics?
What do we like at most? Big bags of triangles to represent our tools and robots? What we like even more? Big [ONNX](https://web.archive.org/web/20250831003626/https://onnx.ai/) files right into our repositories because we're too lazy to properly setup S3-like storages.

Git was not meant to store big binary blobs, so companies made ad hoc solutions like [GitLFS](https://web.archive.org/web/20250904051259/https://git-lfs.com/) to deal with it. If you want to go this way now you have to setup it everywhere you want to reuse you shine big mesh!

With **monorepo** do it once, reuse it everywhere.

### Share configuration

Suppose you have a bunch of repositories with C++ or Python packages.
You matured to the point, when you want to use production technologies such as static analysers and code formatters.
You wrote your `.clang-tidy`, `.clang-format` or `ruff.toml`. What to do next? Of course, Copy-paste them across all repositories! Nowe you want to change something and apply changes to all configuration, he-he...

Solution? Monorepo.

Put the configuration once in the root directory and that's it.

### CI

Wanna run tests and setup a GitHub action for that? Don't forget to set it up for all your repositories. Oh, now you want to trigger tests/builds in the dependant repositories, when you pushed changes to the common one? If you ever tried to do that you know it's not the easiest task.

Do you still want to do it, but don't want to deal with all this hustle?
Use monorepo. All your dependencies at hand. Moreover, most likely you want to run all of your unit-tests when did a change to ensure you didn't break other parts.

### Integration test easier

Since I mention CI and tests.

Extra benefit of using monorepo is simplified writing of integration tests.
Put your mobile/frontend application and in the same repository as your motion planner and enjoy catching bugs in the displaying your metrics when planner failed to plan all trajectories! 

### Docker

Monorepo doesn't prevent you from using micro-services. It's just make building them even more easier. Instead of dealing with uploading docker images to in-house docker registry and making sure you run the recent version, just build it right here.

More to this, you likely want to copy some of the files across multiple containers/images. With monorepo you are an enjoyer of `COPY shared_src/...`.

### Ease trasnsition

Imaging I conviced you to switch to the monorepo and merge all of your seven-eight others into one. How to make it simpler?

Do it iteratively, you don't need to change all at once. Choose the first one: "repo A".
Make sure you have all in-work branches merged in "repo A". After you merge "repo A" into monorepo to merge this branches it will require you manually cherry pick changes. Then, use `git subtree add` (without `--squash` option to preserve the history).

## Stop using Classes

Wherever I worked I often see people use classes everywhere in their code.
I think it comes from the point, that [Java](https://web.archive.org/web/20250902181930/https://www.java.com/en/) and C++ are widely studied in the universities and folks just get used to it.

I have no feelings about classes, but they're often makes writing tests much-much harder since the costructors becoming huge and objects require too many dependencies for initialization.

This is well described in the book ["Working Effectively with Legacy Code"](https://archive.org/details/working-effectively-with-legacy-code) by Michael Feathers which I highly recommend every software engineer to read.

We all know that tests are must have and they can drastically increase your development speed, but as with anything else as hard it to do as likely we avoid it.

So, what's the solution?

### Use functions

Function, and as cleaner as possible.

It may sound obvious, but the beauty of function is they interfaces: parameter and return type.
No implicit dependencies as `this->` or `self.`. Shit in - shit out.

As a contrary, several times I heared that people don't like to split into functions, but having everything in one huge spagetti, motivating that it's "easier to grasp". Well, god judge to them (and to me since I have a strong desire to punch in this case). The good thing about functions, that you can start integrating and testing them in the places, where it feels impossible.

Suppose you have a class `MoneyCutter` with a method `execute` and this method is around 400 loc. The class has a bunch of dependencies, suppose ROS' action clients, services and subscribers. Nobody every dare to cover it with tests. You have to extend this method to support choosing nearest `money_disposal_box`.
You have an option to just puke another 40 loc inside `execute` without any tests and be done. Let the person who will run the code deal with bugs.
The other option is to add a function: `select_nearest_money_disposal_box(money_position, disposal_boxes) -> disposal_box_index` and write a test for it.
The choice is yours, but you know what will make the world a better place.

