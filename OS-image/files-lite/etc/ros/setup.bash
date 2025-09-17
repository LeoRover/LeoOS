# Source the ROS workspace
source /opt/ros/jazzy/setup.bash

# Source aliases for systemd user services
source /etc/ros/aliases


### Robot Configuration

# Set to true if the robot uses mecanum wheels
export MECANUM_WHEELS=false

# Namespace of the robot
# Affects all node namespaces (except the firmware node) and URDF link names
export ROBOT_NAMESPACE=""

# Set to false to disable publishing of odom -> base_footprint TF transform
export PUBLISH_ODOM_TF=true

### Start scripts variables

# Path to the launch file to start.
LAUNCH_FILE="/etc/ros/robot.launch.xml"

# Arguments passed to ros2 launch command
LAUNCH_ARGS=""

# Arguments passed to Micro-ROS agent
UROS_AGENT_ARGS="serial -D /dev/serial0 -b 460800"

# The ID and port of the discovery server. (only used if the discovery server is enabled)
DISCOVERY_SERVER_ID=0
DISCOVERY_SERVER_PORT=11811

### ROS Environment Variables

#export ROS_DOMAIN_ID=10
#export ROS_LOCALHOST_ONLY=1
export RCUTILS_COLORIZED_OUTPUT=1
# export ROS_DISCOVERY_SERVER="127.0.0.1:11811"
# export ROS_SUPER_CLIENT=true