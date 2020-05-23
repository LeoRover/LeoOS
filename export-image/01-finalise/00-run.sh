#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

rm -v -f "${ROOTFS_DIR}/usr/bin/qemu-arm-static"

rm -v -f "${ROOTFS_DIR}/etc/apt/sources.list~"
rm -v -f "${ROOTFS_DIR}/etc/apt/trusted.gpg~"

rm -v -f "${ROOTFS_DIR}/etc/passwd-"
rm -v -f "${ROOTFS_DIR}/etc/group-"
rm -v -f "${ROOTFS_DIR}/etc/shadow-"
rm -v -f "${ROOTFS_DIR}/etc/gshadow-"
rm -v -f "${ROOTFS_DIR}/etc/subuid-"
rm -v -f "${ROOTFS_DIR}/etc/subgid-"

rm -v -f "${ROOTFS_DIR}"/var/cache/debconf/*-old
rm -v -f "${ROOTFS_DIR}"/var/lib/dpkg/*-old

find "${ROOTFS_DIR}/var/log/" -type f -exec cp /dev/null {} \;

ROOT_DEV="$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')"

unmount "${ROOTFS_DIR}"
zerofree -v "${ROOT_DEV}"

unmount_image "${IMG_FILE}"

mkdir -p "${DEPLOY_DIR}"

cp -v "${IMG_FILE}" "${DEPLOY_DIR}"
