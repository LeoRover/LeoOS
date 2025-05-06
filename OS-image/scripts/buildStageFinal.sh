#!/bin/sh -e

DISK=/dev/vda

# Mount everything to /mnt
mkdir /mnt
mount -t ext4 "$DISK"2 /mnt
mount -t vfat "$DISK"1 /mnt/boot/firmware

sed -i "s|@OS_NAME@|${OSName}|g" /mnt/etc/custom-os-release
sed -i "s|@OS_VERSION@|${OSVersion}|g" /mnt/etc/custom-os-release
sed -i "s|@OS_VARIANT@|${OSVariant}|g" /mnt/etc/custom-os-release

# Unmount everything
umount /mnt/boot/firmware
umount /mnt