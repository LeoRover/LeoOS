#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/ros/catkin_ws"
install -m 644 files/leo-erc.repos "${ROOTFS_DIR}/etc/ros/catkin_ws/"
install -m 755 files/update.sh "${ROOTFS_DIR}/etc/ros/catkin_ws/"

on_chroot <<EOF
su ${FIRST_USER_NAME}
/etc/ros/catkin_ws/update.sh
EOF