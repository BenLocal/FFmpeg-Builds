#!/bin/bash

# this is the upstream repo of rga
# SCRIPT_REPO="https://github.com/JeffyCN/mirrors.git"
# SCRIPT_COMMIT="d7a0a485ed6c201f882c20b3a8881e801f131385"
# SCRIPT_BRANCH="linux-rga-multi"

# this is a fork from nyanmisaka with some additional fixes
SCRIPT_REPO="https://github.com/nyanmisaka/rk-mirrors.git"
SCRIPT_COMMIT="571a880951583a3b2a04e7e1fa900861653befde"
SCRIPT_BRANCH="jellyfin-rga"

ffbuild_enabled() {
    [[ $TARGET == linuxarm64 && $ADDINS_STR == *-rk* ]]
}

ffbuild_depends() {
    echo base
    echo rkmpp
}

ffbuild_dockerbuild() {
    export CFLAGS="$RAW_CFLAGS"
    export CXXFLAGS="$RAW_CXXFLAGS"

    mkdir builddir && cd builddir

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=shared
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}

ffbuild_configure() {
    echo --enable-rkrga
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *-rk* ]] || return 0
    echo --disable-rkrga
}

ffbuild_libs() {
    echo -lstdc++
}
