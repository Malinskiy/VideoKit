#!/bin/bash
#
# build_android.sh
# Copyright (c) 2012 Jacek Marchwicki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "Compile ffmpeg shared library for Android"
                        echo " "
                        echo "options:"
                        echo "	-h, --help		show brief help"
                        echo "	-ndk			ndk dir"
                        echo "	-debug			include debug symbols"
                        exit 0
                        ;;
                -ndk)
                        shift
                        export NDK="$1"
                        shift
                        ;;
                -debug)
                        DEBUG_FLAGS="-g"
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

if [ "$NDK" = "" ]; then
	echo NDK variable not set, exiting
	echo "Use: export NDK=/your/path/to/android-ndk"
	exit 1
fi

OS=`uname -s | tr '[A-Z]' '[a-z]'`-`uname -m`

function build_faac {
	PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
	export PATH=${PATH}:$PREBUILT/bin/
	CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
	CFLAGS=$OPTIMIZE_CFLAGS
	export CPPFLAGS="$CFLAGS"
	export CFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"
	export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
	export CC="${CROSS_COMPILE}gcc-$COMPILER_VERSION --sysroot=$PLATFORM"
	export NM="${CROSS_COMPILE}nm"
	export STRIP="${CROSS_COMPILE}strip"
	export RANLIB="${CROSS_COMPILE}ranlib"
	export AR="${CROSS_COMPILE}ar"
	export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -lc -lm -ldl -llog"

	cd fdk-aac
	export PKG_CONFIG_LIBDIR=$(pwd)/$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$(pwd)/$PREFIX/lib/pkgconfig/
	autoreconf -fiv
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}

function build_aac {
	PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
	export PATH=${PATH}:$PREBUILT/bin/
	CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
	CFLAGS=$OPTIMIZE_CFLAGS
#CFLAGS=" -I$ARM_INC -fpic -DANDROID -fpic -mthumb-interwork -ffunction-sections -funwind-tables -fstack-protector -fno-short-enums -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__  -Wno-psabi -march=armv5te -mtune=xscale -msoft-float -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -DANDROID  -Wa,--noexecstack -MMD -MP "
	export CPPFLAGS="$CFLAGS"
	export CFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"
	export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
	export CC="${CROSS_COMPILE}gcc-$COMPILER_VERSION --sysroot=$PLATFORM"
	export NM="${CROSS_COMPILE}nm"
	export STRIP="${CROSS_COMPILE}strip"
	export RANLIB="${CROSS_COMPILE}ranlib"
	export AR="${CROSS_COMPILE}ar"
	export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -lc -lm -ldl -llog"

	cd vo-aacenc
	export PKG_CONFIG_LIBDIR=$(pwd)/$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$(pwd)/$PREFIX/lib/pkgconfig/
	autoreconf -fiv
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}

function build_x264 {
	PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
	export PATH=${PATH}:$PREBUILT/bin/
	CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
	CFLAGS=$OPTIMIZE_CFLAGS

	export CPPFLAGS="$CFLAGS"
	export CFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"
	export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
	export AS="${CROSS_COMPILE}as"
	export CC="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
	export NM="${CROSS_COMPILE}nm"
	export STRIP="${CROSS_COMPILE}strip"
	export RANLIB="${CROSS_COMPILE}ranlib"
	export AR="${CROSS_COMPILE}ar"
	export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -lc -lm -ldl -llog -lgcc"

	cd x264
	./configure --host=$ARCH-linux \
	--prefix=$(pwd)/$PREFIX  \
	--enable-static \
	--disable-cli \
	--disable-opencl \
	$ADDITIONAL_CONFIGURE_FLAG \
	|| exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}

