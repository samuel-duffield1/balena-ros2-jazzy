#!/bin/bash

ros2 run demo_nodes_cpp talker &

# Prevent the container from exiting immediately
while true; do
    sleep 60
done