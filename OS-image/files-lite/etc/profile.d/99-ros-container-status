#!/bin/bash

# Ensure this only prints for interactive logins
if [[ $- == *i* ]]; then
    if systemctl --user is-active --quiet ros-nodes 2>/dev/null && systemctl --user is-active --quiet uros-agent 2>/dev/null; then
        printf "ROS Humble containers are running. To enter the ROS bash shell, run: ros-container-bash\n"
    else
        printf "One or more ROS Humble containers are not running - you can find more info with: ros-status\n"
    fi
fi