function build_ffmpeg {
	PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
	CC=$PREBUILT/bin/$EABIARCH-gcc
	CXX=$PREBUILT/bin/$EABIARCH-g++
	CROSS_PREFIX=$PREBUILT/bin/$EABIARCH-
	PKG_CONFIG=${CROSS_PREFIX}pkg-config
	if [ ! -f $PKG_CONFIG ];
	then
		cat > $PKG_CONFIG << EOF
#!/bin/bash
pkg-config \$*
EOF
		chmod u+x $PKG_CONFIG
	fi
	NM=$PREBUILT/bin/$EABIARCH-nm
	cd ffmpeg
	export PKG_CONFIG_LIBDIR=$(pwd)/$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$(pwd)/$PREFIX/lib/pkgconfig/
	./configure --target-os=linux \
	    --prefix=$PREFIX \
	    --enable-cross-compile \
	    --arch=$ARCH \
	    --cc=$CC \
	    --cxx=$CXX \
	    --cross-prefix=$CROSS_PREFIX \
	    --nm=$NM \
	    --sysroot=$PLATFORM \
	    --extra-cflags=" -O2 -fPIC -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS" \
	    --extra-cxxflags="-fno-rtti" \
	    --disable-shared \
	    --enable-static \
	    --enable-runtime-cpudetect \
	    --extra-ldflags="$ADDITIONAL_LDFLAGS -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -lc -lm -ldl -llog -L$PREFIX/lib -L$ANDROID_LIBS -Wl,-rpath-link,$ANDROID_LIBS -L$ANDROID_STL_LIB" \
	    --extra-cflags=" $ANDROID_INLCLUDES -I$PREFIX/include" \
	    --disable-everything \
	    --disable-debug \
	    --enable-libx264 \
	    --enable-libfdk_aac \
	    --enable-demuxer=rawvideo \
	    --enable-demuxer=pcm_s16le \
	    --enable-demuxer=hls \
	    --enable-demuxer=mpegts \
	    --enable-muxer=stream_segment \
	    --enable-muxer=segment \
	    --enable-muxer=image2 \
	    --enable-muxer=mpegts \
	    --enable-parser=h264 \
	    --enable-encoder=libx264 \
	    --enable-encoder=libfdk_aac \
	    --enable-encoder=mjpeg \
	    --enable-decoder=h264 \
	    --enable-decoder=aac \
	    --enable-decoder=rawvideo \
	    --enable-decoder=pcm_s16le \
	    --disable-filters \
	    --enable-filter=fps \
	    --enable-filter=aresample \
	    --enable-filter=thumbnail \
	    --enable-filter=scale \
	    --enable-filter=transpose \
	    --enable-filter=vflip \
	    --enable-filter=hflip \
	    --enable-protocol=file \
	    --enable-protocol=pipe \
	    --enable-avformat \
	    --enable-avcodec \
	    --enable-avresample \
	    --disable-zlib \
	    --enable-bsf=aac_adtstoasc \
	    --enable-bsf=chomp \
	    --enable-bsf=h264_mp4toannexb \
	    --disable-doc \
	    --disable-ffplay \
	    --enable-ffmpeg \
	    --disable-ffplay \
	    --disable-ffprobe \
	    --disable-ffserver \
	    --disable-avdevice \
	    --disable-nonfree \
	    --disable-network \
	    --disable-postproc \
	    --enable-gpl \
	    --enable-nonfree \
	    --enable-version3 \
	    --enable-memalign-hack \
	    --enable-asm \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1
	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}

function build_one {
	cd ffmpeg
	PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
	$PREBUILT/bin/$EABIARCH-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L$PREFIX/lib  -L$ANDROID_LIBS -L$ANDROID_STL_LIB  -soname $SONAME -shared -nostdlib -z noexecstack -Bsymbolic --whole-archive --no-undefined -o $OUT_LIBRARY -lavcodec -lavfilter -lavformat -lavresample -lavutil -lswresample -lswscale -lx264 -lvo-aacenc -lfdk-aac -lc -lm -lz -ldl -llog $ANDROID_STAGEFRIGHT_ADDITIONAL_LIBS $CRT_BEGINOBJ  --dynamic-linker=/system/bin/linker -zmuldefs $ANDROID_LIB_GCC || exit 1
	if [ -z "$DEBUG_FLAGS" ]; then
	  $PREBUILT/bin/$EABIARCH-strip -s $OUT_LIBRARY
	fi
	cp libavformat/url.h $(pwd)/$PREFIX/include/libavformat
	cp config.h $(pwd)/$PREFIX/include
	cp libavutil/libm.h $(pwd)/$PREFIX/include/libavutil
	cp libavformat/os_support.h $(pwd)/$PREFIX/include/libavformat
	cp libavformat/ffm.h $(pwd)/$PREFIX/include/libavformat
	cp cmdutils_common_opts.h $(pwd)/$PREFIX/include
	cp $(pwd)/$PREFIX/bin/ffmpeg "$(pwd)/$PREFIX/$BINARY_NAME"
	cd ..
}

