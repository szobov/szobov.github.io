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

I have a grandma.

She is already quite elderly and has some severe health issues.

I have lived abroad for two years and, due to some conditions, can't easily travel to my home country.
My grandma is an amazing woman, and I wanted to stay connected with her.
The issue here is that she is unable to use smartphones and can only use **push-button cell phones**.
Another issue is that it's expensive for both of us to call using a traditional GSM network due to roaming.

This article will tell you how I overcame these issues.

# Disclaimer


I've done some research on the available ready-to-use options.
Somehow, I missed Microsoft's options with [Skype](https://www.skype.com/en/international-calls/Russia).
I would have used this instead of tinkering with my solution if I had known it in advance.
But after I implement mine, I'll not switch to Skype since mine provides a few benefits that I'll describe above.

# The equation

(1) I have a SIM card with the local mobile number in my local county. The SIM card is needed to connect with another SIM card.

(2) I can call using my SIM card via smartphone.

(3) When I think of my smartphone, I see it as a small-sized computer with a built-in GSM modem.
 
If I substitute a smartphone from (2) via a small-sized commuter and a modem from (3), I can use the result to solve (1).
With those thoughts, I started to look for solutions.

# The solution 

Once upon a time, I worked with [Asterisk](https://www.asterisk.org/get-started/), so I knew that there are protocols that can connect phones to the Internet.
By using the right keywords, I found [RasPBX](http://www.raspbx.org/): the ready-to-use solution that one can roll out on various system-on-a-chip hardware, like [RaspberryPI](https://www.raspberrypi.com/) or [BeagleBone Black](http://beaglebone-asterisk.raspbx.org/).

Simply speaking, it's a [Raspbian](https://www.raspbian.org/) image with Asterisk with the admin interface provided through [FreePBX](https://www.freepbx.org/). More importantly, it has the drivers to connect a [GSM model USB-dongle](http://www.raspbx.org/documentation/gsm-voip-gateway-with-chan_dongle/).

{% include image.html url="/assets/images/raspbx-grandma/freepbx_interface.png" description="FreePBX interface" %}

The list of supported dongles can be found [here](https://github.com/bg111/asterisk-chan-dongle/wiki/Requirements-and-Limitations).

So, I ordered a second-hand Raspberry 2 and Huawei E169 dongle, which cost me approximately 50 euros.
For the installation and configuration, I followed [these steps](http://www.raspbx.org/documentation/#nextsteps) from the documentation.
The installation was bumpy because some steps from the documentation seemed missing. For example, I needed to create a user "asterisk" because the setup assumed it existed. Anyway, the installation took me only a short time.

{% include image.html url="/assets/images/raspbx-grandma/raspberry_dongle.jpg" description="RaspberryPI 2 and Huawei E169 connected" %}

Moreover, a detailed manual is hosted [here](https://github.com/MatejKovacic/RasPBX-install/blob/main/english.md). It's rich in images and can be an excellent place to find help.

Remember to connect your RaspberryPI 2 (if you're using it) to the router via Ethernet cable since it doesn't have a built-in WiFi module.

To simplify the network and security, I connected RaspberryPI to my VPN, so whenever I need to connect to Asterisk, I must first connect to my VPN.

That's it.

# The test

I installed [ZoiPer](https://www.zoiper.com/) on my phone to test the solution and called my mom first.

_voilà!_ It worked!
There was some delay in transmitting a sound, but we could clearly communicate (with some mental adjustment to always start speaking slowly to let the other side consider the delay).

I asked my mom to let my grandma know that I'd call so as not to scare her suddenly.
Then I called her, and we finally could talk: from Berlin to a small village on the border with Kazakhstan with my SIM card physically in Saint Petersburg.

{% include image.html url="/assets/images/raspbx-grandma/zoiper_call.jpg" description="Zoiper interface for call" %}
{% include image.html url="/assets/images/raspbx-grandma/zoiper_list.jpg" description="Looks like a classic phone calls software" %}

# Other benefits

Across the globe, mobile network providers do something that I don't like: whenever a person is not using a SIM card for a while, it is sold to another person.
Many of us (not except me) used their phone numbers as a second factor for authorization in such critical applications as mobile banks or e-government.

Also, my other family members still send me SMS with good words on my birthday. It's nice to give them this ability.

I hope this article may help you too.
