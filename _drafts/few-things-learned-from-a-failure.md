---
layout: post
title: A few things I learned from a failure
categories:
- knowledge
tags:
- team
- fail
- knowledge
---


* content
{:toc}

## Background

I recently switched jobs because the company I was part of felt bad.
I learned many things working there, but I also was a curious observer of how some decisions can affect the health of the software company.
This list is very subjective, and I may change it in the future, but I'll share those findings with you.

I will also propose possible solutions to some of them.

Let's start.

## Startup

One of our biggest mistakes is calling ourselves a "startup".
Because of so many mistakes and wrong things can be justified by just saying, "we're a startup".

I propose splitting the company's behaviour into two intervals: before and after it got investments.

### Before it got the investments

Do whatever you want. Absolutely.

Your goal is to implement PoC as soon as possible and prove your idea.
It's when it's best to choose any tools that better suit you.

Ruby on rails? Django? Ten years old PHP framework? No matter what people tell you. If you can spend a night implementing a back-end using PostgREST and writing a UI using EmberJS, please do it.

### After

So, you've gotten the investments, and now you're willing to build your own company: hiring new employees, arranging many meetings, and creating a long-term roadmap.

You want to build the COMPANY.

Then please, stop calling yourself a startup and working in a "move fast, break things" paradigm.

With building a company, build start to build a healthy software/hardware culture.

Switch to tools which are tended to force you to write better code.

Start writing tests and documentation. Organize CI&CD. Prepare an architecture of your components.

It may slow you down and make you feel like you are missing the old good wild west of waterfall planning or no planning at all.
But remind yourself that if it slows you down now, most likely, it will make you faster with time.


## Schema

I always think about different teams inside a company as different counties.
Sometimes they work in collaboration. Sometimes they don't.
But the way how they can understand each other is only by speaking the same language.

In terms of software, one schema is the language, which allows all your teams to communicate smoothly.
Sure, schema can slow you down since it brings problems like schema versioning, schema consistency, language support, etc.
But the benefits it brings feel much more important to me.

Speaking of us, we started creating schema, but I think it was too late.
Adding schema to already co-existing components is much more challenging than starting with it.
In our case, we understood the benefits of having schema, but the burden of the complex system was too heavy to express it with schema and force people to adopt it.

Speaking about the suggestions, I'll still recommend using Protobuf. Apache Avro is also something I would consider trying.

## Adoption of the internal products

We were building tools intended to be used for the teams inside the same company.
Some of them were amazing, some of them not, but all of them were struggling with the one curse: adoption.

I think there is a list of reasons, but I'll name a few which I found most important:

### Software clients

Your team built a database.
You tried to make it scalable, fast, and stable. It may even satisfy your user's needs.

Then please, provide your users with clients.

Make it a part of your product because only you know how to make it work smoothly with your component.

Working in one company means that you use a few languages. Even if you use many languages (which is strange, but it's your choice), create clients for the most common one. Write a client in Python, Java and C++. Then if another team is using another language, help them rewrite for their need by providing guidance and advice. We all know the case of Rust, where people were eager to rewrite everything themselves if the original existed.

### Documentation

Even if you have provided users with clients to your product, write documentation.

Even if you're using OpenAPI, write a description for everything.

Host your documentation in a VCS and let the users update it if they find something missing or broken links.

Hire a technical writer if it's not easy for your team. It's fine. We're software developers, not writers.
Add examples of usage, describe existing issues, and tell people how they can use it.
Ask users to tell success stories and their pain points. You're all in one boat, there are no reasons to hide, but there are reasons to spotlight.

### Tests

I won't tell you all the importance of writing tests because you probably know it better than me.
I want to highlight the idea that tests are sometimes even better than documentation.

They are written in the programming language, so people who struggle with reading natural language can understand them.

They can't become obsolete as documentation since they are always aligned with the code.

Of course, it only works if tests are written well (which is a very opinionated thing). But there are some apparent technics which you can follow: keep unit tests more straightforward and write separate acceptance and e2e tests.

## Knowledge sharing

Encourage people to share knowledge.

Make it a part of your work culture.

Let people share their developer setup, the tools they're using, pet projects they're working on, and papers they read.
Did somebody try Rust or Crystal? It should be spotlighted. Did somebody write a blog post about leadership? Let other people learn from it.

Doing so can transform any job into a place where people learn and keep their interest.

It will likely require you to hire professional HRs to moderate it and help people to present things.
Unfortunately, we're engineers, and sometimes we lack presentation skills, but almost anybody can do it with some help, mentoring and guidance.


## Chief technology officer

It may sound obvious, but it was not evident to many people I was working with and to me.

There should be a person who can supervise and observe the system on a bigger scale.
The person who will force every team to use particular tools, components, languages, etc.

Democracy works in a small company, but even there could be that teams won't share code or don't use a tool created by others.

We spent hours trying to agree on some topics instead of telling our points to one person, which then made a last choice.
It was very easy to lose track when responsibilities were not clear.

The person on the top should be responsible for this last choice.

## Afterwords

It's hard to accept, but it's an inevitable part of our life.

One thing that we can do with it is tell people so that they can learn from our mistakes.

Like many others, I wish for a bright future...

But I bet I'll extend this article with new findings. :)
