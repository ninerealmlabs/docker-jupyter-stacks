#!/bin/bash

##############################################################################
# Defaults
##############################################################################
DEFAULT_PYTHON="3.10.*"
# DEFAULT_PLATFORM="linux/amd64"
DEFAULT_PLATFORM="linux/amd64,linux/arm64"

##############################################################################
# Help
##############################################################################
read -r -d '' usage <<EOF
usage: $(basename "$0") [optargs]
assumes 'scripts' dir and 'src' dir are sibling-directories

optargs:
  -h|--help             prints help
  -p|--platform         pass platform(s) as str: default "${DEFAULT_PLATFORM}"
  -s|--source           pass source image as str
  -r|--registry         pass destination registry as str;
                        must be present for multi-arch builds or if --push
  -i|--image_name       name for output image
  -v|--python_version   python version; default "${DEFAULT_PYTHON}"
     --push             will push to registry if present
     --clean            will clean new images from local docker
     --debug            adds extra debugging messages to console

note: $(basename "$0") takes keyword arguments in 'flag=value' format!

example:
$(basename "$0") \
--platform="linux/amd64,linux/arm64" \
--source="jupyter/minimal-notebook" \
--registry="myregistry" \
--image_name="base-env" \
--python_version="3.10.*" \
--push
EOF

##############################################################################
# Parse Args
# "fake" keyword arguments:
# https://unix.stackexchange.com/questions/129391/passing-named-arguments-to-shell-scripts
##############################################################################
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      ## Architecture/Platform for buildx
      echo "${usage}"
      exit 0
      ;;
    -p=* | --platform=*)
      ## Architecture/Platform for buildx
      PLATFORM="${1#*=}"
      ;;
    -s=* | --source=*)
      ## Base image for build-arg
      SOURCE_IMAGE="${1#*=}"
      ;;
    -r=* | --registry=*)
      ## Provide name of registry / owner
      REGISTRY="${1#*=}"
      ;;
    -i=* | --image_name=*)
      ## Provide name of registry / owner
      IMAGE_NAME="${1#*=}"
      ;;
    -v=* | --python_version=*)
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
    --debug)
      ## Do you want to remove local images when done?
      DEBUG=true
      ;;
    *)
      printf "\e[1;31m%s\e[0m\n" "Error: Unknown argument: '${1}'"
      printf "\e[1;31m%s\e[0m\n" "Try using '=' when passing args\n"
      exit 1
      ;;
  esac
  shift
done

# SOURCE_IMAGE must be provided
# if [[ ${#SOURCE_IMAGE} = 0 ]]; then
if [[ -z ${SOURCE_IMAGE:+x} ]]; then
  printf "\e[1;31m%s\e[0m\n" "Error: Must provide source."
  exit 1
fi

# IMAGE_NAME must be provided
# if [[ ${#IMAGE_NAME} = 0 ]]; then
if [[ -z ${IMAGE_NAME:+x} ]]; then
  printf "\e[1;31m%s\e[0m\n" "Error: Must provide image_name."
  exit 1
fi

# if registry not provided/empty
# if [[ ${#REGISTRY} = 0 ]]; then
if [[ -z ${REGISTRY:+x} ]]; then
  [[ -n ${DEBUG:+x} ]] && printf "\e[33m%s\e[0m\n" "Warning: No registry provided; will try to save output locally."
  # can only provide single platform (i.e., local) to build
  if [[ $(echo "${PLATFORM}" | tr -cd , | wc -c | xargs) -gt 0 ]]; then
    printf "\e[1;31m%s\e[0m\n" "Error: Cannot load multi-arch/platform builds locally."
    printf "\e[1;31m%s\e[0m\n" "Provide registry or change to single-platform build."
    printf "\e[1;31m%s\e[0m\n" "Platform: '${PLATFORM}'"
    exit 1
  fi
  # cannot push w/o registry
  if [[ -n ${PUSH:+x} ]]; then
    printf "\e[1;31m%s\e[0m\n" "Error: Cannot push without registry."
    exit 1
  fi
fi

# List currently-existing docker images to preserve post-clean
if [[ -n ${CLEAN:+x} ]]; then
  # IMAGELIST=$(docker image ls -a --format {{.ID}})
  rm -f .imagelist \
    && printf "%s\n" "$(docker image ls -a --format '{{.ID}}')" > .imagelist
