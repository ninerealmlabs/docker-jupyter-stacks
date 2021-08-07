# BASE DOCKERFILE
# NAME: ds_env

ARG BASE_IMAGE
FROM "${BASE_IMAGE}"

# Labels
ARG BUILD_DATE
LABEL build_date="${BUILD_DATE}"
LABEL description="Default environment for python + jupyterlab + datasci stack"

ENV JUPYTER_ENABLE_LAB=yes

USER root

# set apt-get arg for build
ARG DEBIAN_FRONTEND=noninteractive

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

# Install from environment.yml
COPY --chown=${NB_UID}:${NB_GID} environment.yml "/home/${NB_USER}/tmp/"
COPY --chown=${NB_UID}:${NB_GID} requirements.txt "/home/${NB_USER}/tmp/"
RUN mamba env update -n base -f "/home/${NB_USER}/tmp/environment.yml" \
  && mamba clean --all -f -y \
  && pip install --no-deps -r "/home/${NB_USER}/tmp/requirements.txt" \
  && pip cache purge \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

RUN fix-permissions /etc/jupyter \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

# Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}

# Get token and add to ENV variable
# ENV JUPYTER_TOKEN=jupyter_notebook_token
