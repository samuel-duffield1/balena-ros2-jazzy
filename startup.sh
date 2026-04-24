#!/bin/bash

set -euo pipefail

: "${MCAP_OUTPUT_ROOT:=/data/mcap}"
: "${ROSBAG_RECORD_ARGS:=-a}"
: "${ROSBAG_STORAGE_ID:=mcap}"
: "${ROS_TALKER_COMMAND:=ros2 run demo_nodes_cpp talker}"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="${MCAP_OUTPUT_ROOT}/${timestamp}"

mkdir -p "${MCAP_OUTPUT_ROOT}"

cleanup() {
    trap - EXIT SIGINT SIGTERM

    for pid in "${rosbag_pid:-}" "${talker_pid:-}"; do
        if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}" 2>/dev/null || true
        fi
    done

    wait || true
}

trap cleanup EXIT SIGINT SIGTERM

echo "Starting ROS publisher: ${ROS_TALKER_COMMAND}"
bash -lc "${ROS_TALKER_COMMAND}" &
talker_pid=$!

echo "Recording MCAP bag to ${output_dir}"
bash -lc "ros2 bag record ${ROSBAG_RECORD_ARGS} -s ${ROSBAG_STORAGE_ID} -o '${output_dir}'" &
rosbag_pid=$!

status=0
if ! wait -n "${talker_pid}" "${rosbag_pid}"; then
    status=$?
fi

cleanup
exit "${status}"