#!/bin/bash

while getopts ":kip" parameter; do
  case "${parameter}" in
    k)
      BUILD_KERNEL=1
      ;;
    p)
      BUILD_PROGS=1
      ;;
    i)
      RECREATE_IMAGE=1
      ;;
  esac
done

if [ "$BUILD_KERNEL" == "1" ]; then
  pushd linux
  make
  popd
fi
if [ "$BUILD_PROGS" == "1" ]; then
  pushd mkosi.extra/btrfs-progs/
  ./autogen.sh  && ./configure && make
  popd
fi
if [ "$RECREATE_IMAGE" == "1" ]; then
  sudo mkosi -f build
fi


read -p "ready to start QEMU"

IMAGE=./btrfs.img

qemu-system-x86_64 \
  -machine type=pc \
  -kernel linux/arch/x86/boot/bzImage \
  -nographic \
  -m 1g \
  -smp 8 \
  -append "console=ttyS0 rw root=/dev/vda2" \
  -device virtio-scsi-pci,id=scsi \
  -drive file=./btrfs-snapshot-obsolessence-tester.img,format=raw,if=virtio \
  -drive file=$IMAGE,format=raw,if=virtio
