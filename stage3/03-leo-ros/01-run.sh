#!/bin/bash -e

mkdir -p -m 755 "${ROOTFS_DIR}/etc/ros/urdf"
mkdir -p -m 755 "${ROOTFS_DIR}/var/ros/"

install -v -m 644 files/setup.bash "${ROOTFS_DIR}/etc/ros/"
install -v -m 644 files/robot.launch "${ROOTFS_DIR}/etc/ros/"
install -v -m 644 files/robot.urdf.xacro "${ROOTFS_DIR}/etc/ros/urdf/"
install -v -m 644 files/leo.service "${ROOTFS_DIR}/etc/systemd/system/"
install -v -m 755 files/scripts/* "${ROOTFS_DIR}/usr/bin/"
install -v -m 644 files/tmux.conf "${ROOTFS_DIR}/etc/"

sed -i "s|USER|${FIRST_USER_NAME}|" "${ROOTFS_DIR}/etc/systemd/system/leo.service"

on_chroot << EOF
chown ${FIRST_USER_NAME}:${FIRST_USER_NAME} -R "/etc/ros"
chown root:root -R "/etc/ros/rosdep"
chown ${FIRST_USER_NAME}:${FIRST_USER_NAME} "/var/ros"
systemctl enable leo
EOF

if ! grep -q "source /etc/ros/setup.bash" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc"; then
    echo -e "\nsource /etc/ros/setup.bash" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc"
fi