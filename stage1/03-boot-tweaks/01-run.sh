#!/bin/bash -e

mkdir -p -m 755 "${ROOTFS_DIR}/etc/firstboot.d"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"
install -v -m 755 files/init_firstboot "${ROOTFS_DIR}/sbin/"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

rm -rf "${ROOTFS_DIR}/etc/cloud"
rm -f "${ROOTFS_DIR}/boot/firmware/meta-data"
rm -f "${ROOTFS_DIR}/boot/firmware/network-config"
rm -f "${ROOTFS_DIR}/boot/firmware/user-data"
