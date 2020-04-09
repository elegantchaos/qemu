#!/bin/sh

BUILD_DIR="$PWD/qemu-built/build"
INSTALL_DIR="$PWD/qemu-built/installed"
ROOT_DIR=$(dirname $0)

if [[ ! -e "$BUILD_DIR" ]]
then
  mkdir -p "$BUILD_DIR"
  pushd "$BUILD_DIR"
  "../../../configure" --target-list="ppc-softmmu" --audio-drv-list="coreaudio" --enable-libusb --enable-kvm --enable-hvf --enable-cocoa --prefix="$INSTALL_DIR"
  popd
fi

pushd "$BUILD_DIR"
make install
popd
