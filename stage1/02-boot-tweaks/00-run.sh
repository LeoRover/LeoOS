#!/bin/bash -e

log "Purging cloud-init"

# Purge cloud-init
rm -v -rf "${ROOTFS_DIR}/etc/cloud"
rm -v -f "${ROOTFS_DIR}/boot/firmware/meta-data"
rm -v -f "${ROOTFS_DIR}/boot/firmware/network-config"
rm -v -f "${ROOTFS_DIR}/boot/firmware/user-data"

on_chroot << EOF
apt-get purge cloud-init -y
EOF
