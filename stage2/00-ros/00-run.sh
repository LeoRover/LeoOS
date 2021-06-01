#!/bin/bash -e

install -v -m 644 files/ros-latest.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot << EOF
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
apt-get update
EOF