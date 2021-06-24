#!/bin/bash
docker build . \
    --no-cache \
    --build-arg BASE_IMAGE="jupyter/minimal-notebook" \
    --build-arg PYTHON_VERSION="3.8.8" \
    --build-arg BUILD_DATE=$(date +'%Y-%m-%d') \
    -t base_env:openblas

#!/bin/bash
docker build . \
    --no-cache \
    --build-arg BASE_IMAGE="jupyter/minimal-notebook" \
    --build-arg PYTHON_VERSION="3.8.8" \
    --build-arg BLAS="mkl" \
    --build-arg BUILD_DATE=$(date +'%Y-%m-%d') \
    -t base_env:mkl
