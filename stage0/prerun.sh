#!/bin/bash -e

log "Downloading base image"
wget -t 3 -O "${STAGE_WORK_DIR}/base.img.xz" "${BASE_IMG_URL}"

log "Uncompressing the image"
unxz -v -T0 "${STAGE_WORK_DIR}/base.img.xz"

log "Unpacking the filesystem"	

LOOP_DEV=$(losetup --show -f -P "${STAGE_WORK_DIR}"/base.img)
BOOT_DEV="${LOOP_DEV}p1"
ROOT_DEV="${LOOP_DEV}p2"

mkdir -p "${ROOTFS_DIR}"
mkdir -p "${STAGE_WORK_DIR}/mp/boot" "${STAGE_WORK_DIR}/mp/root"

mount -o ro "${BOOT_DEV}" "${STAGE_WORK_DIR}/mp/boot"
mount -o ro "${ROOT_DEV}" "${STAGE_WORK_DIR}/mp/root"

rsync --info=progress2 --no-i-r -h -aHAXx "${STAGE_WORK_DIR}/mp/root/" "${ROOTFS_DIR}/"
rm -v -rf "${ROOTFS_DIR}/boot/firmware"
rsync --info=progress2 --no-i-r -h -aHAXx "${STAGE_WORK_DIR}/mp/boot/" "${ROOTFS_DIR}/boot/firmware/"

umount "${STAGE_WORK_DIR}/mp/boot"
umount "${STAGE_WORK_DIR}/mp/root"
rm -rf "${STAGE_WORK_DIR}/mp"
losetup -d "${LOOP_DEV}"

cp -v /usr/bin/qemu-arm-static "${ROOTFS_DIR}/usr/bin/"
