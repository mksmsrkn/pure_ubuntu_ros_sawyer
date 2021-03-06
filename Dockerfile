FROM ubuntu:xenial

##### ROS Kinetic layer #####
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list' &&\
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 &&\
apt-get update &&\
apt-get -y install ros-kinetic-desktop-full &&\
rosdep init &&\
rosdep update &&\
apt-get -y install python-rosinstall python-rosinstall-generator python-wstool build-essential python-pip python-dev net-tools wget

RUN apt-get install -y git-core python-argparse python-wstool python-vcstools python-rosdep ros-kinetic-control-msgs ros-kinetic-joystick-drivers ros-kinetic-xacro ros-kinetic-tf2-ros ros-kinetic-rviz ros-kinetic-cv-bridge ros-kinetic-actionlib ros-kinetic-actionlib-msgs ros-kinetic-dynamic-reconfigure ros-kinetic-trajectory-msgs ros-kinetic-rospy-message-converter

RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc

##### END : ROS Kinetic layer #####

##### SAWYER INIT SETUP #####
RUN mkdir -p ~/ros_ws/src && \
cd ~/ros_ws/src && \
wstool init . && \
git clone https://github.com/RethinkRobotics/sawyer_robot.git && \
#cd sawyer_robot && git checkout v5.2.0 && cd .. && \ 
wstool merge sawyer_robot/sawyer_robot.rosinstall  && wstool update && \
# cd intera_common && git checkout v5.2.0 && cd .. && \
# cd intera_sdk && git checkout v5.2.0 && cd .. && \
/bin/bash -c "cd ~/ros_ws && source /opt/ros/kinetic/setup.bash"
##### END : SAWYER INIT SETUP #####

##### GAZEBO SETUP #####
RUN apt-get update --fix-missing
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' &&\
cat /etc/apt/sources.list.d/gazebo-stable.list &&\
wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - &&\
apt-get update &&\
 apt-get install -y gazebo7 libgazebo7-dev libignition-math2-dev ros-kinetic-qt-build ros-kinetic-gazebo-ros-control ros-kinetic-gazebo-ros-pkgs ros-kinetic-ros-control ros-kinetic-realtime-tools ros-kinetic-ros-controllers ros-kinetic-xacro python-wstool python-catkin-tools ros-kinetic-tf-conversions ros-kinetic-kdl-parser ros-kinetic-sns-ik-lib ros-kinetic-control-toolbox 
##### END : GAZEBO SETUP #####

##### SAWYER GAZEBO SETUP #####
RUN cd ~/ros_ws/src && \
    git clone https://github.com/RethinkRobotics/sawyer_simulator.git && \
    #cd sawyer_simulator && git checkout v5.2.0 && \
    cd ~/ros_ws/src &&  \
    wstool merge sawyer_simulator/sawyer_simulator.rosinstall && \
    wstool update && \
    /bin/bash -c "cd ~/ros_ws && source /opt/ros/kinetic/setup.bash"
##### END : SAWYER GAZEBO SETUP #####

##### MOVEIT SETUP #####
RUN apt-get install -y ros-kinetic-moveit && \
    cd ~/ros_ws/src  && \
    wstool merge https://raw.githubusercontent.com/RethinkRobotics/sawyer_moveit/master/sawyer_moveit.rosinstall  && \
    wstool update && \
    /bin/bash -c "cd ~/ros_ws && source /opt/ros/kinetic/setup.bash"
##### END : MOVEIT SETUP #####

##### IntelRealsense Camera Gazebo Setup ##########
RUN cd ~/ros_ws/src &&\
    git clone https://github.com/SyrianSpock/realsense_gazebo_plugin &&\
    cd realsense_gazebo_plugin &&\
    git checkout kinetic-devel &&\
    cd ~/ros_ws/ &&\
    /bin/bash -c "cd ~/ros_ws && source /opt/ros/kinetic/setup.bash && catkin build"
##### END:IntelRealsense Camera Gazebo Setup ##########

##### IntelRealsense Camera Gazebo Setup ##########
# install librealsense 2
RUN apt-get install -y software-properties-common usbutils # required for add-apt-repository
RUN apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE && \
        add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u && \
        apt-get update && \
        apt-get install -y librealsense2-utils librealsense2-dev librealsense2-dbg #librealsense2-dkms
RUN cd ~/ && wget https://github.com/intel-ros/realsense/archive/2.1.0.zip &&\
	unzip 2.1.0.zip && mv realsense-2.1.0/ ~/ros_ws/src/ && rm 2.1.0.zip &&\
	cd ~/ros_ws/ && catkin build
##### END:IntelRealsense Camera Gazebo Setup ##########

##### SUBLIME TEXT + TERMINATOR #####
RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - &&\
    apt-get install apt-transport-https &&\
    echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list &&\
    apt-get update  &&\
    apt-get install -y sublime-text &&\
    apt-get install -y terminator
##### END : SUBLIME TEXT + TERMINATOR #####

##### VNC + OPENBOX #####

# Install a VNC X-server, Frame buffer, and windows manager
RUN apt-get install -y x11vnc xvfb openbox obconf

# Finally, install wmctrl needed for bootstrap script
RUN apt-get install -y wmctrl 

# Copy scripts
COPY bootstrap.sh /
COPY intera_setup.sh /root/
##### END : VNC + OPENBOX #####

CMD '/bootstrap.sh'

RUN mv ~/ros_ws/src/intera_sdk/intera.sh ~/ros_ws