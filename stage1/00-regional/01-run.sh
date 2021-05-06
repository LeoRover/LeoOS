#!/bin/bash -e

log "Configuring locales"

rm -v "${ROOTFS_DIR}/etc/locale.gen"

echo "${TIMEZONE_DEFAULT}" > "${ROOTFS_DIR}/etc/timezone"
rm -v -f "${ROOTFS_DIR}/etc/localtime"

on_chroot "dpkg-reconfigure -f noninteractive locales tzdata keyboard-configuration"