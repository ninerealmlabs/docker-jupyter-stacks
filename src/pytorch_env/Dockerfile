# DOCKERFILE FOR PYTORCH
# NAME: pytorch_env

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Labels
ARG BUILD_DATE
LABEL build_date="${BUILD_DATE}"
LABEL description="Base specialized with Pytorch"

USER ${NB_UID}

# Install from environment.yaml
COPY --chown=${NB_UID}:${NB_GID} environment.yaml "/home/${NB_USER}/tmp/"
COPY --chown=${NB_UID}:${NB_GID} requirements.txt "/home/${NB_USER}/tmp/"
# Unpin openblas
RUN sed -i '/openblas/d' "${CONDA_DIR}/conda-meta/pinned"
RUN mamba env update -n base -f "/home/${NB_USER}/tmp/environment.yaml" --prune \
  && mamba update -n base --all \
  && mamba clean --all -f -y \
  #  && pip install --no-deps -r "/home/${NB_USER}/tmp/requirements.txt" \
  #  && pip cache purge \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

## Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}

# Get token and add to ENV variable
# ENV JUPYTER_TOKEN=jupyter_notebook_token
