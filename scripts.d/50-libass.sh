#!/bin/bash

#ASS_REPO="https://github.com/libass/libass.git"
#ASS_COMMIT="a8456e673c473a081febb4c2da5ba90457574c6d"
ASS_REPO="https://github.com/BenLocal/libass.git"
ASS_BRANCH="unibreak"


ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --branch "$ASS_BRANCH" "$ASS_REPO" ass
    cd ass

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --enable-libunibreak
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
