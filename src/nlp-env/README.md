# NLP Environment

JupyterLab environment updated to include packages useful for Natural Language Processing (NLP) tasks
like `NLTK`, `Gensim`, `HuggingFace`, and `SpaCy`.

For package details, see [`environment.yaml`](./environment.yaml) and [`requirements.txt`](./requirements.txt)
See also source `base-env` and `ds-env` image files.

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
