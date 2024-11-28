#!/bin/sh

IMAGE_NAME="taminob-linux"
LATEST_TAG="latest"
NEW_TAG="$(date +'%Y-%m')"
PREVIOUS_TAG="previous"

BUILD_FLAGS="${@}"

docker tag "${IMAGE_NAME}:${LATEST_TAG}" "${IMAGE_NAME}:${PREVIOUS_TAG}"
docker build ${BUILD_FLAGS} --network host \
    -t "${IMAGE_NAME}:${LATEST_TAG}" \
    -t "${IMAGE_NAME}:${NEW_TAG}" \
    -f Dockerfile .
