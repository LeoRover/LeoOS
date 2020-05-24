#!/bin/bash -e

log "Configuring fstab"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"