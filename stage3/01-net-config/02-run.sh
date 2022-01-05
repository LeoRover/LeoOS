#!/bin/bash -e

install -v -m 644 files/netplan/*.yaml "${ROOTFS_DIR}/etc/netplan/"

mkdir -p -m 755 "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service.d"
install -v -m 644 files/dnsmasq.service.d/*.conf "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service.d/"
mkdir -p -m 755 "${ROOTFS_DIR}/etc/systemd/system/hostapd.service.d"
install -v -m 644 files/hostapd.service.d/*.conf "${ROOTFS_DIR}/etc/systemd/system/hostapd.service.d/"
install -v -m 755 files/firstboot.d/* "${ROOTFS_DIR}/etc/firstboot.d/"
install -v -m 755 files/scripts/* "${ROOTFS_DIR}/usr/sbin/"
install -v -m 644 files/iptables/* "${ROOTFS_DIR}/etc/iptables/"

install -v -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -v -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
EOF