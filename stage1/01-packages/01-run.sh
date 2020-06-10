#!/bin/bash -e

rm -v -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/01autoremove-kernels"

on_chroot << EOF
export FK_MACHINE="Raspberry Pi 4 Model B"
apt autoremove --purge -y
apt-get remove open-iscsi -y
EOF