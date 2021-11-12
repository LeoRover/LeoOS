#!/bin/bash -e

install -v -m 644 files/firmware/*.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/firmware/*.bin "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/firmware/README "${ROOTFS_DIR}/boot/firmware/"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"
