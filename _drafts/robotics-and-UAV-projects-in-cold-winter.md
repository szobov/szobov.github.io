---
layout: post
title: The caveats for robotic (UAV) projects in a cold winter
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

As I've mentioned in previous [article]({% post_url 2018-12-24-try-to-avoid-using-usb3.0-and-2.4hz-radio-like-gps %}), my team works on UAV project. Also from time to time we do the trials on a wild nature.
Because of our company located on a north of Russia, in a quite cold climatic zone, we often have a different problems, related to extreme weather condition.

I've decided to mention here a list of this problems and advice how to avoid or mitigate it. May be I'll update this article it there are will be more. I understand that it's maybe obvious, but you'll work in the similar conditions it might help.

## Hardware

### Temperature

Unfortunately, not all hardware is ready to work in extreme conditions. For example onboard computers, like [ODROID-XU4](https://forum.odroid.com/viewtopic.php?t=20864) by specification can operate only in a range **0°**..**+70°C**, for [Raspberry Pi 3 Model B+](https://static.raspberrypi.org/files/product-briefs/Raspberry-Pi-Model-Bplus-Product-Brief.pdf) it's **0°**..**+50°C**. There are some onboard computers that can work in sub-zero, like [NVIDIA Jetson AGX Xavier](https://devblogs.nvidia.com/nvidia-jetson-agx-xavier-32-teraops-ai-robotics/) **-25°**..**+80°C**, or [Arrow BeagleBone Black](Arrow BeagleBone Black) **-40°**..**+80°C**.

The same problem with cameras, for example [oCam-1MGN-U Plus](https://www.hardkernel.com/shop/ocam-1mgn-u-plus-1mp-usb3-0-mono-global-shutter/) according to specification can operate only in a range **0°C** .. **+70°C**. But actually we've done the thermal tests and it can work fine at temperature about **-20°C**.

The situation is better with an autopilot hardware. For the autopilot that we are using, [Holybro Pixhawk 4](https://docs.px4.io/en/flight_controller/pixhawk4.html) it's **-40°**..**+85°C**. This range also the same for [Navio2](https://store.emlid.com/product/navio2/). Unfortunately, for [DJI NAZA-M V2](https://www.dji.com/naza-m-v2/spec_v1-doc) it's just **-10°**..**+50°C**.

As you can noticed, it's a big deal to choose right devices for your project, especially if your project will work in a bad condition. Why I think it's important? Because the consequences can be ready unpleasant in debugging and mitigation. Much more easier to debug the problem in your code than understanding whats going on with, for example, your camera and why it suddenly stops working without any visible problems.

### Water

Let's imagine wet snow, not my favorite weather. The drops drain through you jacket, cover your face and hands. Very unpleasant feelings actually.
So, it's not only about winter, but keep in mind: you have to make your drone waterproofed, at least most important parts, because water will find a way how to break into your hardware.
One of the chip but useful solution could be plastic coverage for drone, some thing [like this](https://www.ebay.ie/itm/201379747797) for *TBS Discovery*.

![coverage](/assets/images/robotics-and-uav-projects-cold-weather/tbs-cover.jpg)

Or you can find or print your own case, like this for [ODROID XU4](https://www.thingiverse.com/thing:3225094).

Also, snow can be a huge problem for visual navigation. For example, [detection of ArUco markers](https://docs.opencv.org/4.0.0/d5/dae/tutorial_aruco_detection.html) by camera would work bad or doesn't work at all in heavy snow condition. I suppose, solution, that relies on infrared emission, like [MarkOne Beacon](https://irlock.com/products/markone-beacon-v2-0) could also work unsafe.

## People

Do not forget about humans. If you want to test your code on a battlefield, it would be better to buy suitable equipment:
* **Insulated workwear**. It's quite comfortable and practical, because it's been designed to protect people, that would work, for example, near to North Pole. Also it has great utilities, like unfastening back part of the pants, and trust me you'll use it. You can find this kind of clothes in special shops, like [this](https://en.vostok.ru/catalog/).
* **Gaiters**. the essential thing when you walking through snowbank. It defends you shoes from snow, event if you are staying knee-deep in a snowbank. You can [do it yourself](https://www.survivalkit.com/blog/diy-simple-but-very-effective-hiking-gaiters/) or just it buy somewhere, like [here](https://www.berghaus.com/on/demandware.store/Sites-brggbgbp-Site/en_MU/GeoShow-Product?pid=433091)
* **Gore-Tex boots**. I've personally tried different types of, but boots with [Gore-Tex](https://en.wikipedia.org/wiki/Gore-Tex) were the best one. I've also tried **insulated workboots**, like from the store that I've mentioned above under insulated workwear point, but they have several unpleasant problems. The most important one is that your boots should "breeze" and your food shouldn't sweat, and not all workboots can provide it.
* **Car with independent heater** is another significant option. If you don't have a shelter, but you have a commodious car, you can us something like [this](http://www.branoslovakia.sk/en/index.php?id=30). We've used it inside [UAZ Patriot](https://uaz.global/cars/suv/upgraded-patriot) and it often saves my fingers and toes from frostbite.
* **Laptop with plastic chassis**. I use [ASUS ZenBook 13 UX331UN](https://www.asus.com/us/Laptops/ASUS-ZenBook-13-UX331UN/) and it's fairly good, but it has nasty property -- metal chassis. Why does it suck? Because it became very-very cold under frost and starts to freeze you hands and thighs. So I recommend to use laptops made from plastic rather than metal.
