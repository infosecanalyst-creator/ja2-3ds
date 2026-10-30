@echo off
title Send Jagged Alliance 2 to 3DS (ftpd)
echo Start ftpd on the 3DS, then enter the IP address it shows.
echo First run uploads ~860 MB of game data; later runs only send what changed.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0send-to-3ds.ps1"
pause
