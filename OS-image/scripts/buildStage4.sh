#!/bin/sh -e

# Configuration
USER_NAME=pi
USER_PASS=raspberry
HOSTNAME=leo

my_chroot() {
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

# Remove redundant files
rm -rf /mnt/etc/update-motd.d/*

# Install configuration files
cp -vr --no-preserve=mode "${FILES_DIR}/"* /mnt/
echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /mnt/etc/sudoers.d/010_${USER_NAME}-nopasswd

# Fix file permissions
chmod -v +x /mnt/usr/sbin/init_firstboot
chmod -v +x /mnt/usr/lib/firstboot/*
chmod -v +x /mnt/usr/lib/ros/*
chmod -v +x /mnt/etc/update-motd.d/*
chmod -v 600 /mnt/etc/netplan/* 
chmod -v 440 "/mnt/etc/sudoers.d/010_${USER_NAME}-nopasswd"

# Symlink resolv.conf to systemd-resolved
ln -vsnf /lib/systemd/resolv.conf /mnt/etc/resolv.conf

# Remove SSH host keys
rm /mnt/etc/ssh/ssh_host_*

# Set hostname
echo "${HOSTNAME}" > "/mnt/etc/hostname"
printf "\n127.0.1.1 ${HOSTNAME}\n" >> "/mnt/etc/hosts"

# Configure nginx
rm -vf /mnt/etc/nginx/sites-enabled/default
ln -vs /etc/nginx/sites-available/leo_ui /mnt/etc/nginx/sites-enabled/leo_ui

my_chroot /mnt /bin/bash -exuo pipefail <<CHROOT
# Create default user
if ! id -u ${USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${USER_NAME}
fi
echo "${USER_NAME}:${USER_PASS}" | chpasswd
for GRP in input spi i2c gpio; do
	groupadd -f -r "\${GRP}"
done
for GRP in adm dialout audio sudo video plugdev input i2c spi gpio; do
    adduser $USER_NAME "\${GRP}"
done

# Enable user services
systemctl --user enable ros-nodes
systemctl --user enable uros-agent
CHROOT

# Enable lingering for default user
mkdir -p -m 755 "/mnt/var/lib/systemd/linger"
touch "/mnt/var/lib/systemd/linger/${USER_NAME}"

# Automatically source our setup when user logs in to bash shell
echo -e "\nsource /etc/ros/setup.bash" >> "/mnt/home/${USER_NAME}/.bashrc"

my_chroot /mnt /bin/bash -exuo pipefail <<CHROOT
export FK_MACHINE="Raspberry Pi 5 Model B Rev 1.0"
export FK_IGNORE_EFI="yes"
export FK_FORCE="yes"
flash-kernel

# Enable Networkd
systemctl enable systemd-networkd

# Enable Hostapd
systemctl unmask hostapd
systemctl enable hostapd

# Enable nftables
systemctl enable nftables
CHROOT

# Unmount everything
umount /mnt/boot/firmware
umount /mnt/sys
umount /mnt/proc
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt
