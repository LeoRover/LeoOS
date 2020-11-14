#!/bin/bash -e

install -v -m 644 files/ros-latest.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/ros.key

on_chroot "apt-get update"