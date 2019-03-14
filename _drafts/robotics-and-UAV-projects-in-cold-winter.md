---
layout: post
title: The caveats for robotic (UAV) project in a very cold winter
categories:
- blog
tags:
- outdoor
- winter
- robots
- uav
- drones
---

# {{ page.title }}

## Background

As I've mentioned in previous [article]({% post_url 2018-12-24-try-to-avoid-using-usb3.0-and-2.4hz-radio-like-gps %}), my team works on UAV project, also from time to time we do a trials on a wild nature.
Because of our company located on a north, in a quite cold climatic zone, we often have a different problems, related to extreme weather condition.

I've decided to mention here a list of this problems and advice how to avoid or mitigate it. May be I'll update this article it there are will be more. I understand that it's maybe obvious, but you'll work in the similar conditions it might help.

## Hardware

### Temperature

Unfortunately, not all hardware is ready to work in extreme conditions. For example onboard computers, like [ODROID-XU4](https://forum.odroid.com/viewtopic.php?t=20864) by specification can operate only in a range **0°**..**+70°C**, for [Raspberry Pi 3 Model B+](https://static.raspberrypi.org/files/product-briefs/Raspberry-Pi-Model-Bplus-Product-Brief.pdf) it's **0°**..**+50°C**. There are some onboard computers that can work in sub-zero, like [NVIDIA Jetson AGX Xavier](https://devblogs.nvidia.com/nvidia-jetson-agx-xavier-32-teraops-ai-robotics/) **-25°**..**+80°C**, or [Arrow BeagleBone Black](Arrow BeagleBone Black) **-40°**..**+80°C**.

The same problem with cameras, for example [oCam-1MGN-U Plus](https://www.hardkernel.com/shop/ocam-1mgn-u-plus-1mp-usb3-0-mono-global-shutter/) according to specification can operate only in a range **0°C** .. **+70°C**. But actually we've done the thermal tests and it can work fine at temperature about **-20°C**.

The situation is better with an autopilot hardware. For the autopilot that we are using, [Holybro Pixhawk 4](https://docs.px4.io/en/flight_controller/pixhawk4.html) it's **-40°**..**+85°C**. This range also the same for [Navio2](https://store.emlid.com/product/navio2/). Unfortunately, for [DJI NAZA-M V2](https://www.dji.com/naza-m-v2/spec_v1-doc) it's just **-10°**..**+50°C**.

As you can noticed, it's a big deal to choose right devices for your project, especially if your project will work in a bad condition. Why I think it's important? Because the consequences can be ready unpleasant in debugging and mitigation. Much more easier to debug the problem in your code than understanding whats going on with, for example, your camera and why it suddenly stops working without any visible problems.

### Water

Let's imagine wet snow, not my favorite weather. The drops drain through you jacket, cover your face and hands. Very unpleasant feelings actually.
So, it's not only about winter, but keep in mind: you have to make your drone waterproofed, at least most important parts, because water will find a way how to break your hardware.
One of the chip but useful solution could be plastic coverage for drone, some thing [like this](https://www.ebay.ie/itm/201379747797) for *TBS Discovery*.

![coverage](/assets/images/robotics-and-uav-projects-cold-weather/tbs-cover.jpg)

Or you can find or print your own case, like this for [ODROID XU4](https://www.thingiverse.com/thing:3225094).

Also, snow can be a huge problem for visual navigation. For example, [detection of ArUco markers](https://docs.opencv.org/4.0.0/d5/dae/tutorial_aruco_detection.html) by camera would work bad or doesn't work at all in heavy snow condition. I suppose, solution, that relies on infrared emission, like [MarkOne Beacon](https://irlock.com/products/markone-beacon-v2-0) could also work unsafe.
