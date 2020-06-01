#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/ros/urdf"
mkdir -p -m 777 "${ROOTFS_DIR}/var/log/ros/"

install -v -m 644 files/setup.bash "${ROOTFS_DIR}/etc/ros/"
install -v -m 644 files/robot.launch "${ROOTFS_DIR}/etc/ros/"
install -v -m 644 files/robot.urdf.xacro "${ROOTFS_DIR}/etc/ros/urdf/"
install -v -m 644 files/leo-start "${ROOTFS_DIR}/usr/sbin/"
install -v -m 644 files/leo-stop "${ROOTFS_DIR}/usr/sbin/"
install -v -m 644 files/leo.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl enable leo
EOF