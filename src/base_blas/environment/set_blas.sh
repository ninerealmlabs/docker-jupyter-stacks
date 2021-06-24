#!/bin/bash

# debug; show variables that can be used
set

# pass ENV variable from dockerfile
blas_type=$1
echo "blas_type: ${blas_type}"

if [[ ${blas_type} = "openblas" ]]; then
  # set openblas options
  echo "blas=*=openblas" >> "${CONDA_DIR}/conda-meta/pinned"
  # set openblas by un/commenting appropriate lines in environment.yml
  sed -i "s|# - conda-forge::blas=*=openblas|- conda-forge::blas=*=openblas|" /home/${NB_USER}/tmp/environment.yml
  sed -i "s|# - nomkl|- nomkl|" /home/${NB_USER}/tmp/environment.yml
  # remove mkl options
  sed -i '/mkl/d' "${CONDA_DIR}/conda-meta/pinned"
  sed -i "s|- conda-forge::blas=*=mkl|# - conda-forge::blas=*=mkl|" /home/${NB_USER}/tmp/environment.yml
elif [[ ${blas_type} = "mkl" ]]; then
  # set mkl options
  echo "blas=*=mkl" >> "${CONDA_DIR}/conda-meta/pinned"
  # remove openblas
  mamba remove blas=*=openblas -n base
  # set mkl by un/commenting appropriate lines in environment.yml
  sed -i "s|# - conda-forge::blas=*=mkl|- conda-forge::blas=*=mkl|" /home/${NB_USER}/tmp/environment.yml
  sed -i "s|- nomkl|# - nomkl|" /home/${NB_USER}/tmp/environment.yml
  # remove mkl options
  sed -i '/openblas/d' "${CONDA_DIR}/conda-meta/pinned"
  sed -i "s|- conda-forge::blas=*=openblas|# - conda-forge::blas=*=openblas|" /home/${NB_USER}/tmp/environment.yml
else
  # halt
  echo "*** ERROR: INVALID BLAS TYPE PASSED: $1 ***"
  exit 1
fi