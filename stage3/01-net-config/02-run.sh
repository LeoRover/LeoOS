#!/bin/bash -e

install -v -m 644 files/netplan/*.yaml "${ROOTFS_DIR}/etc/netplan/"

mkdir -p -m 755 "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service.d"
install -v -m 644 files/systemd/dnsmasq.service.d/*.conf "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service.d/"
mkdir -p -m 755 "${ROOTFS_DIR}/etc/systemd/system/hostapd.service.d"
install -v -m 644 files/systemd/hostapd.service.d/*.conf "${ROOTFS_DIR}/etc/systemd/system/hostapd.service.d/"
mkdir -p -m 755 "${ROOTFS_DIR}/etc/systemd/network/10-netplan-br0.network.d/"
install -v -m 644 files/systemd/10-netplan-br0.network.d/*.conf "${ROOTFS_DIR}/etc/systemd/network/10-netplan-br0.network.d/"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"
install -v -m 755 files/scripts/* "${ROOTFS_DIR}/usr/sbin/"
install -v -m 644 files/iptables/* "${ROOTFS_DIR}/etc/iptables/"

install -v -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -v -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

on_chroot << EOF
systemctl unmask hostapd
echo y | ap-disable
EOF