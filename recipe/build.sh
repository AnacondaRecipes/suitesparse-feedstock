#!/bin/bash

export JOBS=1
export CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_CUDA=0"

# skip graphblas, mongoose by giving them a no-op makefile
cp -v ${RECIPE_DIR}/Makefile.empty GraphBLAS/Makefile
cp -v ${RECIPE_DIR}/Makefile.empty Mongoose/Makefile

# make SuiteSparse
make
make install
