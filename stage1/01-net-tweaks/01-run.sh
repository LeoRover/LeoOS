#!/bin/bash -e

log "Configuring netplan"

install -v -m 644 files/netplan/*.yaml "${ROOTFS_DIR}/etc/netplan/"


log "Setting hostname"

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"

if ! grep -q "127.0.1.1 ${TARGET_HOSTNAME}" "${ROOTFS_DIR}/etc/hosts"; then
    printf "\n127.0.1.1 ${TARGET_HOSTNAME}\n" >> "${ROOTFS_DIR}/etc/hosts"
fi


on_chroot "systemctl disable wpa_supplicant"