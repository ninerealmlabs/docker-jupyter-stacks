# Introduction

[![Scheduled Build](https://github.com/ninerealmlabs/docker-jupyter-stacks/actions/workflows/1-build-stack.yaml/badge.svg?event=schedule)](https://github.com/ninerealmlabs/docker-jupyter-stacks/actions/workflows/1-build-stack.yaml)

This repo contains the source files for juptyer containers based on [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks).

> ⚠️ Deprecation Notice: No longer updating Dockerhub repository ⚠️
>
> Due to March 2023 removal of Docker's free Teams organization & history of price changes,
> images will no longer be pushed to DockerHub.  
> Please use `ghcr.io/ninerealmlabs/<image-name>:<tag>`

- [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Image dependencies / inheritance](#image-dependencies--inheritance)
  - [Features](#features)
  - [Versioning](#versioning)
  - [Development](#development)
    - [Build](#build)
      - [Build Single Image](#build-single-image)
      - [Build Stack](#build-stack)
    - [Push to Registry](#push-to-registry)

## Prerequisites

If unfamiliar with docker see our [Intro to Docker tutorial](./docs/intro-to-docker.md)

## Quick Start

1. Create/edit a `.env` file in project root to specify image and local path to be mounted

   ```sh
   IMG_NAME="ninerealmlabs/ds-env:python-3.10"
   MOUNT_PATH="~/Documents"
   ```

2. Launch locally with `docker-compose up -d` from project root.
3. View URL and token with `docker logs <IMAGENAME>`
4. Run `docker-compose down` to tear down the docker container

## Image dependencies / inheritance

```txt
base-env - customizes `jupyter/minimal-notebook`
  └ ds-env - from `base-env`, catchup `jupyter/scipy-notebook` + customizations
      ├ ts-env  - adds packages for timeseries analysis & forecasting
      └ nlp-env - add packages for text analysis & NLP modeling
          └ web-env - add packages/binaries for web scraping, including a chromedriver/geckodriver binary
```

_Images may have compatibility issues preventing builds depending_
_on platform architecture and python version._

> If image dependencies change, they must be reflected in:
>
> - [./README.md (at repo root)](./README.md)
> - [./scripts/dependencies.txt](./scripts/dependencies.txt)
> - [./tests/images-hierarcy.py](./tests/images-hierarcy.py)
> - [./.github/workflows/2-image-dependencies.yaml](./.github/workflows/2-image-dependencies.yaml)
> - [./.github/workflows/hub-overview.yaml](./.github/workflows/hub-overview.yaml)

## Features

- Images are set to load JupyterLabs, but the standard notebook interface is also available through the menus
- Included in the image is [jupytext](https://jupytext.readthedocs.io/en/latest/introduction.html),
  allowing concurrent .ipynb and .py development
- Jupyterlab-git allows use of git repos from within JupyterLab

## Versioning

Images are tagged by _python version_ and _python version_-_git hash_
Since images are automatically build on a timer, it is possible to have newer images
overwrite older images if there has been no new activity in the git repo.

**Notes:**

- `conda` pins are implemented dynamically in build to stabilize the environment around specific constraints:
  - Python version {major}.{minor}
  <!-- - `numpy` version {major}.{minor} -- version number specified in `environment.yaml` -->
  <!-- - `blas` -- BLAS is set at build time; defaults to `openblas`.
         To build with `MKL`, set `--build-arg BLAS=` -->

<!-- ## Known Issues -->

## Development

### Build

Images are built using [docker buildx](https://docs.docker.com/buildx/working-with-buildx/#overview),
which provides support for multi-architecture/multi-platform builds.
Images are automatically tagged with python version and short git hash.
Build scripts assume that the output image name is the same as the source folder name under `/src`

#### Build Single Image

To update a _single_ image, run the `build.sh` script.
_Remember, images have inheritance and updating a single image will not (necessarily) update the_
_packages inherited from the source image!_

`build.sh` takes the following keyword arguments in `flag=value` format:
| `short flag` | `long flag` | `default value` |
| --- | --- | --- |
| -p | --platform | `linux/amd64,linux/arm64` |
| -s | --source | **required** |
| -r | --registry | _blank / no default_ |
| -i | --image_name | **required** |
| -v | --python_version | `3.10.*` |
| | --push | `true` if present |
| | --clean | `true` if present |
| | --debug | `true` if present |

- `platform` defines CPU architecture (`linux/amd64`, `linux/arm64`, etc.)
- `source` is the source image to build from. This can be provide as full `<registry>/<image>:<tag>` format.
- `registry` is the dockerhub (or other container registry) to push to.
- `image_name` is name of the output image.
   The build script assumes the Dockerfile and required materials are in the <image_name> subdirectory under `/src`
- `python_version` is the python version to pin
- If present, `--push` will push to registry; otherwise, images will attempt to load locally
- If present, `--clean` will remove the local images once built
- If present, `--debug` will add debug printouts

> _Notes:_
>
> - If multiple architectures are provided, it is not possible to load locally.
>   In this case, both `--registry=<registry>` and `--push` are required
> - If `--push` is enabled, it assumes the current CLI session has `docker login` privileges

Examples:

```sh
# build 'base-env' locally with python 3.10
bash ./scripts/build.sh --source="jupyter/minimal-notebook" --image_name="base-env" -v="3.10.*"

# build 'ds-env' (note: this assumes that 'base-env' is also available locally); push to `ninerealmlabs` registry
bash ./scripts/build.sh --source="base-env:python-3.10" --registry="ninerealmlabs" --image_name="ds-env" --push

# build multi-arch image (_must_ push b/c of multiarch build)
bash ./scripts/build.sh -p="linux/amd64,linux/arm64" -b="base-env:python38" -r="ninerealmlabs" -i="ds-env" --push
```

#### Build Stack

To build all images in the stack, run `bash ./scripts/build-stack.sh` from project root.

- Consider whether to update the python version(s) specified
- Review/Update dependencies in `./scripts/dependencies.txt`
- Review/Update dependencies in `./tests/images_hierarcy.py`

`build-stack.sh` takes the following keyword arguments in `flag=value` format:
| `short flag` | `long flag` | `default value` |
| :---: | :---: | :---: |
| -p | --platform | `linux/amd64,linux/arm64` |
| -s | --source | `jupyter/minimal-notebook` |
| -r | --registry | _blank / no default_ |
| -p | --push | `true` if present |
| -c | --clean | `true` if present |
| | --debug | `true` if present |

- `platform` defines CPU architecture (`linux/amd64`, `linux/arm64`, etc.)
- `registry` is the dockerhub (or other container registry) to push to. REGISTRY must be provided.
- If present, `--push` will push to registry; otherwise, images will load locally
- If present, `--clean` will remove the local images once built
- If present, `--debug` will add debug printouts

> _Notes:_
>
> - If multiple architectures are provided, it is not possible to load locally.
>   In this case, both `--registry=<registry>` and `--push` are required
> - If `--push` is enabled, it assumes the current CLI session has `docker login` privileges

Examples:

```sh
# build all images locally - only a single platform can be used
bash ./scripts/build-stack.sh --platform="linux/amd64" --registry="ninerealmlabs"

# build all images, push to `ninerealmlabs` registry, and clean
bash ./scripts/build-stack.sh --registry="ninerealmlabs" --push --clean

# build multi-arch images (_must_ push)
bash ./scripts/build-stack.sh -p="linux/amd64,linux/arm64" -r="ninerealmlabs" --push
```

### Push to Registry

Build scripts include options to push.
If you build local images and later decide to push to your registry:

1. Tag images with `docker tag <imagename> <registry>/<imagename>:<new tag>`
2. Log in with `docker login` and provide username and password/token when prompted
3. Push images and all new tags to registry with `docker push <registry>/<imagename>`

See also [tag-and-push.sh](./scripts/tag-and-push.sh)
