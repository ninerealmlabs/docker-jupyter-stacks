# BASE DOCKERFILE
# NAME: base-env

ARG SOURCE_IMAGE
FROM "${SOURCE_IMAGE}"

# Labels
ARG BUILD_DATE
ARG PYTHON_VERSION
ARG GIT_COMMIT
ENV BUILD_DATE=${BUILD_DATE}
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV GIT_COMMIT=${GIT_COMMIT}
LABEL maintainer="ninerealmlabs"
LABEL build-date="${BUILD_DATE}"
LABEL python-version="python-${PYTHON_VERSION}"
LABEL git-commit="${GIT_COMMIT}"

ENV HOME="/home/${NB_USER}"
ENV XDG_CACHE_HOME="${HOME}/.cache/"
ENV XDG_CONFIG_HOME="${HOME}/.config/"
ENV JUPYTER_ENABLE_LAB=yes

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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

# RUN apt-get update -y --fix-missing \
# # Install Microsoft SQL connector prereqs
#  && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
# # && curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
#  && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
#  && exit \
# # Install MS SQL odbc
#  && ACCEPT_EULA=Y apt-get install -yq msodbcsql17 \
# #  && ACCEPT_EULA=Y apt-get install -yq mssql-tools \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*

# # Add MSSQL stuff to path
# # RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/skel/.bashrc  # works?
# ENV PATH="/opt/mssql-tools/bin:${PATH}"

USER ${NB_UID}

RUN mkdir -p "${XDG_CACHE_HOME}" \
 && mkdir -p "${XDG_CONFIG_HOME}"

# ## update python and jupyter versions and pins
# ## 1. ensure file exists
# ## 2. remove lines declaring existing pins
# ## 3. update env
# ## 4. add new pins
RUN touch "${CONDA_DIR}/conda-meta/pinned" \
 && sed -i '/^python/d' "${CONDA_DIR}/conda-meta/pinned" \
 && mamba install --yes --quiet "python==${PYTHON_VERSION}" \
 && mamba update -n base conda mamba --update-deps --yes --quiet \
 && mamba clean --all --force-pkgs-dirs --yes --quiet \
 && echo "python ${PYTHON_VERSION}" >> "${CONDA_DIR}/conda-meta/pinned" \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

## Install packages required for "JupyterLabOS"
COPY --chown=${NB_UID}:${NB_GID} environment.yaml "${HOME}/tmp/"
COPY --chown=${NB_UID}:${NB_GID} requirements.txt "${HOME}/tmp/"

RUN mamba env update -n base --quiet --file "${HOME}/tmp/environment.yaml"  \
 && mamba update -n base --update-all --yes --quiet \
 && mamba clean --all --yes --quiet \
 && pip install --no-cache-dir --no-deps --quiet -r "${HOME}/tmp/requirements.txt" \
 && pip install --no-cache-dir --no-deps --quiet \
    aquirdturtle-collapsible-headings \
    jupyterlab-material-night-eighties \
 && pip cache purge \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

### Install / activate extensions
RUN jupyter nbextension enable widgetsnbextension --py --sys-prefix \
 && jupyter serverextension enable jupytext \
 && jupyter serverextension enable jupyterlab_git \
#  && jupyter lab build --dev-build=False
 && jupyter lab clean \
 && jlpm cache clean \
 && npm cache clean --force \
 && rm -rf "${HOME}/.local" \
 && rm -rf "${HOME}/.node-gyp" \
 && rm -rf "${HOME}/.npm" \
 && rm -rf "${HOME}/.yarn"
#  \
#  && rm -rf ${HOME}/.cache

### `/etc/ipython` is default location for 'ipython_config.py'
### `/etc/jupyter` is default location for 'jupyter_notebook_config.py' and 'jupyter_server_config.py'
### deprecate in favor of pyproject.toml
# Add ipynb/py pairing to global config for JupyText
# RUN echo -e "\n## Jupytext config" >> /etc/jupyter/jupyter_notebook_config.py \
#  && echo "c.NotebookApp.contents_manager_class = 'jupytext.TextFileContentsManager'" >> /etc/jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.default_jupytext_formats = 'ipynb,py'" >> /etc/jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.preferred_jupytext_formats_save = 'py:percent'" >> /etc/jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.default_notebook_metadata_filter = '-all'" >> /etc/jupyter/jupyter_notebook_config.py \
#  && echo "c.ContentsManager.default_cell_metadata_filter = '-all'" >> /etc/jupyter/jupyter_notebook_config.py

# copy dotfiles and config files to /tmp
# singleuser.lifecycleHooks.postStart.exec.command will be used to copy into pvc
COPY --chown=${NB_UID}:${NB_GID} ./config/user/* "/tmp/"

RUN fix-permissions /etc/jupyter \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

USER root

# Modify standard jupyter lab preferences
# https://jupyterlab.readthedocs.io/en/stable/user/directories.html#jupyterlab-application-directory
ENV LAB_SETTINGS="/opt/conda/share/jupyter/lab/settings/"
RUN mkdir -p "${LAB_SETTINGS}"
COPY --chown=root: ./config/root/overrides.json "${LAB_SETTINGS}/overrides.json"
COPY --chown=root: --chmod=644 ./config/root/.gitattributes_global /etc/gitattributes_global

RUN fix-permissions /etc/jupyter/ \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

# Don't launch as root
USER ${NB_UID}

WORKDIR "${HOME}"
