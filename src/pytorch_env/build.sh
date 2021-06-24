#!/bin/bash
docker build . \
    --no-cache \
    --build-arg BASE_IMAGE="ds_env" \
    --build-arg BUILD_DATE=$(date +'%Y-%m-%d') \
    -t pytorch_env:latest