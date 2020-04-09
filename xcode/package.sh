#!/bin/sh

WORKING_DIR=$(pwd -P)
BUILD_DIR="$WORKING_DIR/qemu-built/build"
INSTALL_DIR="$WORKING_DIR/qemu-built/installed"
PACKAGE_DIR="$WORKING_DIR/qemu-built/package"
ROOT_DIR=$(dirname $0)

if [[ ! -e "$INSTALL_DIR" ]]
then
  source "$ROOT_DIR/build.sh"
fi

mkdir -p "$PACKAGE_DIR"
pushd "$PACKAGE_DIR"

ditto "$INSTALL_DIR/bin"/* .
ditto "$BUILD_DIR/ppc-softmmu/qemu-system-ppc" .

rm -rf "libs"
mkdir -p "libs"

func fix_libs() {
  local TARGET=$1
  local LIBS=$2

  for LIB in ${LIBS[@]}
  do
    local NAME=$(basename "$LIB")
    echo "Packaging library $NAME"
    cp -f "$LIB.dylib" "libs/"
    install_name_tool -change "$LIB.dylib" "@executable_path/libs/$NAME.dylib" qemu-system-ppc
  done

  chmod a+w libs/*
}


LIBS=( \
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

fix_libs "qemu-system-ppc" $LIBS

LIBS=( \
  "/usr/local/Cellar/glib/2.64.1_1/lib/libglib-2.0.0" \
  "/usr/local/opt/gettext/lib/libintl.8" \
  )

fix_libs "libs/libgthread-2.0.0.dylib" $LIBS

chmod a-w libs/*

open "$PACKAGE_DIR"

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
