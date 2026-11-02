$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$work = Join-Path $env:TEMP ('Arena-SharedAssets-Test-' + [guid]::NewGuid().ToString('N'))
$game = Join-Path $work 'game [fixture]'
$source = Join-Path $project 'game-mod/SharedAssets'
try {
    & "$PSScriptRoot/install-shared-assets.ps1" -GameRoot $game
    $files = @(Get-ChildItem -LiteralPath $source -Recurse -File)
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($source.Length + 1)
        if ((Get-FileHash -LiteralPath (Join-Path $game $relative)).Hash -ne (Get-FileHash -LiteralPath $file.FullName).Hash) { throw "Missing/different asset: $relative" }
    }
    & "$PSScriptRoot/install-shared-assets.ps1" -GameRoot $game
    if (Test-Path -LiteralPath (Join-Path $game 'arena-asset-backups')) { throw 'Unchanged install created backups' }
    $gold = Join-Path $game 'Graphics/Trainers/GOLD.png'
    [IO.File]::WriteAllText($gold, 'previous personal sprite')
    $oldHash = (Get-FileHash -LiteralPath $gold).Hash
    & "$PSScriptRoot/install-shared-assets.ps1" -GameRoot $game
    $saved = Join-Path $game "arena-asset-backups/$oldHash/Graphics/Trainers/GOLD.png"
    if ([IO.File]::ReadAllText($saved) -ne 'previous personal sprite') { throw 'Personal sprite backup missing' }
    if ((Get-FileHash -LiteralPath $gold).Hash -ne (Get-FileHash -LiteralPath (Join-Path $source 'Graphics/Trainers/GOLD.png')).Hash) { throw 'Published revision did not replace old asset' }
    [IO.File]::WriteAllText($gold, 'updater previous sprite')
    $backup = Join-Path $work 'update-backup'
    & "$PSScriptRoot/install-shared-assets.ps1" -GameRoot $game -BackupRoot $backup
    if ([IO.File]::ReadAllText((Join-Path $backup 'tools/runtime/essentials-v21.1-base/Graphics/Trainers/GOLD.png')) -ne 'updater previous sprite') { throw 'Updater rollback backup missing' }
    $future = Join-Path $work 'future/Audio/SE'
    New-Item -ItemType Directory -Path $future -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $future 'New sound.wav'), 'future asset')
    & "$PSScriptRoot/install-shared-assets.ps1" -GameRoot $game -SourceRoot (Join-Path $work 'future')
    if ([IO.File]::ReadAllText((Join-Path $game 'Audio/SE/New sound.wav')) -ne 'future asset') { throw 'Future asset was not installed' }
    Write-Host "Shared assets checks passed: $($files.Count) published files, clean install, repeat install, replacement, backups, future asset."
} finally {
    if ([IO.Path]::GetFullPath($work).StartsWith([IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}
