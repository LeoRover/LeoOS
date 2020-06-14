#!/bin/bash -e

install -v -m 644 files/apt/fictionlab.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -v -m 644 files/apt/fictionlab "${ROOTFS_DIR}/etc/apt/preferences.d/"
install -v -m 644 files/rosdep/30-fictionlab.list "${ROOTFS_DIR}/etc/ros/rosdep/sources.list.d/"

on_chroot apt-key add - < files/apt/fictionlab.key

on_chroot << EOF
apt-get update
EOF
