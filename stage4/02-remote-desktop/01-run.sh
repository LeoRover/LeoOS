#!/bin/bash -e

install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"

on_chroot "adduser xrdp ssl-cert"
