param(
    [Parameter(Mandatory=$true)][string]$GameRoot,
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)
$ErrorActionPreference = 'Stop'
$ruby = Join-Path $ProjectRoot 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
if (!(Test-Path -LiteralPath $ruby)) { throw 'Bundled Ruby is missing; cannot update the game plugin cache.' }
$arenaSource = Join-Path $ProjectRoot 'game-mod/Plugins/ArenaDemo'
$arenaTarget = Join-Path $GameRoot 'Plugins/ArenaDemo'
$peerTarget = Join-Path $GameRoot 'Plugins/PEMK'
if (!(Test-Path -LiteralPath (Join-Path $peerTarget 'meta.txt'))) {
    $peerSource = Join-Path $ProjectRoot 'tools/runtime/pemk-workspace/Plugins/PEMK'
    if (!(Test-Path -LiteralPath (Join-Path $peerSource 'meta.txt'))) {
        throw 'PEMK plugin source is missing. Keep this error log and repair the installation before playing online.'
    }
    New-Item -ItemType Directory -Path $peerTarget -Force | Out-Null
    Get-ChildItem -LiteralPath $peerSource -Force | Copy-Item -Destination $peerTarget -Recurse -Force
}
foreach ($file in Get-ChildItem -LiteralPath $arenaSource -File) {
    if ($file.Extension -ne '.rb' -and $file.Name -ne 'meta.txt') { continue }
    $target = Join-Path $arenaTarget $file.Name
    if (Test-Path -LiteralPath $target) {
        $hash = (Get-FileHash -LiteralPath $target).Hash
        if ($hash -eq (Get-FileHash -LiteralPath $file.FullName).Hash) { continue }
        $saved = Join-Path $GameRoot "arena-plugin-backups/$hash/Plugins/ArenaDemo/$($file.Name)"
        New-Item -ItemType Directory -Path (Split-Path $saved -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $target -Destination $saved -Force
    }
    New-Item -ItemType Directory -Path $arenaTarget -Force | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $target -Force
}
& $ruby --disable-gems (Join-Path $ProjectRoot 'game-mod/tools/repair_species_dependencies.rb') $GameRoot
if ($LASTEXITCODE -ne 0) { throw 'Species compiler dependencies could not be repaired; existing PBS files preserved.' }
& $ruby --disable-gems (Join-Path $ProjectRoot 'tools/sync-plugin-cache.rb') $GameRoot
if ($LASTEXITCODE -ne 0) { throw 'The installed game plugin cache could not be updated. Do not launch the stale game.' }
Write-Host 'Installed game scripts and PEMK cache synchronized.'
