@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\local-multiplayer.ps1" -Action Ready
if errorlevel 1 goto failed
rem Close existing game windows before rebuilding the local map.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\local-multiplayer.ps1" -Action Prepare
if errorlevel 1 goto failed
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch-client.ps1" -Instance primary
if errorlevel 1 goto failed
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch-client.ps1" -Instance guest
if errorlevel 1 goto failed
exit /b 0
:failed
pause
exit /b 1
