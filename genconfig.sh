#!/bin/bash
# simple script for extending all the configs

# root directory of universal5420 kernel git repo (default is this script's location)
RDIR=$(pwd)

# directory containing cross-compile armhf toolchain
TOOLCHAIN=$HOME/build/toolchain/gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabihf

export ARCH=arm
export CROSS_COMPILE=$TOOLCHAIN/bin/arm-linux-gnueabihf-

ABORT()
{
	[ "$1" ] && echo "Error: $*"
	exit 1
}

[ -x "${CROSS_COMPILE}gcc" ] ||
ABORT "Unable to find gcc cross-compiler at location: ${CROSS_COMPILE}gcc"

cd "$RDIR" || ABORT "Failed to enter $RDIR!"

while read -r defconfig_file; do
	defconfig=${defconfig_file##*/}
	echo "Defconfig: $defconfig"

	rm -rf build
	mkdir build
	make -s -i -C "$RDIR" O=build "$defconfig" \
		EXTRA_DEFCONFIG=all_defconfig oldconfig
	cp build/.config "$defconfig_file"
	echo "Copied new config to $defconfig_file"
	rm -rf build
done < <(find arch/$ARCH/configs -name "*_*_defconfig")

echo "Done."
