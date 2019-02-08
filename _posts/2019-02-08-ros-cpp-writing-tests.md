---
layout: post
title: Example of writing C++ tests in ROS (Kitetic)
categories:
- blog
tags:
- ros
- c++
- tests
- gtest
- rostest
---

# {{ page.title }}

### Background

> Untested Code is Broken Code

Half year ago I wrote my first ROS C++ code. Along with it, I've started to look into documentation to find how to test my code. Unfortunately, I've found several resources, but all of them didn't provide a good example of what should I actually do to make my test work well with ROS. Plus I wanted my test to show debug output if I need it.
Here is a small boilerplate that you can use to cover your code with tests and take the advantages that I've mentioned above. Also I'll provide you an example of how you can run your tests.

### Environment

My current environment:
* Ubuntu 16.04
* CMake 3.5.1
* [ROS Kinetic](https://wiki.ros.org/kinetic/Installation/Ubuntu)
* [googletest v1.8.1](https://github.com/google/googletest/releases/tag/release-1.8.1)

### Directory structure

Typical ROS package directory:
```
.
├── ...
├── CMakeLists.txt
├── package.xml
├── src
│   ├── source.cpp
└── test
    ├── source_test.cpp
    └── source_test.launch
```

### CMakeList.txt

```cmake
<build instructions for your package is here>
...
if (CATKIN_ENABLE_TESTING)
    find_package(GTest REQUIRED)
    find_package(rostest REQUIRED)

    add_rostest_gtest(source_test
        test/source_test.launch
        test/source_test.cpp
        src/source.cpp
    )
    add_dependencies(source_test
    )
    target_link_libraries(source_test
        ${catkin_LIBRARIES} ${GTEST_LIBRARIES}
    )
endif()
```
### Launch file `test/source_test.launch`

It's very useful to write `ROSCONSOLE_FROMAT` to make log-messages in your code prettier. Also it's better do not write long test and limit it with the argument `time-limit`.

```xml
<launch>
    <env name="ROSCONSOLE_FORMAT" value="[${severity}] [${time}] ${logger}: ${message}"/>
    <test test-name="test" pkg="package_name" type="source_test" time-limit="10.0">
    </test>
</launch>
```
If you want to divide tests in the launch file you can add `gtest_filter` to the arguments for the tag `<test>`:
```xml
<launch>
    <env name="ROSCONSOLE_FORMAT" value="[${severity}] [${time}] ${logger}: ${message}"/>
    <test test-name="test" pkg="package_name" type="source_test" time-limit="10.0"
          args="--gtest_filter=TargetTest.test_ok">
    </test>
</launch>
```


### Test file `test/source_test.cpp`

```cpp
#include <ros/ros.h>
#include <gtest/gtest.h>


class TargetTest: public ::testing::Test
{
public:
    TargetTest(): spinner(0) {};
    ~TargetTest() {};

    ros::NodeHandle* node;
    ros::AsyncSpinner* spinner;

    void SetUp() override
    {
        ::testing::Test::SetUp();
        this->node = new ros::NodeHandle("~");
        this->spinner = new ros::AsyncSpinner(0);
        this->spinner->start();
    };

    void TearDown() override
    {
        ros::shutdown();
        delete this->spinner;
        delete this->node;
        ::testing::Test::TearDown();
    }
};

TEST_F(TargetTest, test_ok)
{
    ASSERT_TRUE(false);
}

int main(int argc, char **argv)
{
    ros::init(argc, argv, "node_name");
    if (ros::console::set_logger_level(ROSCONSOLE_DEFAULT_NAME, ros::console::levels::Debug))
    {
        ros::console::notifyLoggerLevelsChanged(); // To show debug output in the tests
    }
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

```
### Run tests

```shell
# Build package and run tests. But it will show output only for log-messages with ERROR level.
$ catkin_make && catking make run_tests_package_name_rostest_test_source_test.launch
    
# After your tests are built, you can run it with DEBUG logging level
$ rostest --text package_name source_test.launch
```

By default, `catkin_make` returns `0` even if one or more tests are failed. For developing it's acceptable, but if we want to run tests on CI we can use this commands:
```shell
# In order to run test on CI (return error if any tests are failed)
$ catkin_make run_tests && catkin_test_results
```
