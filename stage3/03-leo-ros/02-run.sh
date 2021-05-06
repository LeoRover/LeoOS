#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/ros/catkin_ws"
install -m 644 files/leo-erc.repos "${ROOTFS_DIR}/etc/ros/catkin_ws/"

on_chroot <<EOF
cd /etc/ros/catkin_ws
vcs import < leo-erc.repos
rosdep update
rosdep fix-permissions
rosdep install --from-paths src -iy
catkin config --extend /opt/ros/melodic --install -i /opt/ros/leo
catkin build
EOF
