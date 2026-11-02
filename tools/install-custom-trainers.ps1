param([Parameter(Mandatory=$true)][string]$GameRoot)
$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$cache = Join-Path $PSScriptRoot 'runtime/custom-trainer-assets'
& $ruby --disable-gems (Join-Path $project 'game-mod/tools/install_custom_trainers.rb') $GameRoot $cache
if ($LASTEXITCODE -ne 0) { throw 'Custom trainer installation failed.' }
