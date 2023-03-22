#!/usr/bin/env bash

MASON_NAME=jpeg_turbo
MASON_VERSION=2.1.5.1
MASON_LIB_FILE=lib/libjpeg.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://downloads.sourceforge.net/project/libjpeg-turbo/${MASON_VERSION}/libjpeg-turbo-${MASON_VERSION}.tar.gz \
        0a4a0fa277688681057bc09fd56e5c92de98ffd9

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libjpeg-turbo-${MASON_VERSION}
}

function mason_prepare_compile {
    MASON_PLATFORM= ${MASON_DIR}/mason install nasm 2.16.01
    MASON_NASM=$(MASON_PLATFORM= ${MASON_DIR}/mason prefix nasm 2.16.01)
}

function mason_compile {
    # note CFLAGS overrides defaults so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export ASM="${MASON_NASM}/bin/nasm"
    cmake \
        -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
        -DBUILD_SHARED_LIBS=OFF \
        -DWITH_JPEG8=1 \
        -DWITH_JAVA=0

    make V=1 -j1 # -j1 since build breaks with concurrency
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo -L${MASON_PREFIX}/lib -ljpeg
}

function mason_clean {
    make clean
}

mason_run "$@"
