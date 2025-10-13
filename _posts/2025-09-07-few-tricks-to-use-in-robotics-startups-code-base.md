---
layout: post
title: "Advance your Robotics Startup: Monorepo and Functions"
categories:
- software
tags:
- "code organization"
- management
- ci
- monorepo
- knowledge
- functions
---

* content
{:toc}

## Background

Over a decade, I worked in various **small** high-tech and robotics startups that often shared the same patterns: numerous repositories resembling "micro-services" architecture, OOP, and classes here and there.

None of these things is inherently bad, but they introduce unnecessary complexity that slows down small teams. Unfortunately, in robotics startups, it can kill your company.

Below, you'll find a couple of low-hanging fruits that will help you advance your team. 

## Monorepo

"Microservices" became a trend when I was a junior developer. Almost every company I know brought it because it's "cool". For some reason, people consider the term "microservices" complete only if these "microservices" are split into different repositories. Additionally, people put mobile or frontend applications separately.

Cool, yes, but only if you're a big company with many teams working on the same system.

If you're not, a monorepo should be your go-to solution.
Here is why:

### Re-usage of packages

Suppose you have several private repositories and you want to reuse the code between them.

What are your options?

Set up [Nexus](https://web.archive.org/web/20250814042034/https://www.sonatype.com/products/sonatype-nexus-repository)/[PyPI](https://web.archive.org/web/20250904182025/https://pypi.org/)/[npm](https://web.archive.org/web/20250904154814/https://www.npmjs.com/)/etc Then you have to build your package and upload it to the local registry. Are you done? Not yet: now you need to configure package managers everywhere to point to your local registry. Do not forget, that you can f*ck up [configuration](https://web.archive.org/web/20250901190557/https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610). Finally done? Not yet, because now you also need to figure out versioning.

The other option is using submodules, but you can easily find on the internet why it's not the [best idea](https://web.archive.org/web/20250205194457/https://news.ycombinator.com/item?id=31792303).

Finally, you can use a monorepo!

Literally every package manager supports local imports. No more need to copy constants across several modules, just put them in the module and export them everywhere.
Do you want something fancier, or does your codebase consist of too many different languages? Well, use [buck2](https://web.archive.org/web/20250901201054/https://buck2.build/) or [bazel](https://web.archive.org/web/20250904083730/https://bazel.build/) (but more likely a few bash scripts will be enough in your case).

### Re-usage of static files

Remember, I mentioned robotics?
What do we like most? Big bags of triangles to represent our tools and robots? What do we like even more? Big [ONNX](https://web.archive.org/web/20250831003626/https://onnx.ai/) files right into our repositories because we're too lazy to properly set up S3-like storage.

Git was not meant to store big binary blobs, so companies made ad hoc solutions like [GitLFS](https://web.archive.org/web/20250904051259/https://git-lfs.com/) to deal with it. If you want to go this way now, you have to set it up everywhere you want to reuse your shiny big mesh!

With a **monorepo**, do it once, reuse it everywhere.

### Share configuration

Suppose you have a bunch of repositories with C++ or Python packages.
You have matured to the point where you want to use production technologies such as static analyzers and code formatters.
You wrote your `.clang-tidy`, `.clang-format` or `ruff.toml`. What to do next? Of course, copy-paste them across all repositories! Now you want to change something and apply changes to all configurations, he-he...

Solution? Monorepo.

Put the configuration once in the root directory, and that's it.

### CI

{% include image.html url="/assets/images/monorepo-functions/reddit_comment.png" description="well framed" %}

Wanna run tests and set up a GitHub action for that? Don't forget to set it up for all your repositories. Oh, now you want to trigger tests/builds in the dependent repositories when you push changes to the common one? If you have ever tried to do that, you know it's not the easiest task.


Do you still want to do it, but don't want to deal with all this hustle?
Use a monorepo. All your dependencies are at hand. Moreover, most likely, you want to run all of your unit tests when you make a change to ensure you didn't break other parts.


### Integration tests get easier

Since I mentioned CI and tests.

An extra benefit of using a monorepo is simplified writing of integration tests.
Put your mobile/frontend application in the same repository as your motion planner and enjoy catching bugs in displaying your metrics when the planner fails to plan all trajectories! 

### Docker

Monorepo doesn't prevent you from using microservices. It just makes building them even easier. Instead of dealing with uploading Docker images to the in-house Docker registry and making sure you run the recent version, just build it right here.

More to this, you likely want to copy some of the files across multiple containers/images. With a monorepo, you are an enjoyer of `COPY shared_src/...`.

### Versioning

Versioning among different interdependent packages is hard and requires effort to make it right.

The first question you should ask yourself: Do I need per-component versioning at all?

Likely, the codebase represents your entire system. Monorepo perfectly matches it: you only need to put one tag when you do a release, and you're good to go.

### Ease transition

Imagine I convinced you to switch to the monorepo and merge all of your seven or eight others into one. How to make it simpler?

Do it iteratively; you don't need to change all at once. Choose the first one: "repo A".
Make sure you have all in-work branches merged into "repo A". After you merge "repo A" into the monorepo to merge these branches, it will require you to manually cherry-pick changes. Then, use `git subtree add` (without the `--squash` option to preserve the history).

## Stop using Classes

Wherever I worked, I often saw people use classes everywhere in their code.
I think it comes from the point that [Java](https://web.archive.org/web/20250902181930/https://www.java.com/en/) and C++ are widely studied in universities, and folks just get used to it.

I have no feelings about classes, but they often make writing tests much harder since the constructors become huge and objects require too many dependencies for initialization.

This is well described in the book ["Working Effectively with Legacy Code"](https://archive.org/details/working-effectively-with-legacy-code) by Michael Feathers, which I highly recommend every software engineer to read.

We all know that tests are a must-have and they can drastically increase your development speed, but as with anything else, as hard as it is to do, we likely avoid them.

So, what's the solution?

### Use functions

Function, and as clean as possible.

It may sound obvious, but the beauty of a function is the interface: parameter and return type.
No implicit dependencies as `this->` or `self.`. Shit in - shit out.

On the contrary, several times I heard that people don't like to split into functions, but having everything in one huge spaghetti, motivating that it's "easier to grasp". Well, god judge them (and to me, since I have a strong desire to punch in this case). The good thing about functions is that you can start integrating and testing them in places where it feels impossible.

Suppose you have a class `MoneyCutter` with a method `execute` and this method is around 400 loc. The class has a bunch of dependencies, such as ROS' action clients, services and subscribers. Nobody ever dared to cover it with tests. You have to extend this method to support choosing the nearest `money_disposal_box`.

You have an option to just puke another 40 loc inside `execute` without any tests and be done. Let the person who will run the code deal with bugs.

The other option is to add a function: `select_nearest_money_disposal_box(money_position, disposal_boxes) -> disposal_box_index` and write a test for it.
The choice is yours, but you know what will make the world a better place.

An illustrative example:

```python

class MoneyCutter:
    def __init__(self, action_client, services, money_detector, disposal_boxes):
        self.action_client = action_client
        self.money_detector = money_detector
        self.disposal_boxes = disposal_boxes
        ...

    def execute(self):
        # 400 LOC
        disposal_box_id = select_nearest_disposal(money_position, disposal_boxes)

        pass

def select_nearest_disposal(money_position, boxes):
    return min(range(len(boxes)), key=lambda i: distance(money_position, boxes[i]))

def test_select_nearest_disposal():
    money = (0, 0); boxes = [(10,0),(1,1),(5,5)]
    assert select_nearest_disposal(money, boxes) == 1
```

## Conclusion

tldr;

Default to a monorepo: pull services, apps, and shared assets into one place, keep linters/formatters at the root, build Docker right here, and tag the repo—not every component. Run the full test suite on each change. Push behavior into small, testable functions; keep classes thin and at the edges. Migrate steadily with git subtree add (no --squash) so history comes with you. Do these few things and your robotics team will spend less time wrangling toolchains and more time shipping real robots.

Do this and you’ll be alright.
