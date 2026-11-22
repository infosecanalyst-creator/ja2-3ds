# Changelog

## 2026-11-21

- CONTINUE (LAST EXIT) now loads the exit save itself. On the console it loaded another save from the list (the QuickSave), because the Load screen chose its own entry again after CONTINUE had picked the exit save.
- CONTINUE (LAST EXIT) and Load no longer end on the game's Options screen with an older save: a save that names any screen other than the tactical screen or the map now opens the map (exit saves and quick saves written before the fix above named the Options screen). console.txt gets a line when a save is loaded.
- A game saved by EXIT GAME / HOME > Close opens on the tactical or map screen when loaded (before, it could open on the game's Options screen).
- CONTINUE (LAST EXIT) in the START menu now really loads the exit save from the main menu (before, nothing happened: the main menu never ran the fade the load was waiting for).
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
