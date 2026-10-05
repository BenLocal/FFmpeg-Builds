#!/bin/bash

SCRIPT_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
SCRIPT_COMMIT="a58ce739be0dfb083643d929aee8f0e0ba9bdf63"

SCRIPT_REPO2="$SCRIPT_REPO"
SCRIPT_COMMIT2="v0.3.0.0"

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 701 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl OpenAPV
    echo "cd OpenAPV && git fetch --unshallow --filter=blob:none && cd .."
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" OpenAPV8.1"
    echo "cd OpenAPV8.1 && git fetch --unshallow --filter=blob:none && cd .."
}

ffbuild_dockerbuild() {
    if [[ $ADDINS_STR == *8.1-rk* ]]; then
        # Rockchip 8.1 uses the metadata API from OpenAPV 0.3.
        cd OpenAPV8.1
    else
        cd OpenAPV
    fi

    # No need to build this
    echo > app/CMakeLists.txt

    mkdir build && cd build

    if [[ $TARGET == *32 ]]; then
        export CFLAGS="$CFLAGS -msse -msse2"
        export CXXFLAGS="$CXXFLAGS -msse -msse2"
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DOAPV_APP_STATIC_BUILD=ON -DENABLE_TESTS=OFF ..

    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"

    rm -rf "$FFBUILD_DESTPREFIX"/{bin,lib/oapv,lib/import,include/oapv/oapv_exports.h,lib/liboapv.so*}

    {
        echo "Libs.private: -lm"
        echo "Cflags.private: -DOAPV_STATIC_DEFINE"
    } >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/oapv.pc
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 701 )) || return 0
    echo --disable-liboapv
}
