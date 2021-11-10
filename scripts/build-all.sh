#!/bin/bash

# "fake" keyword arguments: https://unix.stackexchange.com/questions/129391/passing-named-arguments-to-shell-scripts
while [ $# -gt 0 ]; do
  case "$1" in
    -p=* | --platform=*)
      ## Architecture/Platform for buildx
      PLATFORM="${1#*=}"
      ;;
    -r=* | --registry=*)
      ## Provide name of registry / owner
      REGISTRY="${1#*=}"
      ;;
    --push)
      ## Do you want to push to registry?
      PUSH=true
      ;;
    --clean)
      ## Do you want to remove local images when done?
      CLEAN=true
      ;;
    *)
      printf "*** Error: Invalid argument. Must use an '=' when passing args? ***\n"
      exit 1
      ;;
  esac
  shift
done

# PLATFORM=${PLATFORM:-"linux/amd64"}
PLATFORM=${PLATFORM:-"linux/amd64,linux/arm64"}
PUSH=${PUSH:-false}
CLEAN=${CLEAN:-false}

## do not set defaults for BASE_IMAGE or REGISTRY
## REGISTRY is optional (if not provided will build local, assuming single-arch build)
# REGISTRY=${REGISTRY:-ninerealmlabs} ## do not set default

# if registry not provided/empty
if [[ ${#REGISTRY} = 0 ]]; then
  # can only provide single platform (i.e., local) to build
  if [[ $(echo ${PLATFORM} | tr -cd , | wc -c | xargs) > 0 ]]; then
    printf "*** Error: No registry provided, so will try to load locally. ***\n"
    printf "*** Error: Cannot load multi-arch/multi-platform builds locally. ***\n"
  fi
  # cannot push w/o registry
  if ${PUSH}; then
    printf "*** Error: Cannot push without registry. ***\n"
  fi
  printf "*** Run with 'build-all.sh -r=<REGISTRY>' ***\n"
  exit 1
# Add trailing slash to REGISTRY if not empty
else # [[ ${#REGISTRY} > 0 ]]; then
  REGISTRY_="${REGISTRY}/"
fi

if ${PUSH}; then
  _PUSH="--push"
fi

# Collect current docker images to preserve post-clean
if ${CLEAN}; then
  # IMAGELIST=$(docker image ls -a --format {{.ID}})
  rm -f .imagelist \
    && printf "%s\n" $(docker image ls -a --format {{.ID}}) > .imagelist
fi

##############################################################################
# *** Dependency management ***
# Neither `docker-compose` nor `docker buildx bake` support dependency
# management at build time in the manner this stack requires.
# Therefore, we'll have to build in series
##############################################################################

# read in dependencies excluding comments and trim whitespace
DICT=$(grep -v '^#' "$(dirname $0)/dependencies" | tr -d '[:space:]')

function dict_items() {
  arr=$(echo "${DICT:1:${#DICT}-2}" | tr "," "\n")
  for i in $arr; do
    value="${i##*:}"
    key="${i%%:*}"
    echo "${key}: ${value}"
  done
}
function dict_keys() {
  arr=$(echo "${DICT:1:${#DICT}-2}" | tr "," "\n")
  for i in $arr; do
    # value="${i##*|}"
    key="${i%%:*}"
    echo "${key}"
  done
}
function dict_values() {
  arr=$(echo "${DICT:1:${#DICT}-2}" | tr "," "\n")
  for i in $arr; do
    value="${i##*:}"
    # key="${i%%|*}"
    echo "${value}"
  done
}
function get_value() {
  echo "$(expr "${DICT}" : ".*,$1:\([^,]*\),.*")"
}

### can't parallelize; scripts must be run in order due to image dependencies
for PYTHON_VERSION in "3.7.*" "3.8.*" "3.9.*"; do
  echo "Building images for ${PYTHON_VERSION}"

  # Docker doesn't like `.*` for version tags, so truncate from tag
  TAG_VERSION="${PYTHON_VERSION}"
  if [[ ${TAG_VERSION: -1} == "*" ]]; then
    TAG_VERSION=${TAG_VERSION:0:${#TAG_VERSION}-2}
  fi

  # for debug
  echo "PLATFORM: ${PLATFORM}"
  echo "REGISTRY: ${REGISTRY}"
  echo "REGISTRY_: ${REGISTRY_}"
  # echo "IMAGE_NAME: ${IMAGE_NAME}"
  echo "PYTHON_VERSION: ${PYTHON_VERSION}"
  echo "TAG_VERSION: ${TAG_VERSION}"
  echo "PUSH: ${PUSH}"
  echo "_PUSH: ${_PUSH}"

  # for DRY, we'll just re-use `build.sh`
  IMAGE_NAME="base_env"
  BASE_IMAGE="jupyter/minimal-notebook"
  echo "Building ${IMAGE_NAME} from ${BASE_IMAGE}"
  $(dirname $0)/build.sh \
    --platform=${PLATFORM} \
    --base_image="jupyter/minimal-notebook" \
    --registry=${REGISTRY} \
    --image_name=${IMAGE_NAME} \
    --python_version=${PYTHON_VERSION} \
    ${_PUSH}

  for IMAGE_NAME in $(dict_keys); do
    BASE_IMAGE=$(get_value ${IMAGE_NAME})
    echo "Building ${IMAGE_NAME} from ${BASE_IMAGE}"
    $(dirname $0)/build.sh \
      --platform=${PLATFORM} \
      --base_image=${REGISTRY_}${BASE_IMAGE}:python-${TAG_VERSION} \
      --registry=${REGISTRY} \
      --image_name=${IMAGE_NAME} \
      --python_version=${PYTHON_VERSION} \
      ${_PUSH}
  done

done
echo "Build complete."

if ${CLEAN}; then
  # temporarily save list of images with new images
  rm -f .imagelist2 \
    && printf "%s\n" $(docker image ls -a --format {{.ID}}) > .imagelist2
  # remove only the new images we just build
  docker image rm $(comm -13 .imagelist .imagelist2)
  # remove our tempfiles
  rm -f .imagelist .imagelist2
fi
