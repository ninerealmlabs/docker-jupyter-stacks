# BASE DOCKERFILE
# NAME: base-env

ARG SOURCE_IMAGE="jupyter/minimal-notebook"
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
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3037
# hadolint shell=bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p "${XDG_CACHE_HOME}" \
 && mkdir -p "${XDG_CONFIG_HOME}"

USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y --fix-missing \
 && apt-get install -yq --no-install-recommends \
    # general use
    curl \
    gcc \
    gfortran \
    gnupg \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    # for matplotlib anim
    ffmpeg \
    # Install jq for fixing git-ipynb interactions
    jq \
    # # Install requirements for SQL connections
    # unixodbc \
    # unixodbc-dev \
    # pipx
    pipx \
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

RUN fix-permissions /etc/jupyter/

USER ${NB_UID}

## update python and jupyter versions and pins
## 1. ensure file exists
## 2. remove lines declaring existing pins
## 3. update env
## 4. add new pins
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

RUN mamba env update -n base --prune --quiet --file "${HOME}/tmp/environment.yaml"  \
 && mamba clean --all --yes --quiet \
 && pip install --no-cache-dir --no-deps --quiet -r "${HOME}/tmp/requirements.txt" \
 && pip cache purge \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

### Install / activate extensions
RUN jupyter nbextension enable widgetsnbextension --py --sys-prefix \
#  && jupyter serverextension enable --py jupyterlab_code_formatter --sys-prefix \
 && jupyter serverextension enable jupytext \
#  && jupyter serverextension enable jupyterlab_git \
# #  && jupyter lab build --dev-build=False
#  && jupyter lab clean \
#  && jlpm cache clean \
#  && npm cache clean --force \
#  && rm -rf "${HOME}/.local" \
#  && rm -rf "${HOME}/.node-gyp" \
#  && rm -rf "${HOME}/.npm" \
#  && rm -rf "${HOME}/.yarn"
#  \
#  && rm -rf ${HOME}/.cache
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

### config files
# # Modify standard jupyter lab preferences
# # https://jupyterlab.readthedocs.io/en/stable/user/directories.html#jupyterlab-application-directory
COPY --chown=${NB_UID}:${NB_GID} ./config/lab-settings/. "${CONDA_DIR}/share/jupyter/lab/"

# copy dotfiles and config files to /user dir
COPY --chown=${NB_UID}:${NB_GID} ./config/home/. "/home/${NB_USER}/"
# copy user-level extension configurations
COPY --chown=${NB_UID}:${NB_GID} ./config/user-settings/. "/home/${NB_USER}/.jupyter/lab/user-settings/"
RUN fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

# Don't launch as root
USER ${NB_UID}

WORKDIR "${HOME}"
