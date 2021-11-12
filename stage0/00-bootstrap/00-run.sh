#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
    multistrap -d "${ROOTFS_DIR}" -f multistrap.conf
fi