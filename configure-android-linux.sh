#!/bin/bash
#
# Then just run something like:
#
EXAMPLE="./configure-android-linux.sh android-14 arch-arm"

NDK=$ANDROID_NDK_ROOT
echo "Current NDK path: $NDK"

echo "Checking make...$(which make)"

if [ -z "${NDK}" ]; then
    echo "Need to specify NDK environment variable(ANDROID_NDK_ROOT) when calling."
    echo "  -- e.g. ANDROID_NDK_ROOT=/home/yourname/android-ndk-r8e"
    exit 1
fi

if [ "$#" -lt "2" ]; then
    echo "Usage: ./configure-android-linux.sh <platform> <architecture>"
    echo "  -- e.g. ${EXAMPLE}"
    exit 1
else
    PLATFORM=$1
    shift

    ARCHITECTURE=$1
    shift

    COMPILER_VERSION="4.6"

    # Try 64bit
    TOOLCHAIN=${NDK}/toolchains/arm-linux-androideabi-${COMPILER_VERSION}/prebuilt/linux-x86_64/bin
    if [ ! -d "$TOOLCHAIN" ]; then
        echo "Cannot find x86-64bit toolchain, Use 32bit toolchain"
        TOOLCHAIN=${NDK}/toolchains/arm-linux-androideabi-${COMPILER_VERSION}/prebuilt/linux/bin
    fi

    export NDK_TOOLCHAIN=${TOOLCHAIN}
    export CROSS_COMPILE=arm-linux-androideabi

    export AR=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ar
    export CC=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-gcc
    export CXX=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-g++
    export LD=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ld

    export SYSROOT=${NDK}/platforms/${PLATFORM}/${ARCHITECTURE}

    export CPPFLAGS="--sysroot=${SYSROOT} -DANDROID_HARDWARE_generic"
    export CFLAGS="--sysroot=${SYSROOT} -static"

    MACHINE=$( ${CXX} -dumpmachine )

    echo "Machine:           ${MACHINE}"
    echo "Sysroot (Android): ${SYSROOT}"

    argString=""
    
    while [ "$1" != "" ]; do
    argString="${argString} $1"
    shift
    done

    ./configure --prefix=/data/local/valgrind --host=armv7-unknown-linux --target=armv7-unknown-linux

fi
