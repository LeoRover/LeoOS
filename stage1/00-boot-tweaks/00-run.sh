#!/bin/bash -e

for uboot_binary in ${ROOTFS_DIR}/usr/lib/u-boot/*/u-boot.bin; do
    log ${uboot_binary}
    dest_binary=uboot_$(basename $(dirname "${uboot_binary}")).bin
    log ${dest_binary}
    cp -v "${uboot_binary}" "${ROOTFS_DIR}/boot/firmware/${dest_binary}"
done

install -v -m 644 files/boot/*.txt "${ROOTFS_DIR}/boot/firmware/"
install -v -m 644 files/boot/README "${ROOTFS_DIR}/boot/firmware/"

mkdir -p -m 755 "${ROOTFS_DIR}/etc/firstboot.d"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"
install -v -m 755 files/init_firstboot "${ROOTFS_DIR}/sbin/"

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"
