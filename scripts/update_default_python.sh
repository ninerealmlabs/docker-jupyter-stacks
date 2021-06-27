#!/bin/bash

###
# call with `update_default_python.sh <PYTHON_VERSION>`
###
NEW=$1
echo "Changing to python ${NEW}..."

# for fname in $(find $(dirname $0) -name testbuild.sh); do
for fname in $(find $(dirname $0) -name build.sh); do
    # echo $fname
    sed -i.bak "s|PYTHON_VERSION=\${1.*$|PYTHON_VERSION=\$\{1:-${NEW}\}|" $fname
    rm "${fname}.bak"
done

echo "Done."
