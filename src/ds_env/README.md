# Data Science

JupyterLab environment designed for general data analysis and ML, including a variety of libraries for plotting, missing and imbalanced data management, connections to databases. Of particular interest might be [`dataprep`](https://github.com/sfu-db/dataprep).

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)
See also source `base_env` image files

## Image dependencies / inheritance

`base_env`
└ `ds_env`
├ `nlp_env`
├ `pytorch_env`
│ └ `forecast_env`
└ `web_env`
