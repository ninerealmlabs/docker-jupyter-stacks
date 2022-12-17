# NAME: ts-env

ARG SOURCE_IMAGE
FROM ${SOURCE_IMAGE}

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

## Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}
