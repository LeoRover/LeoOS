#!/bin/bash -e

install -v -m 644 files/leo_ui "${ROOTFS_DIR}/etc/nginx/sites-available/"
rm -v -f "${ROOTFS_DIR}/etc/nginx/sites-enabled/default"
ln -fs "/etc/nginx/sites-available/leo_ui" "${ROOTFS_DIR}/etc/nginx/sites-enabled/leo_ui"
