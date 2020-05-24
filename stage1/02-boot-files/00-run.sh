#!/bin/bash -e

rm -v "${ROOTFS_DIR}/boot/firmware"/*.txt

install -v -m 644 files/config.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/syscfg.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/usercfg.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/firmware/"
