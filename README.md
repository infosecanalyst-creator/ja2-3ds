# ja2-3ds

An unofficial New 3DS port of the JA2 Stracciatella engine: dual-screen play with the
stylus, an info dashboard and a built-in manual. **Bring your own game files:** you need
your own copy of Jagged Alliance 2 Gold.

Also contains the TrimUI Brick (NextUI / PortMaster) build of JA2 v1.13 (1vibe13 engine).

## 3DS port (`3ds/`)

Vanilla JA2 on the [JA2 Stracciatella](https://github.com/ja2-stracciatella/ja2-stracciatella)
engine (v0.22.1), patched for the New 3DS (`armv6k-nintendo-3ds`).

- **Bottom (touch) screen:** the whole game at half size; the stylus is the mouse.
- **Top screen:** dashboard: date/time/sector, selected merc's health, energy, morale,
  action points and skills, and the controls for the current screen.
- **SWAP** (from the manual) puts the game on the top screen; the choice is saved.
- **ZL swaps the screens** at any time. **Manual** on SELECT: Circle Pad / C-Stick scroll, D-Pad moves between sections,
  L/R previous/next section, tap a section, B or START closes.
- Quiet click and press animation on the manual's touch buttons; any button skips the intro.

What the patch (`3ds/patches/stracciatella-3ds.patch`) changes, in short:

| Area | Change |
|---|---|
| Rust core | builds for `armv6k-nintendo-3ds` with `-Z build-std`; three dependency bumps (`Cargo.lock.3ds`); home/assets/log dir = `sdmc:/3ds/ja2` |
| File access | 64 KB read cache with open-per-read (the 3DS allows ~19 open files; SLF archives stay mounted); folder/file tests by trying to list/open; sizes via lseek |
| Runtime | `__syscall_tls_*` (pthread TLS keys) and `getrandom()` implemented for libctru |
| Video/input | direct RGB565 framebuffer output, dashboard, swap, buttons/Circle Pad mapping |
| Startup | loading progress on screen; errors shown on screen and in `sdmc:/3ds/ja2/console.txt` |

### Build

Linux x86_64 with devkitARM + libctru (`DEVKITPRO` set), Rust nightly with `rust-src`,
cmake, ninja, python3 + Pillow, DejaVu fonts:

```
cd 3ds && ./build-3ds.sh          # writes ../../SD-CARD/3ds/ja2/ja2.3dsx (override with OUT=...)
```

### Install

Copy to the SD card (or FTP via ftpd): `sdmc:/3ds/ja2/ja2.3dsx`, `ja2.json`,
`externalized/` (from the Stracciatella source), and your JA2 Gold `Data` folder as
`sdmc:/3ds/ja2/gamedata/Data`. `send-to-3ds.ps1` does it over Wi-Fi.

## TrimUI Brick, JA2 v1.13 (`brick/`)

The [1vibe13](https://github.com/tais/1vibe13) SDL3 engine rebuilt for the Brick (aarch64,
glibc 2.23) with an added SDL3 Linux framebuffer video driver (`brick/patches/sdl3-fbdev.patch`),
packaged as a PortMaster port at 1024x768. `build-brick.sh` builds it; `Install JA2 1.13 to Brick.bat`
copies a JA2 Gold + 1.13 install and the port to the card.

## Not included

No game data. You need your own copy of Jagged Alliance 2 Gold (GOG or Steam), and for the
Brick build, the JA2 v1.13 release.

## Licence

**Non-commercial only.** The JA2 source code was released by Strategy First Inc. under the
*Strategy First Inc. Source Code License Agreement* (SFI-SCLA), and both engines used here
(JA2 Stracciatella and 1vibe13 / JA2 1.13) derive from it. This repository's patches, tools
and scripts are distributed under the same agreement, verbatim in
[`SFI Source Code license agreement.txt`](SFI%20Source%20Code%20license%20agreement.txt).
In short:

- You may use, modify and share this for non-commercial purposes only: no selling, no paid
  builds, no bundling with commercial products.
- Anything you distribute that derives from it must carry the same licence, unchanged, and
  must not be relicensed under broader terms (such as GPL or MIT).
- Modified files must say they were changed and when: `3ds/patches/stracciatella-3ds.patch`
  carries that notice, and `build-3ds.sh` puts the licence and a `NOTICE.txt` next to every
  build.
- No warranty and no liability, as set out in sections 7 and 8 of the agreement.

`brick/patches/sdl3-fbdev.patch` modifies SDL3 and is offered under SDL's zlib licence.
The JA2 Stracciatella project releases its own changes to the public domain; see its README.

## Disclaimer

Not affiliated with or endorsed by Strategy First, THQ Nordic, Sir-Tech, the JA2
Stracciatella or JA2 1.13 teams, or Nintendo. *Jagged Alliance* is a trademark of its
owner and is used here only to say which game files the engine reads.
