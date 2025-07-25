FROM ros:jazzy-ros-core

# Install ROS Jazzy Runtime and Demo Nodes
RUN apt-get update && apt-get install -y \
    ros-jazzy-demo-nodes-cpp

# Install additional dependencies for building (development tools only)
RUN apt-get update && apt-get install -y \
    python3-rosdep \
    python3-colcon-common-extensions \
    build-essential \
    git

WORKDIR /app
COPY . .
RUN chmod +x startup.sh

# Run the Demo Node (Edit for your custom application... e.g cpp_pubsub)
CMD ["./startup.sh"]