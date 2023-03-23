#!/usr/bin/env bash

MASON_NAME=libtiff
MASON_VERSION=4.5.0
MASON_LIB_FILE=lib/libtiff.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libtiff-4.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://download.osgeo.org/libtiff/tiff-${MASON_VERSION}.tar.gz \
        2a73f477513d6953146c682cbd7ae977c70ede91

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/tiff-${MASON_VERSION}
}

function mason_prepare_compile {
    JPEG_VERSION=2.1.5.1
    ${MASON_DIR}/mason install jpeg_turbo ${JPEG_VERSION}
    MASON_JPEG=$(${MASON_DIR}/mason prefix jpeg_turbo ${JPEG_VERSION})
    ZLIB_VERSION=1.2.13
    ${MASON_DIR}/mason install zlib ${ZLIB_VERSION}
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib ${ZLIB_VERSION})
}


function mason_compile {
    # note CFLAGS overrides defaults (-g -O2 -Wall -W) so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=${MASON_PREFIX} \
        -DBUILD_SHARED_LIBS=OFF \
        -Djpeg=ON \
        -DJPEG_INCLUDE_DIR=${MASON_JPEG}/include \
        -DJPEG_LIBRARY=${MASON_JPEG}/lib/libturbojpeg.a \
        -DZLIB_INCLUDE_DIR=${MASON_ZLIB}/include \
        -DZLIB_LIBRARY=${MASON_ZLIB}/lib/libz.a \
        -DCXX=OFF \
        -Dlerc=OFF \
        -Dlzma=OFF \
        -Djbig=OFF \
        -Dmdi=OFF \
        -Djpeg12=OFF \
        -Dwebp=OFF \
        -Dpixarlog=OFF \
        -Dnext=OFF \
        -Dold-jpeg=OFF \
        -Dlogluv=OFF \
        -Dthunder=OFF \
        -Dpackbits=OFF \
        -Dccitt=OFF \
        -Dzstd=OFF \
        .
    # ./configure --prefix=${MASON_PREFIX} \
    # ${MASON_HOST_ARG} \
    # --enable-static --disable-shared \
    # --enable-largefile \
    # --enable-defer-strile-load \
    # --enable-chunky-strip-read \
    # --disable-jpeg12 \
    # --disable-dependency-tracking \
    # --disable-cxx \
    # --with-jpeg-include-dir=${MASON_JPEG}/include \
    # --with-jpeg-lib-dir=${MASON_JPEG}/lib \
    # --with-zlib-include-dir=${MASON_ZLIB}/include \
    # --with-zlib-lib-dir=${MASON_ZLIB}/lib \
    # --disable-lzma --disable-jbig --disable-mdi \
    # --without-x --disable-pixarlog --disable-next --disable-old-jpeg --disable-logluv \
    # --disable-thunder --disable-packbits --disable-ccitt

    make -j${MASON_CONCURRENCY} V=1
    make install
}

function mason_ldflags {
    echo "-ltiff -ljpeg -lz"
}

function mason_clean {
    make clean
}

mason_run "$@"
