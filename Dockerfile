FROM ros:jazzy-ros-core

# Install the demo talker, rosbag tooling, and the MCAP storage plugin.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-demo-nodes-cpp \
    ros-jazzy-ros2bag \
    ros-jazzy-rosbag2-storage-mcap \
    python3-rosdep \
    python3-colcon-common-extensions \
    build-essential \
    git \
  && rm -rf /var/lib/apt/lists/*

# Source ROS 2 for interactive bash shells too. ENTRYPOINT only covers PID 1, so
# `docker exec` sessions (devcontainer terminals, `balena ssh`) would otherwise
# start with no ROS on PATH. Deliberately bash-only: setup.bash is not POSIX sh.
RUN printf '%s\n' \
      'source "/opt/ros/$ROS_DISTRO/setup.bash" --' \
      '[ -f /app/cpp_pubsub/install/setup.bash ] && source /app/cpp_pubsub/install/setup.bash -- || true' \
      > /etc/ros-env.bash \
  && echo 'source /etc/ros-env.bash' >> /etc/bash.bashrc

# Scripts live outside /app so the devcontainer's bind mount cannot shadow them.
COPY entrypoint.sh run.sh /
RUN chmod +x /entrypoint.sh /run.sh

WORKDIR /app
COPY . .

# entrypoint.sh sets up the ROS environment and execs its arguments, so the CMD
# below is the only thing to change for your custom application (e.g. cpp_pubsub),
# and `docker compose run ros2 <cmd>` still gets a working ROS environment.
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/run.sh"]
