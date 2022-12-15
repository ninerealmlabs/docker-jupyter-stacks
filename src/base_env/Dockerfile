# BASE DOCKERFILE
# NAME: base_env

ARG BASE_IMAGE
FROM "${BASE_IMAGE}"

# Labels
ARG BUILD_DATE
ARG JUPYTER_VERSION
ARG GIT_COMMIT
ENV BUILD_DATE=${BUILD_DATE}
ENV JUPYTER_VERSION=${JUPYTER_VERSION}
ENV GIT_COMMIT=${GIT_COMMIT}
LABEL maintainer="ninerealmlabs"
LABEL build_date="${BUILD_DATE}"
# LABEL python_version="python-${PYTHON_VERSION}"
LABEL jupyter_version="lab-${JUPYTER_VERSION}"
LABEL git_commit="${GIT_COMMIT}"
LABEL description="Default JupyterLab 'OS' for Jupyter docker stack"

ENV HOME="/home/${NB_USER}"
ENV XDG_CACHE_HOME="${HOME}/.cache/"
ENV XDG_CONFIG_HOME="${HOME}/.config/"
ENV JUPYTER_ENABLE_LAB=yes

USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y --fix-missing \
 && apt-get install -yq --no-install-recommends \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    # for matplotlib anim
    ffmpeg \
    # Install jq for fixing git-ipynb interactions
    jq \
    # Install requirements for SQL connections
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


USER ${NB_UID}

RUN mkdir -p "${XDG_CACHE_HOME}" \
 && mkdir -p "${XDG_CONFIG_HOME}"

## update base environment conda and mamba
RUN mamba update -n base conda mamba --update-deps --yes --quiet

## Install packages required for JupyterLab
COPY --chown=${NB_UID}:${NB_GID} environment.yaml "${HOME}/tmp/"
COPY --chown=${NB_UID}:${NB_GID} requirements.txt "${HOME}/tmp/"

RUN mamba env update -n base --file "${HOME}/tmp/environment.yaml" --quiet \
 && mamba update -n base --update-all --yes --quiet \
 && mamba clean --all --yes
RUN pip install --no-deps --quiet -r "${HOME}/tmp/requirements.txt" \
 && pip cache purge
RUN fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

### From jupyter/scipy-notebook
# Install facets which does not have a pip or conda package at the moment
WORKDIR "${HOME}/tmp"
RUN git clone https://github.com/PAIR-code/facets.git \
 && jupyter nbextension install facets/facets-dist/ --sys-prefix \
 && rm -rf "${HOME}/tmp/" \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

### Install / activate extensions
RUN pip install --no-deps --quiet \
    aquirdturtle_collapsible_headings \
    jupyterlab-material-night-eighties
RUN jupyter nbextension enable widgetsnbextension --py --sys-prefix
RUN jupyter server extension enable jupytext \
 && jupyter server extension enable --py jupyterlab_git \
 && jupyter lab build --dev-build=False \
 && jupyter lab clean \
 && jlpm cache clean \
 && npm cache clean --force \
 && rm -rf "${HOME}/.yarn" \
 && rm -rf "${HOME}/.npm" \
 && rm -rf "${HOME}/.node-gyp" \
 && rm -rf "${HOME}/.local"
#  \
#  && rm -rf ${HOME}/.cache

# # Add ipynb/py pairing to global config for JupyText
# RUN echo -e "\n## Jupytext config" >> ${HOME}/.jupyter/jupyter_notebook_config.py \
#  && echo "c.NotebookApp.contents_manager_class = 'jupytext.TextFileContentsManager'" >> ${HOME}/.jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.default_jupytext_formats = 'ipynb,py'" >> ${HOME}/.jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.preferred_jupytext_formats_save = 'py:percent'" >> ${HOME}/.jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.default_notebook_metadata_filter = '-all'" >> ${HOME}/.jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.default_cell_metadata_filter = '-all'" >> ${HOME}/.jupyter/jupyter_notebook_config.py

# copy dotfiles and config files
COPY --chown=${NB_UID}:${NB_GID} ./configs/* "${HOME}/"

RUN fix-permissions /etc/jupyter \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"


USER root

# Modify standard jupyter lab preferences
ENV LAB_SETTINGS="/opt/conda/share/jupyter/lab/settings/"
RUN mkdir -p "${LAB_SETTINGS}" \
 && mv ${HOME}/overrides.json "${LAB_SETTINGS}/overrides.json"

RUN mv ${HOME}/.gitattributes_global /etc/gitattributes_global \
 && chown root: /etc/gitattributes_global \
 && chmod 644 /etc/gitattributes_global

RUN fix-permissions /etc/jupyter/ \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

# Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}


# Get token and add to ENV variable
# ENV JUPYTER_TOKEN=jupyter_notebook_token
