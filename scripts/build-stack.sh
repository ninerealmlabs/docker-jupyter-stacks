#!/bin/bash

##############################################################################
# *** Defaults ***
##############################################################################
DEFAULT_PYTHONS=(3.8.* 3.9.* 3.10.*)
# DEFAULT_PLATFORM="linux/amd64"
DEFAULT_PLATFORM="linux/amd64,linux/arm64"
DEFAULT_SOURCE="jupyter/minimal-notebook"
ROOT_IMAGE="base-env"

##############################################################################
# *** Help ***
##############################################################################
read -r -d '' usage <<EOF
usage: $(basename "$0") [optargs]
requires 'dependencies' file in same directory as $(basename "$0") script
assumes 'scripts' dir and 'src' dir are sibling-directories

optargs:
  -h|--help             prints help
  -p|--platform         pass platform(s) as str; default "${DEFAULT_PLATFORM}"
  -s|--source           pass source image as str; default "${DEFAULT_SOURCE}"
  -r|--registry         pass destination registry as str;
                        must be present for multi-arch builds or if --push
     --push             will push to registry if present
     --clean            will clean new images from local docker
     --debug            adds extra debugging messages to console

note: $(basename "$0") takes keyword arguments in 'flag=value' format!

example:
$(basename "$0") \
--platform="${DEFAULT_PLATFORM}" \
--registry="myregistry" \
--push
EOF

##############################################################################
# *** Parse Args ***
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

### arg validation for REGISTRY/PLATFORM/PUSH handled in build.sh ###

# List currently-existing docker images to preserve post-clean
# Cleaning is handled outside of the build loop(s)
if [[ -n ${CLEAN:+x} ]]; then
  # IMAGELIST=$(docker image ls -a --format {{.ID}})
  rm -f .imagelist \
    && printf "%s\n" "$(docker image ls -a --format '{{.ID}}')" > .imagelist
fi

##############################################################################
# *** Dependency management ***
# Define parent : child relationship in 'dependencies.txt' file
# located in same directory as build scripts
# 'dependencies.txt' should have a single parent : child relationship per line
##############################################################################
function dict_keys() {
  # dict_keys "${DICT[@]}"
  # dict array is expanded when passed as parameters; each param is single key:value pair
  for item in "$@"; do
    echo "${item%%:*}"
  done
}
function dict_values() {
  # dict_values "${DICT[@]}"
  # dict array is expanded when passed as parameters; each param is single key:value pair
  for item in "$@"; do
    echo "${item##*:}"
  done
}
function get_value() {
  # get_values "KEY" "${DICT[@]}"
  # dict array is expanded when passed as parameters; each param is single key:value pair
  local KEY="$1"
  shift
  for item in "$@"; do
    [[ "${item%%:*}" = "$KEY" ]] && echo "${item##*:}"
  done
}

