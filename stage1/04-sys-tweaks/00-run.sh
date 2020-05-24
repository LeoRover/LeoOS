#!/bin/bash -e

log "Configuring users"

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