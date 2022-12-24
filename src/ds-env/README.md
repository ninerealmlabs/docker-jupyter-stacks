# Data Science Environment

JupyterLab environment designed for general data analysis and ML, including a variety of libraries for plotting,
missing and imbalanced data management, connections to databases.
Of particular interest might be [`dataprep`](https://github.com/sfu-db/dataprep).

For package details, see [`environment.yaml`](./environment.yaml) and [`requirements.txt`](./requirements.txt)
See also source `base-env` image files

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

## Image dependencies / inheritance

```txt
base-env - customizes `jupyter/minimal-notebook`
  └ ds-env - from `base-env`, catchup `jupyter/scipy-notebook` + customizations
      ├ ts-env  - adds packages for timeseries analysis & forecasting
      └ nlp-env - add packages for text analysis & NLP modeling
          └ web-env - add packages/binaries for web scraping, including a chromedriver/geckodriver binary
```
