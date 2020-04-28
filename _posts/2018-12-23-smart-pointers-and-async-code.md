---
layout: post
title: Be careful of using smart pointers and async code (C++)
categories:
- software
image: /assets/images/default/logo.png
tags:
- c++
- shared_ptr
- boost::asio
---

* content
{:toc}

One day I've spent some time to debug very odd **segfault**, that was caused by careless using of `std::shared_ptr` and `boost::asio`'s callbacks. It was easy to fix, but difficult to find the root of a problem. Here is a small advice, how you can avoid this mistake.


### Advice

Do not forget to [make a shared pointer](https://en.cppreference.com/w/cpp/memory/enable_shared_from_this) from `this` if you pass it in [lambda](https://en.cppreference.com/w/cpp/language/lambda) or [bind](https://en.cppreference.com/w/cpp/utility/functional/bind), especially if you will use it somehow asynchronously, e.g. with [boost::asio](https://www.boost.org/doc/libs/1_69_0/doc/html/boost_asio.html). In case you'd pass it as a raw pointer, you can get a segmentation fault because object won't be tracked by `shared_ptr`, and when callback will be executed the pointer on `this` will be invalid.

{% highlight c++ %}
#include <functional>
#include <memory>
#include <boost/asio.hpp>

class WonderfulClass: public std::enable_shared_from_this<WonderfulClass>
{
    ...
    void badCallbackCreation()
    {
        // auto clbk = std::bind(&WonderfulClass::func, this); <-- Can cause a sigfault
        auto clbk = std::bind(&WonderfulClass::func,
                              this->enable_shared_from_this());
        this->asyncThingy.post(clbk);
    }

    void func()
    {
        this->foo.bar();
    }
    ...
};

{% endhighlight %}
