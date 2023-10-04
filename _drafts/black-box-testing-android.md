---
layout: post
title: Black box testing for Android application
categories:
- software
tags:
- testing
- mobile
- android
- maestro
---


* content
{:toc}

## Background

A few months ago I asked a question on linkedin:
![linkedin_post](/assets/images/android-black-box-testing/linked_in_post_android_testing.png)

Unfortunately, it didn't attract a lot of attention and I was still wondering.
In my current company, we use an Android application as a frontend to our complex backend system.
This Android application is the first and the only one user facing, so we needed a tool to ensure its quality.

Before I joined it was always manually tested, but the problem of this approach is not scalable.
We needed automated tests, but we didn't want to get into the Kotlin/Java code to write them.

**Our objective was**: _we need a tool to write automated tests which doesn't require Android/Java/Kotlin knowledge._

## Available options

We did initial research on the possible solution.
I'm unsure it's a full list, but these are the things we've found:
1. [screenshot-tests-for-android](https://facebook.github.io/screenshot-tests-for-android) -- a [snapshot testing](https://en.wikipedia.org/wiki/Software_testing#Output_comparison_testing) testing tool, but a little unflexible if UI of your application changes often. Also, requires integration in the source code of the application.
2. [BrowserStack](https://www.browserstack.com/app-live) -- a cloud-based platform to run tests or real or virtual devices. It seems like a powerful instrument, but vendor-locking, recurrent subscription and complexity are things that make us hesitant to try it. On it's own doesn't provide a test framework, but supports running many.
3. [Espresso](https://developer.android.com/training/testing/espresso) -- Android UI test framework. Again, requires the integration with the source code and Kotlin/Java knowledge.
4. [Appium](http://appium.io/docs/en/2.1/) -- as stated in the docs: "is an open-source project and ecosystem of related software, designed to facilitate UI automation of many app platforms". Basically, a complex UI test framework that can run on different platform: physical, virtual devices or BrowserStack. We tried to run a setup, but somehow and didn't feel easy and required many steps to integrate.
5. [Maestro](https://maestro.mobile.dev) -- the first sentence in the docstrings stated: "is the simplest and most effective mobile UI testing framework.", which made me a little skeptical, but after a we tried it turn out to be are choice. I'll describe it in details in the next section.

## Maestro

Rather new and quite obscure tool.
The first mentioning on hackernews I found [dates Aug 31, 2022](https://news.ycombinator.com/item?id=32664686).
We choice this tool over the other since:

### Simple Language

The language of writing tests is simple DSL written im YAML files. The language is simple, but capable of expressing complex flows.
This is the first example we wrote for our testing:
```yaml
appId: com.mirai.app
---
- launchApp
- extendedWaitUntil:
    visible: "Skill Overview"
    timeout: 70000 # ms (eq 70 sec)
- assertVisible:
    text: "Add new skill"
    enabled: true
```
You can see, that it's very descriptive. All the [commands](https://maestro.mobile.dev/api-reference/commands) covers what I usually do when I use our application.
Also, it's possible to express [loops](https://maestro.mobile.dev/api-reference/commands/repeat) and [importing](https://maestro.mobile.dev/api-reference/commands/runflow) from other files.
You may say it's rather too simple, but in my personal feelings complicated language leads to complicated and ofter hard to maintain tests.

### Decoupled from the Application

Maestro setup knows nothing about your application. All app-specific logic a expressed only in the tests itself. Maestro only start the application as user do it and than run a flow of commands against it. You can change the language your mobile app written in, change your build system, do whatever you want -- as far is the interface is the same, your maestro tests will stay as they are.

### Decoupled from the Hardware

You can run your tests against a physical device or against emulator.
For our setup I build a [Docker Image](https://hub.docker.com/r/szobov/maestro-android-emulator) based on [docker-android](https://github.com/budtmo/docker-android).
Speaking frankly it required a small tests update to increase the timings, since the application in the emulator works slowly, but I would say it's expected.
But the obvious benefit from wiring up these to tools: it is a perfect setup for your CI pipeline.
The hardware devices are nice, but it's not scalable, or you need to pay clouds providers, like mentioned BrowserStack. But with Docker you can ran as many instances of the simulator as could fit into your CI server.

### Click-to-test UI

Maestro includes a [browser-based UI](https://maestro.mobile.dev/getting-started/maestro-studio) where you can click and selected the elements of your app and convert them to the tests.
Personally, I consider it a killer feature, since it very much simplifies the test writing workflow.

### Readability

The file with UI tests can grow big very quickly and hard to comprehend.
Maestro support including code from other files via [runFlow](https://maestro.mobile.dev/api-reference/commands/runflow) command.
To make tests more self-descriptive you can use [label](https://github.com/mobile-dev-inc/maestro/pull/1292) with human-readable text.

## Downsides

Maestro is a very new tool and under an active development. Some features are not documented and you need from to time upgrade your installation.
Also, we didn't face any issues running it, but I may predict there could be bugs and breaking changes.

## Conclusion




