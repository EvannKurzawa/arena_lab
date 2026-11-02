param([ValidateSet('DS','previous')][string]$Style = 'DS')
$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$source = Join-Path $project "game-mod/AssetSources/DeviceArt-$Style"
if (!(Test-Path -LiteralPath $source)) { throw "Missing saved device art: $source" }
Get-ChildItem -LiteralPath $source -Filter '*.png' -File | Copy-Item -Destination (Join-Path $project 'game-mod/Graphics/ArenaDevices') -Force
[IO.File]::WriteAllText((Join-Path $project 'game-mod/Graphics/ArenaDevices/device-art-style.txt'), $Style, [Text.Encoding]::ASCII)
Write-Host "Selected $Style coil and magnetic antenna sprites. Restart Play-Arena.bat to install."
