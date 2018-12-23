---
layout: post
title: My first blog post
categories:
- blog
tags:
- blog
- c++
- shared_ptr
---

# {{ page.title }}

## Small note

Hey, I've decided to start write my own blog. As many people, I'll use it as my dairy to save a pieces of my experience. Maybe someone can find here something useful and interesting.

On a first glance Github Pages looks like a perfect place to do a blog: auto-deployment, markdown, version control system and already prepared themes. Hope I'll pay all my attention only on blog content not on the any site processes.

> English, MF, do you speak it?

Unfortunately, I've chosen English for blog, but it's not my main language. It means that here is would be the tons of typos, but I hope I'll improve it with a time. If you found any, you can make a pull request with the fixes, I'll appreciate it.

Have a great time!

### Here is the test of the code highlighting and the small c++ advice

Do not forget to [make a shared pointer](https://en.cppreference.com/w/cpp/memory/enable_shared_from_this) from `this` if you pass it in [lambda](https://en.cppreference.com/w/cpp/language/lambda) or [bind](https://en.cppreference.com/w/cpp/utility/functional/bind), especially if you will use it somehow asynchronously, e.g. with [boost::asio](https://www.boost.org/doc/libs/1_69_0/doc/html/boost_asio.html). In case you'd pass it as a raw pointer, you can get a segmentation fault because object won't be tracked by `shared_ptr`:

{% highlight c++ %}
#include <functional>
#include <memory>

class WonderfulClass: public std::enable_shared_from_this<WonderfulClass>
{
    ...

    void badCallbackCreation()
    {
        // auto clbk = std::bind(&WonderfulClass::func, this); <-- Will cause a sigfault
        auto clbk = std::bind(&WonderfulClass::func,
                              this->enable_shared_from_this());
        this->asyncThingy.post(clbk);
    }

    void func()
    {
        return;
    }
    ...
};

{% endhighlight %}
