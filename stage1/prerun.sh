#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
    copy_previous
fi

rm -v -f "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 8.8.8.8" > "${ROOTFS_DIR}/etc/resolv.conf"
on_chroot "apt update"
