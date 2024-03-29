#!/bin/bash -e

log "Configuring user"

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi
echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
for GRP in input spi i2c gpio bluetooth; do
	groupadd -f -r "\${GRP}"
done
for GRP in adm dialout audio sudo video plugdev input gpio spi i2c netdev bluetooth; do
  adduser $FIRST_USER_NAME "\${GRP}"
done
EOF

echo "${FIRST_USER_NAME} ALL=(ALL) NOPASSWD: ALL" > "${ROOTFS_DIR}/etc/sudoers.d/010_${FIRST_USER_NAME}-nopasswd"
chmod -v 440 "${ROOTFS_DIR}/etc/sudoers.d/010_${FIRST_USER_NAME}-nopasswd"

on_chroot "systemctl disable ModemManager"

log "Performing other system modifications"

install -v -m 644 files/apt/fictionlab "${ROOTFS_DIR}/etc/apt/preferences.d/"
install -v -m 644 files/udev.d/99-com.rules "${ROOTFS_DIR}/etc/udev/rules.d/"
install -v -m 644 files/sysctl.d/99-rpi.conf "${ROOTFS_DIR}/etc/sysctl.d/"
install -v -m 644 files/polkit/*.pkla "${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/"

on_chroot << EOF
systemctl disable motd-news.timer
systemctl disable apt-daily-upgrade.timer
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
EOF