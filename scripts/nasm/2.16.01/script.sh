#!/usr/bin/env bash

MASON_NAME=nasm
MASON_VERSION=2.16.01
MASON_LIB_FILE=bin/nasm

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://www.nasm.us/pub/nasm/releasebuilds/${MASON_VERSION}/${MASON_NAME}-${MASON_VERSION}.tar.bz2 \
        b64a8dc792f409694fe1e5aedf107c7904572486

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    echo ${MASON_HOST_ARG}
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG}

    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
