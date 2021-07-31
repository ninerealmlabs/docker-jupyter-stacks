# Introduction

This repo contains the source files for 'Data Science Anywhere' Data Science environments.  The base 'ds_env' image is modeled after [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) scipy-notebook.

## Installation

1. Installation process:
    * [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
    * [Getting started with Docker](https://docs.docker.com/)
2. Clone this repo

## Launch

1. Create/edit a `.env` file in project root to specify image and local path to be mounted

   ```sh
   IMG_NAME="ninerealmlabs/ds_env:python-3.8"
   MOUNT_PATH="~"
   ```

2. Launch locally with `docker-compose up -d` from project root.
3. View URL and token with `docker logs <IMAGENAME>`
4. Run `docker-compose down` to tear down the docker container

## Build

Images are built using [docker buildx](https://docs.docker.com/buildx/working-with-buildx/#overview), which provides support for multi-architecture/multi-platform builds.
Images are automatically tagged with python version and short git sha.
Build scripts assume that the output image name is the same as the source folder name under /src

> To update the default version of python, run `/scripts/update_default_python.sh` from project root and provide the semver version
>
> ```sh
> bash ./scripts/update_default_python.sh "3.9.*"
> ```

### Build Single Image

To update a _single_ image, run the `build.sh` script.
_Remember, images have inheritance and updating a single image will not (necessarily) update the packages inherited from the source image!_

`build.sh` takes the following keyword arguments in `flag=value` format:
| `short flag`  | `long flag`   | `default value`   |
| ---           | ---           | ---               |
| -p            | --platform    | "linux/amd64"     |
| -b            | --base_image  | _depends on image_    |
| -r            | --registry    | _blank / no default_  |
| -i            | --image_name  | _blank / no default_  |
| -v            | --python_version | "3.8.*"        |
|               | --push        | `true` if present |
|               | --clean       | `true` if present |

* `platform` is for multi-architecture builds (amd64, arm64/aarch64, etc.), assuming jupyter/docker-stacks [implements this](https://github.com/jupyter/docker-stacks/pull/1368)
  * If loading locally, only a single architecture can be provided, otherwise both `--registry` and `--push` are required
* `base_image` is the source image to build from.  This can be provide as full <registry>/<image>:<tag> format.
* `registry` is the dockerhub (or other container registry) to push to.
* `image_name` is name of the output image.  The build script assumes the Dockerfile and required materials are in a subdirectory under /src with called <image_name>
* `python_version` is the python version to pin
* If present, `--push` will push to registry; otherwise, images will load locally
* If present, `--clean` will remove the local images once built

Examples:

```
# build 'ds_env' locally (note: this assumes that 'base_env' is also available locally)
bash ./scripts/build.sh --base_image="base_env:python-3.8" --image_name="ds_env"

# build 'ds_env' to use Python 3.9.4, push to `ninerealmlabs` registry
bash ./scripts/build.sh --base_image="base_env:python-3.8" --registry="ninerealmlabs" --image_name="ds_env" --push

# build multi-arch image (_must_ push)
bash ./scripts/build.sh -p="linux/amd64,linux/arm64" -b="base_env:python-3.8" -r="ninerealmlabs" -i="ds_env" --push
```

### Build Stack

To build all images in the stack, run `bash ./scripts/build-all.sh` from project root.

* Consider whether to update the python version(s) specified in the for loop.
* _Update dependencies in `./scripts/dependencies`_ if required

> **Note:** `docker-build.yml` is deprecated and we prefer `build-all.sh`.  However, it should still function if the build args are set appropriately.

`build-all.sh` takes the following keyword arguments in `flag=value` format:
| `short flag`  | `long flag`   | `default value`   |
| :---:         | :---:         | :---:             |
| -p            | --platform    | "linux/amd64"     |
| -r            | --registry    | ninerealmlabs     |
| -p            | --push        | `true` if present |
| -c            | --clean       | `true` if present |

* `platform` is for multi-architecture builds (amd64, arm64/aarch64, etc.), assuming jupyter/docker-stacks [implements this](https://github.com/jupyter/docker-stacks/pull/1368)
  * If loading locally, only a single architecture can be provided, otherwise both `--registry` and `--push` are required
* `registry` is the dockerhub (or other container registry) to push to.  REGISTRY must be provided.
* If present, `--push` will push to registry; otherwise, images will load locally
* If present, `--clean` will remove the local images once built

Examples:

```sh
# build all images locally
bash /scripts/build-all.sh --REGISTRY="ninerealmlabs"

# build all images, push to `ninerealmlabs` registry, and clean
bash /scripts/build-all.sh --REGISTRY="ninerealmlabs" --PUSH --CLEAN

# build multi-arch images (_must_ push)
bash /scripts/build-all.sh -a="linux/amd64,linux/arm64" -r="ninerealmlabs" -p
```

## Push to Registry

Build scripts include options to push.  If you build local images and later decide to push to your registry:

1. Tag images with `docker tag <imagename> <registry>/<imagename>`
2. Log in with `docker login` and provide username and password/token when prompted
3. Push images to registry with `docker push <registry>/<imagename>`

## Image dependencies / inheritance

```txt
`base_env`
  └ `ds_env`
      ├ `nlp_env`
      ├ `pytorch_env`
      │   └ `forecast_env`
      └ `web_env`
```

## Features

* Images are set to load JupyterLabs, but the standard notebook interface is also available through the menus
* Included in the image is [jupytext](https://jupytext.readthedocs.io/en/latest/introduction.html), allowing concurrent .ipynb and .py develpment
* Jupyterlab-git allows use of git repos from within JupyterLab

## Known Issues

**27 June 2021**

* [base_env] _jupyter-sql_ extensions are currently not update for JupyterLab 3.  Docker images will need to be rebuilt if/when the bugfixes/patches are released.
* [forecast_env] `greykite` requires `fbprophet` library and has tight dependencies; `fbprophet` will not build on python 3.9. See https://github.com/linkedin/greykite/issues/11
* [web_env] `scrapy` is not available on `conda` or `conda-forge` for python 3.9.*.  See https://github.com/scrapy/scrapy/issues/5195

## Roadmap

* [ ] Add ARM64 architectures (pending jupyter/docker-stacks support)
* [ ] BLAS-specific images

<!-- * [ ] Add Tensorflow/Keras -->
<!-- * [ ] Add CUDA and ROCm -->
