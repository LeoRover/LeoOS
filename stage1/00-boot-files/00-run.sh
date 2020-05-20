#!/bin/bash -e

install -v -m 644 files/btcmd.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/nobtcmd.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/syscfg.txt "${ROOTFS_DIR}/boot/firmware/"

rm -rf "${ROOTFS_DIR}/etc/cloud"
rm -f "${ROOTFS_DIR}/boot/firmware/meta-data"
rm -f "${ROOTFS_DIR}/boot/firmware/network-config"
rm -f "${ROOTFS_DIR}/boot/firmware/user-data"
rm -f "${ROOTFS_DIR}/usr/share/initramfs-tools/local-premount/btrfs"

on_chroot << EOF
apt-get purge cloud-init btrfs-tools -y
update-initramfs -u
EOF
