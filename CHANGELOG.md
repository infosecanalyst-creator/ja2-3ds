# Changelog

## 2026-11-21

- New CONTINUE (LAST EXIT) button on the main menu's START menu: loads the game that EXIT GAME or HOME > Close saved.
- EXIT GAME and HOME > Close now save into their own slot, "ExitSave", so they no longer overwrite your own QuickSave. If that save fails you are asked EXIT ANYWAY or NO instead of losing progress.
- Saving is safer: saves over an old slot keep a backup until the new file is in place, and writes are checked.
- Saving and loading are faster (buffered writes); the screen redraws only what changed, so play is smoother.
- If the game errors out while a game is running, it makes an emergency save first.
- The START menu hints follow the left-hand setting.
- The manual's chapter 11 now explains all of this, with the files and logs.

## 2026-11-20

- Install path: the program is /3ds/ja2.3dsx (data stays in /3ds/ja2/).
- Detailed logging is off by default (smaller, faster); an empty /3ds/ja2/debug.txt turns it on. console.txt gets both normal and error output.
- HOME > Close quick-saves first, like EXIT GAME; fixed a crash when exiting.
- Manual: drag the stylus to scroll, with a little momentum; the section buttons act on a tap. The contents page shows the build version.
- Licence notices added.
