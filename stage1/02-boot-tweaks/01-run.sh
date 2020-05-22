#!/bin/bash -e

log "Tweaking initramfs"

install -v -m 644 files/resume "${ROOTFS_DIR}/etc/initramfs-tools/conf.d/"

rm -v "${ROOTFS_DIR}/usr/share/initramfs-tools/scripts/local-premount"/*

on_chroot << EOF
export FK_MACHINE=none
update-initramfs -u
EOF

install -v -m 755 "${ROOTFS_DIR}/boot/initrd.img" "${ROOTFS_DIR}/boot/firmware/initrd.img"
