@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\local-multiplayer.ps1" -Action Prepare
if errorlevel 1 goto failed
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch-client.ps1" -Instance primary
set "GAME_RESULT=%ERRORLEVEL%"
if not "%GAME_RESULT%"=="0" goto failed
exit /b %GAME_RESULT%

:failed
pause
exit /b 1
