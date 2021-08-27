#!/bin/bash

UNIBREAK_REPO="https://github.com/adah1972/libunibreak.git"
UNIBREAK_COMMIT="a6bcee2daf6fb884edd1ff78ce58521ab31f9826"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$UNIBREAK_REPO" "$UNIBREAK_COMMIT" unibreak
    cd unibreak
    
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
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
