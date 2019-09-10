---
layout: post
title: ARM big.LITTLE -- backstabbing
categories:
- hardware
image: /assets/images/arm-big-little/odroid-xu4.jpeg
tags:
- ARM
- ARM-big-little
- CPU
- threading
- contextswitching
---

* content
{:toc}

Single board computers, like [Raspberry Pi](https://www.raspberrypi.org/products/) or [others](https://all3dp.com/1/single-board-computer-raspberry-pi-alternative/), are widely used in robotics and embedded. A lots of this kind of computers contains [ARM](https://en.m.wikipedia.org/wiki/ARM_architecture) CPU. Many of them designed with the [ARM big.LITTLE](https://en.wikipedia.org/wiki/ARM_big.LITTLE) architecture, that provides the different advantages. In short words it makes possible to use high-performance CPU cores with low-power and less-performance cores on one chip, even if this cores are located on the different CPU.

## Our case

As I've mentioned in my previous articles ([1]({% post_url 2019-08-08-experiments-with-pose-estimations-and-aruco %}), [2]({% post_url 2019-04-26-robotics-UAV-projects-in-a-cold-winter %})) we are using [ODROID-XU4](https://wiki.odroid.com/odroid-xu4/odroid-xu4) on our drone.

![odroid](/assets/images/arm-big-little/odroid-xu4.jpeg)

It does a lots of different things, like communicates with ground station, process some business logic, does the **robotics things** and etc. One of this robotic thing is a visual position estimation, and as you can read in [this article]({% post_url 2019-08-08-experiments-with-pose-estimations-and-aruco %}), once I had to optimize it. While I've experimented, I've noticed, that sometimes my **algorithm takes 4x more time**, and it seems like it happens with absolutely random cases. The algorithm does a bunch of the complex things: process a new frame from a camera, detect the ArUco markers on this frame and solve a point to point problem. Debugging with GDB and logs didn't help, just the randomly happened delays. But after I've assumed that the problem is not in my code, but in **cooperation between CPU and OS's scheduler**, it's been quite easy to check and fix it.

To be clear, all commands executed on **Ubuntu 16.04**.

## Find who is a villain

To find each cores are weaker I've used this magic script:

```
$ for cpuN in /sys/bus/cpu/devices/*; do echo "$cpuN:"; for info in cpu_capacity cpufreq/affected_cpus cpufreq/cpuinfo_max_freq; do cat $cpuN/$info | xargs -I{} printf "\t%-25s\t%s\n" "$info" "{}"; done; done
/sys/bus/cpu/devices/cpu0:
        cpu_capacity                    404
        cpufreq/affected_cpus           0 1 2 3
        cpufreq/cpuinfo_max_freq        1500000
/sys/bus/cpu/devices/cpu1:
        cpu_capacity                    404
        cpufreq/affected_cpus           0 1 2 3
        cpufreq/cpuinfo_max_freq        1500000
/sys/bus/cpu/devices/cpu2:
        cpu_capacity                    404
        cpufreq/affected_cpus           0 1 2 3
        cpufreq/cpuinfo_max_freq        1500000
/sys/bus/cpu/devices/cpu3:
        cpu_capacity                    404
        cpufreq/affected_cpus           0 1 2 3
        cpufreq/cpuinfo_max_freq        1500000
/sys/bus/cpu/devices/cpu4:
        cpu_capacity                    1024
        cpufreq/affected_cpus           4 5 6 7
        cpufreq/cpuinfo_max_freq        2000000
/sys/bus/cpu/devices/cpu5:
        cpu_capacity                    1024
        cpufreq/affected_cpus           4 5 6 7
        cpufreq/cpuinfo_max_freq        2000000
/sys/bus/cpu/devices/cpu6:
        cpu_capacity                    1024
        cpufreq/affected_cpus           4 5 6 7
        cpufreq/cpuinfo_max_freq        2000000
/sys/bus/cpu/devices/cpu7:
        cpu_capacity                    1024
        cpufreq/affected_cpus           4 5 6 7
        cpufreq/cpuinfo_max_freq        2000000
```

On this output you can find, that cores with numbers 0, 1, 2 and 3 have the smaller capacity and max frequency. The strongest cores are **4, 5, 6 and 7**.
Actually, you can obtain this information in the different ways, like using `hwinfo --cpu --short`.

## The command to nail a process

I've found which cores are strongest and I want it to process my CPU-intensive code, so I deal it with command `taskset`.

From `man taskset`:
> taskset  is  used  to  set or retrieve the CPU affinity of a running process given its pid, or to launch a new command with a given CPU affinity.  CPU affinity is a scheduler property that "bonds" a process to a given set of CPUs on the system.  The Linux scheduler will honor the given CPU affinity and the process will not run on any other CPUs.  Note that the Linux scheduler also supports natural CPU affinity: the scheduler attempts to keep processes on the same CPU as long as practical for performance reasons.  Therefore, forcing a specific CPU affinity is useful only in certain applications.

I think, yes, absolutely, I want my application to be run on the certain CPUs. Consequently, I wrote a small piece of code, that retrieve a current process identificator using [getpid](http://man7.org/linux/man-pages/man2/getpid.2.html) and nail it with the command: `taskset -apc 4-7 <pid>`.

After this manipulations, I've get best and stable performance without change sophisticated image processing code.

To conclude, I just want you and me to remember, that sometimes the performance problems and bottlenecks could be not in our code, but come from hardware. Especially, if you're working on the small computer, like our **ODROID**.
