:: SuiteSparse 7.0 build instructions for windows are to add all cmake projects individually to Visual Studio.
:: We're going the same way.

echo on

set "SS_OPENMP_C_FLAGS="
set "SS_OPENMP_C_LIB_NAMES="
set "SS_OPENMP_LIBIOMP="

if "%blas_impl%"=="openblas" (
    set "SS_BLAS=-DBLA_VENDOR=OpenBLAS"
) else if "%blas_impl%"=="mkl" (
    set "SS_BLAS=-DBLA_VENDOR=Intel10_64lp"
    :: Use Intel OpenMP for SuiteSparse's MSVC OpenMP checks to match MKL.
    set "SS_OPENMP_C_FLAGS=-DOpenMP_C_FLAGS=/openmp"
    set "SS_OPENMP_C_LIB_NAMES=-DOpenMP_C_LIB_NAMES=libiomp5md"
    set "SS_OPENMP_LIBIOMP=-DOpenMP_libiomp5md_LIBRARY=%LIBRARY_LIB%\libiomp5md.lib"
) else (
    echo ERROR: blas_impl must be openblas or mkl, got "%blas_impl%"
    exit 1
)

:: flang on Windows uses lowercase-no-underscore naming (dgemm), but OpenBLAS
:: exports lowercase-with-underscore (dgemm_).  Override the Fortran symbol
:: convention via an initial-cache file.  The echo lines with parentheses must
:: be at the top level so cmd.exe does not mangle them.  See SuiteSparse #765.
echo set(SUITESPARSE_USE_FORTRAN OFF CACHE BOOL "" FORCE)> "%SRC_DIR%\ss_blas.cmake"
if "%blas_impl%"=="openblas" echo set(SUITESPARSE_C_TO_FORTRAN "(name,NAME) name##_" CACHE STRING "" FORCE)>> "%SRC_DIR%\ss_blas.cmake"
if "%blas_impl%"=="mkl" echo set(SUITESPARSE_C_TO_FORTRAN "(name,NAME) NAME" CACHE STRING "" FORCE)>> "%SRC_DIR%\ss_blas.cmake"

:: Skip LAGraph, GraphBLAS, and Mongoose.
FOR %%G IN (SuiteSparse_config,AMD,BTF,CAMD,CCOLAMD,COLAMD,CHOLMOD,CSparse,CXSparse,LDL,KLU,UMFPACK,ParU,RBio,SPQR,SPEX) DO (
    pushd %%G\build
    if errorlevel 1 exit 1
    cmake -G "Ninja" ^
          %CMAKE_ARGS% ^
          %SS_BLAS% ^
          %SS_OPENMP_C_FLAGS% ^
          %SS_OPENMP_C_LIB_NAMES% ^
          %SS_OPENMP_LIBIOMP% ^
          -C "%SRC_DIR%\ss_blas.cmake" ^
          -DBUILD_SHARED_LIBS=ON ^
          -DBUILD_STATIC_LIBS=ON ^
          -DCMAKE_BUILD_TYPE:STRING=Release ^
          -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
          -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
          ..
    if errorlevel 1 exit 2
    cmake --build . -j%CPU_COUNT%
    if errorlevel 1 exit 3
    cmake --install .
    if errorlevel 1 exit 4
    popd
    if errorlevel 1 exit 5
)
