#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}"

# Remove backup files
find "${ROOTFS_DIR}/etc/apt" -type f -name "*.save" -exec rm -v {} \;
find "${ROOTFS_DIR}/etc" -type f -name "*.dpkg-old" -exec rm -v {} \;
find "${ROOTFS_DIR}/etc" -type f -name "*-" -exec rm -v {} \;
find "${ROOTFS_DIR}/etc" -type f -name "*~" -exec rm -v {} \;
find "${ROOTFS_DIR}/var" -type f -name "*-old" -exec rm -v {} \;
find "${ROOTFS_DIR}/boot" -type f -name "*.old" -exec rm -v {} \;
find "${ROOTFS_DIR}/boot" -type f -name "*.bak" -exec rm -v {} \;

# Truncate all logs
find "${ROOTFS_DIR}/var/log/" -type f -exec cp -v /dev/null {} \;

# Clear up /run directory
rm -v -rf "${ROOTFS_DIR}/run/"*

# Remove generated host keys
rm -v -f "${ROOTFS_DIR}/etc/xrdp/rsakeys.ini"
rm -v -f "${ROOTFS_DIR}/etc/xrdp/cert.pem"
rm -v -f "${ROOTFS_DIR}/etc/xrdp/key.pem"
rm -v -f "${ROOTFS_DIR}/etc/ssl/certs/ssl-cert-snakeoil.pem"
rm -v -f "${ROOTFS_DIR}/etc/ssl/private/ssl-cert-snakeoil.key"
rm -v -f "${ROOTFS_DIR}/etc/ssh/ssh_host_"*"_key"*

# Remove resolver configuration
rm -v -f "${ROOTFS_DIR}/etc/resolv.conf"

ROOT_DEV="$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')"

unmount "${ROOTFS_DIR}"
zerofree -v "${ROOT_DEV}"

unmount_image "${IMG_FILE}"

mkdir -p "${DEPLOY_DIR}"

mv -v "${IMG_FILE}" "${DEPLOY_DIR}"
