@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\local-multiplayer.ps1" -Action Server
if errorlevel 1 goto failed
exit /b 0
:failed
echo Server startup failed. Review the error above and tools\runtime\pemk-server.log.
pause
exit /b 1
