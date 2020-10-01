#!/bin/bash -e

on_chroot << EOF
adduser ros --system --group --home /var/ros
chmod 775 /var/ros
for GRP in dialout audio video input gpio spi i2c; do
  adduser ros "\${GRP}"
done
adduser $FIRST_USER_NAME ros
EOF

mkdir -p -m 775 "${ROOTFS_DIR}/etc/ros/urdf"

install -v -m 664 files/setup.bash "${ROOTFS_DIR}/etc/ros/"
install -v -m 664 files/robot.launch "${ROOTFS_DIR}/etc/ros/"
install -v -m 664 files/robot.urdf.xacro "${ROOTFS_DIR}/etc/ros/urdf/"
install -v -m 755 files/leo-start "${ROOTFS_DIR}/usr/bin/"
install -v -m 755 files/leo-stop "${ROOTFS_DIR}/usr/bin/"
install -v -m 644 files/leo.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
chown root:ros -R "/etc/ros"
systemctl enable leo
EOF

if ! grep -q "source /etc/ros/setup.bash" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc"; then
    echo -e "\nsource /etc/ros/setup.bash" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc"
fi