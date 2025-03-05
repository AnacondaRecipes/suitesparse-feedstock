#!/usr/bin/env bash

# Skip LAGraph, GraphBLAS, and Mongoose.
for module in SuiteSparse_config AMD BTF CAMD CCOLAMD COLAMD CHOLMOD CSparse CXSparse LDL KLU UMFPACK ParU RBio SPQR SPEX
do
  pushd ${module}/build || exit 1
  cmake %CMAKE_ARGS% \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    .. || exit 2
  cmake --build . -j${CPU_COUNT} || exit 3
  cmake --install . || exit 4
  popd || exit 5
done
