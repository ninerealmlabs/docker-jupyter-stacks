# Time Series environment

JupyterLab environment with packages for forecasting and time-series data analysis.

For package details, see [`environment.yaml`](./environment.yaml) and [`requirements.txt`](./requirements.txt)
See also source `base-env` and `ds-env` image files.

**Notes:**

- `sktime` appears to have a bad dependency requirement. May try including it in future builds

## Image dependencies / inheritance

```txt
`base-env`
  └ `ds-env`
    └ `ts-env`
```
