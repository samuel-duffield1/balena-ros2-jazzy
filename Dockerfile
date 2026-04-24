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

WORKDIR /app
COPY . .
RUN chmod +x startup.sh

# Run the Demo Node (Edit for your custom application... e.g cpp_pubsub)
CMD ["./startup.sh"]