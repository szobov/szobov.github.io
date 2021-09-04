---
layout: post
title: Debugging segfaults in C++. Advice for non C++ experts.
categories:
- software
tags:
- c++
- debugging
- sanitizers
- segfaults
---


* content
{:toc}

> Long time no see.


## Background

C++ is everywhere. Unfortunately or not, but we should deal with it very often. Even if you’re Chad ML Researcher, after you’ve trained your model using Python, there is a high probability you’ll run the inference using C++ code. Computer Vision frameworks, Robotics software, Crypto, etc., many of this stuff is usually written in C++. Of course, I hope you’ll never face any issues, but things like segfaults, infinite-loops can happen sometimes.

Here I would like to share with you some tricks I use to debug C++ code. It is mostly about cases when you need to build code yourself using some build tools, like CMake, Make, catkin, or something similar.

## Include debug symbols

First of all, you need to build your code to add [debug symbols](https://en.wikipedia.org/wiki/Debug_symbol). In general, the default option is to build the most optimized code with any debug information (yes, we all suppose that our code is perfect). So, for **CMake** it could be done by specifying parameter `-DCMAKE_BUILD_TYPE=RelWithDebInfo`, for example, to execute CMake like `cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo`.
It is also useful sometimes to disable optimizations, like passing `-O0` to compilator or setting `CMAKE_BUILD_TYPE=Debug`, but be careful, quite often it really slow down your code or even can [break it](https://www.reddit.com/r/cpp_questions/comments/n4whha/eigen_types_generating_wonky_results_depending_on/). So, if you can't disable optimizations, don't be scared if debuggers will show you wrong line numbers.

## Core dumps

The next important thing is [core dumps](https://en.wikipedia.org/wiki/Core_dump). In general, it's disabled by default, but you can [find on the internet](https://stackoverflow.com/questions/6152232/how-to-generate-core-dump-file-in-ubuntu) how to enable it. When it's enabled, every time any program on your PC will crash with *SIGSEGV* (segfault!). By "any" I mean if your web-browser will crash it will leave the core dump. A core dump is like a snapshot of the program, just before it has been interrupted.

## Debuggers

The most important thing is a debugger, without it everything is almost impossible.
There are two options [LLDB](https://lldb.llvm.org) and [GDB](https://www.gnu.org/software/gdb/). It's probably better to debug [clang](https://clang.llvm.org) compiled code with **LLDB** and [gcc](https://gcc.gnu.org) compiled code with **GDB**, but they should work pretty smooth interchangeably.
In my previous blog post, I already mentioned [debugging with LLDB and Python]({% post_url 2020-09-22-debug-cpp-code-with-lldb-and-python %}), but I'll recommend you to try both options or at least get familiar with them.

## Examples

### Segfault

Let's now look at some examples of running debuggers.
I had a program that encounters some [bug in CGAL](https://github.com/CGAL/cgal/issues/5711) (you can find code there). When I run it, the output has been quite short:

```shell
$ ./src/test/test_exe 
Segmentation fault (core dumped)   <---- ヽ(°〇°)ﾉ
```

Let's now run this program with **lldb**:

```shell
$ lldb ./src/test/test_exe 
(lldb) target create "./src/test/test_exe"
Current executable set to '.../build_debug/src/test/test_exe' (x86_64).
(lldb) r
Process 239893 launched: 'test_exe' (x86_64)
Process 239893 stopped
* thread #1, name = 'test_exe', stop reason = signal SIGSEGV: invalid address (fault address: 0x38)
    frame #0: 0x0000555555636cd3 test_exe`CGAL::SNC_FM_decorator<CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::determine_facet(this=0x00007fffffffd390, e=<unavailable>, MinimalEdge=size=1, FacetCycle=0x00007fffffffcbd0, Edge_of=size=4) const at SNC_FM_decorator.h:420:22
   417 	    #endif
   418 	    CGAL_assertion( e_below != SHalfedge_handle() );
   419 	    CGAL_NEF_TRACEN("  edge below " << debug(e_below));
-> 420 	    Halffacet_handle f = e_below->facet();
   421 	    if ( f != Halffacet_handle() ) return f; // has already a facet
   422 	    // e_below also has no facet
   423 	    f = determine_facet(e_below, MinimalEdge, FacetCycle, Edge_of);
(lldb) thread backtrace 
* thread #1, name = 'test_exe', stop reason = signal SIGSEGV: invalid address (fault address: 0x38)
  * frame #0: 0x0000555555636cd3 test_exe`CGAL::SNC_FM_decorator<CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::determine_facet(this=0x00007fffffffd390, e=<unavailable>, MinimalEdge=size=1, FacetCycle=0x00007fffffffcbd0, Edge_of=size=4) const at SNC_FM_decorator.h:420:22
    frame #1: 0x000055555565ef26 test_exe`CGAL::SNC_FM_decorator<CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::create_facet_objects(this=0x00007fffffffd390, plane_supporting_facet=<unavailable>, start=<unavailable>, end=<unavailable>) const at SNC_FM_decorator.h:646:22
    frame #2: 0x000055555565fbe2 test_exe`CGAL::SNC_external_structure<CGAL::SNC_indexed_items, CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::categorize_facet_cycles_and_create_facets(this=0x00007fffffffd640) const at SNC_external_structure.h:1274:7
    frame #3: 0x000055555566f48b test_exe`CGAL::SNC_external_structure<CGAL::SNC_indexed_items, CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::build_external_structure(this=0x00007fffffffd640) at SNC_external_structure.h:1371:5
    frame #4: 0x0000555555672fad test_exe`CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::Nef_polyhedron_3<CGAL::Epeck, CGAL::Polyhedron_items_3, CGAL::HalfedgeDS_default, std::allocator<int> >(CGAL::Polyhedron_3<CGAL::Epeck, CGAL::Polyhedron_items_3, CGAL::HalfedgeDS_default, std::allocator<int> >&) [inlined] CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::build_external_structure(this=<unavailable>) at Nef_polyhedron_3.h:352:5
    frame #5: 0x0000555555672f8b test_exe`CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::Nef_polyhedron_3<CGAL::Epeck, CGAL::Polyhedron_items_3, CGAL::HalfedgeDS_default, std::allocator<int> >(this=0x00007fffffffd900, P=0x00007fffffffd920) at Nef_polyhedron_3.h:607
    frame #6: 0x00005555555e8234 test_exe`main at test.cpp:29:9
    frame #7: 0x00007ffff79640b3 libc.so.6`__libc_start_main + 243
    frame #8: 0x00005555555e856e test_exe`_start + 46
```

What I did here?
1. `lldb ./src/test/test_exe` -- started the program under **lldb**
2. `r` -- to run a program. Because we have a segfault, **lldb** will automatically stop in the place where it happened.
3. `thread backtrace` -- show traceback of the program with line numbers! One of the easy-to-use and most valuable command in my opinion.

Now we have a clue, where we can look to resolve this issue. It's in the file [SNC_FM_decorator.h in line number 420](https://github.com/CGAL/cgal/blob/50389862bf378d44123969f798caaaf086cd249f/Nef_3/include/CGAL/Nef_3/SNC_FM_decorator.h#L420). Seems like it's [nullpointer dereference](https://en.wikipedia.org/wiki/Null_pointer#Null_dereferencing) and now we can put some `ifs` around it and check the pointer correctness before it will crash the whole program.
Even something like this may be enough in such cases:

```cpp
if (e_below == nullptr) {
    std::cout << "Broken e_below ponter" << std::endl;
    throw std::runtime_error(); // At least we can catch it on the top-level now  ¯\_(ツ)_/¯
}
```

### Infinite loop / long runs

Another issue that could happen with C++ code -- is infinite loops. Because people do not always use modern [range-based for loop](https://en.cppreference.com/w/cpp/language/range-for) but instead use raw pointers or iterators, it could sometimes hang your program without any feedback. I also got such behavior with mentioned above **CGAL** lib.

But with the debugger it's deadly simple to find what's going on, just run your program under the debugger and send it an interruption signal with `Ctrl + C`. For example, **lldb** will catch it, stop the program in this broken loop, where you can check the pointers or other variables, affecting the iterations.

## Sanitizers

Some time ago people realized that in C++ you can override almost everything, and what if we can do an implementation of memory, address, or other accessors, which will control the wrong behavior. It's how [sanitizers](https://github.com/google/sanitizers) came to life (before them at least [Valgrind](https://www.valgrind.org) already exists). Sanitizers can control the errors like use-after-free, double-free and etc, which often cause segfaults we want to debug. The usage of sanitizers is very-very good practice in general, but right now I don't want to explain to you all details. You can read about it on the internet on slides like this [one](https://www.slideshare.net/sermp/sanitizer-cppcon-russia).

Let's look again at the similar program which causes a segfault, but we'll now compile it with address sanitizer before.
Because I don't want to change CMake files, I'll just pass the required options in the command line:
```shell
$ cmake -S . -B build_debug -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_FLAGS="-fsanitize=address  -fsanitize=leak -g" -DCMAKE_C_FLAGS="-fsanitize=address  -fsanitize=leak -g" -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address  -fsanitize=leak" -DCMAKE_MODULE_LINKER_FLAGS="-fsanitize=address  -fsanitize=leak"
```
After a build, if I'll re-run the program, the output will be quite cumbersome, but with some pieces of useful information:

```shell
=================================================================
==87528==ERROR: AddressSanitizer: heap-use-after-free on address 0x60f000216820 at pc 0x55cdc9027f96 bp 0x7fff99cb3160 sp 0x7fff99cb3150
READ of size 8 at 0x60f000216820 thread T0
    #0 0x55cdc9027f95 in CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::~Nef_polyhedron_3_rep() .../libigl/external/cgal/Nef_3/include/CGAL/Nef_polyhedron_3.h:126
    #1 0x55cdc9027f95 in CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted::~RefCounted() .../libigl/external/cgal/STL_Extension/include/CGAL/Handle_for.h:40
    #2 0x55cdc9027f95 in void __gnu_cxx::new_allocator<CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted>::destroy<CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted>(CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted*) /usr/include/c++/9/ext/new_allocator.h:153
    #3 0x55cdc9027f95 in void std::allocator_traits<std::allocator<CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted> >::destroy<CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted>(std::allocator<CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted>&, CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted*) /usr/include/c++/9/bits/alloc_traits.h:497
    #4 0x55cdc9027f95 in CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::~Handle_for() .../libigl/external/cgal/STL_Extension/include/CGAL/Handle_for.h:155
    #5 0x55cdc8321adb in CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::~Nef_polyhedron_3() .../libigl/external/cgal/Nef_3/include/CGAL/Nef_polyhedron_3.h:382
    #6 0x55cdc8321adb in exact_decompose(Eigen::Matrix<double, -1, -1, 0, -1, -1> const&, Eigen::Matrix<int, -1, -1, 0, -1, -1> const&) .../test/src/test/src/exact_decompose.cpp:55
    #7 0x55cdc83cbd1a in Object::decompose(std::vector<std::reference_wrapper<Object>, std::allocator<std::reference_wrapper<Object> > >) .../test/src/test/src/object.cpp:77
    #8 0x55cdc83b626f in process(std::unordered_map<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, Object, std::hash<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::equal_to<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::allocator<std::pair<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const, Object> > >&, std::unordered_map<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > >, std::hash<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::equal_to<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::allocator<std::pair<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > > > > > const&, Object&, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > > const&) .../test/src/test/src/main.cpp:148
    #9 0x55cdc83b6b48 in process(std::unordered_map<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, Object, std::hash<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::equal_to<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::allocator<std::pair<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const, Object> > >&, std::unordered_map<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > >, std::hash<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::equal_to<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > >, std::allocator<std::pair<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > > > > > const&) .../test/src/test/src/main.cpp:120
    #10 0x55cdc832db99 in main .../test/src/test/src/main.cpp:93
    #11 0x7fa70b88e0b2 in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x270b2)
    #12 0x55cdc833785d in _start (.../test/build_debug/src/test/decompose_exe+0x1e185d)

0x60f000216820 is located 0 bytes inside of 176-byte region [0x60f000216820,0x60f0002168d0)
freed by thread T0 here:
    #0 0x7fa70c021025 in operator delete(void*, unsigned long) (/lib/x86_64-linux-gnu/libasan.so.5+0x111025)
    #1 0x55cdc902ab71 in CGAL::SNC_point_locator_by_spatial_subdivision<CGAL::SNC_decorator<CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::~SNC_point_locator_by_spatial_subdivision() .../libigl/external/cgal/Nef_3/include/CGAL/Nef_3/SNC_point_locator.h:432
    #2 0x55cdc902ab71 in CGAL::External_structure_builder<CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::operator()(CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::SNC_and_PL&) .../libigl/external/cgal/Convex_decomposition_3/include/CGAL/Convex_decomposition_3/External_structure_builder.h:127

previously allocated by thread T0 here:
    #0 0x7fa70c01f947 in operator new(unsigned long) (/lib/x86_64-linux-gnu/libasan.so.5+0x10f947)
    #1 0x55cdc902a474 in CGAL::SNC_point_locator_by_spatial_subdivision<CGAL::SNC_decorator<CGAL::SNC_structure<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::clone() const .../libigl/external/cgal/Nef_3/include/CGAL/Nef_3/SNC_point_locator.h:408
    #2 0x55cdc902a474 in CGAL::External_structure_builder<CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool> >::operator()(CGAL::Nef_polyhedron_3<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::SNC_and_PL&) .../libigl/external/cgal/Convex_decomposition_3/include/CGAL/Convex_decomposition_3/External_structure_builder.h:125

SUMMARY: AddressSanitizer: heap-use-after-free .../libigl/external/cgal/Nef_3/include/CGAL/Nef_polyhedron_3.h:126 in CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::~Nef_polyhedron_3_rep()
Shadow bytes around the buggy address:
  0x0c1e8003acb0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003acc0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003acd0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003ace0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003acf0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
=>0x0c1e8003ad00: fa fa fa fa[fd]fd fd fd fd fd fd fd fd fd fd fd
  0x0c1e8003ad10: fd fd fd fd fd fd fd fd fd fd fa fa fa fa fa fa
  0x0c1e8003ad20: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003ad30: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003ad40: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c1e8003ad50: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
==87528==ABORTING
```


Are you scared of this? Me -- yes, but I glad that I can find here those lines:

```
==87528==ERROR: AddressSanitizer: heap-use-after-free on address 0x60f000216820 at pc 0x55cdc9027f96 bp 0x7fff99cb3160 sp 0x7fff99cb3150
READ of size 8 at 0x60f000216820 thread T0
    #0 0x55cdc9027f95 in CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>::~Nef_polyhedron_3_rep() .../libigl/external/cgal/Nef_3/include/CGAL/Nef_polyhedron_3.h:126
    #1 0x55cdc9027f95 in CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::RefCounted::~RefCounted() .../libigl/external/cgal/STL_Extension/include/CGAL/Handle_for.h:40
    ...
    #4 0x55cdc9027f95 in CGAL::Handle_for<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool>, std::allocator<CGAL::Nef_polyhedron_3_rep<CGAL::Epeck, CGAL::SNC_indexed_items, bool> > >::~Handle_for() .../libigl/external/cgal/STL_Extension/include/CGAL/Handle_for.h:155
```

Hell yeah! Someone did manual memory-management control instead of smart-pointers and introduced shiny double-free error!
Now we can trace and patch places where objects are deleted several times and finally get our code working (not exactly, but at least now it won't segfault)!

## Conclusion

As I mentioned at the beginning of this article, C++ is everywhere, and have some expertise in its debugging is a very useful skill, ether you developer or researcher.
Of course, you can always try to use IDEs like [VSCode](https://code.visualstudio.com) and hope, that it will work out of the box and help you with debugging, but for me stuff like **LLDB** or sanitizers much simpler and easy to start with, without any GUI.

I'll also clarify, that I didn't cover all of the possible abilities of mentioned tools, but I hope now you'll spend some time to get familiar with it.

Good luck and hope you'll be never forced to use advice from this article.
