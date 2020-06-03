#!/bin/bash -e

rm -v -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/01autoremove-kernels"

on_chroot << EOF
apt autoremove --purge -y
apt-get remove open-iscsi -y
EOF