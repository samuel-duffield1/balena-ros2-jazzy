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

At the same time, the container records ROS 2 traffic to MCAP bags under `/data/mcap`, which is backed by a named Docker volume so recordings persist across container updates on balena devices.

If you are running locally with Docker Compose, start the stack with:

```bash
docker compose up --build
```

Recorded bags will be stored in the `ros-logs` volume, with one timestamped directory per container start.

You can change the recorder behaviour with service environment variables in [docker-compose.yml](./docker-compose.yml):

- `MCAP_OUTPUT_ROOT` sets the in-container root directory for bag files.
- `ROSBAG_RECORD_ARGS` controls which topics are recorded. The default is `-a` to record all topics.
- `ROSBAG_STORAGE_ID` defaults to `mcap`.

## How the Container Starts

The image splits environment setup from the workload, so the two can be changed independently:

- [entrypoint.sh](./entrypoint.sh) is the `ENTRYPOINT`. It sources `/opt/ros/$ROS_DISTRO/setup.bash`,
  overlays `cpp_pubsub/install/setup.bash` if you have built it, and then `exec`s its arguments.
- [run.sh](./run.sh) is the `CMD`. It starts the talker and the `ros2 bag record` process.

Because the entrypoint execs whatever it is handed, anything you run in the container inherits a
working ROS environment without a wrapper of its own:

```bash
docker compose run --rm ros2 ros2 topic list
docker compose run --rm ros2 bash
```

To swap in your own application, change the `CMD` in the [Dockerfile](./Dockerfile) (or edit
[run.sh](./run.sh)) and leave the entrypoint alone. `docker exec` sessions and `balena ssh` do not
pass through the entrypoint, so the image also sources ROS from `/etc/bash.bashrc` for interactive
shells.

### Validate Logging with `mcap cat`

After starting the stack, you can validate that messages were really written to MCAP by reading one bag file.

1. Let the demo run for a few seconds:

```bash
docker compose up --build
```

2. In a second terminal, copy the newest non-empty MCAP file out of the container:

```bash
MCAP_IN_CONTAINER="$(docker compose exec -T ros2 sh -lc 'find /data/mcap -type f -name "*.mcap" -size +0c -printf "%T@ %p\n" | sort -nr | head -n 1 | cut -d" " -f2-')"
docker compose cp "ros2:${MCAP_IN_CONTAINER}" ./latest-demo.mcap
```

Note: the actively-written bag file can be temporarily 0 bytes while recording is still in progress. Selecting the newest non-empty file avoids this race.

3. Print records with the `mcap cat` CLI:

```bash
mcap cat ./latest-demo.mcap | head -n 20
```

If recording is working, the output will contain messages from the `topic` channel, including values like `Hello, world! N`.

## Developing - Using Devcontainers
This project also provides a basic `.devcontainer` setup for prototyping your ROS2 application on Windows/MacOS/Linux before deploying to your Edge Compute device.

Run the command `Dev Containers: Open folder in container` to begin building your ROS2 application on your host machine.

The devcontainer reuses the same [Dockerfile](./Dockerfile) as the device image, with
`overrideCommand: true` so the container idles instead of starting [run.sh](./run.sh). ROS 2 is
already sourced in every terminal you open, and `rosdep` is bootstrapped by the container's
`onCreateCommand`, so you can go straight to building:

```bash
cd /app/cpp_pubsub
rosdep install -i --from-path . --rosdistro jazzy -y
colcon build
source install/setup.bash
ros2 run cpp_pubsub talker
```

Note that `--network=host` and `privileged` in [devcontainer.json](./.devcontainer/devcontainer.json)
mirror the device deployment but only take effect on a Linux host; drop them if you are not
prototyping against host hardware or a ROS graph running outside the container.

Source code can be found in [src](./cpp_pubsub/src/publisher_lambda_function.cpp).

Follow the instructions on how to [build a cpp ROS2 application](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Cpp-Publisher-And-Subscriber.html) on the official ROS2 documentation site.


## Deploying - Using Balena
You can deploy this robotics application to [any supported device on Balena](https://www.balena.io/devices), anywhere in the world, using balena push:
```bash
balena push <org>/<fleet>
```

For balena deployments, the project now follows the multicontainer pattern with a named volume in [docker-compose.yml](./docker-compose.yml), which is the supported way to persist application data on balenaOS.

The repository also includes [balena.yml](./balena.yml) with basic fleet metadata for balena-style project packaging.
