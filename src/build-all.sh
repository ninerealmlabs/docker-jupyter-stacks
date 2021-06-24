#!/bin/bash

# get today's date and update `build-compose.yml`
DATE=$(date "+%Y%m%d")
sed -i.deleteme "s|BUILD_DATE:.*$|BUILD_DATE: ${DATE}|g" ./docker-build.yml
rm *.deleteme

docker-compose -f ./docker-build.yml build --no-cache