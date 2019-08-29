---
layout: post
title: GSM and altitude
categories:
- radio
image: /assets/images/default/logo.png
tags:
- GSM
- 4G
- radio
- drones
- uav
- robots
---

* content
{:toc}

## Why do we need GSM?

There are several ways to communicate with a flying copter, like a [radio telemetry](https://docs.px4.io/v1.9.0/en/telemetry/), **Wi-Fi**, or **GSM**. Actually, all of them are different kinds of a radio, but with it's own characteristics, like frequency, **range** and **bandwidth**. In our UAV project we need to transfer a huge amount of data on a long distance. And, yes, the **Wi-Fi** is a very good choice, because it can work [on the long distance](https://dev.px4.io/v1.9.0/en/qgc/video_streaming_wifi_broadcast.html), but I don't think it will work beyond visual line of sight. **GSM** could, but I wasn't sure, that it will work on a height about **60-70 meters** as well as on the ground, so I've checked it.

## Experiment

We are using [iRZ RL01w](https://irz.net/en/products/routers/r0-series/rl01w#docs) router, because it has **4G** and **Wi-Fi** in a one case and without this case it's lightweight. I've tested this router with the two famous Russian mobile operators [MTS](https://en.wikipedia.org/wiki/MTS_(network_provider)) and [MegaFon](https://en.wikipedia.org/wiki/MegaFon). The experiment occurs in a small town. There was [iperf](https://iperf.fr/) client of copter and server, exposed on our office machine.

Here is the plots of result:

![megafon](/assets/images/gsm_and_altitude/MegaFon.svg)

![mts](/assets/images/gsm_and_altitude/MTS.svg)

## Conclusion

> It's ain't much but it's honest work

Yes, you're absolutely right. It's not representative example, because the small altitude, the network coverage and the another things, which could affect the bandwidth, but I hope I'll provide more interesting data soon. Till this moment, I can definitely say, that under 70 meters, bandwidth doesn't severely decreases.
