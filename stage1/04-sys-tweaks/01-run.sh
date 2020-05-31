#!/bin/bash -e

install -v -m 664 files/regenerate_ssh_host_keys.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
systemctl enable regenerate_ssh_host_keys
EOF

log "Configuring user"

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi
echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
echo "root:root" | chpasswd
for GRP in input spi i2c gpio; do
	groupadd -f -r "\${GRP}"
done
for GRP in adm dialout audio sudo video plugdev input gpio spi i2c netdev; do
  adduser $FIRST_USER_NAME "\${GRP}"
done
EOF

echo "${FIRST_USER_NAME} ALL=(ALL) NOPASSWD: ALL" > "${ROOTFS_DIR}/etc/sudoers.d/010_${FIRST_USER_NAME}-nopasswd"
chmod -v 440 "${ROOTFS_DIR}/etc/sudoers.d/010_${FIRST_USER_NAME}-nopasswd"
