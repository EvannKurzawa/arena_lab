param(
    [Parameter(Mandatory = $true)][string]$GameRoot,
    [string]$ArchivePath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'Following Pokemon EX.rar')
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$rubyExe = Join-Path $projectRoot 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$pluginTarget = Join-Path $GameRoot 'Plugins/Following Pokemon EX'
$marker = Join-Path $GameRoot 'Data/ArenaFollowingPokemonEX.sha256'

if (!(Test-Path -LiteralPath $ArchivePath)) {
    if ((Test-Path -LiteralPath (Join-Path $pluginTarget 'meta.txt')) -and
        (Select-String -LiteralPath (Join-Path $pluginTarget 'meta.txt') -Pattern '^Version\s*=\s*2\.5\.1\s*$' -Quiet)) {
        Write-Host 'Following Pokemon EX 2.5.1 is already installed in the local Essentials project.'
        return
    }
    if (!(Test-Path -LiteralPath $pluginTarget)) {
        Write-Host 'Optional Following Pokemon EX archive not found; continuing without follower visuals. Arena Lab and multiplayer remain available.'
        return
    }
    throw "An incompatible Following Pokemon plugin is installed, but no replacement archive was provided. To enable followers, supply the Essentials 21.1 archive at '$ArchivePath' (https://eeveeexpo.com/resources/516/)."
}
if (!(Test-Path -LiteralPath $rubyExe)) { throw 'Bundled Ruby is missing; run the Arena Lab installer first.' }

$archiveHash = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash
$installedHash = if (Test-Path -LiteralPath $marker) { (Get-Content -LiteralPath $marker -Raw).Trim() } else { '' }
if ($installedHash -eq $archiveHash -and (Test-Path -LiteralPath (Join-Path $pluginTarget 'meta.txt'))) {
    Write-Host 'Following Pokemon EX 2.5.1 is already prepared.'
    return
}

$stage = Join-Path ([IO.Path]::GetTempPath()) ("arena-following-ex-" + [guid]::NewGuid().ToString('N'))
Write-Host 'Extracting Following Pokemon EX v2.5.1 for Essentials 21.1...'
New-Item -ItemType Directory -Path $stage | Out-Null
try {
    & tar.exe -xf $ArchivePath -C $stage 'Plugins/Following Pokemon EX' 'Graphics/Characters/Followers' 'Graphics/Animations' 'Data/Animations.rxdata'
    if ($LASTEXITCODE -ne 0) { throw 'Could not extract the Following Pokemon EX archive. Confirm it is the v21.1 RAR from the Eevee Expo resource.' }
    $pluginStage = Join-Path $stage 'Plugins/Following Pokemon EX'
    $meta = Join-Path $pluginStage 'meta.txt'
    if (!(Test-Path -LiteralPath $meta) -or !(Select-String -LiteralPath $meta -Pattern '^Version\s*=\s*2\.5\.1\s*$' -Quiet) -or !(Select-String -LiteralPath $meta -Pattern '^Essentials\s*=\s*21\.1\s*$' -Quiet)) {
        throw 'The archive is not Following Pokemon EX 2.5.1 for Essentials 21.1.'
    }
    $sourceAnimations = Join-Path $stage 'Data/Animations.rxdata'
    $targetAnimations = Join-Path $GameRoot 'Data/Animations.rxdata'
    if (!(Test-Path -LiteralPath $sourceAnimations) -or !(Test-Path -LiteralPath $targetAnimations)) { throw 'The plugin or Essentials animation data is missing.' }
    if (Test-Path -LiteralPath $pluginTarget) {
        $existingMeta = Join-Path $pluginTarget 'meta.txt'
        if (!(Test-Path -LiteralPath $existingMeta) -or !(Select-String -LiteralPath $existingMeta -Pattern '^Version\s*=\s*2\.5\.1\s*$' -Quiet)) {
            throw 'A different Following Pokemon EX plugin already exists. Review it before replacing it.'
        }
    }
    foreach ($relative in @('Graphics/Characters/Followers', 'Graphics/Animations')) {
        $source = Join-Path $stage $relative
        $destination = Join-Path $GameRoot $relative
        if (!(Test-Path -LiteralPath $source)) { throw "The archive is missing $relative." }
        if (!(Test-Path -LiteralPath $destination)) { continue }
        Get-ChildItem -LiteralPath $source -File -Recurse | ForEach-Object {
            $subPath = $_.FullName.Substring($source.Length).TrimStart('\')
            $target = Join-Path $destination $subPath
            if ((Test-Path -LiteralPath $target) -and
                (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash) {
                throw "A different local asset already exists at $relative/$subPath; it was preserved."
            }
        }
    }
    Write-Host 'Merging follower animations while keeping Essentials animations...'
    if (!(Test-Path -LiteralPath $marker)) {
        & $rubyExe (Join-Path $PSScriptRoot 'merge-following-animations.rb') $GameRoot $sourceAnimations $pluginStage
        if ($LASTEXITCODE -ne 0) { throw 'Following Pokemon EX animations could not be merged safely.' }
    } else {
        throw 'A different Following Pokemon EX archive is already recorded. Restore the Arena Lab animation backup before changing the plugin archive.'
    }

    Write-Host 'Installing plugin scripts and walking sprite assets...'
    New-Item -ItemType Directory -Path (Split-Path $pluginTarget) -Force | Out-Null
    if (Test-Path -LiteralPath $pluginTarget) { Remove-Item -LiteralPath $pluginTarget -Recurse -Force }
    Copy-Item -LiteralPath $pluginStage -Destination $pluginTarget -Recurse
    foreach ($relative in @('Graphics/Characters/Followers', 'Graphics/Animations')) {
        $source = Join-Path $stage $relative
        $destination = Join-Path $GameRoot $relative
        if (!(Test-Path -LiteralPath $source)) { throw "The archive is missing $relative." }
        & robocopy.exe $source $destination /E /COPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP
        if ($LASTEXITCODE -ge 8) { throw "Could not install $relative assets (robocopy exit $LASTEXITCODE)." }
    }
    Set-Content -LiteralPath $marker -Value $archiveHash -Encoding ASCII
    Write-Host 'Installed Following Pokemon EX 2.5.1, its walking sprites, and merged its animations without replacing Essentials animations.'
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
}
