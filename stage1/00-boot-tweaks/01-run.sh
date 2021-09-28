#!/bin/bash -e

mkdir -p -m 755 "${ROOTFS_DIR}/etc/firstboot.d"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"
install -v -m 755 files/init_firstboot "${ROOTFS_DIR}/sbin/"

printf " init=/sbin/init_firstboot" >> "${ROOTFS_DIR}/boot/firmware/cmdline.txt"
