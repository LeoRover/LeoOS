#!/bin/bash -e

for uboot_binary in ${ROOTFS_DIR}/usr/lib/u-boot/*/u-boot.bin; do
    log ${uboot_binary}
    dest_binary=uboot_$(basename $(dirname "${uboot_binary}")).bin
    log ${dest_binary}
    cp -v "${uboot_binary}" "${ROOTFS_DIR}/boot/firmware/${dest_binary}"
done

install -v -m 644 files/firmware/*.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/firmware/README "${ROOTFS_DIR}/boot/firmware/"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"
