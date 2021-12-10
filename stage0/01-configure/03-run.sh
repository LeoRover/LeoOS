#!/bin/bash -e 

# Copy resolver configuration file from host
rm -v -f "${ROOTFS_DIR}/etc/resolv.conf"
cp -v /etc/resolv.conf "${ROOTFS_DIR}/etc/resolv.conf"

on_chroot "apt update"
