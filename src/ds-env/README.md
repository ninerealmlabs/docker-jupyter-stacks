# Data Science

JupyterLab environment designed for general data analysis and ML, including a variety of libraries for plotting,
missing and imbalanced data management, connections to databases.
Of particular interest might be [`dataprep`](https://github.com/sfu-db/dataprep).

For package details, see [`environment.yaml`](./environment.yaml) and [`requirements.txt`](./requirements.txt)
See also source `base-env` image files

## Image dependencies / inheritance

```txt
`base-env`
  └ `ds-env`
    ├ `nlp-env`
    ├ `pytorch-env`
    │ └ `ts-env`
    └ `web-env`
```
