# DOCKERFILE FOR WEBMODELS
# NAME: web_env

ARG BASE_IMAGE
FROM ${BASE_IMAGE}
# ARG CHROMEDRIVER

# Labels
ARG BUILD_DATE
LABEL build_date="${BUILD_DATE}"
LABEL description="Environment specialized for web scraping & modeling"

USER root

## install chrome & chrome webdriver for selenium
# https://sites.google.com/chromium.org/driver/home
RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > "/tmp/chrome.deb" \
 && apt-get update -y --fix-missing \
 && apt-get install -yq --no-install-recommends \
    graphviz \
    /tmp/chrome.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -f /tmp/chrome.deb \
 && export CHROMEDRIVER_VERSION=$(curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
 && curl  https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip > "/tmp/chromedriver.zip" \
 && unzip "/tmp/chromedriver.zip" > /usr/local/bin/chromedriver \
 && chmod 0755 /usr/local/bin/chromedriver \
 && rm -f /tmp/chromedriver.zip

## Should be automatically found in path;
## if not, may have to add to .bashrc, .bash_profile, and/or .profile
#  && echo -e '\n## Export chromedriver path' >> /etc/skel/.bashrc \
#  && echo 'WEBDRIVER="usr/local/bin/chromedriver"' >> /etc/skel/.bashrc \
#  && echo 'export WEBDRIVER' >> /etc/skel/.bashrc

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


# Don't launch as root
USER ${NB_UID}

WORKDIR ${HOME}


# Get token and add to ENV variable
# ENV JUPYTER_TOKEN=jupyter_notebook_token
