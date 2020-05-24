#!/bin/bash -e

echo "${TARGET_HOSTNAME}" > "${ROOTFS_DIR}/etc/hostname"
echo "127.0.0.1		${TARGET_HOSTNAME}" >> "${ROOTFS_DIR}/etc/hosts"
