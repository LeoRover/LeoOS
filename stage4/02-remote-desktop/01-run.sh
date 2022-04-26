#!/bin/bash -e

install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"

on_chroot "adduser xrdp ssl-cert"

install -v -m 644 files/systemd/x0vncserver.service "${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 644 files/.xsessionrc "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"

on_chroot "systemctl enable x0vncserver"
