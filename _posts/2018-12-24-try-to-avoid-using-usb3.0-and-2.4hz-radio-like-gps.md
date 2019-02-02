---
layout: post
title: Difficulties of using USB3.0 and 2.4 GHz radio devices
categories:
- blog
tags:
- usb3.0
- radio
- interference
- drones
---

# {{ page.title }}

## tl;dr;

Try to avoid using USB3.0 connected devices, like storage or camera, with any radio devices working on 2.4 GHz frequencies closely, even though you are using a shield on USB3.0 cable and connector. In opposite case you can get extremely unpredictable behaviour, like GPS with very highly noised output.
Especially if the devices located in small space like on the drone.

## Background

We are working with drones, like quadcopters, powered by [PX4](https://github.com/PX4/Firmware) and [pixhawk](https://pixhawk.org/#autopilots) as an autopilot. Also we are using [oCam camera](https://www.hardkernel.com/shop/ocam-1mgn-u-plus-1mp-usb3-0-mono-global-shutter/) for visual navigation. oCam is fairly cheap and compact UAV compatible camera with a global shutter. This camera supports data transfer with USB3.0 for fast data transmission. Both, flight controller and camera connected to onboard computer. Nothing special, right?
Occasionally, we test our code indoor, for visual landing and takeoff, and, less often, outdoor, to check long ranged flight using GPS.

## How we met the problem

One day we've written the part of code, that checks GPS signal before the copter starts flight. All looked very well, but when code was started, new check has been failed because of no GPS signal...
tough luck. Since this moment, it takes several hours to find that here were no bugs in out code and no problems in flight controller, but...
By the way, all PX4 ecosystem has been built to be very friendly to debug different kind of problem. So using [QGroundControl](https://github.com/mavlink/qgroundcontrol) we've found that our GPS receives signal from more than 16 satellites, but when we run our code, actual data obtained from receiver becomes absolutely noised and it looses all available satellites. What was the more interesting, after we've stopped the code we found that all the noise disappeared and it becomes noised only if we starts working with the camera. It was a sign that a root of our problem is in the camera or in the communication between camera and the onboard computer. We've decided to replace the camera cable with USB2.0 instead of USB3.0. And, wow, all noise are gone and since this moment all our flights were successful and without any GPS troubles.

## The investigation

We've spent the evening on investigating this problem and found several resources that describe the similar behaviour. The most interesting one is the Intel's paper ["USB 3.0* Radio Frequency Interference on 2.4 GHz Devices"](https://www.intel.com/content/www/us/en/io/universal-serial-bus/usb3-frequency-interference-paper.html). This document contains the report about the subject, with a recommendations how to reduce the impact of the interference. Also several good suggestions could be found in [datasheet for Intel's RealSense Camera](https://www.intel.com/content/dam/support/us/en/documents/emerging-technologies/intel-realsense-technology/realsense-camera-r200-datasheet.pdf) in the section "Shielding".

Also I've tested dependence of GPS noise and USB3.0/USB2.0 cables. The test was made in the our laboratory in indoor environment, but it can be noticed with naked eyes how sharply increase the value of several parameters on GPS receiver output. Below screenshots of [MAVLink inspector from QGroundControl](https://docs.qgroundcontrol.com/en/app_menu/mavlink_inspector.html) and I've marked more interesting values:

![comparison](/assets/images/try-to-avoid-using-usb3-and-2.4hz-radio-like-gps/usb3.0-usb2.0-comparison.png)
As you can see, here is very noticeable difference in values when data transmitted through USB3.0 cable from camera. And almost no difference when using USB2.0 cable, only some parameters, like altitude, but it's normal when test it indoor.

How devices and cable located on the real copter:

![How it's located on the drone](/assets/images/try-to-avoid-using-usb3-and-2.4hz-radio-like-gps/usb3.0-gps-location.png)

## Conclusion

For this moment it was easy for us to fix the problem. We just replaced the USB3.0 cable with USB2.0 and for our purposes it's ok, because the speed of data transfer from the camera isn't a bottleneck in our system. But what scares me is Intel's RealSense Camera that we want to use in the future. It can be connected only by USB3.0 cable and need a really fast data transfer for points cloud. Unfortunately, good shield takes space and weight, and it matters on the drone, so we can't easily use it. But I hope we'll deal with this problem somehow.
