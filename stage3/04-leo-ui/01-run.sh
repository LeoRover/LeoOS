#!/bin/bash -e

on_chroot << EOF
if [ ! -d /opt/leo_ui ]; then
    git clone https://github.com/LeoRover/leo_ui.git /opt/leo_ui
fi
EOF

install -v -m 644 files/leo_ui "${ROOTFS_DIR}/etc/nginx/sites-available/"
rm -v -f "${ROOTFS_DIR}/etc/nginx/sites-enabled/default"
ln -fs "/etc/nginx/sites-available/leo_ui" "${ROOTFS_DIR}/etc/nginx/sites-enabled/leo_ui"