fi

# Docker doesn't like '.*' for version tags, so truncate from tag
VERSION_TAG="python-${PYTHON_VERSION/'.*'/}"
# get git commit identifier for tags
SHA_TAG=$(git rev-parse --short HEAD)

SHORT_TAG="${IMAGE_NAME}:${VERSION_TAG}"
LONG_TAG="${IMAGE_NAME}:${VERSION_TAG}-${SHA_TAG}"
if [[ -n ${REGISTRY:+x} ]]; then
  SHORT_TAG="${REGISTRY}/${SHORT_TAG}"
  LONG_TAG="${REGISTRY}/${LONG_TAG}"
fi

# use default buildx builder to build from images loaded locally
# ref: https://github.com/moby/moby/issues/42893
docker buildx use default
# docker buildx create --name mybuilder --use

# printf "\e[1;36m%s\e[0m\n" "Building ${IMAGE_NAME} from ${SOURCE_IMAGE}"
printf "\e[32m%s\e[0m " "Building"
printf "\e[3;32m%s\e[0m " "${SHORT_TAG}"
printf "\e[32m%s\e[0m " "from"
printf "\e[3;32m%s\e[0m\n" "${SOURCE_IMAGE}"

# args=(-f docker-compose.yaml)
# args+=(--set "*.platform=${PLATFORM}")
# args+=(--set "*.args.SOURCE_IMAGE=${SOURCE_IMAGE}")
# args+=(--set "*.args.PYTHON_VERSION=${PYTHON_VERSION}")
# args+=(--set "*.args.BUILD_DATE=$(date +'%Y-%m-%d')")
# args+=(--set "*.args.GIT_COMMIT=${SHA_TAG}")
# args+=(--set "*.tags=${SHORT_TAG}")
# args+=(--set "*.tags=${LONG_TAG}")
# if [[ -n ${PUSH:+x} ]]; then
#   args+=(--push)
# else
#   args+=(--load)
# fi
#
# [[ -n ${DEBUG:+x} ]] \
#   && printf "\e[1;36m%s\e[0m " "bake args:" \
#   && printf "\e[36m%s\e[0m\n" "${args[*]}"
#
# # buildx bake
# cd "$(dirname "$0")/../src/${IMAGE_NAME}" && docker buildx bake "${args[@]}"
# unset args

args=()
args+=(--platform="${PLATFORM}")
args+=(--build-arg SOURCE_IMAGE="${SOURCE_IMAGE}")
args+=(--build-arg PYTHON_VERSION="${PYTHON_VERSION}")
args+=(--build-arg BUILD_DATE="$(date +'%Y-%m-%d')")
args+=(--build-arg GIT_COMMIT="${SHA_TAG}")
args+=(--tag "${SHORT_TAG}")
args+=(--tag "${LONG_TAG}")
args+=(--progress=tty)  # "plain" will show container output

if [[ -n ${PUSH:+x} ]]; then
  args+=(--push)
else
  args+=(--load)
fi

[[ -n ${DEBUG:+x} ]] \
  && printf "\e[1;36m%s\e[0m " "buildx args:" \
  && printf "\e[36m%s\e[0m\n" "${args[*]}"

# build
docker buildx build "${args[@]}" "$(dirname "$0")/../src/${IMAGE_NAME}"
BUILD_STATUS="$?"
unset args

if [[ "${BUILD_STATUS}" -eq 0 ]]; then
  printf "\e[1;32m%-8s\e[0m " "Success:"
  printf "\e[32m%s\e[0m\n" "${SHORT_TAG}"
else
  printf "\e[1;31m%-8s\e[0m " "Failure:"
  printf "\e[31m%s\e[0m\n" "${SHORT_TAG}"
fi
# # remove builder instance
# docker buildx rm mybuilder

if [[ -n ${CLEAN:+x} ]]; then
  # temporarily save list of images with new images
  rm -f .imagelist2 \
    && printf "%s\n" "$(docker image ls -a --format '{{.ID}}')" > .imagelist2
  # remove only the new images we just build
  docker image rm -f "$(comm -13 .imagelist .imagelist2)"
  # remove our tempfiles
  rm -f .imagelist .imagelist2
fi

exit "${BUILD_STATUS}"
