#!/bin/bash -e

install -v -m 644 files/syscfg.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/nobtcfg.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/nobtcmd.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/btcfg.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/btcmd.txt "${ROOTFS_DIR}/boot/firmware/"
