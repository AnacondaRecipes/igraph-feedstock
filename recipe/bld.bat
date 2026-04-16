@echo on

mkdir build
if errorlevel 1 exit 1

cd build

rem set prefix to use forward slashes when generating igraph.pc, which pkg-config won't mangle. 
rem this way the package can be used as dependency by python-igraph.
set "LIBRARY_PREFIX_FWD=%LIBRARY_PREFIX:\=/%"
set "LIBRARY_LIB_FWD=%LIBRARY_LIB:\=/%"
set "LIBRARY_INC_FWD=%LIBRARY_INC:\=/%"

if "%blas_impl%"=="openblas" (
    set "BLAS_CMAKE_FLAGS=-DBLA_VENDOR=OpenBLAS"
) else (
    set "BLAS_CMAKE_FLAGS=-DBLA_VENDOR=Intel10_64lp"
)

cmake %CMAKE_ARGS% %BLAS_CMAKE_FLAGS% -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB_FWD% ^
      -DCMAKE_INSTALL_INCLUDEDIR=%LIBRARY_INC_FWD% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX_FWD% ^
      -DCMAKE_POSITION_INDEPENDENT_CODE=on ^
      -DIGRAPH_USE_INTERNAL_BLAS=0 ^
      -DIGRAPH_USE_INTERNAL_LAPACK=0 ^
      -DIGRAPH_USE_INTERNAL_ARPACK=1 ^
      -DIGRAPH_USE_INTERNAL_GLPK=0 ^
      -DIGRAPH_USE_INTERNAL_GMP=1 ^
      -DBUILD_SHARED_LIBS=on ^
      -DIGRAPH_ENABLE_LTO=1 ^
      -DIGRAPH_ENABLE_TLS=1 ^
      -DIGRAPH_GRAPHML_SUPPORT=1 ^
      ..
if errorlevel 1 exit 1

cmake --build . --config Release --target igraph -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --build . --config Release --target build_tests -j%CPU_COUNT%
if errorlevel 1 exit 1

ctest --progress --output-on-failure --extra-verbose -j%CPU_COUNT%
if errorlevel 1 exit 1
cmake --build . --config Release --target install -j%CPU_COUNT%
if errorlevel 1 exit 1
