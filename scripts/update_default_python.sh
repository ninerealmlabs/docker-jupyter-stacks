#!/bin/bash

###
# call with `update_default_python.sh <PYTHON_VERSION>`
###
NEW=$1
echo "Changing to python ${NEW}..."

# for fname in $(find $(dirname $0) -name testbuild.sh); do
for fname in $(find $(dirname $0)/.. -name build.sh); do
    echo "Updating ${fname}"
    sed -i.bak "s|PYTHON_VERSION=\${PYTHON_VERSION:-.*$|PYTHON_VERSION=\$\{PYTHON_VERSION:-${NEW}\}|" $fname
    rm "${fname}.bak"
done

# Docker doesn't like `.*` for version tags, so truncate from tag
TAG="${NEW}"
if [[ ${TAG: -1} == "*" ]]; then
    TAG=${TAG: 0:${#TAG}-2}
fi

# for fname in $(find $(dirname $0)/.. -name test-compose.yml); do
for fname in $(find $(dirname $0)/.. -name docker-compose.yml); do
    echo "Updating ${fname}"
    sed -i.bak "s|PYTHON_VERSION:.*$|PYTHON_VERSION: ${NEW}|" $fname
    sed -i.bak "s|python-.*$|python-${TAG}|" $fname
    rm "${fname}.bak"
done

echo "Done."
