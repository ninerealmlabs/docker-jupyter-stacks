# Base

JupyterLab environment designed as a base image.
Built from [jupyter/docker-stacks/minimal-notebook](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook),
with additional customization to the "jupyterhub OS" to allow multiple environments,
pre-install jupyterlab extensions, and standardize configuration for upstream images.

For package details, see [`environment.yaml`](./environment.yaml) and [`requirements.txt`](./requirements.txt)

## Versioning

As this is a base image, we tag by _jupyterlab version_.
Upstream images will pin to python versions, or python-package versions.

**Notes:**

- `conda` pins are implemented dynamically in build to stabilize the environment around specific constraints:
  1. Python version {major}.{minor}
  2. `numpy` version {major}.{minor} -- version number specified in `environment.yaml`
       <!-- 3. `blas` -->
     <!-- * BLAS is set at build time; defaults to `openblas`.  To build with `MKL`, set `--build-arg BLAS=` -->

## Image dependencies / inheritance

```txt
base-env
  └ ds-env
      ├ forecastmodels-env
      ├ nlpmodels-env
      ├ pytorch-env
      ├ recommendermodels-env
      └ webmodels-env
```
