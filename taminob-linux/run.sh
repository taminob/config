#!/bin/sh

# systemctl start docker

# run as root: --user=0

HOST_SHARED_DIR="/tmp/taminob-linux"

mkdir -pv "${HOST_SHARED_DIR}"
exec docker run \
           -e XDG_RUNTIME_DIR="/tmp" \
           -e WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
           -v "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}":"/tmp/${WAYLAND_DISPLAY}" \
           -v "${HOST_SHARED_DIR}":"/mnt" \
           --net=host --rm -it \
           --name=taminob-linux --hostname=taminob-linux \
           taminob-linux:latest
