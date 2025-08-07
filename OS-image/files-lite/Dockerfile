FROM ros:humble-ros-base-jammy

RUN mkdir -p /root/ros_ws/src
WORKDIR /root/ros_ws

RUN git clone -b humble-leo1.9 https://github.com/LeoRover/leo_robot-ros2.git src/leo_robot-ros2
RUN git clone https://github.com/LeoRover/leo_common-ros2.git src/leo_common-ros2

RUN curl -sSL http://files.fictionlab.pl/repo/fictionlab.gpg -o /usr/share/keyrings/fictionlab-archive-keyring.gpg
RUN echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/fictionlab-archive-keyring.gpg] http://files.fictionlab.pl/repo \
      $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
      tee /etc/apt/sources.list.d/fictionlab.list > /dev/null

RUN apt-get update && rosdep update && \
      rosdep install --from-paths src --ignore-src -y

RUN apt-get install -y \
      ros-humble-micro-ros-agent

RUN . /opt/ros/humble/setup.sh && \
      colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

COPY ./entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Commands to build and run the container
#sudo docker build -t leo_humble_1_9 .

#sudo docker run \
#  --privileged \
#  --net=host \
#  -v /dev:/dev \
#  -v /usr/lib/ros/ros-nodes:/usr/lib/ros/ros-nodes \
#  -v /usr/lib/ros/uros-agent:/usr/lib/ros/uros-agent \
#  -v /etc/ros:/etc/ros \
#  -v /home/pi/.ros:/root/.ros \
#  -it --rm leo_humble_1_9 \
#  uros-agent

ENTRYPOINT [ "/root/entrypoint.sh" ]

#TODO: remove unnecessary source from ros-nodes and uros-agent
#Add libcamera (leo_camera_ros)
#Reboot and shutdownis not working