#!/bin/sh -ex

cd sources/kernel/kernel-4.4

export ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-

num_cpu=$(nproc)

# Build kernel
make "$JETSON_KERNEL_CONFIG" \
     snappy/containers.config \
     snappy/generic.config \
     snappy/security.config \
     snappy/snappy.config \
     snappy/systemd.config
make -j"$num_cpu" zImage modules dtbs

# Copy around files to install folder, so they can be staged

make -j"$num_cpu" INSTALL_MOD_PATH="$SNAPCRAFT_PART_INSTALL" modules_install
mv "$SNAPCRAFT_PART_INSTALL"/lib/* "$SNAPCRAFT_PART_INSTALL"/
rmdir "$SNAPCRAFT_PART_INSTALL"/lib
mkdir "$SNAPCRAFT_PART_INSTALL"/dtbs
cp arch/arm64/boot/dts/*.dtb "$SNAPCRAFT_PART_INSTALL"/dtbs

KERNEL_RELEASE=$(ls -1 "$SNAPCRAFT_PART_INSTALL"/modules)
cp arch/arm64/boot/zImage "$SNAPCRAFT_PART_INSTALL"/kernel.img
ln "$SNAPCRAFT_PART_INSTALL"/kernel.img "$SNAPCRAFT_PART_INSTALL"/zImage-"$KERNEL_RELEASE"
cp System.map "$SNAPCRAFT_PART_INSTALL"/System.map-"$KERNEL_RELEASE"
cp .config "$SNAPCRAFT_PART_INSTALL"/config-"$KERNEL_RELEASE"

# Get initramfs from core snap, which we need to download
core_url=$(curl -s -H "X-Ubuntu-Series: 16" -H "X-Ubuntu-Architecture: arm64" \
                "https://search.apps.ubuntu.com/api/v1/snaps/details/core?channel=stable" \
               | jq -r ".anon_download_url")
curl -L "$core_url" > core.snap
# Glob so we get both link and regular file
unsquashfs core.snap "boot/initrd.img-core*"
cp squashfs-root/boot/initrd.img-core "$SNAPCRAFT_PART_INSTALL"/initrd.img
ln "$SNAPCRAFT_PART_INSTALL"/initrd.img "$SNAPCRAFT_PART_INSTALL"/initrd-"$KERNEL_RELEASE".img
