@echo off
setlocal
start "" powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\play-arena.ps1"
