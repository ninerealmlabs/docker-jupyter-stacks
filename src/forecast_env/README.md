# Forecasting

JupyterLab environment with packages for forecasting and time-series data analysis.

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)
See also source `base_env` and `ds_env` image files.

Note that `forecast_env` is based on `pytorch_env`, where we unpin `openblas` and allow `mkl`. This may provide strange behaviors on systems running non-intel processors.

**Notes:**

- `sktime` appears to have a bad dependency requirement. May try including it in future builds

## Image dependencies / inheritance

`base_env`
└ `ds_env`
└ `pytorch_env`
└ `forecast_env`
