#!/bin/bash -e

log "Configuring locales"

rm -v "${ROOTFS_DIR}/etc/locale.gen"

on_chroot << EOF
dpkg-reconfigure -f noninteractive locales
EOF