# Introduction
This repo contains the source files for 'Data Science Anywhere' Data Science environments.  The base 'ds_env' image is modeled after [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) scipy-notebook.


## Getting Started
1.	Installation process:
    *  [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
    *  [Getting started with Docker](https://docs.docker.com/)
2.	Build process
    *  To build all images in the stack, run `bash ./src/build-all.sh`. Consider whether to update the python version specified for the `base_env` in `docker-build.yml`
    *  To update a _single_ image, run the `build.sh` script in the relevant directory.
        > Remember that images have inheritance and updating a project image will not update the packages inherited from the source image!
1.  Deploying to Docker Hub
    *  Tag images with `docker tag <imagename> <registry>/<imagename>`
    *  Log in to with `docker login` and provide username and password/token when prompted
    *  Push images to registry with `docker push <registry>/<imagename>`
    *  Alternatively, use the `tag_and_push.sh` script


## Image dependencies / inheritance
```
`base_env`
  └ `ds_env`
      ├ `nlp_env`
      ├ `pytorch_env`
      │   └ `forecast_env`
      └ `web_env`
```

## Run process (local)
1.  Edit `.env` file to change image and local path to be mounted
2.  Launch locally with `docker-compose up -d` from project root.
3.  View URL and token with `docker logs <IMAGENAME>`
4.  If a foreground process is running, halt with `ctrl-c`; run `docker-compose down` to tear down the docker container.


## Features
*  Images are set to load JupyterLabs, but the standard notebook interface is also available through the menus
*  Included in the image is [jupytext](https://jupytext.readthedocs.io/en/latest/introduction.html), allowing concurrent .ipynb and .py develpment
*  Jupyterlab-git allows use of git repos from within JupyterLab


## Known Bugs
*  *jupyter-sql* extensions are currently not update for JupyterLab 3.  Docker images will need to be rebuilt if/when the bugfixes/patches are released.

## Roadmap
* [ ] BLAS-specific images
* [ ] Add ARM64 architectures
<!-- * [ ] Add Tensorflow/Keras (if requested) -->
<!-- * [ ] Add CUDA and ROCm (if requested) -->
