#!/bin/bash -e

install -v -m 664 files/ros-latest.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/ros.asc

on_chroot << EOF
apt-get update
EOF