# BASE DOCKERFILE
# NAME: base_env

ARG BASE_IMAGE
FROM "${BASE_IMAGE}"
# ARG PYTHON_VERSION
# FROM "${BASE_IMAGE}:python-${PYTHON_VERSION}"

# Labels
ARG BUILD_DATE
ARG PYTHON_VERSION
ARG GIT_COMMIT
ENV BUILD_DATE=${BUILD_DATE}
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV GIT_COMMIT=${GIT_COMMIT}
LABEL maintainer="ninerealmlabs"
LABEL build_date="${BUILD_DATE}"
LABEL python_version="python-${PYTHON_VERSION}"
LABEL git_commit="${GIT_COMMIT}"
LABEL description="Default environment for python + jupyterlab + datasci stack"

ENV JUPYTER_ENABLE_LAB=yes

USER root

# set apt-get arg for build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y --fix-missing \
 && apt-get install -yq --no-install-recommends \
    # ffmpeg for matplotlib anim & dvipng+cm-super for latex labels
    ffmpeg \
    dvipng \
    cm-super \
    # Install requirements for SQL connections
    curl \
    gnupg \
    unixodbc \
    unixodbc-dev \
    # Install jq for fixing git-ipynb interactions
    jq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


USER ${NB_UID}

# Install from environment.yml
COPY --chown=${NB_UID}:${NB_GID} environment.yml "/home/${NB_USER}/tmp/"
COPY --chown=${NB_UID}:${NB_GID} requirements.txt "/home/${NB_USER}/tmp/"

## unpin python, change version, pin python
# RUN sed -i s"/python.*/python ${PYTHON_VERSION}/" ${CONDA_DIR}/conda-meta/pinned \
RUN sed -i "/python/d" ${CONDA_DIR}/conda-meta/pinned
RUN mamba install -n base python=${PYTHON_VERSION} -y -f \
 && mamba update -n base --all -y
RUN echo "python ${PYTHON_VERSION}.*" >> "${CONDA_DIR}/conda-meta/pinned"

## pin blas
# RUN  echo "blas=*=openblas" >> "${CONDA_DIR}/conda-meta/pinned"
## pin numpy version (major.minor)
RUN echo "numpy $(echo "$(awk '/numpy==*/{print $2}' /home/${NB_USER}/tmp/environment.yml)" | sed 's/numpy==//'.*" >> "${CONDA_DIR}/conda-meta/pinned"

RUN mamba env update -n base -f "/home/${NB_USER}/tmp/environment.yml" \
 && mamba clean --all -f -y \
 && pip install --no-deps -r "/home/${NB_USER}/tmp/requirements.txt" \
 && pip cache purge \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"


### From jupyter/scipy-notebook  ###
# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
# Install facets which does not have a pip or conda package at the moment
# WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git /tmp/facets \
 && jupyter nbextension install /tmp/facets/facets-dist/ --sys-prefix \
 && rm -rf /tmp/facets \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
 && fix-permissions "/home/${NB_USER}"

# Activate ipywidgets extension in the environment that runs the notebook server
RUN jupyter nbextension enable widgetsnbextension --py --sys-prefix \
#  ## currently broken for jupyterlab=3
#  && jupyter labextension install jupyterlab-flake8 --no-build \
#  && jupyter serverextension enable jupyterlab_sql --py --sys-prefix \
 ## plotly support
 && jupyter labextension install jupyterlab-plotly --no-build \
#  && jupyter labextension install @jupyter-widgets/jupyterlab-manager plotlywidget --no-build \
 ## themes
 && jupyter labextension install @ninerealmlabs/jupyterlab_material_darker --no-build \
 && jupyter lab build \
 && jupyter server extension enable jupytext \
 && jupyter server extension enable --py jupyterlab_git \
 && jupyter lab clean \
 && jlpm cache clean \
 && npm cache clean --force \
 && rm -rf /home/${NB_USER}/.yarn \
 && rm -rf /home/${NB_USER}/.npm \
 && rm -rf /home/${NB_USER}/.node-gyp \
 && rm -rf /home/${NB_USER}/.local
#  \
#  && rm -rf /home/${NB_USER}/.cache

# Add ipynb/py pairing to global config for JupyText
RUN echo -e "\n## Jupytext config" >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py \
 && echo "c.NotebookApp.contents_manager_class = 'jupytext.TextFileContentsManager'" >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py \
 && echo "c.ContentsManager.default_jupytext_formats = 'ipynb,py'" >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py \
 && echo "c.ContentsManager.preferred_jupytext_formats_save = 'py:percent'" >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py \
 && echo "c.ContentsManager.default_notebook_metadata_filter = '-all'" >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py \
 && echo "c.ContentsManager.default_cell_metadata_filter = '-all'" >> /home/${NB_USER}/.jupyter/jupyter_notebook_config.py

# copy dotfiles and config files
COPY ./configs /home/${NB_USER}/

RUN fix-permissions /etc/jupyter \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"


USER root

# Modify standard jupyter lab preferences
RUN mv /home/${NB_USER}/overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json \
 && mv /home/${NB_USER}/.gitattributes_global /etc/gitattributes_global \
 && chown root: /etc/gitattributes_global \
 && chmod 644 /etc/gitattributes_global

RUN fix-permissions /etc/jupyter/ \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

# Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}


# Get token and add to ENV variable
# ENV JUPYTER_TOKEN=jupyter_notebook_token
