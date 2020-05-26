#!/bin/bash -e

install -v -m 644 files/01-network-manager-all.yaml "${ROOTFS_DIR}/etc/netplan/"
