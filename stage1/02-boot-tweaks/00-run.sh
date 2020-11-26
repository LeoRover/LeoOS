#!/bin/bash -e

rm -v "${ROOTFS_DIR}/boot/firmware"/*.txt

install -v -m 644 files/boot/*.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/boot/README "${ROOTFS_DIR}/boot/firmware/"

mkdir -p -m 755 "${ROOTFS_DIR}/etc/firstboot.d"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"
install -v -m 755 files/init_firstboot "${ROOTFS_DIR}/sbin/"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

rm -v -rf "${ROOTFS_DIR}/etc/cloud"
rm -v -f "${ROOTFS_DIR}/boot/firmware/meta-data"
rm -v -f "${ROOTFS_DIR}/boot/firmware/network-config"
rm -v -f "${ROOTFS_DIR}/boot/firmware/user-data"
