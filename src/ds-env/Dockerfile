# NAME: ds-env

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

ENV JUPYTER_ENABLE_LAB=yes

USER root

# set apt-get arg for build
ARG DEBIAN_FRONTEND=noninteractive

USER ${NB_UID}

# Update environment
COPY --chown=${NB_UID}:${NB_GID} environment.yaml "${HOME}/tmp/"
# COPY --chown=${NB_UID}:${NB_GID} requirements.txt "${HOME}/tmp/"

RUN mamba env update -n base --quiet --file "${HOME}/tmp/environment.yaml"  \
 && mamba update -n base --update-all --yes --quiet \
 && mamba clean --all --yes --quiet \
#  && pip install --no-deps --quiet -r "${HOME}/tmp/requirements.txt" \
#  && pip cache purge \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

# Import matplotlib the first time to build the font cache.
RUN mamba activate ds; MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
 && fix-permissions "${HOME}"

RUN fix-permissions /etc/jupyter \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

# Don't launch as root
USER ${NB_UID}

WORKDIR "${HOME}"
