#!/bin/bash -e

log "Configuring locales"

rm -v "${ROOTFS_DIR}/etc/locale.gen"

echo "${TIMEZONE_DEFAULT}" > "${ROOTFS_DIR}/etc/timezone"
rm -v -f "${ROOTFS_DIR}/etc/localtime"

on_chroot << EOF
export FK_MACHINE="Raspberry Pi 4 Model B"
dpkg-reconfigure -f noninteractive locales
dpkg-reconfigure -f noninteractive tzdata
dpkg-reconfigure -f noninteractive console-setup
dpkg-reconfigure -f noninteractive keyboard-configuration
EOF