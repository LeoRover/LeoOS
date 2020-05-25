#!/bin/bash -e

rm -v "${ROOTFS_DIR}/etc/apt/apt.conf.d/01autoremove-kernels"

on_chroot << EOF
apt autoremove --purge -y
EOF