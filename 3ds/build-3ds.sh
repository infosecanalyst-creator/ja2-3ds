#!/bin/bash
# Rebuild ja2.3dsx (JA2 Stracciatella v0.22.1, New 3DS port). Linux x86_64 shell.
# Needs: devkitARM + libctru (DEVKITPRO), Rust nightly with rust-src, cmake, ninja, python3+PIL.
set -e
HERE=$(cd "$(dirname "$0")" && pwd); W=${WORK:-$HOME/ja2-3ds-work}; mkdir -p $W
: "${DEVKITPRO:?set DEVKITPRO}"; export DEVKITARM=$DEVKITPRO/devkitARM PATH=$DEVKITARM/bin:$DEVKITPRO/tools/bin:$PATH
# 1. SDL2 for 3DS
[ -d $W/sdl2 ] || git clone -q --depth 1 --branch release-2.30.9 https://github.com/libsdl-org/SDL.git $W/sdl2
cmake -S $W/sdl2 -B $W/sdl2/build -G Ninja -DCMAKE_TOOLCHAIN_FILE=$DEVKITPRO/cmake/3DS.cmake -DCMAKE_BUILD_TYPE=Release \
  -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST=OFF -DCMAKE_INSTALL_PREFIX=$W/prefix && ninja -C $W/sdl2/build install
# 2. Stracciatella source + 3DS patch
if [ ! -d $W/strac ]; then
  git clone -q --depth 1 --branch v0.22.1 https://github.com/ja2-stracciatella/ja2-stracciatella.git $W/strac
  (cd $W/strac && git apply $HERE/patches/stracciatella-3ds.patch && cp $HERE/patches/Cargo.lock.3ds rust/Cargo.lock)
fi
# 3. Rust core for armv6k-nintendo-3ds
export CC_armv6k_nintendo_3ds=arm-none-eabi-gcc AR_armv6k_nintendo_3ds=arm-none-eabi-gcc-ar
export CFLAGS_armv6k_nintendo_3ds="-march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -D__3DS__ -I$DEVKITPRO/libctru/include"
mkdir -p $W/prefix/strac/include $W/prefix/strac/lib
(cd $W/strac/rust && HEADER_LOCATION=$W/prefix/strac/include/stracciatella.h CARGO_TARGET_DIR=$W/ctarget \
  cargo +nightly build -Z build-std=std,panic_abort --target armv6k-nintendo-3ds --release -p stracciatella_c_api)
cp $W/ctarget/armv6k-nintendo-3ds/release/libstracciatella_c_api.a $W/prefix/strac/lib/
# 4. Game
# Generated headers first: the game is compiled with them (they used to be written
# after ninja, so builds shipped the stale manual from the patch: labels cut off).
python3 $HERE/tools/gen_font.py $W/strac/src/sgp/n3ds/N3DS_Font.h
python3 $HERE/tools/gen_manual.py $HERE/docs/manual.txt $W/strac/src/sgp/n3ds/N3DS_Manual.h
# Hardware test hooks (3ds-test-suite hwtest/selftest): inactive unless the test
# agent starts the game with --selftest=<script>. Linked as one object with --wrap.
arm-none-eabi-gcc -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -O2 -D__3DS__ \
  -I$DEVKITPRO/libctru/include -c $HERE/selftest/selftest.c -o $W/selftest.o
SELFTEST_LD="$W/selftest.o"
for f in hidScanInput hidKeysHeld hidKeysDown hidKeysDownRepeat hidKeysUp hidTouchRead hidCircleRead irrstCstickRead aptMainLoop; do
  SELFTEST_LD="$SELFTEST_LD -Wl,--wrap=$f"
done
cmake -S $W/strac -B $W/build -G Ninja -DCMAKE_TOOLCHAIN_FILE=$DEVKITPRO/cmake/3DS.cmake -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS_RELEASE="$SELFTEST_LD" \
  -DPREBUILT_STRACCIATELLA_DIR=$W/prefix/strac -DSDL2_INCLUDE_DIR=$W/prefix/include/SDL2 \
  -DSDL2_LIBRARY_TEMP=$W/prefix/lib/libSDL2.a -DSDL2MAIN_LIBRARY=$W/prefix/lib/libSDL2main.a \
  -DWITH_UNITTESTS=OFF -DWITH_RUST_BINARIES=OFF -DBUILD_LAUNCHER=OFF
ninja -C $W/build
# 5. Package into the one SD-CARD location
python3 -c "from PIL import Image; Image.open('$W/strac/assets/icons/logo.png').convert('RGBA').resize((48,48)).save('$W/icon48.png')"
smdhtool --create "Stracciatella 3DS" "Plays your own JA2 Gold data (non-commercial)" "ja2-3ds (unofficial)" $W/icon48.png $W/ja2.smdh
OUT=${OUT:-$HERE/../../SD-CARD/3ds/ja2}; mkdir -p $OUT   # override with OUT=...
3dsxtool $W/build/ja2.elf $OUT/ja2.3dsx --smdh=$W/ja2.smdh
arm-none-eabi-nm -C -n $W/build/ja2.elf | gzip -9 > $OUT/ja2.sym.gz   # symbol map for crash analysis (3dsx base 0x100000)
cp -r $W/strac/assets/externalized $OUT/
# SFI-SCLA: a build is a derivative work, so it travels with the licence and the change notice
cp "$W/strac/SFI Source Code license agreement.txt" $OUT/
printf '%s\n' "ja2.3dsx is a MODIFIED build of JA2 Stracciatella v0.22.1 (changed by the ja2-3ds" \
  "authors, 2026-10; see 3ds/patches/stracciatella-3ds.patch). Non-commercial use only, under" \
  "the Strategy First Inc. Source Code License Agreement in this folder. No warranty; no game data." > $OUT/NOTICE.txt
echo "built $OUT/ja2.3dsx"
