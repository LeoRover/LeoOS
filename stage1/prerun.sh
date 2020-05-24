#!/bin/bash -e

copy_previous

rm "${ROOTFS_DIR}/etc/resolv.conf"
echo "nameserver 1.1.1.1" > "${ROOTFS_DIR}/etc/resolv.conf"
