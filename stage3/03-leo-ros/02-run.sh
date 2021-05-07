#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/ros/catkin_ws"
install -m 644 files/leo-erc.repos "${ROOTFS_DIR}/etc/ros/catkin_ws/"
