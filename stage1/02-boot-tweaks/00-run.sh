#!/bin/bash -e

# Purgin cloud-init
rm -rf "${ROOTFS_DIR}/etc/cloud"
rm -f "${ROOTFS_DIR}/boot/firmware/meta-data"
rm -f "${ROOTFS_DIR}/boot/firmware/network-config"
rm -f "${ROOTFS_DIR}/boot/firmware/user-data"

on_chroot << EOF
export FK_MACHINE=none
apt-get purge cloud-init -y
EOF

# install -v -m 755 "${ROOTFS_DIR}/boot/initrd.img" "${ROOTFS_DIR}/boot/firmware/initrd.img"
