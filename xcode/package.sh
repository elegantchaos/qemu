#!/bin/bash

WORKING_DIR=$(pwd -P)
BUILD_DIR="$WORKING_DIR/.build/obj"
INSTALL_DIR="$WORKING_DIR/.build/installed"
PACKAGE_DIR="$WORKING_DIR/.build/package"
ROOT_DIR=$(dirname $0)

if [[ ! -e "$INSTALL_DIR" ]]
then
  source "$ROOT_DIR/build.sh"
fi

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
pushd "$PACKAGE_DIR"

echo "Copying binaries."
ditto "$INSTALL_DIR/bin"/* .
ditto "$BUILD_DIR/ppc-softmmu/qemu-system-ppc" .

echo "Copying bios."
ditto "$INSTALL_DIR/share/qemu" ./pc-bios

echo "Copying libraries."
rm -rf "libs"
mkdir -p "libs"
function fix_libs() {
  local TARGET=$1
  shift
  echo "Fixing references in $TARGET."

  while (( "$#" ))
  do
    local LIB="$1"
    local NAME=$(basename "$LIB")
    if [[ ! -e "libs/$NAME.dylib" ]]
    then
      echo "Copying library $NAME."
      cp -f "$LIB.dylib" "libs/"
    fi

    install_name_tool -change "$LIB.dylib" "@executable_path/libs/$NAME.dylib" $TARGET
    shift
  done

  chmod a+w libs/*
}


APP_LIBS=( \
  "/usr/local/opt/glib/lib/libgio-2.0.0" \
  "/usr/local/opt/glib/lib/libgobject-2.0.0" \
  "/usr/local/opt/glib/lib/libglib-2.0.0" \
  "/usr/local/opt/libusb/lib/libusb-1.0.0" \
  "/usr/local/opt/vde/lib/libvdeplug.3" \
  "/usr/local/opt/libssh/lib/libssh.4" \
  "/usr/local/opt/pixman/lib/libpixman-1.0" \
  "/usr/local/opt/libpng/lib/libpng16.16" \
  "/usr/local/opt/jpeg/lib/libjpeg.9" \
  "/usr/local/opt/lzo/lib/liblzo2.2" \
  "/usr/local/opt/glib/lib/libgthread-2.0.0" \
  "/usr/local/opt/nettle/lib/libnettle.6" \
  "/usr/local/opt/gnutls/lib/libgnutls.30" \
  )


GLIB_LIBS=( \
  "/usr/local/Cellar/glib/2.64.1_1/lib/libglib-2.0.0" \
  "/usr/local/opt/gettext/lib/libintl.8" \
  "/usr/local/Cellar/glib/2.64.1_1/lib/libgobject-2.0.0" \
  "/usr/local/Cellar/glib/2.64.1_1/lib/libgmodule-2.0.0" \
  "/usr/local/opt/pcre/lib/libpcre.1" \
  "/usr/local/opt/libffi/lib/libffi.6" \
  "/usr/local/opt/openssl@1.1/lib/libcrypto.1.1" \
  "/usr/local/opt/p11-kit/lib/libp11-kit.0" \
  "/usr/local/opt/libidn2/lib/libidn2.0" \
  "/usr/local/opt/libunistring/lib/libunistring.2" \
  "/usr/local/opt/libtasn1/lib/libtasn1.6" \
  "/usr/local/opt/nettle/lib/libnettle.6" \
  "/usr/local/opt/nettle/lib/libhogweed.4" \
  "/usr/local/opt/gmp/lib/libgmp.10" \
  "/usr/local/Cellar/nettle/3.4.1/lib/libnettle.6" \
  )

fix_libs "qemu-system-ppc" "${APP_LIBS[@]}"
fix_libs "libs/libgthread-2.0.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libgio-2.0.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libglib-2.0.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libgobject-2.0.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libgmodule-2.0.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libssh.4.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libgnutls.30.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libp11-kit.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libidn2.0.dylib" "${GLIB_LIBS[@]}"
fix_libs "libs/libhogweed.4.dylib" "${GLIB_LIBS[@]}"


chmod a-w libs/*

echo "Zipping..."
ditto -c "$PACKAGE_DIR" "$WORKING_DIR/qemu.zip"

echo "Done."
open "$WORKING_DIR"

#
# #fix dependencies of qemu-system-ppc
# install_name_tool -change /usr/local/opt/glib/lib/libgthread-2.0.0.dylib @executable_path/Libs/libgthread-2.0.0.dylib qemu-system-ppc
# install_name_tool -change /usr/local/opt/glib/lib/libglib-2.0.0.dylib @executable_path/Libs/libglib-2.0.0.dylib qemu-system-ppc
# install_name_tool -change /usr/local/opt/gettext/lib/libintl.8.dylib @executable_path/Libs/libintl.8.dylib qemu-system-ppc
# install_name_tool -change /usr/local/opt/pixman/lib/libpixman-1.0.dylib @executable_path/Libs/libpixman-1.0.dylib qemu-system-ppc
# install_name_tool -change /usr/local/opt/libpng/lib/libpng16.16.dylib @executable_path/Libs/libpng16.16.dylib qemu-system-ppc
# install_name_tool -change /usr/local/opt/libusb/lib/libusb-1.0.0.dylib @executable_path/Libs/libusb-1.0.0.dylib qemu-system-ppc
# install_name_tool -change /usr/local/opt/usbredir/lib/libusbredirparser.1.dylib @executable_path/Libs/libusbredirparser.1.dylib qemu-system-ppc
#
# #fix dependencies of qemu-img
# install_name_tool -change /usr/local/opt/glib/lib/libgthread-2.0.0.dylib @executable_path/Libs/libgthread-2.0.0.dylib qemu-img
# install_name_tool -change /usr/local/opt/glib/lib/libglib-2.0.0.dylib @executable_path/Libs/libglib-2.0.0.dylib qemu-img
# install_name_tool -change /usr/local/opt/gettext/lib/libintl.8.dylib @executable_path/Libs/libintl.8.dylib qemu-img
#
# cd Libs
#
# #fix dependencies of libgthread-2.0.0.dylib
# sudo install_name_tool -change /usr/local/Cellar/glib/2.46.2/lib/libglib-2.0.0.dylib @executable_path/Libs/libglib-2.0.0.dylib libgthread-2.0.0.dylib
# sudo install_name_tool -change /usr/local/opt/gettext/lib/libintl.8.dylib @executable_path/Libs/libintl.8.dylib libgthread-2.0.0.dylib
