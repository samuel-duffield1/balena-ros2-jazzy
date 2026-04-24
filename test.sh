#!/usr/bin/env sh
set -eu

MCAP_IN_CONTAINER="$(docker compose exec -T ros2 sh -lc 'find /data/mcap -type f -name "*.mcap" -size +0c -printf "%T@ %p\n" | sort -nr | head -n 1 | cut -d" " -f2-')"

if [ -z "${MCAP_IN_CONTAINER}" ]; then
	echo "No non-empty .mcap files found yet. Let the demo run a bit longer and retry."
	exit 1
fi

docker compose cp "ros2:${MCAP_IN_CONTAINER}" ./latest-demo.mcap

if [ ! -s ./latest-demo.mcap ]; then
	echo "Copied file is empty. Retry after a few seconds."
	exit 1
fi

echo "Copied ${MCAP_IN_CONTAINER} to ./latest-demo.mcap"