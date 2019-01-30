#!/bin/sh

OPENWRT_OR_LEDE_TOOLCHAIN_FOR_ARM7=/mnt/build/lede/ac58u/staging_dir/toolchain-arm_cortex-a7+neon-vfpv4_gcc-8.1.0_musl_eabi/bin/
BOARDNAME=$1

die() {
	echo Error: $1
	exit 1
}

no_toolchain() {
	cat << EOF

No working toolchain was found for the given directoy.
      >>> You have to make one.<<<
LEDE/OpenWRT toolchains work fine for this.

Return once you finished.
EOF

	exit 1
}

[ -z "$BOARDNAME" ] && die "Usage: make-uboot <BOARDNAME>"

[ -e "$OPENWRT_OR_LEDE_TOOLCHAIN_FOR_ARM7" ] || no_toolchain

export PATH="$PATH:$OPENWRT_OR_LEDE_TOOLCHAIN_FOR_ARM7"

arm-openwrt-linux-gcc -v || no_toolchain
arm-openwrt-linux-ld -v || no_toolchain

make clean || die "Can't clean old cruft"

USE_PRIVATE_LIBGCC=yes make $BOARDNAME || die "Failed to set build target"

USE_PRIVATE_LIBGCC=yes make || die "Failure during u-boot build"

[ -e u-boot.bin ] || die "Build succeeded. But u-boot.bin wasn't created"

fritz/fritzcreator.sh $BOARDNAME || die "Failure during Fritzing"

[ -e uboot-${BOARDNAME}.bin ] || die "No idea, but the uboot-${BOARDNAME}.bin wasn't created."
