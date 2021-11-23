#!/bin/bash -e

install -v -m 644 files/netplan/*.yaml "${ROOTFS_DIR}/etc/netplan/"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"

on_chroot "systemctl disable wpa_supplicant"

log "Setting hostname"

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"

if ! grep -q "127.0.1.1 ${TARGET_HOSTNAME}" "${ROOTFS_DIR}/etc/hosts"; then
    printf "\n127.0.1.1 ${TARGET_HOSTNAME}\n" >> "${ROOTFS_DIR}/etc/hosts"
fi
