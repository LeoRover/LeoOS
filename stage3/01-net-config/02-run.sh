#!/bin/bash -e

install -v -m 644 files/udev/*.rules "${ROOTFS_DIR}/etc/udev/rules.d/"
install -v -m 644 files/netplan/*.yaml "${ROOTFS_DIR}/etc/netplan/"
mkdir -p -m 755 "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service.d"
install -v -m 644 files/dnsmasq.service.d/*.conf "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service.d/"

install -v -m 644 files/iptables.ipv4.nat "${ROOTFS_DIR}/etc/iptables.ipv4.nat"
install -v -m 755 files/rc.local "${ROOTFS_DIR}/etc/rc.local"
install -v -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -v -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
EOF