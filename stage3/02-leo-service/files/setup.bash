source /opt/ros/melodic/setup.bash

## leo service variables

# Path to the launch file to start
export LAUNCH_FILE=/etc/ros/robot.launch

## leo_bringup variables

# Uncomment this line if you use the Pololu motors
# export LEO_MOTORS=pololu

## ROS variables
## http://wiki.ros.org/ROS/EnvironmentVariables

export ROS_LOG_DIR=/var/log/ros
export ROS_HOSTNAME=leo
# export ROS_IP=10.0.0.1
export ROS_MASTER_URI=http://localhost:11311
# export ROS_NAMESPACE=leo1