---
layout: post
title: Human-readable protobuf -- text and JSON formats.
categories:
- utilities
tags:
- protobuf
- c++
- JSON
---

* content
{:toc}

This article can be interesting for you if you use or plan to use [protobuf](https://github.com/protocolbuffers/protobuf).
**Protobuf** is a binary format and it's wonderful, but sometimes we need something more readable, and **protobuf** can give it to us with [text](https://developers.google.com/protocol-buffers/docs/reference/cpp/google.protobuf.text_format) or [JSON](https://developers.google.com/protocol-buffers/docs/reference/cpp/google.protobuf.util.json_util) formats.

## Example

For example we have a messages definition `message.proto`, like this:
```protobuf
message Bar {
    string name = 1;
}
message Foo {
    string super_name = 1;
    Bar bar = 2;
}
```
Now we can create a messages from this definition:
```cpp
#include <google/protobuf/text_format.h>
#include <google/protobuf/util/json_util.h>
#include <our_proto_files/proto.h>

// Create and fill messages
our_proto::Foo fooInstance;
fooInstance.set_super_name("some cool super name");

auto barInstance = fooInstance.mutable_bar();
barInstance.set_name("another, but also cool name");
fooInstance.set_allocated_bar(barInstance);

// Make prototext version of our messages
std::string prototextOutput;
google::protobuf::TextFormat::PrintToString(fooInstance, &prototextOutput);

// Make also JSON version
std::string JSONOutput;
google::protobuf::util::MessageToJsonString(fooInstance, &JSONOutput);

// Write strings with serialized messages into the files
...
```
Now you can see, that so **prototext** output looks like this:
```json
super_name: "some cool super name"
bar {
  name: "another, but also cool name"
}
```
And **JSON** like this:
```json
{"super_name":"some cool super name","bar":{"name":"another, but also cool name"}}
```
Unfortunately, JSON is not so pretty by default, but it stays quite readable, than protobuf.

This **protobuf**'s option can be useful in some cases. For example, you need to transfer files and you want to add some readable metadata with it. You don't need to add additional dependency or write serialization code, you can just use this option out of the box.