##############################################################################
# *** Call Builder ***
##############################################################################
STATUS_ARRAY=()
for PYTHON_VERSION in "${DEFAULT_PYTHONS[@]}"; do
  printf "\e[1;32m%s\e[0m\n" "Building image stack for python ${PYTHON_VERSION} ..."

  # Docker doesn't like '.*' for version tags, so remove from tag
  VERSION_TAG="python-${PYTHON_VERSION/'.*'/}"
  SHA_TAG=$(git rev-parse --short HEAD)

  # Build root-of-build-tree separate from dependencies loop
  if [[ -n ${SOURCE_IMAGE:+x} ]]; then
    SOURCE_TAG="${SOURCE_IMAGE}:latest"
  else
    SOURCE_TAG="${DEFAULT_SOURCE}:latest"
  fi

  IMAGE_NAME="${ROOT_IMAGE}"

  args=()
  [[ -n ${PLATFORM:+x} ]] \
    && args+=(--platform="${PLATFORM}") \
    || args+=(--platform="${DEFAULT_PLATFORM}")
  args+=(--source="${SOURCE_TAG}")
  [[ -n ${REGISTRY:+x} ]] && args+=(--registry="${REGISTRY}")
  args+=(--image_name="${IMAGE_NAME}")
  args+=(--python_version="${PYTHON_VERSION}")
  [[ -n ${PUSH:+x} ]] && args+=(--push)
  [[ -n ${DEBUG:+x} ]] && args+=(--debug)
  # do not include clean in indivdual build.sh args
  [[ -n ${DEBUG:+x} ]] && printf "\e[1;36m%s\e[0m " "build-stack args:" && printf "\e[36m%s\e[0m\n" "${args[*]}"

  # call build script
  "$(dirname "$0")"/build.sh "${args[@]}"
  BUILD_STATUS="$?"
  if [[ "${BUILD_STATUS}" -eq 0 ]]; then
    STATUS_ARRAY+=("Success: ${IMAGE_NAME}:${VERSION_TAG}")
  else
    STATUS_ARRAY+=("Failure: ${IMAGE_NAME}:${VERSION_TAG}")
  fi
  unset args
  unset SOURCE_TAG
  unset IMAGE_NAME
  unset BUILD_STATUS

  ### read in dependencies excluding comments and trim whitespace
  # NOTE: for zsh, remove '-a' option
  IFS=$'\n' read -r -d '' -a  DEPENDENCY_DICT <<< "$(grep -v '^#' "$(dirname "$0")/dependencies.txt" | tr -d ' ')"

  for IMAGE_NAME in $(dict_keys "${DEPENDENCY_DICT[@]}"); do
    PARENT_IMAGE=$(get_value "${IMAGE_NAME}" "${DEPENDENCY_DICT[@]}")
    PARENT_TAG="${PARENT_IMAGE}:${VERSION_TAG}-${SHA_TAG}"
    [[ -n ${REGISTRY:+x} ]] && PARENT_TAG="${REGISTRY}/${PARENT_TAG}"

    args=()
    [[ -n ${PLATFORM:+x} ]] && args+=(--platform="${PLATFORM}") || args+=(--platform="${DEFAULT_PLATFORM}")
    args+=(--source="${PARENT_TAG}")
    [[ -n ${REGISTRY:+x} ]] && args+=(--registry="${REGISTRY}")
    args+=(--image_name="${IMAGE_NAME}")
    args+=(--python_version="${PYTHON_VERSION}")
    [[ -n ${PUSH:+x} ]] && args+=(--push)
    [[ -n ${DEBUG:+x} ]] && args+=(--debug)
    # do not include clean in indivdual build.sh args
    [[ -n ${DEBUG:+x} ]] && printf "\e[1;36m%s\e[0m " "build-stack args:" && printf "\e[36m%s\e[0m\n" "${args[*]}"

    # call build script
    "$(dirname "$0")"/build.sh "${args[@]}"
    BUILD_STATUS="$?"
    if [[ "${BUILD_STATUS}" -eq 0 ]]; then
      STATUS_ARRAY+=("Success: ${IMAGE_NAME}:${VERSION_TAG}")
    else
      STATUS_ARRAY+=("Failure: ${IMAGE_NAME}:${VERSION_TAG}")
    fi
    unset args
    unset PARENT_IMAGE
    unset PARENT_TAG
    unset IMAGE_NAME
    unset BUILD_STATUS
  done
  unset DEPENDENCY_DICT
  unset PYTHON_VERSION
done

if [[ -n ${CLEAN:+x} ]]; then
  # temporarily save list of images with new images
  rm -f .imagelist2 \
    && printf "%s\n" "$(docker image ls -a --format '{{.ID}}')" > .imagelist2
  # remove only the new images we just build
  docker image rm "$(comm -13 .imagelist .imagelist2)"
  # remove our tempfiles
  rm -f .imagelist .imagelist2
fi

printf "\e[1;32m%s\e[0m\n" "Stack build complete:"
for STATUS in "${STATUS_ARRAY[@]}"; do
  [[ "${STATUS}" == Success* ]] && printf "\e[32m%s\e[0m\n" "${STATUS}"
  [[ "${STATUS}" == Failure* ]] && printf "\e[31m%s\e[0m\n" "${STATUS}"
done
