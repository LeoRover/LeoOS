#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
    copy_previous
fi

rm "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 1.1.1.1" > "${ROOTFS_DIR}/etc/resolv.conf"
