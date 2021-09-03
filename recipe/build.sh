#!/bin/bash

if [ "$(uname)" == "Darwin" ]
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    DYNAMIC_EXT=".dylib"
    export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
    DYNAMIC_EXT=".so"
fi
cp -f "${RECIPE_DIR}/SuiteSparse_config.mk" SuiteSparse_config/SuiteSparse_config.mk

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export INSTALL_LIB="${PREFIX}/lib"
export INSTALL_INCLUDE="${PREFIX}/include"

if [ "$blas_impl" == "mkl" ]; then
    export BLAS="-lmkl_rt"
    export LAPACK="-lmkl_rt"
elif [ "$blas_impl" == "openblas" ]; then
    export BLAS="-lblas -llapack"
    export LAPACK="-lblas -llapack"
else
    echo "blas_impl undefined in variant or not recognized.  Edit cvxopt's build.sh if you need to add a new supported blas"
fi

export CUDA="no"
export JOBS=1
export INSTALL="${PREFIX}"
# continue to ignore docs
export INSTALL_DOC="${SRC_DIR}/doc"
# make sure CMake install goes in the right place
export CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib"

# export environment variable so SuiteSparse will use the METIS built above
export MY_METIS_LIB="-L${PREFIX}/lib -lmetis -Wl,-rpath,$PREFIX/lib"
export MY_METIS_INC="-I${PREFIX}/include"

# (optional) write out various make variables for easier build debugging
make config 2>&1 | tee make_config.txt

# skip graphblas, mongoose by giving them a no-op makefile
cp -v ${RECIPE_DIR}/Makefile.empty GraphBLAS/Makefile
cp -v ${RECIPE_DIR}/Makefile.empty Mongoose/Makefile

# make SuiteSparse
make library static VERBOSE=1
make install

# manually install the static libraries
cp ${SRC_DIR}/AMD/Lib/libamd.a ${PREFIX}/lib
cp ${SRC_DIR}/BTF/Lib/libbtf.a ${PREFIX}/lib
cp ${SRC_DIR}/CAMD/Lib/libcamd.a ${PREFIX}/lib
cp ${SRC_DIR}/CCOLAMD/Lib/libccolamd.a ${PREFIX}/lib
cp ${SRC_DIR}/CHOLMOD/Lib/libcholmod.a ${PREFIX}/lib
cp ${SRC_DIR}/COLAMD/Lib/libcolamd.a ${PREFIX}/lib
cp ${SRC_DIR}/CSparse/Lib/libcsparse.a ${PREFIX}/lib
cp ${SRC_DIR}/CXSparse/Lib/libcxsparse.a ${PREFIX}/lib
cp ${SRC_DIR}/KLU/Lib/libklu.a ${PREFIX}/lib
cp ${SRC_DIR}/LDL/Lib/libldl.a ${PREFIX}/lib
cp ${SRC_DIR}/RBio/Lib/librbio.a ${PREFIX}/lib
cp ${SRC_DIR}/SPQR/Lib/libspqr.a ${PREFIX}/lib
cp ${SRC_DIR}/SuiteSparse_config/libsuitesparseconfig.a ${PREFIX}/lib
cp ${SRC_DIR}/UMFPACK/Lib/libumfpack.a ${PREFIX}/lib
