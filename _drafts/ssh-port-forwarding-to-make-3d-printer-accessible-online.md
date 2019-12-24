---
layout: post
title: Make 3D-printer online with SSH port-forwarding
categories:
- 3dprinter
image:
tags:
- 3dprinter
- ssh
- octoprint
- portforwarding
---

* content
{:toc}

## What is the problem?

Since I've bought a 3D-printer ((Ender 3)[https://www.creality3d.shop/products/creality3d-ender-3-pro-high-precision-3d-printer]) I wanted to print remotely. Think you know, it takes quite long time to print something, so I want this machine to work, even when I'm not in home.
I use an [OctoPrint](https://github.com/foosel/OctoPrint) server instance and it has a very reach **web-page** to access the 3D-printer. Due to it's **web**-page I can make it available online for the remote control. 

My (ISP)[https://www.sknt.ru/] provides free Static IPv4/6 address, and I could use it, but I don't want to deal with all this security configurations to prevent everyone from access to the printer.
There is also one alternative, even suggested by official [documentation](http://docs.octoprint.org/en/master/features/accesscontrol.html), and it is a [VPN](). And yes, it's nice, but to be frank, I've already configured the [OpenVPN]() instance, so I don't feel it's a simplest solution.

To add more context, the **OctoPrint** server run on small computer on [Ubuntu 18.04]. I also have a small virtual server in [Digital Ocean] that also run on **Ubuntu**. They both have the [SSH](https://en.wikipedia.org/wiki/Secure_Shell) server and client out of the box, so why don't I use it to provide and easiest and secure access to my printer?

## Alternatives

The [OctoPrint's blog post](https://octoprint.org/blog/2018/09/03/safe-remote-access/) shows that you can use different kinds of methods to access your printer and all of them have pros and cons.
Like [Polar Cloud](https://polar3d.com/), [MakerBot Cloud](https://www.makerbot.com/3d-printers/apps/) or [Ultimaker Cloud](https://account.ultimaker.com/app) are all closed-source software, so you pay **your privacy** and **reliability**, because it's commercial companies with not so big audience, so they may not have that experience that covers all corner cases. Actually, [thespaghettidetective](https://plugins.octoprint.org/plugins/thespaghettidetective/) looks like very nice solution, but it works on the private servers and costs some money. [DiscordRemote](https://plugins.octoprint.org/plugins/DiscordRemote/) or [Telegram](https://plugins.octoprint.org/plugins/telegram/) plugins are not the **Octoprint** interface and IMO that's not comfortable. **VPN** or **Reverse Proxy** are too complicated to set up.
For me, **SSH Port Forwarding** is the simplest and secure solution.

## Receipt

We have three main parts:

1. The computer, constantly connected to the printer. With the operation system, that supports [SSH Client](https://en.wikipedia.org/wiki/Comparison_of_SSH_clients#Platform). There are also two requirements: it should support 3d-printer controlling software, like **OctoPrint** or [Repeater server](https://www.repetier-server.com/). Likely, it will be Linux (Ubuntu/Debian) server, because they are normally used with computers like [Raspberry PI](https://www.raspberrypi.org/), [Orange PI](http://www.orangepi.org/), or even your old [Android Phone](https://github.com/foosel/OctoPrint/wiki/Using-an-Android-phone-as-a-webcam).
2. Virtual server, that could be ordered from the plethora of different kinds of cloud-providers. With the operation system, that supports [SSH Server](https://en.wikipedia.org/wiki/Comparison_of_SSH_servers#Platform). It could be either **Windows** or **Linux**.
3. Your **Linux**/**BSD**/**Windows**/**MacOS** computer, that also supports **SSH client**.

I assume, that you know, how to create and configure computer for 3d-printer server and virtual server. If you don't, you can use [this](https://www.digitalocean.com/docs/droplets/how-to/) and [this](https://octoprint.org/download/) tutorials.
