source /opt/ros/noetic/setup.bash

### leo service variables

# Path to the launch file to start.
export LAUNCH_FILE="/etc/ros/robot.launch"

# Set to false if you run roscore somewhere else.
export START_ROSCORE=true

# Control whether to use rosmon or roslaunch for starting and managing nodes.
# In case of problems with rosmon, set this to false.
export USE_ROSMON=true

# Set additional arguments for rosmon or roslaunch
export ROSMON_ARGS=""
export ROSLAUCH_ARGS=""

# If set to true, starts rosmon (with ui) and roscore in a tmux session 
# to which you can connect (using leo-attach script) and control the state
# of the nodes.
export INTERACTIVE=false


### ROS Environment Variables
### http://wiki.ros.org/ROS/EnvironmentVariables

export ROS_HOME="/var/ros"
export ROS_MASTER_URI="http://localhost:11311"
export ROS_IP="10.0.0.1"
#export ROS_HOSTNAME="master.lan"
#export ROS_NAMESPACE="leo1"
