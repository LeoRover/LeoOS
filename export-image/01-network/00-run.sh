#!/bin/bash -e

ln -sf "/run/systemd/resolve/stub-resolv.conf" "${ROOTFS_DIR}/etc/resolv.conf"
