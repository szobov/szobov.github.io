---
layout: post
title: Human-readable protobuf -- prototext and JSON
categories:
- blog
tags:
- protobuf
- c++
---

# {{ page.title }}

If [protobuf](https://github.com/protocolbuffers/protobuf) is one of you main data transfer format, you can use it not only as a binary format, but also as a human readable format.
For example we have a messages definition `message.proto`, like this:
```protobuf
message Bar {
    string name = 1;
}
message Foo {
    string super_name = 1;
    repeated Bar bar = 2;
}
```
Now we can create a message from this definition:
```cpp
#include <our_proto_files/proto.h>
#include <google/protobuf/text_format.h>

// Create and fill our messages
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

// Write the strings with serialized message to the files
...
```
Now you can see, so **prototext** output look like this:
```
super_name: "some cool super name"
bar {
  name: "another, but also cool name"
}
```
And **JSON ** like this:
```json
{"super_name":"some cool super name","bar":{"name":"another, but also cool name"}}
```
Unfortunately, JSON is not so pretty by default, but it stays quite readable, then protobuf.

It useful in some cases, for example you need to transfer files and you want to add some readable metadata with it. You don't need to add additional dependency or write serialization code, you can just use this functional out of the box.

