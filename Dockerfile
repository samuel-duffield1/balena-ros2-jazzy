FROM ros:jazzy-ros-core
RUN apt-get update && apt-get install -y \
    ros-jazzy-demo-nodes-cpp

WORKDIR /app
COPY . .
RUN chmod +x startup.sh

CMD ["./startup.sh"]