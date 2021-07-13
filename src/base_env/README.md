# Data Science

JupyterLab environment designed for general data analysis and ML, with the basic `numpy`, `pandas`, `scipy`, `scikit-learn` stack.

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)
See also [jupyter/docker-stacks/minimal-notebook](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook) for overall source image.
Version increases are python-version based, and will be sourced from `jupyter/minimal-notebook:python-{version}` tags.

**Notes:**
* `conda` pins are implemented dynamically in build to stabilize the environment around 3 main constraints:
  1. Python version {major}.{minor}
  2. `numpy` version {major}.{minor} -- version number specified in `environment.yml`
  <!-- 3. `blas` -->
<!-- * BLAS is set at build time; defaults to `openblas`.  To build with `MKL`, set `--build-arg BLAS=` -->

**To Do:**
* pin blas (openblas vs mkl).  see:
  * https://docs.anaconda.com/mkl-optimizations/index.html
  * https://conda.io/projects/conda/en/latest/user-guide/concepts/packages.html
  * https://github.com/conda-forge/numpy-feedstock/issues/108


## Image dependencies / inheritance
`base_env`
  └ `ds_env`
      ├ `nlp_env`
      ├ `pytorch_env`
      │   └ `forecast_env`
      └ `web_env`