param(
    [Parameter(Mandatory=$true)][string]$GameRoot,
    [string]$BackupRoot = '',
    [string]$SourceRoot = (Join-Path $PSScriptRoot '../game-mod/SharedAssets')
)
$ErrorActionPreference = 'Stop'
$SourceRoot = [IO.Path]::GetFullPath($SourceRoot).TrimEnd('\', '/')
# Only graphics/audio from the published asset tree may enter the game.
# No runtime directory, configuration, database or save is imported.
foreach ($category in @('Graphics', 'Audio')) {
    $base = Join-Path $SourceRoot $category
    if (!(Test-Path -LiteralPath $base)) { continue }
    foreach ($file in Get-ChildItem -LiteralPath $base -Recurse -File) {
        if ($file.Extension.ToLowerInvariant() -notin @('.png','.jpg','.jpeg','.gif','.bmp','.ogg','.mp3','.wav','.mid','.midi')) {
            throw "Unsupported shared asset: $($file.FullName)"
        }
        $relative = Join-Path $category $file.FullName.Substring($base.Length + 1)
        $target = Join-Path $GameRoot $relative
        if (Test-Path -LiteralPath $target) {
            if ((Get-FileHash -LiteralPath $target).Hash -eq (Get-FileHash -LiteralPath $file.FullName).Hash) { continue }
            # Keep each replaced version available, including personal edits.
            $saved = if ($BackupRoot) { Join-Path $BackupRoot "tools/runtime/essentials-v21.1-base/$relative" } else {
                Join-Path $GameRoot ("arena-asset-backups/" + (Get-FileHash -LiteralPath $target).Hash + "/$relative")
            }
            New-Item -ItemType Directory -Path (Split-Path $saved -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $saved -Force
        }
        New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force
    }
}
Write-Host 'Shared game graphics and audio installed.'
