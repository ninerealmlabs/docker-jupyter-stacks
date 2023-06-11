# NAME: web-env

ARG SOURCE_IMAGE
FROM ${SOURCE_IMAGE}
# ARG CHROMEDRIVER

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

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3037
# hadolint shell=bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# TODO: explore selenium-manager

## install firefox & gecko webdriver for selenium
# https://github.com/mozilla/geckodriver/releases
# may be installed with firefox: https://askubuntu.com/questions/870530/how-to-install-geckodriver-in-ubuntu
RUN apt-get update -y --fix-missing \
 && apt-get install -yq --no-install-recommends \
    chromium-browser \
    chromium-chromedriver \
    firefox \
    graphviz \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 # \ &&
# detect architecture ["aarch64", "x86_64"]

# hadolint ignore=SC2155
RUN [[ $(arch) = "aarch64" ]] && export platform="linux-aarch64" || export platform="linux64"; \
    export json=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest); \
    export url=$(echo -E "$json" | jq -r '.assets[].browser_download_url | select(contains(env.platform) and endswith("gz"))'); \
    curl -s -L "${url}" | tar -xz \
 && mv geckodriver /usr/local/bin/geckodriver \
 && chmod 0755 /usr/local/bin/geckodriver

# ## install chrome & chrome webdriver for selenium
# # https://sites.google.com/chromium.org/driver/home
# RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > "/tmp/chrome.deb" \
#   && apt-get update -y --fix-missing \
#   && apt-get install -yq --no-install-recommends \
#     graphviz \
#     /tmp/chrome.deb \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/* \
#   && rm -f /tmp/chrome.deb \
#   && CHROMEDRIVER_VERSION="$(curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" \
#   curl "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" > "/tmp/chromedriver.zip" \
#   && unzip "/tmp/chromedriver.zip" > /usr/local/bin/chromedriver \
#   && chmod 0755 /usr/local/bin/chromedriver \
#   && rm -f /tmp/chromedriver.zip

## Should be automatically found in path;
## if not, may have to add to .bashrc, .bash_profile, and/or .profile
#  && echo -e '\n## Export chromedriver path' >> /etc/skel/.bashrc \
#  && echo 'WEBDRIVER="usr/local/bin/chromedriver"' >> /etc/skel/.bashrc \
#  && echo 'export WEBDRIVER' >> /etc/skel/.bashrc

USER ${NB_UID}

# Update environment
COPY --chown=${NB_UID}:${NB_GID} environment.yaml "${HOME}/tmp/"
# COPY --chown=${NB_UID}:${NB_GID} requirements.txt "${HOME}/tmp/"

RUN mamba env update -n base --quiet --file "${HOME}/tmp/environment.yaml"  \
 && mamba clean --all --yes --quiet \
#  && pip install --no-deps --quiet -r "${HOME}/tmp/requirements.txt" \
#  && pip cache purge \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

# Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}
