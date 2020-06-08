#!/bin/bash -e

ln -sf "${ROOTFS_DIR}/run/systemd/resolve/stub-resolv.conf" "${ROOTFS_DIR}/etc/resolv.conf"
