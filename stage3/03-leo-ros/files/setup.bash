#source /opt/ros/melodic/setup.bash
source /opt/ros/leo/setup.bash

### leo service variables

# Path to the launch file to start
export LAUNCH_FILE="/etc/ros/robot.launch"
# Additional command-line arguments passed to roslaunch
#export ROSLAUNCH_ARGS="--wait"

### leo_bringup variables

# Uncomment this line if you use the Pololu motors
#export LEO_MOTORS=pololu

### ROS Environment Variables
### http://wiki.ros.org/ROS/EnvironmentVariables

export ROS_HOME="/var/ros"
export ROS_HOSTNAME="master.localnet"
export ROS_MASTER_URI="http://master.localnet:11311"
#export ROS_IP="10.0.0.1"
#export ROS_NAMESPACE="leo1"
