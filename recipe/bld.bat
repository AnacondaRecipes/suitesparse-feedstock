:: SuiteSparse 7.0 build instructions for windows are to add all cmake projects individually to Visual Studio.
:: We're going the same way.

echo on

:: Skip LAGraph, GraphBLAS, and Mongoose.
FOR %%G IN (SuiteSparse_config,AMD,BTF,CAMD,CCOLAMD,COLAMD,CHOLMOD,CSparse,CXSparse,LDL,KLU,UMFPACK,ParU,RBio,SPQR,SPEX) DO (
    pushd %%G\\build
    if errorlevel 1 exit 1
    cmake -G "Ninja" ^
          %CMAKE_ARGS% ^
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
