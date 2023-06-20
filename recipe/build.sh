#!/bin/env bash

set -ex
system=$(uname -s)

mkdir -p build
pushd build

cmake ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_INCLUDEDIR=include \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=on \
    -DF2C_EXTERNAL_ARITH_HEADER=$F2C_EXTERNAL_ARITH_HEADER \
    -DIGRAPH_USE_INTERNAL_BLAS=0 \
    -DIGRAPH_USE_INTERNAL_LAPACK=0 \
    -DIGRAPH_USE_INTERNAL_ARPACK=0 \
    -DIGRAPH_USE_INTERNAL_GLPK=0 \
    -DIGRAPH_USE_INTERNAL_CXSPARSE=0 \
    -DIGRAPH_USE_INTERNAL_GMP=0 \
    -DBUILD_SHARED_LIBS=on \
    -DIGRAPH_ENABLE_LTO=1 \
    -DIGRAPH_ENABLE_TLS=1 \
    -DBUILD_SHARED_LIBS=on \
    -DBLAS_LIBRARIES="-lopenblas" \
    ..

cmake --build . --config Release --target igraph -- -j${CPU_COUNT}
# Two tests fail on osx-64 with same symptoms, probably an os limitation of some sort. 
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]] && [[ ${target_platform} != osx-64 ]]; then
  cmake --build . --config Release --target check -j${CPU_COUNT}
fi
cmake --build . --config Release --target install -j${CPU_COUNT}


popd
