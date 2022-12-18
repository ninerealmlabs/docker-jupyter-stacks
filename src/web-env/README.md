# Web Environment

JupyterLab environment that includes packages useful when modeling web traffic and behavior or web scraping.

For package details, see [`environment.yaml`](./environment.yaml) and [`requirements.txt`](./requirements.txt)
See also source `base-env` and `ds-env` image files.

This image also includes `chrome` and `chromedriver` useful when using `selenium` for web scraping and testing.
Chromedriver version is specified (as of builddate) as [LATEST](https://chromedriver.chromium.org/downloads/version-selection)

## Image dependencies / inheritance

```txt
`base-env`
  └ `ds-env`
    └ `nlp-env`
        └ `web-env`
```
