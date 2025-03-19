#!/bin/sh -e

DISK=/dev/vda

my_chroot() {
    DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    $(type -tP chroot) $@
}

# Create partition table for Raspberry Pi
parted $DISK --script mklabel msdos
parted $DISK --script mkpart primary fat32 1MiB 256MiB
parted $DISK --script mkpart primary ext4 256MiB 100%

# Ensure that the partition block devices (/dev/vda1 etc) exist
partx -u "$DISK"
# Make a FAT filesystem for the Raspberry Pi boot partition 
mkfs.vfat -F32 -n boot "$DISK"1
# Make an ext4 filesystem for the system root
mkfs.ext4 "$DISK"2 -L root

# Mount everything to /mnt and provide some directories needed later on
mkdir /mnt
mount -t ext4 "$DISK"2 /mnt
mkdir -p /mnt/{proc,dev,sys,boot/firmware}
mount -t vfat "$DISK"1 /mnt/boot/firmware
mount -o bind /proc /mnt/proc
mount -o bind /dev /mnt/dev
mount -o bind /dev/pts /mnt/dev/pts
mount -t sysfs sysfs /mnt/sys

# Make the Nix store available in /mnt, because that's where the .debs live.
mkdir -p /mnt/inst${NIX_STORE_DIR}
mount -o bind ${NIX_STORE_DIR} /mnt/inst${NIX_STORE_DIR}

# Ubuntu Noble requires merged /usr directories scheme
mkdir -p /mnt/usr/{bin,sbin,lib,lib64}
ln -s /usr/bin /mnt/bin
ln -s /usr/sbin /mnt/sbin
ln -s /usr/lib /mnt/lib
ln -s /usr/lib64 /mnt/lib64

echo "Unpacking Debs..."

DEBS_UNPACK_FILES=$(cat ${debs_unpack})

for deb in ${DEBS_UNPACK_FILES}; do
    echo "$deb..."
    dpkg-deb --extract "$deb" /mnt
done

echo "Installing Debs..."

DEBS_INSTALL_FILES=$(cat ${debs_install})

oldIFS="$IFS"
IFS="|"
for component in ${DEBS_INSTALL_FILES}; do
    IFS="$oldIFS"
    echo
    echo ">>> INSTALLING COMPONENT: $component"
    debs=
    for i in $component; do
        debs="$debs /inst$i";
    done

    my_chroot /mnt dpkg --install --force-conflicts --force-overwrite $debs < /dev/null
done

# Unmount everything
umount /mnt/inst${NIX_STORE_DIR}
umount /mnt/boot/firmware
umount /mnt/sys
umount /mnt/proc
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt