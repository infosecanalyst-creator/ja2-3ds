# Changelog

## 2026-11-21 (night: audit fixes)

- Message boxes get big answer buttons at the foot of the touch screen (the game's own YES / NO are about 22 x 9 pixels there), and the message is shown in a readable size on the top screen. The gold ring starts on No. Tap, or D-pad and A.
- The "Surrender?" box seen right after CONTINUE is the game's own: with one to three mercs against at least three times as many enemies, an enemy offers surrender. It is not a loading fault. It can now be answered with the big buttons, and the enemy's words are listed on the dashboard. The manual explains it.
- Main menu: big buttons for NEW GAME, LOAD GAME, PREFERENCES, CREDITS and QUIT (QUIT asks first), plus CONTINUE (LAST EXIT) when there is an exit save. The top screen says how to choose, how to read small text and how to carry on.
- Options page: big SAVE, LOAD, QUIT and DONE buttons. Save / load list: big SAVE or LOAD and CANCEL buttons (D-pad up / down picks a slot). New-game page: big OK and CANCEL buttons.
- START menu: new QUICK SAVE and QUICK LOAD (QUICK LOAD asks first, focus on NO), END TURN on your turn in combat, and a SETTINGS page holding MAGNIFIER and LEFT HAND. Buttons that cannot be used are grey.
- Dashboard: with no merc selected and on the map it shows money, turn or time state, the number of mercs and the newest game messages in a readable size. The main menu page is no longer nearly empty.
- Loading: the top screen shows "Loading..." with the percentage for the whole load.
- The game's own help windows are off: they name keyboard keys and close with a 9-pixel X.
- EXIT GAME shows the same sentence on both screens.
- Manual: Close button (in place of Save/Load/Quit, which is in the START menu); the highlighted section has the gold ring.
- Hint lines use one style: "Button: what it does".
- Settings that cannot be written to the SD card are reported (log line and a line on the SETTINGS page). The log of the run before is kept as console.old.txt.

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
