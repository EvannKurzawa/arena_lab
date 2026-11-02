param([string]$SourceRoot = (Join-Path $PSScriptRoot 'runtime/furniture-sources'))
$ErrorActionPreference = 'Stop'
$ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
& $ruby --disable-gems (Join-Path $PSScriptRoot 'build-extra-furniture-art.rb') $SourceRoot
if ($LASTEXITCODE -ne 0) { throw 'Furniture artwork packing failed.' }
