#!/bin/env bash

set -x -e

export LIBIGRAPH_FALLBACK_INCLUDE_DIRS="${PREFIX}/include"
export LIBIGRAPH_FALLBACK_LIBRARY_DIRS="${PREFIX}/lib"

if [ "$(uname)" == "Linux" ]
then
   export LDFLAGS="$LDFLAGS -Wl,-rpath-link,${PREFIX}/lib"
fi
# fix the simple test runner which doesn't use ldflags
export CC="${CC} ${CFLAGS} ${LDFLAGS}"

./configure --prefix=${PREFIX} | sed "s/$PREFIX/<PREFIX>/g"
make -j $CPU_COUNT
(make check | sed "s/$PREFIX/<PREFIX>/g") || (cat tests/testsuite.log && exit 1)
make install
mv igraph.pc ${PREFIX}/lib/pkgconfig
