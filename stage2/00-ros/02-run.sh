#!/bin/bash 

on_chroot << EOF
rosdep init
su - ${FIRST_USER_NAME}
rosdep update
EOF