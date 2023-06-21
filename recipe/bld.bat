@echo on
setlocal enabledelayedexpansion

mkdir build
if errorlevel 1 exit 1

cd build

set "path_to_lib=%LIBRARY_PREFIX%\mingw-w64\lib"
set "path_to_lib_forwardslashes=!path_to_lib:\=\/!"
echo %path_to_lib_forwardslashes%

cmake %CMAKE_ARGS% -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB% ^
      -DCMAKE_INSTALL_INCLUDEDIR=%LIBRARY_INC% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_MODULE_PATH="%path_to_lib_forwardslashes%/pkgconfig" ^
      -DARPACK_LIBRARY=%path_to_lib_forwardslashes%
      -DCMAKE_POSITION_INDEPENDENT_CODE=on ^
      -DIGRAPH_USE_INTERNAL_BLAS=0 ^
      -DIGRAPH_USE_INTERNAL_LAPACK=0 ^
      -DIGRAPH_USE_INTERNAL_ARPACK=0 ^
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

ctest --progress --output-on-failure --config Release --extra-verbose -j%CPU_COUNT%
if errorlevel 1 exit 1
cmake --build . --config Release --target install -j%CPU_COUNT%
if errorlevel 1 exit 1
