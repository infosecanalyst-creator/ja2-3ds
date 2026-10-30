@echo off
setlocal
title Install Jagged Alliance 2 v1.13 to TrimUI Brick
set "SRC=C:\devkitPro\3ds-projects\ja2-113-3ds\JA2-113"
set "PORT=%~dp0port"
set "DRV=I:"
set /p "DRV=Brick SD card drive letter [I:]: "
if "%DRV:~-1%" neq ":" set "DRV=%DRV%:"
set "PORTS=%DRV%\Roms\Ports (PORTS)"

if not exist "%PORTS%\.ports\" (
  echo.
  echo Could not find "%PORTS%\.ports" - is the Brick card in %DRV% with PortMaster installed?
  pause
  exit /b 1
)

echo.
echo Copying game data (about 3.5 GB, ~93,000 files). Nothing on the card is deleted.
robocopy "%SRC%" "%PORTS%\.ports\ja2-113" /E /MT:16 /R:1 /W:1 /NFL /NDL /NP /NJH ^
  /XD Docs Shaders ja2server ^
  /XF *.exe *.dll *.url *.ico *.pdf *.vdf ddraw.ini Ja2.ini Ja2.ini.orig INIEditor*.xml XMLEditor*.xml "XML Editor.exe.config" Game.ico
if %ERRORLEVEL% GEQ 8 goto fail

echo Copying Brick engine, controls and settings...
robocopy "%PORT%\ja2-113" "%PORTS%\.ports\ja2-113" /E /R:1 /W:1 /NFL /NDL /NP /NJH
if %ERRORLEVEL% GEQ 8 goto fail
copy /Y "%PORT%\Jagged Alliance 2 v1.13.sh" "%PORTS%\" >nul || goto fail

echo.
echo Done. Eject the card safely before removing it, then look for
echo "Jagged Alliance 2 v1.13" under Ports on the Brick.
pause
exit /b 0

:fail
echo.
echo Copy FAILED (robocopy code %ERRORLEVEL%). Check the card and try again - it is safe to re-run.
pause
exit /b 1
