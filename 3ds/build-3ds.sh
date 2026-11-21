#!/bin/bash
# Rebuild ja2.3dsx (JA2 Stracciatella v0.22.1, New 3DS port). Linux x86_64 shell.
# Needs: devkitARM + libctru (DEVKITPRO), Rust nightly with rust-src, cmake, ninja, python3+PIL.
# RUST_TOOLCHAIN picks the nightly (CI pins one, e.g. nightly-2026-11-21; default: nightly).
set -e
HERE=$(cd "$(dirname "$0")" && pwd); W=${WORK:-$HOME/ja2-3ds-work}; mkdir -p $W
# Port version for the manual's contents page, taken before anything is built.
export PORT_VERSION=$(git -c safe.directory='*' -C "$HERE" describe --always --dirty 2>/dev/null || echo unknown)
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
  cargo +${RUST_TOOLCHAIN:-nightly} build -Z build-std=std,panic_abort --target armv6k-nintendo-3ds --release -p stracciatella_c_api)
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
# Always-on crash restart (3ds-test-suite hwtest/restartguard): a crash restarts the console by itself.
arm-none-eabi-gcc -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -O2 -D__3DS__ \
  -I$DEVKITPRO/libctru/include -c $HERE/selftest/restartguard.c -o $W/restartguard.o
SELFTEST_LD="$W/selftest.o $W/restartguard.o"
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
# The .3dsx lives directly in /3ds on the SD card (sdmc:/3ds/ja2.3dsx); everything else in
# /3ds/ja2/. With OUT=... (CI) everything, the .3dsx included, goes into that one folder.
if [ -z "${OUT:-}" ]; then OUT=$HERE/../../SD-CARD/3ds/ja2; APP=${APP:-$HERE/../../SD-CARD/3ds/ja2.3dsx}
else APP=${APP:-$OUT/ja2.3dsx}; fi
mkdir -p $OUT "$(dirname "$APP")"
3dsxtool $W/build/ja2.elf "$APP" --smdh=$W/ja2.smdh
arm-none-eabi-nm -C -n $W/build/ja2.elf | gzip -9 > $OUT/ja2.sym.gz   # symbol map for crash analysis (3dsx base 0x100000)
cp -r $W/strac/assets/externalized $OUT/
# SFI-SCLA: a build is a derivative work, so it travels with the licence and the change notice
cp "$W/strac/SFI Source Code license agreement.txt" $OUT/
printf '%s\n' "ja2.3dsx is a MODIFIED build of JA2 Stracciatella v0.22.1 (changed by the ja2-3ds" \
  "authors, 2026-10; see 3ds/patches/stracciatella-3ds.patch). Non-commercial use only, under" \
  "the Strategy First Inc. Source Code License Agreement in this folder. No warranty; no game data." \
  "" \
  "This build uses libsmacker, (c) 2012-2013 Greg Kennedy (http://libsmacker.sourceforge.net)," \
  "under the Creative Commons Attribution Non-Commercial License 2.0 (libsmacker-LICENSE.txt)," \
  "as modified by JA2 Stracciatella. Other third-party code (SDL2: zlib; Lua, sol2, string_theory," \
  "magic_enum: MIT; miniaudio: public domain/MIT-0; Rust crates; libctru: zlib) is listed in" \
  "NOTICE.txt in the ja2-3ds repository." > $OUT/NOTICE.txt
cp "$W/strac/dependencies/lib-smacker/LICENSE.txt" $OUT/libsmacker-LICENSE.txt
echo "built $APP (engine files in $OUT)"
