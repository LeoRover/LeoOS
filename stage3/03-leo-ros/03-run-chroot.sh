export ROS_HOME=/var/ros
cd /etc/ros/catkin_ws
vcs import < leo-erc.repos
rosdep update
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /var/ros/rosdep
rosdep install --rosdistro melodic --from-paths src -iy
catkin config --extend /opt/ros/melodic --install -i /opt/ros/leo
catkin build --no-status