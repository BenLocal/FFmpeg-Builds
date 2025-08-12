#!/bin/bash

SCRIPT_REPO="https://github.com/nyanmisaka/mpp.git"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    echo "git clone -b jellyfin-mpp --depth=1 \"$SCRIPT_REPO\" ."
}

ffbuild_dockerbuild() {
    mkdir build && cd build
    cmake \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TEST=OFF
    make -j $(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-rkmpp
}

ffbuild_unconfigure() {
    echo --disable-rkmpp
}
