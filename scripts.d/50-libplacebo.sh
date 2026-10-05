#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libplacebo.git"
SCRIPT_COMMIT="1937beef3a2f508266c68efea1491e3fc4600e04"

SCRIPT_REPO2="$SCRIPT_REPO"
SCRIPT_COMMIT2="2bd627f823ba1cedbc51a0ee6eb7a9fb433d912e"

ffbuild_depends() {
    echo base
    echo vulkan
    echo lcms2
    echo xxhash
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 600 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl libplacebo
    echo "cd libplacebo && git submodule update --init --recursive --depth=1 --filter=blob:none && cd .."
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" libplacebo2"
    echo "cd libplacebo2 && git submodule update --init --recursive --depth=1 --filter=blob:none && cd .."
}

ffbuild_dockerbuild() {
    if [[ $ADDINS_STR == *6.1-rk* ]]; then
        cd libplacebo2
        sed -i 's/DPL_EXPORT/DPL_STATIC/' src/meson.build
        # Python 3.14 requires an Element rather than a nested ElementTree.
        sed -i 's/VkXML(ET.parse(xmlfile))/VkXML(ET.parse(xmlfile).getroot())/' src/vulkan/utils_gen.py
    else
        cd libplacebo
    fi

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dvulkan=enabled
        -Dvk-proc-addr=enabled
        -Dvulkan-registry="$FFBUILD_PREFIX"/share/vulkan/registry/vk.xml
        -Dshaderc=enabled
        -Dglslang=disabled
        -Dlcms=enabled
        -Dxxhash=enabled
        -Ddemos=false
        -Dtests=false
        -Dbench=false
        -Dfuzz=false
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            -Dd3d11=enabled
        )
    fi

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

    echo "Libs.private: -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libplacebo.pc
}

ffbuild_configure() {
    echo --enable-libplacebo
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 500 )) || return 0
    echo --disable-libplacebo
}
