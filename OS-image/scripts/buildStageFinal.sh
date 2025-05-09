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

# Zero out free space
zerofree -v "$DISK"2

# Shrink the filesystem to fit the data
e2fsck -vfy "$DISK"2
resize2fs -M "$DISK"2

START_SECTOR=$(parted "$DISK" unit s print | awk '$1 == 2 {print $2}' | sed 's/s//')

# Get sector size in bytes
SECTOR_SIZE=$(cat /sys/block/$(basename $DISK)/queue/hw_sector_size)

# Calculate total sectors for new size
NEW_SIZE_BYTES=$(dumpe2fs -h ${DISK}2 | grep "Block count:" | awk '{print $3 * 4096}')
NEW_SIZE_SECTORS=$((NEW_SIZE_BYTES / SECTOR_SIZE))
NEW_END_SECTOR=$((START_SECTOR + NEW_SIZE_SECTORS - 1))

parted $DISK ---pretend-input-tty <<EOF
resizepart 2 ${NEW_END_SECTOR}s
Yes
print free
EOF
