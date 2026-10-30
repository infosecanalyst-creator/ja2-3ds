#!/bin/bash
# Rebuild the Brick binaries (run in a Linux x86_64 shell with python3, pip, git).
# Produces JA2_ENGLISH / JA2UB_ENGLISH in ./out
set -e
H=$PWD/work; mkdir -p $H/bin $H/sys/include $H/sys/lib out
pip install --user -q ziglang cmake ninja
export PATH=$HOME/.local/bin:$PATH
Z=$(python3 -c "import ziglang,os;print(os.path.dirname(ziglang.__file__))")/zig
printf '#!/bin/sh\nexec %s cc -target aarch64-linux-gnu.2.23 -mcpu=cortex_a53 "$@"\n' $Z > $H/bin/zcc
printf '#!/bin/sh\nexec %s c++ -target aarch64-linux-gnu.2.23 -mcpu=cortex_a53 "$@"\n' $Z > $H/bin/zcxx
printf '#!/bin/sh\nexec %s ar "$@"\n' $Z > $H/bin/zar; printf '#!/bin/sh\nexec %s ranlib "$@"\n' $Z > $H/bin/zranlib
chmod +x $H/bin/*
# TrimUI SDK (download once into ./sdk): https://github.com/trimui/toolchain_sdk_smartpro/releases/download/20231018/SDK_usr_tg5040_a133p.tgz
# ALSA headers + lib from the TrimUI SDK (sdk/SDK_usr_tg5040_a133p.tgz)
tar xzf sdk/SDK_usr_tg5040_a133p.tgz -C $H usr/include/alsa usr/lib/libasound.so.2.0.0
cp -r $H/usr/include/alsa $H/sys/include/; cp $H/usr/lib/libasound.so.2.0.0 $H/sys/lib/libasound.so
sed "s|@BIN@|$H/bin|g; s|@SYS@|$H/sys|g" toolchain/brick-toolchain.cmake > $H/toolchain.cmake
[ -d $H/sdl3 ] || { git clone -q https://github.com/libsdl-org/SDL.git $H/sdl3; (cd $H/sdl3 && git checkout -q 9b230dfb36d21f6c0133ecadcb4860ebefe6b1a2 && git apply ../../patches/sdl3-fbdev.patch); }
[ -d $H/v13 ] || git clone -q --branch v0.10.0-alpha1 --depth 1 https://github.com/tais/1vibe13.git $H/v13
cmake -S $H/v13 -B $H/build -G Ninja >/dev/null 2>&1 || true   # first run only copies a preset template
cmake -S $H/v13 -B $H/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$H/toolchain.cmake \
  -DUSE_CCACHE=OFF -DFETCHCONTENT_SOURCE_DIR_SDL3=$H/sdl3 -DCMAKE_EXE_LINKER_FLAGS=-s \
  -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_KMSDRM=OFF -DSDL_OPENGL=OFF -DSDL_OPENGLES=OFF -DSDL_VULKAN=OFF \
  -DSDL_UNIX_CONSOLE_BUILD=ON -DSDL_ALSA=ON -DALSA_LIBRARY=$H/sys/lib/libasound.so -DALSA_INCLUDE_DIR=$H/sys/include \
  -DSDL_PULSEAUDIO=OFF -DSDL_PIPEWIRE=OFF -DSDL_JACK=OFF -DSDL_SNDIO=OFF -DSDL_DBUS=OFF -DSDL_IBUS=OFF \
  -DSDL_LIBUDEV=OFF -DSDL_HIDAPI=OFF -DSDLMIXER_WAVPACK=OFF -DSDLMIXER_GME=OFF -DSDLMIXER_MOD=OFF -DSDLMIXER_MIDI=OFF
ninja -C $H/build JA2_ENGLISH JA2UB_ENGLISH
cp $H/build/JA2_ENGLISH $H/build/JA2UB_ENGLISH out/
