#!/bin/bash -e 

wget -O "${ROOTFS_DIR}/tmp/husarion-tools.zip" "https://files.husarion.com/husarion-tools/husarion-tools.zip"
unzip -q -o "${ROOTFS_DIR}/tmp/husarion-tools.zip" -d "${ROOTFS_DIR}/tmp/"

install -v -m 755 "${ROOTFS_DIR}/tmp/husarion-tools/rpi-linux/core2-flasher" "${ROOTFS_DIR}/usr/bin/"

rm -rf "${ROOTFS_DIR}/tmp/"*
