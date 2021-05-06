#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}"

rm -v -f "${ROOTFS_DIR}/usr/bin/qemu-arm-static"

rm -v -f "${ROOTFS_DIR}/etc/apt/sources.list~"
rm -v -f "${ROOTFS_DIR}/etc/apt/trusted.gpg~"

rm -v -f "${ROOTFS_DIR}/etc/passwd-"
rm -v -f "${ROOTFS_DIR}/etc/group-"
rm -v -f "${ROOTFS_DIR}/etc/shadow-"
rm -v -f "${ROOTFS_DIR}/etc/gshadow-"
rm -v -f "${ROOTFS_DIR}/etc/subuid-"
rm -v -f "${ROOTFS_DIR}/etc/subgid-"

rm -v -f "${ROOTFS_DIR}/var/cache/debconf/"*-old
rm -v -f "${ROOTFS_DIR}/var/lib/dpkg/"*-old

rm -v -rf "${ROOTFS_DIR}/boot/"dtb*
rm -v -f "${ROOTFS_DIR}/boot/"*.old

rm -v -f "${ROOTFS_DIR}/etc/xrdp/rsakeys.ini"
rm -v -f "${ROOTFS_DIR}/etc/xrdp/cert.pem"
rm -v -f "${ROOTFS_DIR}/etc/xrdp/key.pem"
rm -v -f "${ROOTFS_DIR}/etc/ssl/certs/ssl-cert-snakeoil.pem"
rm -v -f "${ROOTFS_DIR}/etc/ssl/private/ssl-cert-snakeoil.key"

find "${ROOTFS_DIR}/boot/firmware" -type f -name "*.bak" -exec rm -v {} \;
find "${ROOTFS_DIR}/etc/apt" -type f -name "*.save" -exec rm -v {} \;
find "${ROOTFS_DIR}/etc" -type f -name "*.dpkg-old" -exec rm -v {} \;

find "${ROOTFS_DIR}/var/log/" -type f -exec cp /dev/null {} \;

rm -v -rf "${ROOTFS_DIR}/run/"*

ROOT_DEV="$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')"

unmount "${ROOTFS_DIR}"
zerofree -v "${ROOT_DEV}"

unmount_image "${IMG_FILE}"

mkdir -p "${DEPLOY_DIR}"

mv -v "${IMG_FILE}" "${DEPLOY_DIR}"
