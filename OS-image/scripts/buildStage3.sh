#!/bin/sh -e

DISK=/dev/vda

my_chroot() {
    DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    $(type -tP chroot) $@
}

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

DEBS_STAGE3_FILES=$(cat ${debsStage3})
echo "Installing Debs..."

oldIFS="$IFS"
IFS="|"
for component in ${DEBS_STAGE3_FILES}; do
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