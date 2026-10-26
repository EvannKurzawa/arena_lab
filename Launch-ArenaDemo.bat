@echo off
setlocal

set "ROOT_DIR=%~dp0"
set "GAME_DIR=%ROOT_DIR%tools\runtime\essentials-v21.1-base"
set "RUBY_EXE=%ROOT_DIR%tools\runtime\ruby-portable\rubyinstaller-3.3.12-1-x64\bin\ruby.exe"
set "PLUGIN_SOURCE=%ROOT_DIR%game-mod\Plugins\ArenaDemo"
set "PLUGIN_TARGET=%GAME_DIR%\Plugins\ArenaDemo"

if not exist "%GAME_DIR%\Game.exe" goto missing_game
if not exist "%RUBY_EXE%" goto missing_ruby
if not exist "%PLUGIN_TARGET%" mkdir "%PLUGIN_TARGET%"

copy /Y "%PLUGIN_SOURCE%\001_ArenaDemo.rb" "%PLUGIN_TARGET%\001_ArenaDemo.rb" >nul
if errorlevel 1 goto copy_failed
copy /Y "%PLUGIN_SOURCE%\meta.txt" "%PLUGIN_TARGET%\meta.txt" >nul
if errorlevel 1 goto copy_failed

"%RUBY_EXE%" "%ROOT_DIR%game-mod\tools\build_arena_map.rb" "%GAME_DIR%"
if errorlevel 1 goto build_failed

pushd "%GAME_DIR%"
call PlayMMO-debug.bat
set "GAME_RESULT=%ERRORLEVEL%"
popd
exit /b %GAME_RESULT%

:missing_game
echo Could not find the local Essentials game at:
echo %GAME_DIR%
goto failed

:missing_ruby
echo Could not find the bundled Ruby runtime at:
echo %RUBY_EXE%
goto failed

:copy_failed
echo Could not copy the Arena Demo plugin into the local game.
goto failed

:build_failed
echo The arena map build failed. The game was not started.
goto failed

:failed
pause
exit /b 1
