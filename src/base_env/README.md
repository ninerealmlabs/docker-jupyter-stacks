# Base

JupyterLab environment designed as a base image.
Built from [jupyter/docker-stacks/minimal-notebook](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook),
with additional customization to the "jupyterhub OS" to allow multiple environments,
pre-install jupyterlab extensions, and standardize configuration for upstream images.

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)

## Versioning

As this is a base image, we tag by _jupyterlab version_.
Upstream images will pin to python versions, or python-package versions.

**Notes:**

- `conda` pins are implemented dynamically in build to stabilize the environment around 3 main constraints:
  1. Python version {major}.{minor}
  2. `numpy` version {major}.{minor} -- version number specified in `environment.yml`
       <!-- 3. `blas` -->
     <!-- * BLAS is set at build time; defaults to `openblas`.  To build with `MKL`, set `--build-arg BLAS=` -->

**To Do:**

- pin blas (openblas vs mkl). see:
  - https://docs.anaconda.com/mkl-optimizations/index.html
  - https://conda.io/projects/conda/en/latest/user-guide/concepts/packages.html
  - https://github.com/conda-forge/numpy-feedstock/issues/108

## Image dependencies / inheritance

```txt
base_env
  └ ds_env
      ├ clvmodels_env
      ├ nlpmodels_env
      ├ pytorch_env
      │   └ forecastmodels_env
      ├ recommendermodels_env
      └ webmodels_env
```
