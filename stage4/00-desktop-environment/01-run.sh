#!/bin/bash -e

install -v -m 644 files/lightdm/autologin.conf "${ROOTFS_DIR}/etc/lightdm/lightdm.conf.d/"

sed -i "s|USERNAME|${FIRST_USER_NAME}|" "${ROOTFS_DIR}/etc/lightdm/lightdm.conf.d/autologin.conf"

mkdir -v -p "${ROOTFS_DIR}/usr/share/themes/leo"
install -v -m 644 files/leo-mars-wallpaper.jpg "${ROOTFS_DIR}/usr/share/themes/leo/"

mkdir -v -p "${ROOTFS_DIR}/etc/xdg/nm-tray"
install -v -m 644 files/nm-tray/nm-tray.conf "${ROOTFS_DIR}/etc/xdg/nm-tray/"

