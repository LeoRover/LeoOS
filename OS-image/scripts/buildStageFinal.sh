#!/bin/sh -e

DISK=/dev/vda

# Mount everything to /mnt
mkdir /mnt
mount -t ext4 "$DISK"2 /mnt
mount -t vfat "$DISK"1 /mnt/boot/firmware

# Set the OS name, version, and variant
sed -i "s|@OS_NAME@|${OSName}|g" /mnt/etc/custom-os-release
sed -i "s|@OS_VERSION@|${OSVersion}|g" /mnt/etc/custom-os-release
sed -i "s|@OS_VARIANT@|${OSVariant}|g" /mnt/etc/custom-os-release

# Remove backup files
find "/mnt/etc" -type f -name "*-" -exec rm -v {} \;
find "/mnt/var" -type f -name "*-old" -exec rm -v {} \;

# Truncate all logs
find "/mnt/var/log/" -type f -exec cp -v /dev/null {} \;

# Clear up /run directory
rm -v -rf "/mnt/run/"*

# Unmount everything
umount /mnt/boot/firmware
umount /mnt

zerofree -v "$DISK"2
