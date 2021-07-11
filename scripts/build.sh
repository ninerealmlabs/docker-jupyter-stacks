#!/bin/bash

# "fake" keyword arguments: https://unix.stackexchange.com/questions/129391/passing-named-arguments-to-shell-scripts
while [ $# -gt 0 ]; do
  case "$1" in
    -p=*|--platform=*)
      ## Architecture/Platform for buildx
      PLATFORM="${1#*=}"
      ;;
    -b=*|--base_image=*)
      ## Base image for build-arg
      BASE_IMAGE="${1#*=}"
      ;;
    -r=*|--registry=*)
      ## Provide name of registry / owner
      REGISTRY="${1#*=}"
      ;;
    -i=*|--image_name=*)
      ## Provide name of registry / owner
      IMAGE_NAME="${1#*=}"
      ;;
    -v=*|--python_version=*)
      ## Python version for build-arg
      PYTHON_VERSION="${1#*=}"
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
      printf "*** Error: Invalid argument. Did you use an '=' when passing args? ***\n"
      exit 1
  esac
  shift
done

PLATFORM=${PLATFORM:-"linux/amd64"}
PYTHON_VERSION=${PYTHON_VERSION:-3.8.*}
PUSH=${PUSH:-false}
CLEAN=${CLEAN:-false}

## do not set defaults for BASE_IMAGE or REGISTRY
## REGISTRY is optional (if not provided will build local, assuming single-arch build)
# REGISTRY=${REGISTRY:-ninerealmlabs} ## do not set default

# BASE_IMAGE must be provided
if [[ ${#BASE_IMAGE} = 0 ]]; then
    printf "*** Error: Must provide BASE_IMAGE. ***\n"
    exit 1
fi

# IMAGE_NAME must be provided
if [[ ${#IMAGE_NAME} = 0 ]]; then
    printf "*** Error: Must provide IMAGE_NAME. ***\n"
    exit 1
fi

# if REGISTRY not provided/empty
if [[ ${#REGISTRY} = 0 ]]; then
    # can only provide single platform (i.e., local) to build
    if [[ $(echo ${PLATFORM} | tr -cd , | wc -c | xargs) > 0 ]]; then
        printf "*** Error: No registry provided, so will try to load locally. ***\n"
        printf "*** Error: Cannot load multi-arch/multi-platform builds locally. ***\n"
        exit 1
    fi
    # cannot push w/o registry
    if ${PUSH}; then
        printf "*** Error: Cannot push without registry. ***\n"
        exit 1
    fi
# Add trailing slash to REGISTRY if not empty
else # [[ ${#REGISTRY} > 0 ]]; then
    REGISTRY_="${REGISTRY}/"
fi

if ${PUSH}; then
    _PUSH="--push"
else
    # if single-platform (as determined by 0 commas), then load locally
    if [[ $(echo ${PLATFORM} | tr -cd , | wc -c | xargs) = 0 ]]; then
        _PUSH="--load"
    else
        printf "*** Error: Cannot load multi-platform build locally.  Must push. ***\n"
        exit 1
    fi
fi

# Collect current docker images to preserve post-clean
if ${CLEAN}; then
    # IMAGELIST=$(docker image ls -a --format {{.ID}})
    rm -f .imagelist && \
    printf "%s\n" $(docker image ls -a --format {{.ID}})  > .imagelist
fi


# Docker doesn't like `.*` for version tags, so truncate from tag
TAG_VERSION="${PYTHON_VERSION}"
if [[ ${TAG_VERSION: -1} == "*" ]]; then
    TAG_VERSION=${TAG_VERSION: 0:${#TAG_VERSION}-2}
fi

# get git branch identifier for tags
GIT_REF=$(git rev-parse --abbrev-ref HEAD)
# get git commit identifier for tags
GIT_SHA=$(git rev-parse --short HEAD)
# GIT_SHA=$(git rev-parse HEAD)


# # for debug
# echo "PLATFORM: ${PLATFORM}"
# echo "BASE_IMAGE: ${BASE_IMAGE}"
# echo "REGISTRY: ${REGISTRY}"
# echo "REGISTRY_: ${REGISTRY_}"
# echo "IMAGE_NAME: ${IMAGE_NAME}"
# echo "PYTHON_VERSION: ${PYTHON_VERSION}"
# echo "TAG_VERSION: ${TAG_VERSION}"
# echo "GIT_REF: ${GIT_REF}"
# echo "GIT_SHA: ${GIT_SHA}"
# echo "PUSH: ${PUSH}"
# echo "_PUSH: ${_PUSH}"

# # if using local images, use `docker` driver
# # otherwise, use `docker-container` per defaults
# if [[ ${_PUSH} == "--load" ]]; then
#   docker buildx create --name mybuilder --driver docker --use
# fi

cd $(dirname $0)/../src/${IMAGE_NAME} && \
docker buildx bake \
-f docker-compose.yml \
--set *.platform=${PLATFORM} \
--set *.args.BASE_IMAGE=${BASE_IMAGE} \
--set *.args.PYTHON_VERSION=${PYTHON_VERSION} \
--set *.args.BUILD_DATE=$(date +'%Y-%m-%d') \
--set *.tags="${REGISTRY_}${IMAGE_NAME}:python-${TAG_VERSION}" \
--set *.tags="${REGISTRY_}${IMAGE_NAME}:python-${TAG_VERSION}-${GIT_SHA}" \
${_PUSH}

# --no-cache \

# # remove builder instance
# docker buildx rm mybuilder

if ${CLEAN}; then
    # temporarily save list of images with new images
    rm -f .imagelist2 && \
    printf "%s\n" $(docker image ls -a --format {{.ID}}) > .imagelist2
    # remove only the new images we just build
    docker image rm -f $(comm -13 .imagelist .imagelist2)
    # remove our tempfiles
    rm -f .imagelist .imagelist2

fi