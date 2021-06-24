# DOCKERFILE FOR NLPMODELS
# NAME: nlp_env

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

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

USER root

# python 3.7+ fix for pattern 3.6
ENV PYTHON_VERSION="${PYTHON_VERSION}"
COPY --chown=${NB_UID}:${NB_GID} ./fixes "/home/${NB_USER}/tmp/fixes"
RUN cp "/home/${NB_USER}/tmp/fixes/pattern/__init__.py" "/opt/conda/lib/python${PYTHON_VERSION::3}/site-packages/pattern/text/__init__.py" \
 && rm -rf "/home/${NB_USER}/tmp/fixes" \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"


# Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}

# Get token and add to ENV variable
# ENV JUPYTER_TOKEN=jupyter_notebook_token
