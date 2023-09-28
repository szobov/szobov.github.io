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
1. [screenshot-tests-for-android](https://facebook.github.io/screenshot-tests-for-android) -- snapshot testing...
2. [BrowserStack](https://www.browserstack.com/app-live)
3. [Espresso](https://developer.android.com/training/testing/espresso)
4. [Appium](http://appium.io/docs/en/2.1/)
5. [calabash-android](https://github.com/calabash/calabash-android)
6. [Maestro](https://maestro.mobile.dev)

