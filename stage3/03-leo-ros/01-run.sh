#!/bin/bash -e

mkdir -p -m 775 "${ROOTFS_DIR}/etc/ros/urdf"
mkdir -p -m 775 "${ROOTFS_DIR}/var/log/ros/"

install -v -m 664 files/setup.bash "${ROOTFS_DIR}/etc/ros/"
install -v -m 664 files/robot.launch "${ROOTFS_DIR}/etc/ros/"
install -v -m 664 files/robot.urdf.xacro "${ROOTFS_DIR}/etc/ros/urdf/"
install -v -m 755 files/leo-start "${ROOTFS_DIR}/usr/bin/"
install -v -m 755 files/leo-stop "${ROOTFS_DIR}/usr/bin/"
install -v -m 644 files/leo.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
groupadd -f -r ros
adduser $FIRST_USER_NAME ros
chown root:ros -R "/etc/ros"
chown root:ros "/var/log/ros"
systemctl enable leo
EOF

if ! grep -q "source /etc/ros/setup.bash" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc"; then
    echo -e "\nsource /etc/ros/setup.bash" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc"
fi