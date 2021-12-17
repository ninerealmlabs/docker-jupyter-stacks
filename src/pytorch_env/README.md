# PyTorch Environment

JupyterLab environment that includes PyTorch.

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)
See also source `base_env` and `ds_env` image files.

**Notes:**

- Generally, we pin `blas=*=openblas` for broader compatibility. This limits the `pytorch` and `pytorch`-adjacent packages that we can install. In order to run in the ecosystem, the `pytorch` dockerfile unpins `openblas`.

## Image dependencies / inheritance

`base_env`  
└ `ds_env`  
└ `pytorch_env`  
└ `forecast_env`  
