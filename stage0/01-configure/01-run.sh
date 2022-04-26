#!/bin/bash -e

mkdir -p -m 755 "${ROOTFS_DIR}/boot/firmware"

echo "${TIMEZONE_DEFAULT}" > "${ROOTFS_DIR}/etc/timezone"
