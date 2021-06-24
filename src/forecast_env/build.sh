#!/bin/bash
docker build . \
    --no-cache \
    --build-arg BASE_IMAGE="pytorch_env" \
    --build-arg BUILD_DATE=$(date +'%Y-%m-%d') \
    -t forecast_env:latest