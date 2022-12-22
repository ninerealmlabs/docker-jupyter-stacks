#!/bin/bash
printf "\e[33m%s\e[0m\n" "Have you logged in with 'docker login'?"

REGISTRY="ninerealmlabs"

# tag: python-version as version
IMAGES=("base-env" "ds-env" "ts-env" "nlp-env" "web-env")
for IMAGE_NAME in "${IMAGES[@]}"; do
  printf "\e[32m%s\e[0m\n" "Tagging and pushing ${IMAGE_NAME} to registry..."

  for PYTHON_VERSION in "3.8.*" "3.9.*" "3.10.*"; do
    VERSION_TAG="python-${PYTHON_VERSION/'.*'/}"
    SHA_TAG=$(git show --oneline | awk '{print $1}')
    SHORT_TAG="${IMAGE_NAME}:${VERSION_TAG}"
    LONG_TAG="${IMAGE_NAME}:${VERSION_TAG}-${SHA_TAG}"

    docker tag "${SHORT_TAG}" "${REGISTRY}/${SHORT_TAG}"
    docker tag "${LONG_TAG}" "${REGISTRY}/${LONG_TAG}"
  done

  # Docker 19.*: pushing without explicity tag will push all tags
  docker push "${REGISTRY}/${IMAGE_NAME}"
  printf "\e[32m%s\e[0m\n" "$(date) -- ${IMAGE_NAME} push complete."

done
