mkdir -p /etc/ros/ros_ws/src
cd /etc/ros/ros_ws/src
git clone https://github.com/LeoRover/leo_bringup.git -b erc
git clone https://github.com/LeoRover/leo_description.git -b new_model
cd ..
source /opt/ros/melodic/setup.bash
catkin config --extend /opt/ros/melodic --install -i /opt/ros/leo
catkin build