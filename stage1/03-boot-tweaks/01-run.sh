#!/bin/bash -e

install -v -m 774 files/expand-rootfs "${ROOTFS_DIR}/sbin/"
install -v -m 774 files/init_expand "${ROOTFS_DIR}/sbin/"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

log "Purging cloud-init"

rm -rf "${ROOTFS_DIR}/etc/cloud"
rm -f "${ROOTFS_DIR}/boot/firmware/meta-data"
rm -f "${ROOTFS_DIR}/boot/firmware/network-config"
rm -f "${ROOTFS_DIR}/boot/firmware/user-data"

on_chroot << EOF
systemctl disable hciuart
apt-get purge cloud-init -y
EOF
