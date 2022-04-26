#!/bin/bash -e

on_chroot <<EOF
su ${FIRST_USER_NAME}
/etc/ros/catkin_ws/update.sh
EOF