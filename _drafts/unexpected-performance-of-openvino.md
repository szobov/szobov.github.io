---
layout: post
title: "Goodbye CUDA, Hello OpenVINO: Unexpected Benefits of Upgrading Python"
categories:
- software
tags:
- "ONNX"
- "OpenVINO"
- "machine learning"
- "benchmarks"
- "CUDA"
- "Ubuntu"
- "Python"
---

* content
{:toc}


# Background

At my current workplace I was tired of using an obsolete python **3.6** and decided to focus on upgrading python to something more recent, **3.10**.
My main reasoning was to improve dev-experience in using modern tooling and language feature. Also, bug fixes and safity patches.

It turned out, one of the side-effects of this upgrade was enable non-[CUDA](https://en.wikipedia.org/wiki/CUDA) machine learning inference with a noticible perfomance boost.

This article will tell you about this side-effect and may also help you to convince your collegues on why upgrades are important.

# Difficulties of upgrade

There is a bunch of problems I faced when I started the transition.

At this time we used quite an old Ubuntu **16.04** version and lead to some libraries were not available in public repos.
The most critical ones were **CUDA** related libraries.

But why should I bother about **CUDA** at all? Well, because we're using [onnxruntime](onnxruntime.ai) for machine learning inference. The version of this library is tightly bound to two things: the version of python and the version of [CUDA toolkit](https://developer.nvidia.com/cuda-toolkit). If I want to upgrade **python** I need to upgrade **onnxruntime** and inevitably **CUDA**.

At the time of the transition the only supported versions of **ubuntu** for **CUDA** were **20.04** and **22.04**.

_That's a bummer._

I was puzzled if I should continue the transition, since one of the most important parts of our system is not available.
The tough thoughts led me to a very dirty, but working solution.

I opened the instruction on installing **CUDA** toolit locally and noticed a pattern in how URL to downloading was built.

![Ubuntu20.04 nvidia repo download](/assets/images/onnx-cpu-performance/nvidia-url-download.png)

I built an URL for ubuntu **16.04** in the same manner and _voilà!_
It worked!

![Ubuntu16.04 nvidia repo download](/assets/images/onnx-cpu-performance/nvidia-16-04-debs.png)

After some back-and-forth (upgrade [linux kernel](https://kernel.ubuntu.com/mainline/) and [gcc](https://gcc.gnu.org/)) I was able to upgrade **CUDA** toolkit and install **onnxruntime** compatible with new **python**!

Show must go on!

# Metrics

Let me give a little bit of context regarding metrics.

Whenever you're doing anything regarding performance, you first need to find a reasonable way to measure _this_ performance.

In our case, we had an exact place where the actual "work" was done. Measuring the time it takes us to run this code would be perfect because, in the end, it's much easier for me to compare statistics from one place than trying to optimize several ones.

I was fortunate to have an exceptional engineer, [Georges Dubus](https://www.linkedin.com/in/georges-dubus-305a4140/), who already brought to our project [Open Telemtry](https://opentelemetry.io) stack. 

The only thing left to me is to introduce a few "flags" to distinguish metrics from different setups.

# Old CUDA vs new CPU

To this moment I had two setups: one running old python and one running new.
More over, I made it in the way, so I can quickly switch between different [Execution Providers](https://onnxruntime.ai/docs/execution-providers/).

After the first banch of benchmarks I was not going to belive it.

{% include image.html url="/assets/images/onnx-cpu-performance/new_cpu_vs_old_cuda.png" description="old vs new / GPU vs CPU (smaller is better)" %}

The _performance_ of a default **CPU** provider with newer version was roughly _equal_ to the performance of **CUDA**/**GPU** provider with the older one.


### Bigger model

I ran these benchmarks on a different setup, but the numbers were quite similar.

Sounds good, right? Well, yes, until I tested an inference of a bigger (deeper) machine learning model.
Unfortunately, the performance of **CPU** Provider was not acceptable. So I begin the research on other options.

You may also ask me, if the performance of **CUDA**/**GPU** on a newer version was good enough, why didn't I just chose this option.
Unfortunately, as I mentioned above upgrade **CUDA** was quite a laborious work, required different steps executed in a very precise order. Therefore I didn't try to fully avoid this option, but left it as a last resort.

# OpenVINO

The hardware we using utilizes **Intel CPU**.
Since after the python's upgrade this **CPU** gives us a fair performance, can I squeze more from it?

The answer is yes.
Intel made an open-source toolkit, called [OpenVINO](https://www.intel.com/content/www/us/en/developer/tools/openvino-toolkit/overview.html).
The idea is very similar to **CUDA**: optimizing training and inference of machine learning models on vendor-specific hardware.

Lucky me, Intel already implemented an [ONNX's ExecutionProvider](https://onnxruntime.ai/docs/execution-providers/OpenVINO-ExecutionProvider.html) and even made pre-compiled [wheels](https://pypi.org/project/onnxruntime-openvino/).
The changes I need to implement to benchmark is adding a new provider ["OpenVINOExecutionProvider"](https://onnxruntime.ai/docs/execution-providers/OpenVINO-ExecutionProvider.html#python-api) and executing `pip install onnxruntime-openvino`.

The only thing left to me was to run benchmarks and compare results.

Unfortunately, I don't have nice plots to show here, but here is as table consiting the statistics for the same metric I described above.

| provider | 99th percentile | Average |
| --- | --- | --- |
| CPUExecutionProvider | 65ms |49ms |
| CUDAExecutionProvider |30ms | 21ms |
| OpenVINOExecutionProvider | 33ms | 24ms |

As you can see, the performance of `OpenVINOExecutionProvider` is roughly equal to `CUDAExecutionProvider`.

# Conclusion

As you may already understood, I stick to the **OpenVINO**.

It was a bit of a journey and research, but in the end I brought an upgrade of the whole system and simplification of the requirements. **OpenVINO** runs on **CPU**, that means our product will run fully on **CPU** reducing the cost of the product! Something I didn't expect when I started the upgrade.
