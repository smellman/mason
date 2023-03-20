#!/usr/bin/env bash

MASON_NAME=zlib
MASON_VERSION=1.2.13
MASON_LIB_FILE=lib/libz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/zlib.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/madler/zlib/archive/v${MASON_VERSION}.tar.gz \
        adf740834fcce1eb379b7bdc921c0a079a169551

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/zlib-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        --static

    make install -j${MASON_CONCURRENCY}
}

mason_run "$@"
