---
layout: post
title: TeraRanger Evo 60m and disappointment
categories:
- sensors
image: /assets/images/terraranger-evo-60-m-dissapointment/pack-rangefinders1.jpg
tags:
- teraranger
- rangefinder
- garmin
- lidar
- sensor
- drones
- uav
- robots
---

* content
{:toc}

## What is the problem?

As I've told you in the previous articles, currently I'm working on the UAV project and we're using [ArUco markers]({% post_url 2019-08-08-experiments-with-pose-estimations-and-aruco %}) for a precise positioning. Also we're doing a horizontal landing, so we have our markers placed on the one internal side of a big box. What all this means? Just one thing: after a drone flies out and returns to the box it must get into a place, where it could see the markers. And that is the problem. Because usual systems with **GPS** and **barometer** are too noisy. I mean, even in good conditions, like clear sky, sunny, windless it would give to us up to the several meters of the position error. But we can divide this problem on the to separate parts: the horizontal and vertical position measurement. For the precise horizontal position we can use [GPS RTK](https://en.wikipedia.org/wiki/Real-time_kinematic) and for vertical -- **rangefinders**.

This post is about my expressions after experiments with rangefinders. Especially about one of them.

## Experiments

We've looked on the three different devices: **ultrasonic rangefinder**, [TeraRanger Evo 60m](https://web.archive.org/web/20200711091755/https://www.terabee.com/shop/lidar-tof-range-finders/teraranger-evo-60m/) and [Garmin LIDAR-Lite v3](https://buy.garmin.com/en-US/US/p/557294).

![Rangefinders pack](/assets/images/terraranger-evo-60-m-dissapointment/pack-rangefinders2.jpg)

The **ultrasonic device** has been got off first: a small working distance, an unreliable output and a very high radio interference.

So, we had two competitors: **TeraRanger** and **LIDAR**. This article is not about the whole experiment, but the spoiler -- **LIDAR is a winner**.

## TeraRanger

From it's description on [this](https://web.archive.org/web/20200711091755/https://www.terabee.com/shop/lidar-tof-range-finders/teraranger-evo-60m/) the webpage:

> TeraRanger Evo 60m is the long-range Time-of-Flight addition to the Evo sensor family. With its 60 meters detection range and an update rate of up to 240Hz, it offers high-performance in a compact (from 9 grams) and low-cost design.

Sounds very promisingly, right?
But the first testing flight shown weird results. It suddenly stopped to post any distance's measurements after **10 meters** and started after we've landed below this **10 meters**. OK, we returned to the laboratory and replaced the tested **TeraRanger** with a new one and checked all wiring. Also we've checked the [source code](https://github.com/Terabee/teraranger) of the **TeraRanger ROS Node** to make sure, that it is not bad. Everything looked working. Next day of the trials shown better results, but still strange. It was quite cloudy day, but with the sunny moments. So, from the one test flight to another, **TeraRanger**'s output interrupted on the different distances, **from 5 and up to 20 meters**.

I took a break and decided to [duckduckgo](https://duckduckgo.com/) this problem. Pretty quickly I found the [article](https://www.terabee.com/wp-content/uploads/2019/04/TeraRanger-Evo-60m-Test-Results-Report-Outdoor.pdf) **"Test Results Report for TeraRanger Evo 60m sensor potential maximum range in varying outdoor conditions"**. **TLDR;** the output of the sensor depends on the surface and the light conditions. For example, for a grass bump and a cloudy day it's maximum range is **11 meters**, but for sunny day with a clear sky is **5 meters**.

Below you can see the plots with the three sources of an altitude: **LIDAR**, **TeraRanger** and **fused EKF data from the flight controller**. (The code, that collected data from LIDAR was buggy and lost timestamps, but the actual data is very accurate).

![rangefinders experiment 1](/assets/images/terraranger-evo-60-m-dissapointment/range-finders-1.png)
[click to open in new tab](/assets/images/terraranger-evo-60-m-dissapointment/range-finders-1.png)

![rangefinders experiment 2](/assets/images/terraranger-evo-60-m-dissapointment/range-finders-2.png)
[click to open in new tab](/assets/images/terraranger-evo-60-m-dissapointment/range-finders-2.png)

## Conclusion

I think you understand, why we didn't decide to use **TeraRanger** --  we want our system to work in the most outdoor conditions. Actually, **LIDAR-Lite v3** is also not a silver bullet, but it's much more reliable and stable for weather and surfaces.
