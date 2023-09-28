---
layout: post
title: Reformat documentation using GPT4
categories:
- software
tags:
- docstrings
- gpt4
---


* content
{:toc}

## Background

In my hubmle opinion Software Engineers write docstrings not to themselves but to other people.
But the problem with docstrings in the code, that it usually visible only to Software Engineers.
It was also the case for my current project: we had a few people we wanted from time to time understand how the things are working underneath but the only source was code in the git repository.
I decided to change it and the bright thing is that people for the long time understood it and created a way to represent docstrings as a wonderfuly rendered web pages or pdf files. In my case the choise was [Sphinx](https://web.archive.org/web/20230819153933/https://www.sphinx-doc.org/en/master/) and its plugin [apidoc](https://web.archive.org/web/20230713123316/https://www.sphinx-doc.org/en/master/man/sphinx-apidoc.html).
Unfortunately, as soon as I integrated it to our CI pipeline I noticed that some of the docstrings are not rendered properly and than I started to dig into this issue.

## Malformatted docstrings

*apidoc* works 
* Write about Sphinx, docs and make an example on broken formating



* Write about privacy and why you don't want to share code itself
* Write about converting first to ReST and then to Google style.
* Write about costs.
* Share code snippet.
