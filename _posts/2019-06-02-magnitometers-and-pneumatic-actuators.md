---
layout: post
title: The problem of using pneumatic actuators and magnitometers
categories:
- hardware
tags:
- pneumatic
- magnet
- magntetometer
- robots
- uav
- drones
---

* content
{:toc}

My current project contains not only a flying drone, but also a special drone's house, where the drone is living. Actually, it's a ground station, an enclosure or just a big box, which also contains the different kinds of hardware. Significant part of this hardware is the **pneumatic actuators**, like this [festo's devices](https://www.festo.com/cat/en-us_us/products_010200). This sort of actuators are pretty well, but we've bought some of them, that used magnets to detect the position of the actuator... Bought lots of them and that wasn't a brilliant idea.

One day we've decided to check our drone with its new shiny house, but the first flight shown, that we are in a big trouble: [yaw angle](https://en.wikipedia.org/wiki/Yaw_(rotation))(heading) inside and outside the box has about **20 deg** difference. Absolutely unacceptable, because we are sending controlling signal (in our case velocity vector) to the drone in a [local tangent plane coordinates](https://en.wikipedia.org/wiki/Local_tangent_plane_coordinates), that means we can't flying in the so unstable conditions.

We've decided to mitigate it by using angles from visual position estimations and constant offset regarding to North. That means we aren't using magnetometer at all, while flying inside the enclosure.

### Conclusion

I strongly recommend to **do not use the metal and magnetic things close to your robot, if it uses the magnetometer**. If you can't, try to put it as far as possible and check magnetometer readings before starting any actions.
