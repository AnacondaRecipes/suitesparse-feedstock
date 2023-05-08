:: SuiteSparse 7.0 build instructions for windows are to add all cmake projects individually to Visual Studio.
:: We're going the same way.

echo on

copy /Y /V %RECIPE_DIR%\\SuiteSparseBLAS.cmake SuiteSparse_config\\cmake_modules\\SuiteSparseBLAS.cmake
if errorlevel 1 exit 1

set JOBS=4
set CMAKE_OPTIONS="%CMAKE_ARGS% -DCMAKE_PREFIX_PATH=%PREFIX% -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_INSTALL_LIBDIR=Library/lib -DCMAKE_INSTALL_BINDIR=Library/bin -DENABLE_CUDA=0"
echo %CMAKE_OPTIONS%

:: make all except graphblas, mongoose and spex
FOR %%G IN (SuiteSparse_config,AMD,BTF,CAMD,CCOLAMD,COLAMD,CHOLMOD,CSparse,CXSparse,LDL,KLU,UMFPACK,RBio,SuiteSparse_GPURuntime,GPUQREngine,SPQR) DO (
    pushd %%G\\build
    if errorlevel 1 exit 1
    cmake -G "Ninja" ^
          %CMAKE_ARGS% ^
          -DENABLE_CUDA=0 ^
          -DCMAKE_BUILD_TYPE=Release ^
          -DCMAKE_PREFIX_PATH=%PREFIX% ^
          -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
          ..
    if errorlevel 1 exit 1
    cmake --build . --config Release
    if errorlevel 1 exit 1
    cmake --install .
    if errorlevel 1 exit 1
    popd
    if errorlevel 1 exit 1
)
