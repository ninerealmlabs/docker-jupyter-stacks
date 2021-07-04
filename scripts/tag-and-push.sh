#!/bin/bash
echo "Have you logged in with `docker login`?"


REGISTRY="ninerealmlabs"


# tag: python-version as version
for PYTHON_VERSION in "3.7.*" "3.8.*" "3.9.*"; do

    TAG_VERSION=${PYTHON_VERSION}
    if [[ ${TAG_VERSION: -1} == "*" ]]; then
        TAG_VERSION=${TAG_VERSION: 0:${#TAG_VERSION}-2}
    fi
    echo ${TAG_VERSION}

    docker tag base_env ${REGISTRY}/base_env:${TAG_VERSION}
    docker tag ds_env ${REGISTRY}/ds_env:${TAG_VERSION}
    docker tag forecast_env ${REGISTRY}/forecast_env:${TAG_VERSION}
    docker tag nlp_env ${REGISTRY}/nlp_env:${TAG_VERSION}
    docker tag pytorch_env ${REGISTRY}/pytorch_env:${TAG_VERSION}
    docker tag web_env ${REGISTRY}/web_env:${TAG_VERSION}

done

# tag: git commit sha
SHORT=$(git show --oneline | awk '{print $1}')
FULL=$(git rev-parse HEAD)

docker tag base_env ${REGISTRY}/base_env:${SHORT}
docker tag ds_env ${REGISTRY}/ds_env:${SHORT}
docker tag forecast_env ${REGISTRY}/forecast_env:${SHORT}
docker tag nlp_env ${REGISTRY}/nlp_env:${SHORT}
docker tag pytorch_env ${REGISTRY}/pytorch_env:${SHORT}
docker tag web_env ${REGISTRY}/web_env:${SHORT}

echo "Tag complete."

echo "Pushing to registry..."
# Docker 19.*: pushing without explicity tag will push all tags

# push images
docker push ${REGISTRY}/base_env
docker push ${REGISTRY}/ds_env
docker push ${REGISTRY}/forecast_env
docker push ${REGISTRY}/nlp_env
docker push ${REGISTRY}/pytorch_env
docker push ${REGISTRY}/web_env

echo "`date` -- Push complete."