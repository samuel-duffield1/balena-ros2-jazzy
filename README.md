# balena-ros2-jazzy

A project demonstrating containerisation of a ROS2 Robotics application, in the most basic/simplest sense, to provide a platform to develop off of for your custom Robotics application.

This project is compatible with [Balena](https://www.balena.io) for deployment of your robotics project to an edge compute device with remote fleet management.

## Quick Start - Running a ROS2 Node

This example uses the `talker` example from the `demo_nodes_cpp` workspace in the `ros-jazzy-demo-nodes-cpp` package to produce the following output:

```bash
ros2-1  | [INFO] [1753370299.123600377] [talker]: Publishing: 'Hello World: 1'
ros2-1  | [INFO] [1753370300.121480544] [talker]: Publishing: 'Hello World: 2'
ros2-1  | [INFO] [1753370301.119789419] [talker]: Publishing: 'Hello World: 3'
ros2-1  | [INFO] [1753370302.119318961] [talker]: Publishing: 'Hello World: 4'
ros2-1  | [INFO] [1753370303.122725253] [talker]: Publishing: 'Hello World: 5'
ros2-1  | [INFO] [1753370304.123026212] [talker]: Publishing: 'Hello World: 6'
ros2-1  | [INFO] [1753370305.120326213] [talker]: Publishing: 'Hello World: 7'
ros2-1  | [INFO] [1753370306.123128213] [talker]: Publishing: 'Hello World: 8'
ros2-1  | [INFO] [1753370307.119615380] [talker]: Publishing: 'Hello World: 9'
ros2-1  | [INFO] [1753370308.122677881] [talker]: Publishing: 'Hello World: 10'
...
```

## Developing - Using Devcontainers
This project also provides a basic `.devcontainer` setup for prototyping your ROS2 application on Windows/MacOS/Linux before deploying to your Edge Compute device.

Run the command `Dev Containers: Open folder in container` to begin building your ROS2 application on your host machine.

Source code can be found in [src](./cpp_pubsub/src/publisher_lambda_function.cpp).

Follow the instructions on how to [build a cpp ROS2 application](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Cpp-Publisher-And-Subscriber.html) on the official ROS2 documentation site.


## Deploying - Using Balena
You can deploy this robotics application to [any supported device on Balena](https://www.balena.io/devices), anywhere in the world, using balena push:
```bash
balena push <org>/<fleet>
```
