---
layout: post
title: "RasPBX: connecting with my Grandma"
categories:
- software
- hardware
tags:
- "VoIP"
- "SIP"
- "RaspberryPI"
- "Asterisk"
- "FreePBX"
---

* content
{:toc}


# Background

I have a grandma. She is already quite in her elderly and has some severe health issues.
I live abroad for two years and due to some conditions, can't easily travel to my home country.
My grandma is an amazing woman and I wanted to stay connected with her.
The issue here, that she is unable use smartphones and can only use push-button cellphone.
Another issue, it's expensive for both of us to call using traditional GSM network due to roaming.

This article will tell you how I overcome these issues.

# Disclaimer


I've done some research on the available ready-to use options.
Somehow I missed the options Microsoft provides with [Skype](https://www.skype.com/en/international-calls/Russia).
If I would know it in advance, I would use this instead of tinkering my solution.
But after I implemented mine I'll not switch to Skype, since mine provides a few benefits I'll describe above.

# The equation

(1) I have a SIM-card in my local county with the local mobile number. The SIM-card is needed to connect with another SIM-card.
(2) I can make a call using my SIM-card via smart phone.
(3) When I think of my smartphone I see it as a small-sized computer with built-in GSM-modem.
If I substitue a smartphone from (2) via small-sized commuter and modem from (3) I can use the result to solve (1).
With those thoughts I started to look for the solutions.

# The solution 

Once upon a time I worked with [Asterisk](https://www.asterisk.org/get-started/) so I knew that there are protocols, that can connect phones to the internet.
By using right keywords I found [RasPBX](http://www.raspbx.org/): the ready to use solution that one can roll out on a various system-on-a-chip hardware, like RaspberryPI or [BeagleBone Black](http://beaglebone-asterisk.raspbx.org/).

Simply speaking, it's a [Raspbian](https://www.raspbian.org/) image with Asterisk with the admin interface provided through [FreePBX](https://www.freepbx.org/). And more importantly, it has the the drivers to connect a [GSM model USB-dongle](http://www.raspbx.org/documentation/gsm-voip-gateway-with-chan_dongle/).

The list of supported dongles can be found [here](https://github.com/bg111/asterisk-chan-dongle/wiki/Requirements-and-Limitations).

So, I ordered a second hand RaspberryPI 2 and Huawei E169 dongle which cost me approximately 50 euro.
For the installation and configuration I simply followed [these steps](http://www.raspbx.org/documentation/#nextsteps) from the documentation.
The installation was a little bumpy since some steps from the documentation seems to be missing. For example, I needed to create a user "asterisk" because the setup assume it exists. Anyway, the installation didn't take me long.

Moreover, there is a very detailed manual hosted [here](https://github.com/MatejKovacic/RasPBX-install/blob/main/english.md). It's reach on images so can be a good place to find help.

Don't forget to connect your RaspberryPI 2 (if you're using it) to the router via Ethernet cable, since it doesn't have built-in WiFi module.

To simply the network part and the security I connected RaspberryPI to my VPN, so whenever I need to connect to Asterisk I need to connect to my VPN first.

That's it. For the tests I called a few of my friends first...




