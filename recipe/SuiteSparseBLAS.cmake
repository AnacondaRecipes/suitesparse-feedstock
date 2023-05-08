# SuiteSparse has a hard time finding MKL on Windows.
# This cuts the search drastically.

cmake_minimum_required ( VERSION 3.22 )

# Look for Intel MKL BLAS with 32-bit integers (and 64-bit pointer)
message ( STATUS "Looking for Intel 32-bit BLAS" )
set ( BLA_VENDOR Intel10_64lp )
set ( BLA_SIZEOF_INTEGER 4 )
set ( BLAS_FOUND True )
find_library(BLAS_LIBRARIES mkl_rt)
set ( BLAS_INCLUDE_DIRS ${CMAKE_INCLUDE_PATH} )
set ( BLAS_LINKER_FLAGS "" )
include ( SuiteSparseBLAS32 )
