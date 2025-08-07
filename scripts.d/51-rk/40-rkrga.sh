#!/bin/bash

SCRIPT_REPO="https://github.com/nyanmisaka/rk-mirrors.git"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    echo "git clone -b jellyfin-rga --depth=1 \"$SCRIPT_REPO\" rkrga"
}

ffbuild_dockerbuild() {
    meson setup rkrga rkrga_build \
    --prefix=/usr \
    --libdir=lib \
    --buildtype=release \
    --default-library=shared \
    -Dcpp_args=-fpermissive \
    -Dlibdrm=false \
    -Dlibrga_demo=false
    meson configure rkrga_build
    ninja -C rkrga_build install
}

ffbuild_configure() {
    echo --enable-rkrga
}

ffbuild_unconfigure() {
    echo --disable-rkrga
}