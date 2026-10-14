#!/bin/bash

SCRIPT_REPO="https://github.com/alsa-project/alsa-lib.git"
SCRIPT_COMMIT="81d70a27136840fa8fb1bec6eb8e04fc1475a380" # v1.2.14

ffbuild_enabled() {
    [[ $TARGET == linuxarm64 && $ADDINS_STR == *-rk* ]]
}

ffbuild_dockerbuild() {
    autoreconf -fi

    # Keep relocatable code, but use ALSA's static built-in plugin registration.
    # alsa-lib rejects --with-pic for static builds; -DPIC selects dlopen instead.
    export CFLAGS="${CFLAGS//-DPIC/} -fPIC"

    ./configure \
        --prefix="$FFBUILD_PREFIX" \
        --host="$FFBUILD_TOOLCHAIN" \
        --disable-shared \
        --enable-static \
        --disable-python \
        --with-configdir=/usr/share/alsa \
        --with-plugindir=/usr/lib/alsa-lib
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-alsa --enable-indev=alsa --enable-outdev=alsa
}
