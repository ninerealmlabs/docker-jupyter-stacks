#!/bin/bash
###
# call with `build.sh <PYTHON_VERSION=${1:-3.8.*}
###

PYTHON_VERSION=${1:-3.8.*}

# Docker doesn't like `*`, so drop trailing ".*" from tag
TAG_VERSION=${PYTHON_VERSION}
if [[ ${TAG_VERSION: -1} == "*" ]]; then
    TAG_VERSION=${TAG_VERSION: 0:${#TAG_VERSION}-2}
fi
# echo ${TAG_VERSION}

# `$(dirname $0)` is equivalent to `.` if building from /src/base_env
# but is required if referencing `build.sh` from any other location
docker build $(dirname $0) \
    --no-cache \
    --build-arg BASE_IMAGE="base_env:python-${TAG_VERSION}" \
    --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
    --build-arg BUILD_DATE=$(date +'%Y-%m-%d') \
    --tag ds_env:python-${TAG_VERSION}