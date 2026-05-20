#!/usr/bin/env bash

SS_BLAS_ARGS=()
SS_OPENMP_ARGS=()

if [[ "${blas_impl}" == "openblas" ]]; then
  SS_BLAS_ARGS+=(-DBLA_VENDOR=OpenBLAS)
elif [[ "${blas_impl}" == "mkl" ]]; then
  SS_MKL_LIBS="${PREFIX}/lib/libmkl_gf_lp64${SHLIB_EXT};${PREFIX}/lib/libmkl_intel_thread${SHLIB_EXT};${PREFIX}/lib/libmkl_core${SHLIB_EXT};${PREFIX}/lib/libiomp5${SHLIB_EXT};pthread;m;dl"
  SS_BLAS_ARGS+=(
    -DBLA_VENDOR=Intel10_64lp
    "-DBLAS_LIBRARIES=${SS_MKL_LIBS}"
  )
  SS_OPENMP_ARGS+=(
    -DOpenMP_C_FLAGS=-fopenmp
    -DOpenMP_CXX_FLAGS=-fopenmp
    -DOpenMP_C_LIB_NAMES=iomp5
    -DOpenMP_CXX_LIB_NAMES=iomp5
    -DOpenMP_iomp5_LIBRARY=${PREFIX}/lib/libiomp5${SHLIB_EXT}
    -DOpenMP_C_LIBRARIES=${PREFIX}/lib/libiomp5${SHLIB_EXT}
    -DOpenMP_CXX_LIBRARIES=${PREFIX}/lib/libiomp5${SHLIB_EXT}
  )
else
  echo "ERROR: blas_impl must be openblas or mkl, got '${blas_impl}'"
  exit 1
fi

# Skip LAGraph, GraphBLAS, and Mongoose.
for module in SuiteSparse_config AMD BTF CAMD CCOLAMD COLAMD CHOLMOD CSparse CXSparse LDL KLU UMFPACK ParU RBio SPQR SPEX
do
  pushd ${module}/build || exit 1
  cmake ${CMAKE_ARGS} \
    "${SS_BLAS_ARGS[@]}" \
    "${SS_OPENMP_ARGS[@]}" \
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
