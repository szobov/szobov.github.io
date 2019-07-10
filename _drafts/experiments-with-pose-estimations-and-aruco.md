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

If your robot will move in the conditions, where a using of GPS is almost impossible, e.g. inside buildings, you need to have spare source of pose estimation. One of the cheap and proven solution is pose estimation with a [calibrated camera]({% post_url 2019-05-19-camera-calibration-with-ros %}) and printed markers, like [AprilTags](https://github.com/AprilRobotics/apriltag) or [ArUco](https://docs.opencv.org/3.1.0/d5/dae/tutorial_aruco_detection.html) markers. The second variant of markers we are using in our project. After a long road of different experiments, now we take **5-10 centimeters precision** with a distance of **6-7 meters**. Also we have quite acceptable framerate, about **50 fps**.

I've decided to mention in this article several important notes, that I got, while developed this system of visual positioning.
All of this notes related to [OpenCV 3.4](https://docs.opencv.org/3.4.6/d9/d6a/group__aruco.html). All benchmarks has been made on [ODROID-XU4](https://forum.odroid.com/viewtopic.php?t=20864) and using [oCam-1MGN-U Plus](https://www.hardkernel.com/shop/ocam-1mgn-u-plus-1mp-usb3-0-mono-global-shutter/).

## Resolution is important

It's quite obvious, that time consumption of marker detection algorithm depends on a count of pixels of processing image. If you have **1280x720** pixels image, every time the algorithm will process **3 times more**, then if it was **640x480**. But if you want decrease resolution in order to get a performance, a precision will decrease accordingly.

**oCam-1MGN-U Plus** can provide **60fps@1280×720** and **80fps@640×480**, and when I changed the resolution I've noticed, that time to take an image from camera matrix to my program through the [v4l](http://wiki.ros.org/usb_cam) driver changes too. The changes were not too big, about several milliseconds, but if we are speaking about robot positioning, we need to get as fast system as possible with a acceptable precision.

## Effect of binning

The camera matrix sensor has physically a fixed resolution and it's equal to maximal image resolution. Usually you can see it counted in megapixels, for example for mentioned [oCam's sensor](https://www.onsemi.com/PowerSolutions/product.do?id=AR0135AT) it is `1280 x 960 / 1000000` and approximately equal to **1.2 MP**.
The question is how camera can provide the image with smaller size? Here is no magic, it calls [binning](https://www.baslerweb.com/ru/prodazhi-i-tekhpodderzhka/baza-znanij/vopros-otvet-faq/what-is-binning/15191/). Long story short, an image processor inside the camera takes several pixels of raw image and make just one pixel from them. In my case, for **640x480** we have **4 --> 1** pixel transformation. Why is it important? Because the neighboring pixels start to affect each other. If we have some markers close, on some shoots we can have incorrectly detected marker's contours. To mitigate it, try to do not put markers close to each other.

How this effect does look like:

![binning_effect](/assets/images/experiments-with-pose-estimations-and-aruco/binning_effect.png)

## Focus is important

As you can understand from the text above, the visibility of marker's contours have a significant impact. So, before doing anything, be sure that your camera is **focused on an acceptable distance**.

## Light condition

When I've debugged our problem with pose estimation, I was surprised how the output of [adaptive thresholding](https://docs.opencv.org/3.4.0/d7/d1b/group__imgproc__misc.html#ga72b913f352e4a1b1b397736707afcde3) strongly depends on illumination of marker's board.
We've used IR projectors [DOMINANT II™+ Infra Red](http://www.irtechnologies.ru/infra-red-d252.html)  as a source of light, but it's not enough. They produces light with (#TODO lumens) [lumens](https://en.wikipedia.org/wiki/Lumen_(unit))  and a quite small radius, so they can't provide uniform illumination and a __white color becoming gray__. Unfortunately, this is unacceptable for marker detection, because adaptive thresholding starts to give a noisy and wrong output.
With several tests, I've found that an acceptable illumination with about (#TODO lumens) of [luminous flux](https://en.wikipedia.org/wiki/Luminous_flux).
(#TODO images with effect of good light and bad)

## IMU as a source of angles

The [IMU](https://en.wikipedia.org/wiki/Inertial_measurement_unit) of our [flight controller](https://docs.px4.io/en/flight_controller/pixhawk-2.html) can gives a very precise value of [rotation quaternion](https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation). But wait, the output of [solvePnP](https://docs.opencv.org/3.4.6/d9/d0c/group__calib3d.html#ga549c2075fac14829ff4a58bc931c033d) is the rotation and the translation vectors. What if we'll use the rotation angles from IMU, but the translation from `solvePnP`? Actually, the estimations of the translation vector by `solvePnP` is more precise, then rotation, that means if we will use more accurate source of rotation angles, we will get better working system. Additionally, we can use a smaller resolution of an image, enough to estimate the translation fairly, and score in the performance.
To be clear, we've used the `pose.orientation` from [/local_position/pose](http://wiki.ros.org/mavros#mavros.2BAC8-Plugins.local_position) topic, and then converted it to Euler angles (it's easy to deal with and more understandable for humans). After it, you can make the [tf2::Transform](http://docs.ros.org/jade/api/geometry_msgs/html/msg/Transform.html) and use it everywhere you want in your ROS code.
We've tested this solution and it works really well: very precise positioning without severe deviations. Just what we want, but...

## Magnets: strikes back

In my [previous article]({% post_url 2019-06-02-magnetometers-and-pneumatic-actuators %}) I've mentioned that one day we've discovered a very hard magnetic interference inside our automated ground station. Yes, that breaks all our plans, because since this moment we can use the **yaw angle** from IMU. Is it a Time to return to the Stone Age or we can do something to make our visual position estimation robust and precise again?

## Game of parameters

That was a time, when I took my laptop and went to our laboratory to find a solution. We didn't want to use a bigger resolution due to it hurts the performance, but we had to fix the accuracy.
I've started to rereading a documentation and looking on our algorithm. We had two players: `aruco::detectMarkers` and `cv::solvePnP`. It didn't take too much time to find, that `cv::solvePnP` is doing it's job quite well, but `aruco::detectMarkers` is not. Because of binning, illumination and focus, it was difficult for `detectMarkers` to recognize contours of markers. I've found that this method has [lots of parameters](https://docs.opencv.org/3.4.1/d1/dcd/structcv_1_1aruco_1_1DetectorParameters.html) and I didn't want to choose it manually. Also with several experiments I've noticed, that most important parameters is:
* `adaptiveThreshWinSizeMax`
* `adaptiveThreshWinSizeMin`
* `adaptiveThreshWinSizeStep`
* `cornerRefinementMethod`
* `cornerRefinementWinSize`
* `cornerRefinementMinAccuracy`

Too many parameters to find with brute force, unfortunately. But we can use the same value for `adaptiveThreshWinSizeMax` and `adaptiveThreshWinSizeMin`, because we just want to find the best window. That means that we can rid of `adaptiveThreshWinSizeStep`. We also can set a small value for `cornerRefinementMinAccuracy` and after check it's effect visually. The value of `cornerRefinementMethod` was also chosen as `CORNER_REFINE_CONTOUR` because it was more stable than `CORNER_REFINE_NONE` and `CORNER_REFINE_SUBPIX`.
So, after this inspection left only two mutable parameters: `adaptiveThreshWinSize` and `cornerRefinementWinSize`.
I wrote small piece of code, that went through parameters, sent it to another service, that calculated [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) and combined it to `csv` file. After I've put the camera on fixed place, turned on the light and went out to do something else. After several hours the report was done.

[Here is](https://docs.google.com/spreadsheets/d/1EDb3lZr4qxF3SI_sTS4PJj2DlKOLGCD5HGJkCgIwjaA/edit?usp=sharing) two of several reports, that I've created. I'm not so good in math, so I just took a standard deviation of position and yaw angle, normalized it (unfortunately, you can't just sum degrees with meters :(((() and looked on a top10.
Long story short, I chosen this values: `adaptiveThreshWinSizeMin=5, adaptiveThreshWinSizeMax=5, adaptiveThreshWinSizeStep=100, cornerRefinementWinSize=10, cornerRefinementMinAccuracy=0.001, cornerRefinementMaxIterations=50`. I'm not sure, that it's a best one, but tests in a real world show, that it works quite well and better than it was.

* Conclusion
