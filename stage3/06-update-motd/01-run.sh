#!/bin/bash -e

rm -rf "${ROOTFS_DIR}/etc/update-motd.d/"*

install -v -m 755 files/* "${ROOTFS_DIR}/etc/update-motd.d/"
