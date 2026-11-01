param([Parameter(Mandatory=$true)][string]$GameRoot, [string]$SourceSheet = '')
$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$importer = Join-Path $project 'game-mod/tools/install_dark_lugia.rb'
if (!$SourceSheet) { $SourceSheet = Join-Path $project 'xd001.png' }
& $ruby --disable-gems $importer $GameRoot $SourceSheet
if ($LASTEXITCODE -ne 0) { throw 'Dark Lugia sprite import failed.' }
