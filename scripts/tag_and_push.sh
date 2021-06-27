#!/bin/bash
echo "Have you logged in with `docker login`?"

REGISTRY="ninerealmlabs"

PYTHON_VERSION=$()
# tag: python-version as version
docker tag base_env ${REGISTRY}/base_env:${PYTHON_VERSION}
docker tag ds_env ${REGISTRY}/ds_env:${PYTHON_VERSION}
docker tag forecast_env ${REGISTRY}/forecast_env:${PYTHON_VERSION}
docker tag nlp_env ${REGISTRY}/nlp_env:${PYTHON_VERSION}
docker tag pytorch_env ${REGISTRY}/pytorch_env:${PYTHON_VERSION}
docker tag recommender_env ${REGISTRY}/recommender_env:${PYTHON_VERSION}
docker tag web_env ${REGISTRY}/web_env:${PYTHON_VERSION}

# tag: latest  # should automatically be applied, but force to be sure
docker tag base_env ${REGISTRY}/base_env:latest
docker tag ds_env ${REGISTRY}/ds_env:latest
docker tag forecast_env ${REGISTRY}/forecast_env:latest
docker tag nlp_env ${REGISTRY}/nlp_env:latest
docker tag pytorch_env ${REGISTRY}/pytorch_env:latest
docker tag recommender_env ${REGISTRY}/recommender_env:latest
docker tag web_env ${REGISTRY}/web_env:latest

echo "Tag complete."


echo "Pushing to registry..."
# Docker 19.*: pushing without explicity tag will push all tags

# push images
docker push azureregistrypoc.azurecr.io/base_env
docker push azureregistrypoc.azurecr.io/ds_env
docker push azureregistrypoc.azurecr.io/clv_env
docker push azureregistrypoc.azurecr.io/forecast_env
docker push azureregistrypoc.azurecr.io/nlp_env
docker push azureregistrypoc.azurecr.io/pytorch_env
docker push azureregistrypoc.azurecr.io/recommender_env
docker push azureregistrypoc.azurecr.io/web_env

echo "`date` -- Push complete."