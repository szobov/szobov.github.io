---
layout: post
title: Example of writing c++ tests in ROS
categories:
- blog
tags:
- ros
- c++
- tests
---

# {{ page.title }}

### CMakeList.txt

    add_rostest_gtest(target_test
        test/target_test.launch
        test/target_test.cpp
    )
    add_dependencies(target_test
    )
    target_link_libraries(target_test
        ${catkin_LIBRARIES} ${GTEST_LIBRARIES}
    )

### Launch file `test/target_test.launch`

     <launch>
        <env name="ROSCONSOLE_FORMAT" value="[${severity}] [${time}] ${logger}: ${message}"/>
        <test test-name="test" pkg="package_name" type="target_test" time-limit="10.0">
        </test>
    </launch>

### Test file `test/target_test.cpp`

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
        ...
    }

     int main(int argc, char **argv)
    {
		ros::init(argc, argv, "node_name");
		if(ros::console::set_logger_level(ROSCONSOLE_DEFAULT_NAME, ros::console::levels::Debug))
		{
				ros::console::notifyLoggerLevelsChanged();
		}
		::testing::InitGoogleTest(&argc, argv);
		return RUN_ALL_TESTS();
    }

### Launch this test

    # Make packages and run test, but it logging will be only for ROS_ERROR*
    $ catkin_make && catking make run_tests_package_name_rostest_test_target_test.launch
    
    # After you can run test with DEBUG logging level
    $ rostest --text package_name target_test.launch
    
    # In order to run test on CI (return error if any test is failed)
    $ catkin_make run_tests && catkin_test_results
