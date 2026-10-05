#!/bin/bash

package_variant() {
    IN="$1"
    OUT="$2"

    mkdir -p "$OUT"/bin
    cp "$IN"/bin/* "$OUT"/bin

    if [[ $TARGET == linuxarm64 && $ADDINS_STR == *-rk* ]]; then
        mkdir -p "$OUT/lib"
        cp -a "$IN"/lib/librockchip_*.so* "$IN"/lib/librga.so* "$OUT/lib"
    fi

    mkdir -p "$OUT/doc"
    cp -r "$IN"/share/doc/ffmpeg/* "$OUT"/doc

    mkdir -p "$OUT/man"
    cp -r "$IN"/share/man/* "$OUT"/man

    mkdir -p "$OUT/presets"
    cp "$IN"/share/ffmpeg/*.ffpreset "$OUT"/presets
}
