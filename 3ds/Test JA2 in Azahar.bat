@echo off
title Test Jagged Alliance 2 in Azahar
set "SD=%APPDATA%\Azahar\sdmc\3ds\ja2"
echo Copying engine to %SD% ...
robocopy "C:\devkitPro\3ds-projects\SD-CARD\3ds\ja2" "%SD%" /E /R:1 /W:1 /NFL /NDL /NJH /NP >nul
echo Copying JA2 Gold data (first time only, ~860 MB) ...
robocopy "C:\Program Files (x86)\Steam\steamapps\common\Jagged Alliance 2 Gold\Data" "%SD%\gamedata\Data" /E /R:1 /W:1 /NFL /NDL /NJH /NP /XO >nul
set "AZ="
for /f "delims=" %%A in ('dir /s /b "%USERPROFILE%\OneDrive\Desktop\Simgolf\azahar.exe" "%USERPROFILE%\Desktop\Simgolf\azahar.exe" "%LOCALAPPDATA%\Programs\Azahar\azahar.exe" "C:\Program Files\Azahar\azahar.exe" 2^>nul') do if not defined AZ set "AZ=%%A"
if not defined AZ (
  echo Could not find azahar.exe - open Azahar yourself and load %SD%\ja2.3dsx
  pause & exit /b 1
)
echo Starting %AZ%
start "" "%AZ%" "%SD%\ja2.3dsx"
