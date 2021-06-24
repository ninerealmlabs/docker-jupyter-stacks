#!/bin/bash
docker build . \
    --no-cache \
    --build-arg BASE_IMAGE="base_env" \
    --build-arg BUILD_DATE=$(date +'%Y-%m-%d') \
    -t ds_env:latest