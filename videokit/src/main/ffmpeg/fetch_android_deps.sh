#!/bin/bash

function make_unyaffs {
  if [ ! -f "./unyaffs/unyaffs" ]; then
    cd unyaffs
    
    make -v >/dev/null 2>&1 || { echo "I require foo but it's not installed.  Aborting." >&2; exit 1; }
    
    make    
    chmod +x ./unyaffs
    
    cd ..
  fi
}

function fetch_sysimage {
  if [ ! -d "./android-libs/$ABI" ]; then
    if [ ! -f "./$SYSIMAGE_FILE" ]; then
      wget $SYSIMAGE_LINK -P./
    fi

  unzip ./$SYSIMAGE_FILE $ABI/system.img -d./
  cd $ABI
  ../unyaffs/unyaffs system.img ./
  mkdir -p ../android-libs/$ABI
  mv ./lib ../android-libs/$ABI
  cd ..
  fi
}

echo "Fetching Android system headers"
git clone --depth=1 --branch ics-release https://github.com/CyanogenMod/android_frameworks_base.git ./android-source/frameworks/base
git clone --depth=1 --branch ics-release https://github.com/CyanogenMod/android_system_core.git ./android-source/system/core
git clone --depth=1 --branch ics-release https://github.com/CyanogenMod/android_hardware_libhardware.git ./android-source/hardware/libhardware

echo "Fetching Android libraries for linking"

make_unyaffs

#armeabi-v7a
ABI=armeabi-v7a
SYSIMAGE_FILE=sysimg_armv7a-15_r02.zip
SYSIMAGE_LINK=https://dl-ssl.google.com/android/repository/sysimg_armv7a-15_r02.zip
fetch_sysimage

#x86
ABI=x86
SYSIMAGE_FILE=sysimg_x86-15_r01.zip
SYSIMAGE_LINK=https://dl-ssl.google.com/android/repository/sys-img/x86/sysimg_x86-15_r01.zip
fetch_sysimage

#mips
ABI=mips
SYSIMAGE_FILE=sysimg_mips-15_r01.zip
SYSIMAGE_LINK=https://dl-ssl.google.com/android/repository/sys-img/mips/sysimg_mips-15_r01.zip
fetch_sysimage

#armeabi
cp -R $(pwd)/android-libs/armeabi-v7a $(pwd)/android-libs/armeabi