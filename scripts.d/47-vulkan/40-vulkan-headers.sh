#!/bin/bash

SCRIPT_REPO="https://github.com/KhronosGroup/Vulkan-Headers.git"
SCRIPT_COMMIT="v1.4.363"
SCRIPT_TAGFILTER="v?.*.*"

SCRIPT_REPO2="$SCRIPT_REPO"
SCRIPT_COMMIT2="v1.3.276"

ffbuild_dockerdl() {
    default_dl Vulkan-Headers
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" Vulkan-Headers2"
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 404 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    if [[ $ADDINS_STR == *6.1-rk* ]]; then
        cd Vulkan-Headers2
    else
        cd Vulkan-Headers
    fi

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DVULKAN_HEADERS_ENABLE_MODULE=NO -DVULKAN_HEADERS_ENABLE_TESTS=NO -DVULKAN_HEADERS_ENABLE_INSTALL=YES ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}
