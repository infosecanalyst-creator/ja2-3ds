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
- **ZL swaps the screens** at any time. **Manual** (START > MANUAL): Circle Pad / C-Stick scroll, D-Pad moves between sections,
  L/R previous/next section, tap a section, B, START or the Close button closes.
- Quiet click and press animation on the manual's touch buttons; any button skips the intro.
- **START menu:** RESUME, MANUAL, QUICK SAVE, QUICK LOAD (asks first), SAVE / LOAD / OPTIONS, SETTINGS (MAGNIFIER, LEFT HAND), END TURN (your turn in combat) and EXIT GAME; on the main menu **CONTINUE (LAST EXIT)** in place of the save buttons. A button that cannot be used right now is grey. Questions are YES / NO with the gold ring on NO; B means no.
- **Big buttons where the game's own are tiny:** the main menu (NEW GAME, LOAD GAME, PREFERENCES, CREDITS, QUIT, and CONTINUE (LAST EXIT) when there is an exit save), every message box (one button per answer; the message itself is shown in a readable size on the top screen; the gold ring starts on No) the Options page (SAVE, LOAD, QUIT, DONE), the save / load list (SAVE or LOAD, CANCEL) and the new-game page (OK, CANCEL). Tap, or D-pad and A.
- **Dashboard:** with no merc selected and on the map it shows your money, whose turn it is or whether time is running, and the newest game messages in a readable size. With a merc selected it also shows the item in hand and its rounds; on the map it lists the team (name, sector, job, contract days, health); on the Options page it lists every option with ON / OFF (D-pad and A change them). During a load it shows "Loading..." with the percentage. The game's own help windows (they name keyboard keys) are off.
- **EXIT GAME** asks "Exit Jagged Alliance 2?" first, then saves into its own slot, `ExitSave`, and quits; HOME > Close does the same while a game is running. If that save fails the game says so and asks EXIT ANYWAY / NO. `ExitSave` never replaces your own QuickSave. CONTINUE loads it.
- Logs: `sdmc:/3ds/ja2/console.txt` (start, exit, errors; the run before is kept as `console.old.txt`); an empty `sdmc:/3ds/ja2/debug.txt` switches on the full log.

What the patch (`3ds/patches/stracciatella-3ds.patch`) changes, in short:

| Area | Change |
|---|---|
| Rust core | builds for `armv6k-nintendo-3ds` with `-Z build-std`; three dependency bumps (`Cargo.lock.3ds`); home/assets/log dir = `sdmc:/3ds/ja2` |
| File access | 64 KB read cache with open-per-read (the 3DS allows ~19 open files; SLF archives stay mounted); folder/file tests by trying to list/open; sizes via lseek |
| Runtime | `__syscall_tls_*` (pthread TLS keys) and `getrandom()` implemented for libctru |
| Video/input | direct RGB565 framebuffer output, dashboard, swap, buttons/Circle Pad mapping |
| Startup | loading progress on screen; errors shown on screen and in `sdmc:/3ds/ja2/console.txt` |
| Debug log | off by default (only start, exit, save-on-exit and error lines); an empty `sdmc:/3ds/ja2/debug.txt` turns on the full log (memory trace, engine info lines), buffered, rolled over at 1 MB |

### Build

Linux x86_64 with devkitARM + libctru (`DEVKITPRO` set), Rust nightly with `rust-src`,
cmake, ninja, python3 + Pillow, DejaVu fonts:

```
cd 3ds && ./build-3ds.sh          # writes ../../SD-CARD/3ds/ja2.3dsx + ../../SD-CARD/3ds/ja2/ (override with OUT=...)
```

### Install

Copy to the SD card (or FTP via ftpd): `ja2.3dsx` directly in `/3ds` as `sdmc:/3ds/ja2.3dsx`,
then `ja2.json` and `externalized/` (from the Stracciatella source) into `sdmc:/3ds/ja2/`,
and your JA2 Gold `Data` folder as `sdmc:/3ds/ja2/gamedata/Data`. `send-to-3ds.ps1` does it over Wi-Fi.

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

The licence is also in [`LICENSE`](LICENSE). [`NOTICE.txt`](NOTICE.txt) is the change notice and
lists the third-party code in the 3DS build, including **libsmacker** (c) Greg Kennedy, which the
game uses for its videos under the Creative Commons Attribution Non-Commercial 2.0 licence.

`brick/patches/sdl3-fbdev.patch` modifies SDL3 and is offered under SDL's zlib licence.
The JA2 Stracciatella project releases its own changes to the public domain; see its README.

## Disclaimer

Not affiliated with or endorsed by Strategy First, THQ Nordic, Sir-Tech, the JA2
Stracciatella or JA2 1.13 teams, or Nintendo. *Jagged Alliance* is a trademark of its
owner and is used here only to say which game files the engine reads.
