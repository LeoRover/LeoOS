#!/bin/bash -e

mkdir -v -p "${ROOTFS_DIR}/usr/share/themes/leo"
install -v -m 644 files/leo-mars-wallpaper.jpg "${ROOTFS_DIR}/usr/share/themes/leo/"

mkdir -v -p "${ROOTFS_DIR}/etc/xdg/nm-tray"
install -v -m 644 files/nm-tray/nm-tray.conf "${ROOTFS_DIR}/etc/xdg/nm-tray/"

