#!/bin/bash

export ROS_HOME=/var/ros

cd /etc/ros/catkin_ws
vcs import < leo-erc.repos
rosdep update
rosdep install --rosdistro noetic --from-paths src -iy
catkin config --extend /opt/ros/noetic --install -i /opt/ros/leo
sudo catkin build --no-status
