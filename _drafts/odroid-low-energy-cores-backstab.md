---
layout: post
title: ARM big.LITTLE -- backstabbing
categories:
- hardware
tags:
- cuncurrency
- CPU
- threading
- contextswitching
---

* content
{:toc}

##

Single board computers, like [Raspberry Pi](https://www.raspberrypi.org/products/) or [others](https://all3dp.com/1/single-board-computer-raspberry-pi-alternative/), are widely used in robotics and embedded. A lots of this kind of computers contains [ARM](https://en.m.wikipedia.org/wiki/ARM_architecture) CPU. Many of them designed with [ARM big.LITTLE](https://en.wikipedia.org/wiki/ARM_big.LITTLE) architecture, that provides many advantages. In short words it makes possible to use high-performance CPU cores with low-power and less-performance cores on one chip, even if this cores are located on the different CPU.

## Our case

As I've mentioned in my previous articles ([1]({% post_url 2019-08-08-experiments-with-pose-estimations-and-aruco %}), [2]({% post_url 2019-04-26-robotics-UAV-projects-in-a-cold-winter %})) we are using [ODROID-XU4](https://wiki.odroid.com/odroid-xu4/odroid-xu4) on our drone. It does a lots of different things, like communicate with ground station, process some business logic, does the *robotics things* and etc. One of this robotic thing is visual position estimation, and as you can read in [this article]({% post_url 2019-08-08-experiments-with-pose-estimations-and-aruco %}), once I had to optimize it. While I experimented, I've noticed, that sometime my algorithm takes 4x more time, and it seems like it happens with absolutely random cases. The algorithm does complex things: process a new frame from camera, detect the ArUco markers on this frame and solve point to point problem.


* It's affect on perfomance
* Command to check this cores
* Command to nail pid to cores
