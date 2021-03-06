#!/bin/bash
pushd `dirname $0`
. settings.sh

if [[ $DEBUG == 1 ]]; then
  echo "DEBUG = 1"
  DEBUG_FLAG="--disable-stripping"
fi

# I haven't found a reliable way to install/uninstall a patch from a Makefile,
# so just always try to apply it, and ignore it if it fails. Works fine unless
# the files being patched have changed, in which cause a partial application
# could happen unnoticed.
patch -N -p1 --reject-file=- < redact-plugins.patch
patch -N -p1 --reject-file=- < arm-asm-fix.patch
patch -d ffmpeg -N -p1 --reject-file=- < \
    ARM_generate_position_independent_code_to_access_data_symbols.patch
patch -d ffmpeg -N -p1 --reject-file=- < \
    ARM_intmath_use_native-size_return_types_for_clipping_functions.patch
patch -d ffmpeg -N -p1 --reject-file=- < \
    enable-fake-pkg-config.patch

pushd ffmpeg

./configure \
$DEBUG_FLAG \
--arch=arm \
--cpu=cortex-a8 \
--target-os=linux \
--enable-runtime-cpudetect \
--prefix=$prefix \
--cross-prefix=$NDK_TOOLCHAIN_BASE/bin/$NDK_ABI-linux-androideabi- \
--sysroot="$NDK_SYSROOT" \
--extra-cflags="-I../x264 -mfloat-abi=softfp -mfpu=neon" \
--extra-ldflags="-L../x264" \
--enable-pic \
--enable-yasm \
\
\
--disable-everything \
\
\
--enable-ffmpeg \
\
--enable-static \
\
--enable-network \
--enable-protocol=http \
--enable-protocol=file \
--enable-protocol=concat \
\
--enable-decoder=h264 \
--enable-decoder=rawvideo \
--enable-decoder=aac \
\
--enable-encoder=rawvideo \
\
--enable-parser=h264 \
--enable-parser=aac \
\
--enable-demuxer=mov \
--enable-muxer=tgp \
--enable-muxer=mp4 \
\
--enable-hwaccels

popd; popd


