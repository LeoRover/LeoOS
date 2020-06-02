#!/bin/bash -e

install -v -m 644 files/01-network-manager-all.yaml "${ROOTFS_DIR}/etc/netplan/"

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.0.1 ${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"

install -v -m 644 files/regenerate_ssh_host_keys.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl enable regenerate_ssh_host_keys
EOF