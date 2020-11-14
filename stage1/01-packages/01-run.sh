#!/bin/bash -e

rm -v -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/01autoremove-kernels"

on_chroot << EOF
apt-get purge cloud-init cloud-guest-utils cloud-initramfs-copymods cloud-initramfs-dyn-netconf open-iscsi -y
apt autoremove --purge -y
EOF

rm -v -rf "${ROOTFS_DIR}/etc/systemd/system/cloud-config.service.d"
rm -v -rf "${ROOTFS_DIR}/etc/systemd/system/cloud-final.service.d"
rm -v -rf "${ROOTFS_DIR}/etc/systemd/system/cloud-init-local.service.d"
