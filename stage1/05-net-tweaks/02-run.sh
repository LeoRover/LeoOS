#!/bin/bash -e

install -v -m 644 files/netplan/*.yaml "${ROOTFS_DIR}/etc/netplan/"
install -v -m 644 files/polkit/*.pkla "${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/"

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"

if ! grep -q "127.0.1.1 ${TARGET_HOSTNAME}" "${ROOTFS_DIR}/etc/hosts"; then
    printf "\n127.0.1.1 ${TARGET_HOSTNAME}\n" >> "${ROOTFS_DIR}/etc/hosts"
fi

install -v -m 644 files/regenerate_ssh_host_keys.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl enable regenerate_ssh_host_keys
EOF