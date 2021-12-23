# Web Environment

JupyterLab environment that includes packages useful when modeling web traffic and behavior or web scraping.

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)
See also source `base_env` and `ds_env` image files.

This image also includes `chrome` and `chromedriver` useful when using `selenium` for web scraping and testing.
Chromedriver version is specified (as of builddate) as [LATEST](https://chromedriver.chromium.org/downloads/version-selection)

## Image dependencies / inheritance

```txt
`base_env`
  └ `ds_env`
    └ `web_env`
```
