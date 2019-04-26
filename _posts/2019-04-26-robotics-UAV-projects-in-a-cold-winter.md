---
layout: post
title: The caveats for robotics (UAV) projects in a cold winter
categories:
- outdoor
tags:
- outdoor
- winter
- robots
- uav
- drones
- weather
- people
---

* content
{:toc}

As I've mentioned in the previous [article]({% post_url 2018-12-24-try-to-avoid-using-usb3.0-and-2.4hz-radio-like-gps %}), my team works on UAV project. From time to time we are doing the trials of our code and robots on a wild nature.
Because of our company located on a north of Russia, in a quite cold climatic zone, we often have a different problems, related to extreme weather condition.

So, I've decided to mention in this article the list of possible problems and advice how to avoid or mitigate it. I'll update this post if there are will be more. I understand that it could be obvious, but if you will work in the similar conditions it might help you.

Just to show you an example, it's me on one of our winter trials:

![hello](/assets/images/robotics-and-uav-projects-cold-weather/hello.jpg)

And where we are usually working:

![tumba](/assets/images/robotics-and-uav-projects-cold-weather/tumba.jpg)

I don't want to spend too much time on showing up, so let's start.


## Hardware

### Low temperature

Unfortunately, not all hardware is ready to work in such extreme conditions. For example, the onboard computers, like [ODROID-XU4](https://forum.odroid.com/viewtopic.php?t=20864) by specification can operate only in a range **0°**..**+70°C**. For [Raspberry Pi 3 Model B+](https://static.raspberrypi.org/files/product-briefs/Raspberry-Pi-Model-Bplus-Product-Brief.pdf) it's **0°**..**+50°C**. There are some onboard computers that can work at sub-zero, like [NVIDIA Jetson AGX Xavier](https://devblogs.nvidia.com/nvidia-jetson-agx-xavier-32-teraops-ai-robotics/) **-25°**..**+80°C**, or [Arrow BeagleBone Black](Arrow BeagleBone Black) **-40°**..**+80°C**.

The same problem with the cameras, for example [oCam-1MGN-U Plus](https://www.hardkernel.com/shop/ocam-1mgn-u-plus-1mp-usb3-0-mono-global-shutter/) according to specification can operate only in a range **0°C** .. **+70°C**. But actually we've done the thermal tests and it can work as expected at temperature about **-20°C**.

The situation is better with an autopilot hardware. For the autopilot that we are using, [Holybro Pixhawk 4](https://docs.px4.io/en/flight_controller/pixhawk4.html), it's **-40°**..**+85°C**. This range also the same for [Navio2](https://store.emlid.com/product/navio2/). Unfortunately, for [DJI NAZA-M V2](https://www.dji.com/naza-m-v2/spec_v1-doc) it's just **-10°**..**+50°C**.

As you can noticed, it's a big deal to choose right devices for your project, especially if your robots will work in a bad conditions. Why I think it's important? Because the consequences can be very unpleasant in debugging and mitigation. Much more easier to debug the problem in your code than understanding whats going on with hardware, for example your camera and why it suddenly stops to working without any visible problem.

It would be better to test your devices indoor, before let them fly outside. It's quite easy, just put your devices connected and tuned on into a freezer and wait. If it's still work when temperature went down, so it likely will work outside under the same temperature.

Also you can provide an additional heating. For example, if you have a big accumulator, it'll heat up under load. So, you can put your hardware somewhere near the battery and check, maybe it's enough to maintain operable temperature.

If your system will work fully automatically, you can check the temperature before starting any actions and if it's unacceptable weather condition outside, just keep your robot in a safe place and do not let it crash. To get the information about the weather you can use web api, like [Dark Sky API](https://darksky.net/dev), buy your own station, like [Vantage Vue](https://www.davisinstruments.com/solution/vantage-vue/), or [make it yourself](https://www.instructables.com/id/Complete-DIY-Raspberry-Pi-Weather-Station-with-Sof/).

### Water

Let's imagine wet snow... Mmmm, not my favorite weather. The raindrops drain through you jacket, cover your face and hands, very nasty feelings. The same for robots.
It's not only about winter, but keep in mind: you have to make your drone waterproofed, at least most important parts, because water will find a way to break your hardware.

On one of trial we wrapped up our copter with sellotape in order to provide waterproofed protection, but it wasn't good idea. This day copter dramatically fell down, because of camera suddenly shutdown. A snowbank was a good place to fall.
![wet_tbs](/assets/images/robotics-and-uav-projects-cold-weather/wet_tbs.jpg)

One of the chip but useful solution could be plastic coverage for drone, some thing [like this](https://www.ebay.ie/itm/201379747797) for *TBS Discovery*.

![coverage](/assets/images/robotics-and-uav-projects-cold-weather/tbs-cover.jpg)

Or you can find or 3D print your own case, [like this for ODROID XU4](https://www.thingiverse.com/thing:3225094). it ain't not much, but it's honest work.

Also, snow can be a huge problem for visual navigation. For example, [detection of ArUco markers](https://docs.opencv.org/4.0.0/d5/dae/tutorial_aruco_detection.html) by camera will work bad or doesn't work at all in heavy snow condition. I suppose, solution, that relies on infrared emission, like [MarkOne Beacon](https://irlock.com/products/markone-beacon-v2-0) could also work unsafe.

## People

Do not forget about humans. If you want to test your robot on a battlefield, it would be better to buy suitable equipment for you:
* **Insulated workwear**. Quite comfortable and practical, because it's been designed to protect people, that would work, for example, near to North Pole. Also it has great utilities, like unfastening back part of the pants, and trust me you'll be happy to have it. You can find this kind of clothes in special shops, like in [this one](https://en.vostok.ru/catalog/).
* **Gaiters**. The essential thing when you walking through snowbank. It defends you shoes from snow, even if you are staying knee-deep in a snowbank. You can [do it yourself](https://www.survivalkit.com/blog/diy-simple-but-very-effective-hiking-gaiters/) or just buy it somewhere, like [here](https://www.berghaus.com/on/demandware.store/Sites-brggbgbp-Site/en_MU/GeoShow-Product?pid=433091).
* **Gore-Tex boots**. I've personally tried different types of, but boots with [Gore-Tex](https://en.wikipedia.org/wiki/Gore-Tex) were the best one. I've also tried **insulated workboots**, like from the store that I've mentioned above in **insulated workwear** section, but they have several unpleasant drawbacks. The most important one is that your boots should "breeze" and your foot shouldn't sweat, but not all workboots can provide this feature.
* **Car with independent heater**. Another significant option. If you don't have a dry and warm shelter, but you have a commodious car, you can use something like [this](http://www.branoslovakia.sk/en/index.php?id=30). We've used it inside [UAZ Patriot](https://uaz.global/cars/suv/upgraded-patriot) and it often saves my fingers and toes from frostbite. ![car_and_chair](/assets/images/robotics-and-uav-projects-cold-weather/car_and_chair.jpg)
* **Laptop with plastic chassis**. I use [ASUS ZenBook 13 UX331UN](https://www.asus.com/us/Laptops/ASUS-ZenBook-13-UX331UN/) and it's fairly good laptop, but it has nasty property -- metal chassis. Why does it suck? Because it became very-very cold under frost and also starts to freeze you hands and thighs. I recommend to use laptops made from plastic rather than metal. For example, [Lenovo ThinkPad X1 Carbon](https://www.lenovo.com/us/en/laptops/thinkpad/thinkpad-x/ThinkPad-X1-Carbon-6th-Gen/p/22TP2TXX16G) can be a better choice.

Additionally, you can look on equipment for winter mountaineering or something similar, because people  there often deal with the same problems.

## Afterwords

As you can see, winter is a big deal.

You have to be prepared, but do not be afraid. Think deeply about different aspects, related to weather condition and all will go well.

I really hope, that my advice will help someone. You can also make a PR with notes about your experience, I'll be happy to update this article.

Keep your robots and yourself safe.

![sky](/assets/images/robotics-and-uav-projects-cold-weather/sky.jpg)

