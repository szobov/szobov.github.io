---
layout: post
title: "Debugging Machine Learning Model with Netron"
categories:
- software
tags:
- "ONNX"
- "OpenVINO"
- "machine learning"
- "debug"
- "netron"
---

* content
{:toc}


# Background

This article a part of a story I wrote in ["Goodbye CUDA, Hello OpenVINO: Unexpected Benefits of Upgrading Python"]({% post_url 2024-02-03-unexpected-performance-of-openvino %}).

During this upgrade, I faced an issue that initially felt like a show-stopper but became an easy-to-fix bug.


Let me tell you the details.

# An issue

I had a machine learning model exported as [ONNX model](https://onnxruntime.ai).

* If I run an inference of this model using [CUDA Execution Provider](https://onnxruntime.ai/docs/execution-providers/CUDA-ExecutionProvider.html), it runs. 

* If  I run an inference using [OpenVINO Execution Provider](https://onnxruntime.ai/docs/execution-providers/OpenVINO-ExecutionProvider.html) it fails with the following error:
```python
onnxruntime.capi.onnxruntime_pybind11_state.RuntimeException: [ONNXRuntimeError] : 6 : RUNTIME_EXCEPTION : Exception during initialization: /home/onnxruntimedev/onnxruntime/onnxruntime/core/providers/openvino/ov_interface.cc:53 onnxruntime::openvino_ep::OVExeNetwork onnxruntime::openvino_ep::OVCore::LoadNetwork(const string&, std::string&, ov::AnyMap&, std::string) [OpenVINO-EP]  Exception while Loading Network for graph: OpenVINOExecutionProvider_OpenVINO-EP-subgraph_2_0Exception from src/inference/src/core.cpp:149:
Exception from src/frontends/onnx/frontend/src/core/graph_cache.cpp:25:
output/pos:0 node not found in graph cache
```

# Bad guess

First, I tried to understand if I correctly configured an `ExecutionProvider`.

Since the error contains the word "**cache**," I searched for a solution to clear this cache.
I found that [OpenVINOExecutionProvider has an option "cache_dir"](https://onnxruntime.ai/docs/execution-providers/OpenVINO-ExecutionProvider.html#summary-of-options), which sounded like a good candidate for fixing. 
I used this option and re-started an inference, and surprisingly, it worked, so I described it in the [GitHub Issues](https://github.com/microsoft/onnxruntime/issues/18042).

Unfortunately, it was wrong. I misstructured the way parameters passed, and it turned out the inference was silently switching to the default `CPUExecutionProvider`. It was a big pity, so I needed to look for other solutions.

# Working sample

Before continuing my search, I decided to check if this error was happening on all the files or on a particular one.
Luckily, the following sample of the trained model I took worked without errors on `OpenVINOExecutionProvider`.
That's already something!

# Look at a structure

The error tells us something is missing in the graph, so let's look at the graph.

To visualize the underlying graph structure of our model, I used [Netron](https://github.com/lutzroeder/netron): an open-source visualizer for neural networks.

Lucky me, **Netron** supports **ONNX** models as an input, so I started with visualizing the graph for the model that was rising an expection:

![Missing nodes](/assets/images/netron-debug-openvino/missing_graph.png)

Then, I compered it to the working sample:

![Correct graph](/assets/images/netron-debug-openvino/correct_graph.png)

_voilà!_

The graph clearly shows that there are missing nodes.
`OpenVINOExecutionProvider` gave me the legitimate exception!

Therefore, the fix should be done on the model side.

# Source of the bug

It turned out the incomplete model was trained on the older version of the code, which used [keras's TerminateOnNan](https://www.tensorflow.org/api_docs/python/tf/keras/callbacks/TerminateOnNaN), which was [softly](https://github.com/tensorflow/tensorflow/blob/v2.2.0/tensorflow/python/keras/callbacks.py#L807-L817) terminating a training in case of NaN values encountered in the losses. When training data was malformed, it sometimes crashed on the first epoch and produced an incomplete model.

# Conclusion

Solving the ONNX model issue with OpenVINO was tough but helpful.

At first, I thought the problem was about a cache setting, but that was wrong. The real issue was missing nodes in the model's structure, which I discovered by using **Netron** to compare the broken model with a working one. This experience showed how important it is to use the right tools for debugging machine learning models.
