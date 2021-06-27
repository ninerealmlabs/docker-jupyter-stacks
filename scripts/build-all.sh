#!/bin/bash

# # get today's date and update `build-compose.yml`
# DATE=$(date "+%Y%m%d")
# sed -i.deleteme "s|BUILD_DATE:.*$|BUILD_DATE: ${DATE}|g" ./docker-build.yml
# rm *.deleteme

# # docker-compose -f ./docker-build.yml build --no-cache

# for PYTHON_VERSION in "3.7.*" "3.8.*" "3.9.*"; do
#     echo "Building images for ${PYTHON_VERSION}"
#     sed -i.deleteme "s|PYTHON_VERSION:.*$|PYTHON_VERSION: ${PYTHON_VERSION}|g" ./docker-build.yml
#     rm *.deleteme

#     docker-compose -f ./docker-build.yml build --no-cache
# done;


### use each docker images's local build.sh to build
### do not parallelize; scripts must be run in order due to image dependencies
for PYTHON_VERSION in "3.7.*" "3.8.*" "3.9.*"; do
    echo "Building images for ${PYTHON_VERSION}"
    $(dirname $0)/../src/base_env/build.sh ${PYTHON_VERSION}

    $(dirname $0)/../src/ds_env/build.sh ${PYTHON_VERSION}

    $(dirname $0)/../src/nlp_env/build.sh ${PYTHON_VERSION}
    $(dirname $0)/../src/web_env/build.sh ${PYTHON_VERSION}

    $(dirname $0)/../src/pytorch_env/build.sh ${PYTHON_VERSION}
    $(dirname $0)/../src/forecast_env/build.sh ${PYTHON_VERSION}
done;
echo "Build complete."