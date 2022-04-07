#!/bin/bash -e

mkdir -v -p "${ROOTFS_DIR}/usr/share/themes/leo"
install -v -m 644 files/leo-mars-wallpaper.jpg "${ROOTFS_DIR}/usr/share/themes/leo/"

mkdir -v -p "${ROOTFS_DIR}/etc/xdg/nm-tray"
install -v -m 644 files/nm-tray/nm-tray.conf "${ROOTFS_DIR}/etc/xdg/nm-tray/"

sed -i "s|user = CHANGE_ME|user = ${FIRST_USER_NAME}|" "${ROOTFS_DIR}/etc/lightdm/lightdm-mini-greeter.conf"
install -v -m 644 files/lightdm/greeter.conf "${ROOTFS_DIR}/etc/lightdm/lightdm.conf.d/"