function configure_opts {
ANDROID_STL_LIB="$NDK/sources/cxx-stl/gnu-libstdc++/$COMPILER_VERSION/libs/$ABI"
ANDROID_INLCLUDES="$ANDROID_INCLUDES_BASE -I$NDK/sources/cxx-stl/gnu-libstdc++/$COMPILER_VERSION/include -I$NDK/sources/cxx-stl/gnu-libstdc++/$COMPILER_VERSION/libs/$ABI/include"
ANDROID_LIBS=$(pwd)/android-libs/$ABI/lib
PREFIX=../../jni/ffmpeg/$ABI
OUT_BINARY=../../libs/$ABI/
OUT_LIBRARY=$PREFIX/$SONAME
CRT_BEGINOBJ="$PREBUILT/lib/gcc/$EABIARCH/$COMPILER_VERSION/crtbegin.o $PREBUILT/lib/gcc/$EABIARCH/$COMPILER_VERSION/crtend.o"
ANDROID_LIB_GCC="$PREBUILT/lib/gcc/$EABIARCH/$COMPILER_VERSION/libgcc.a"
PLATFORM_VERSION=android-9
}

./fetch_android_deps.sh

ANDROID_SOURCE=$(pwd)/android-source
ANDROID_INCLUDES_BASE="-I$ANDROID_SOURCE/frameworks/base/include"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/frameworks/base/include/media/stagefright/openmax"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/frameworks/base/native/include"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/frameworks/native/include"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/frameworks/native/include/media/openmax"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/frameworks/av/include"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/system/core/include"
ANDROID_INCLUDES_BASE="$ANDROID_INCLUDES_BASE -I$ANDROID_SOURCE/hardware/libhardware/include"
ANDROID_STAGEFRIGHT_ADDITIONAL_LIBS="-lstagefright -lmedia -lutils -lbinder -lgnustl_shared"

#arm v5
EABIARCH=arm-linux-androideabi
ARCH=arm
ABI=armeabi
CPU=armv5
OPTIMIZE_CFLAGS="-marm -march=$CPU $DEBUG_FLAGS"
ADDITIONAL_CONFIGURE_FLAG=--disable-asm
ADDITIONAL_LDFLAGS=
COMPILER_VERSION=4.6
SONAME=libffmpeg.so
BINARY_NAME=lib_xyz.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-$COMPILER_VERSION/prebuilt/$OS
configure_opts
build_x264
build_aac
build_faac
build_ffmpeg
build_one

#x86
EABIARCH=i686-linux-android
ARCH=x86
ABI=x86
OPTIMIZE_CFLAGS="-m32 $DEBUG_FLAGS"
ADDITIONAL_CONFIGURE_FLAG=--disable-asm
ADDITIONAL_LDFLAGS=
COMPILER_VERSION=4.6
SONAME=libffmpeg.so
BINARY_NAME=lib_xyz.so
PREBUILT=$NDK/toolchains/x86-$COMPILER_VERSION/prebuilt/$OS
configure_opts
build_x264
build_aac
build_faac
build_ffmpeg
build_one

#mips
EABIARCH=mipsel-linux-android
ARCH=mips
ABI=mips
OPTIMIZE_CFLAGS="-EL -march=mips32 -mips32 -mhard-float $DEBUG_FLAGS"
ADDITIONAL_CONFIGURE_FLAG="--disable-mips32r2 --disable-mipsdspr1 --disable-mipsdspr2"
ADDITIONAL_LDFLAGS="-fuse-ld=mcld"
COMPILER_VERSION=4.8
SONAME=libffmpeg.so
BINARY_NAME=lib_xyz.so
PREBUILT=$NDK/toolchains/mipsel-linux-android-$COMPILER_VERSION/prebuilt/$OS
#configure_opts
#build_x264
#build_aac
#build_faac
#build_ffmpeg
#build_one

#arm v7vfpv3
EABIARCH=arm-linux-androideabi
ARCH=arm
ABI=armeabi-v7a
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU $DEBUG_FLAGS"
ADDITIONAL_CONFIGURE_FLAG=--disable-asm
ADDITIONAL_LDFLAGS=
COMPILER_VERSION=4.6
SONAME=libffmpeg.so
BINARY_NAME=lib_xyz.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-$COMPILER_VERSION/prebuilt/$OS
configure_opts
build_x264
build_aac
build_faac
build_ffmpeg
build_one

#arm v7 + neon (neon also include vfpv3-32)
EABIARCH=arm-linux-androideabi
ARCH=arm
ABI=armeabi-v7a
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8 -mthumb -D__thumb__ $DEBUG_FLAGS"
ADDITIONAL_CONFIGURE_FLAG="--enable-neon --disable-asm"
ADDITIONAL_LDFLAGS=
COMPILER_VERSION=4.6
SONAME=libffmpeg-neon.so
BINARY_NAME=lib_xyz_neon.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-$COMPILER_VERSION/prebuilt/$OS
configure_opts
build_x264
build_aac
build_faac
build_ffmpeg
build_one
