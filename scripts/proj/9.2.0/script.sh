#!/usr/bin/env bash

MASON_NAME=proj
MASON_VERSION=9.2.0
MASON_LIB_FILE=lib/libproj.a
PROJ_DATA_VERSION="1.5"
SQLITE_VERSION=3.41.2
LIBTIFF_VERSION=4.5.0
JPEG_TURBO_VERSION=2.1.5.1
LIBCURL_VERSION=8.0.1

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://download.osgeo.org/proj/proj-${MASON_VERSION}.tar.gz \
        ac3a0eccfe5dc4892f48337b5ba46da58249f1ca

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install sqlite ${SQLITE_VERSION}
    ${MASON_DIR}/mason link sqlite ${SQLITE_VERSION}
    MASON_SQLITE=$(${MASON_DIR}/mason prefix sqlite ${SQLITE_VERSION})
    ${MASON_DIR}/mason install libtiff ${LIBTIFF_VERSION}
    MASON_LIBTIFF=$(${MASON_DIR}/mason prefix libtiff ${LIBTIFF_VERSION})
    ${MASON_DIR}/mason install jpeg_turbo ${JPEG_TURBO_VERSION}
    MASON_LIBCURL=$(${MASON_DIR}/mason prefix libcurl ${LIBCURL_VERSION})
    ${MASON_DIR}/mason install libcurl ${LIBCURL_VERSION}
}

function mason_compile {
    #curl --retry 3 -f -# -L https://download.osgeo.org/proj/proj-data-${PROJ_DATA_VERSION}.tar.gz -o proj-data-${PROJ_DATA_VERSION}.tar.gz
    export PATH="${MASON_ROOT}/.link/bin:${PATH}"
    #export PKG_CONFIG_PATH="${MASON_SQLITE}/lib/pkgconfig:${MASON_LIBTIFF}/lib/pkgconfig"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    mkdir build
    cd build
    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=${MASON_PREFIX} \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_CURL=ON \
        -DCURL_INCLUDE_DIR=${MASON_LIBCURL}/include \
        -DCURL_LIBRARY=${MASON_LIBCURL}/lib/libcurl.a \
        -DSQLITE3_INCLUDE_DIR=${MASON_SQLITE}/include \
        -DSQLITE3_LIBRARY=${MASON_SQLITE}/lib/libsqlite3.a \
        -DENABLE_TIFF=ON \
        -DTIFF_INCLUDE_DIR=${MASON_LIBTIFF}/include \
        -DTIFF_LIBRARY_RELEASE=${MASON_LIBTIFF}/lib/libtiff.a \
        -DBUILD_TESTING=OFF \
        -DBUILD_CCT=OFF \
        -DBUILD_CS2CS=OFF \
        -DBUILD_GEOD=OFF \
        -DBUILD_GIE=OFF \
        -DBUILD_PROJ=OFF \
        -DBUILD_PROJINFO=OFF \
        -DBUILD_PROJSYNC=OFF \
        ..
    # ./configure --prefix=${MASON_PREFIX} \
    # ${MASON_HOST_ARG} \
    # --enable-static \
    # --disable-shared \
    # --disable-dependency-tracking \
    # --without-curl
    echo `sqlite3 --version`
    make -j${MASON_CONCURRENCY}
    make install
    #cd ${MASON_PREFIX}/share/proj
    #tar xvfz proj-data-${PROJ_DATA_VERSION}.tar.gz
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo "-lproj"
}

function mason_clean {
    make clean
}

mason_run "$@"
