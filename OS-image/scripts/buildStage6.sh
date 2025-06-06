#!/bin/sh -e

# Configuration
USER_NAME=pi

my_chroot() {
    env -i \
    DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    $(type -tP chroot) $@
}

DISK=/dev/vda

# Mount everything to /mnt and provide some directories needed later on
mkdir /mnt
mount -t ext4 "$DISK"2 /mnt
mkdir -p /mnt/{proc,dev,sys,boot/firmware}
mount -t vfat "$DISK"1 /mnt/boot/firmware
mount -o bind /proc /mnt/proc
mount -o bind /dev /mnt/dev
mount -o bind /dev/pts /mnt/dev/pts
mount -t sysfs sysfs /mnt/sys

# Install configuration files
cp -vr --no-preserve=mode "${FILES_DIR}/"* /mnt/

# Patch configuration files
sed -i "s|user = CHANGE_ME|user = ${USER_NAME}|" /mnt/etc/lightdm/lightdm-mini-greeter.conf
sed -i "s|Clearlooks|Lubuntu Arc|g" /mnt/etc/xdg/openbox/rc.xml

# Disable autostart applications
echo "Hidden=true" >> /mnt/etc/xdg/autostart/lxqt-powermanagement.desktop
echo "Hidden=true" >> /mnt/etc/xdg/autostart/nm-applet.desktop

echo -n " video=HDMI-A-1:1280x800@30D" >> /mnt/boot/firmware/cmdline.txt

my_chroot /mnt systemctl enable x0vncserver

# Unmount everything
umount /mnt/boot/firmware
umount /mnt/sys
umount /mnt/proc
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt
