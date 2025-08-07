#!/bin/bash

source /opt/ros/humble/setup.bash
source install/setup.bash
# Temporary domain change to avoid issues with micro_ros_agent when somebody has Jazzy sourced in the office
export ROS_DOMAIN_ID=77

export PATH="/usr/lib/ros:$PATH"

"$@"