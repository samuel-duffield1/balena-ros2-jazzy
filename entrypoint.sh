#!/usr/bin/env bash
# Sources the ROS 2 environment, then hands over to whatever command it is given:
# the image CMD (/run.sh) on a device, or an ad-hoc command from
# `docker compose run ros2 <cmd>`. The trailing `--` stops setup.bash from
# treating our arguments as its own.
set -e

source "/opt/ros/${ROS_DISTRO}/setup.bash" --

# Overlay the colcon workspace once it has been built (see cpp_pubsub/).
if [ -f /app/cpp_pubsub/install/setup.bash ]; then
    source /app/cpp_pubsub/install/setup.bash --
fi

exec "$@"
