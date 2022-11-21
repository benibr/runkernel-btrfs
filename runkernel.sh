#!/bin/bash

while getopts ":bip" parameter; do
  case "${parameter}" in
    b)
      BUILD=1
      ;;
    p)
      BUILD_PACKAGE=1
      ;;
    i)
      RECREATE_IMAGE=1
      ;;
  esac
done

if [ "$BUILD" == "1" ]; then
  pushd linux
  make
  popd
fi
if [ "$BUILD_PACKAGE" == "1" ]; then
  pushd btrfs-progs-git/
  makepkg -f
  popd
fi
if [ "$RECREATE_IMAGE" == "1" ]; then
  LAST_PKG=$(ls -1 btrfs-progs-git/btrfs-progs-git-*tar.zst | tail -n1)
  cp $LAST_PKG mkosi.extra/
  sudo mkosi -f build
fi


read -p "ready to start QEMU"

IMAGE=./btrfs.img

qemu-system-x86_64 \
  -machine type=pc \
  -kernel linux/arch/x86/boot/bzImage \
  -nographic \
  -m 2g \
  -append "console=ttyS0 root=/dev/vda2" \
  -device virtio-scsi-pci,id=scsi \
  -drive file=./btrfs-snapshot-obsolessence-tester.img,format=raw,if=virtio \
  -drive file=$IMAGE,format=raw,if=virtio
