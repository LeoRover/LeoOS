#!/bin/bash 

rm -v -rf "${ROOTFS_DIR}/etc/ros/rosdep"

on_chroot << EOF
rosdep init
EOF
