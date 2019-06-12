---
layout: post
title: Experiments with pose estimation by ArUco Markers and SolvePnP
categories:
- camera
tags:
- ros
- camera
- opencv
- robots
---

* content
{:toc}

## What am I talking about?

If your robot will move in the conditions, where a using of GPS is almost impossible, e.g. inside buildings, you need to have spare source of pose estimation. One of the cheap and proven solution is pose estimation with a [calibrated camera]({% post_url 2019-05-19-camera-calibration-with-ros %}) and printed markers, like [AprilTags](https://github.com/AprilRobotics/apriltag) or [ArUco](https://docs.opencv.org/3.1.0/d5/dae/tutorial_aruco_detection.html) markers. The second variant of markers we are using in our project. After a long road of different experiments, now we take 5-10 centimeters precision with a distance of 6-7 meters. Also we have quite acceptable framerate, about 50 fps.

I've decided to mention in this article several important notes, that I got, while developed this system of visual positioning.
All of this notes related to [OpenCV 3.4](https://docs.opencv.org/3.4.6/d9/d6a/group__aruco.html). All benchmarks has been made on [ODROID-XU4](https://forum.odroid.com/viewtopic.php?t=20864) and using [oCam-1MGN-U Plus](https://www.hardkernel.com/shop/ocam-1mgn-u-plus-1mp-usb3-0-mono-global-shutter/).

## Resolution is important

It's quite obvious, that time consumption of marker detection algorithm depends on a count of pixels of processing image. If you have 1280x720 pixels image, every time the algorithm will process 3 times more, then if it was 640x480. But if you want decrease resolution in order to get a performance, a precision will decrease accordingly.

oCam-1MGN-U Plus can provide 60fps@1280×720 and 80fps@640×480, and when I changed the resolution I've noticed, that time to take an image from camera matrix to my program through the [v4l](http://wiki.ros.org/usb_cam) driver changes too. The changes were not too big, about several milliseconds, but if we are speaking about robot positioning, we need to get as fast system as possible with a acceptable precision.

## Effect of binning

The camera matrix sensor has physically a fixed resolution and it's equal to maximal image resolution. Usually you can see it counted in megapixels, for example for mentioned [oCam's sensor](https://www.onsemi.com/PowerSolutions/product.do?id=AR0135AT) it is `1280 x 960 / 1000000` and approximately equal to 1.2 MP.
The question is how camera can provide the image with smaller size? Here is no magic, it calls [binning](https://www.baslerweb.com/ru/prodazhi-i-tekhpodderzhka/baza-znanij/vopros-otvet-faq/what-is-binning/15191/). Long story short, an image processor inside the camera takes several pixels of raw image and make just one pixel from them. In my case, for 640x480 we have 4 --> 1 pixel transformation. Why is it important? Because the neighboring pixels start to affect each other. If we have some markers close, on some shoots we can have incorrectly detected marker's contours. To mitigate it, try to do not put markers close to each other.

How this effect does look like:

![binning_effect](/assets/images/experiments-with-pose-estimations-and-aruco/binning_effect.png)

## Focus is important

As you can understand from the text above, the visibility of marker's contours have a significant impact. So, before doing anything, be sure that your camera is **focused on an acceptable distance**.

## Light condition

When I've debugged our problem with pose estimation, I was surprised how the output of [adaptive thresholding](https://docs.opencv.org/3.4.0/d7/d1b/group__imgproc__misc.html#ga72b913f352e4a1b1b397736707afcde3) strongly depends on illumination of marker's board.
We've used (#TODO model of our current IR projectors) as a source of light, but it's not enough. They produces light with (#TODO lumens) [lumens](https://en.wikipedia.org/wiki/Lumen_(unit))  and a quite small radius, so they can't provide uniform illumination and a **white color becoming gray**. Unfortunately, this is unacceptable for marker detection, because adaptive thresholding starts to give a noisy and wrong output.
With several tests, I've found that an acceptable illumination with about (#TODO lumens) of [luminous flux](https://en.wikipedia.org/wiki/Luminous_flux).
(#TODO images with effect of good light and bad)

## IMU as a source of angles

The [IMU](https://en.wikipedia.org/wiki/Inertial_measurement_unit) of our [flight controller](https://docs.px4.io/en/flight_controller/pixhawk-2.html) can give to us very precise value of [rotation quaternion](https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation)



* How we use it with correction of ground truth angles from IMU?
* Why need to change it?
* Effect of corner refining
* Table of std and parameters
* Conclusion
