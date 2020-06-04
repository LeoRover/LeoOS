#!/bin/bash -e

install -v -m 644 files/fictionlab.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

on_chroot apt-key add - < files/fictionlab.key

on_chroot << EOF
apt-get update
EOF

install -v -m 644 files/30-fictionlab.list "${ROOTFS_DIR}/etc/ros/rosdep/sources.list.d/"

on_chroot << EOF
su - ${FIRST_USER_NAME}
rosdep update
EOF
