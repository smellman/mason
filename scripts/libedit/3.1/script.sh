#!/usr/bin/env bash

MASON_NAME=libedit
MASON_VERSION=3.1
MASON_LIB_FILE=lib/libedit.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    # mason_download fails with 406 error
    mason_download \
        https://www.dropbox.com/s/teaqxjh5rhc0759/libedit-20221030-${MASON_VERSION}.tar.gz \
        9de8011b84997904bbd0317ba9cf2f85201f3ece
    # mason_download \
    #     https://www.thrysoee.dk/editline/libedit-20221030-${MASON_VERSION}.tar.gz \
    #     9de8011b84997904bbd0317ba9cf2f85201f3ece

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libedit-20221030-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    # HAVE__SECURE_GETENV allows compatibility with old (circa ubuntu precise) glibc
    # per https://sourceware.org/glibc/wiki/Tips_and_Tricks/secure_getenv
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    if [[ $(uname -s) == 'Linux' ]]; then
        export CFLAGS="${CFLAGS} -DHAVE___SECURE_GETENV=1"
    fi
    ./configure \
        --prefix=${MASON_PREFIX} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    V=1 make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_clean {
    make clean
}

mason_run "$@"
