param([switch]$Download)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$runtimeRoot = Join-Path $PSScriptRoot 'runtime'
$gameRoot = Join-Path $runtimeRoot 'essentials-v21.1-base'
$engineRoot = Join-Path $runtimeRoot 'mkxp-official-test'
$archive = Join-Path $runtimeRoot 'downloads/mkxp-official-windows.zip'
$commit = '37a04d14413454551a7b6aadbb4e93e67168accb'
$archiveHash = 'F9438D765F608CD99186EABF92C3BE9D7B2EDA0F93D83D51CA45BFE9D53C3B59'
$binaryHash = '3ACB84AEACEC93F80D40372B041F2774E454F63454561BDD90AF173A62760768'
$url = 'https://nightly.link/mkxp-z/mkxp-z/actions/runs/37110075912/mkxp-z.windows.cross.x86_64.dev-37a04d1.zip'
$engine = Join-Path $engineRoot 'mkxp-z.x86_64.exe'
if (!(Test-Path -LiteralPath $engine)) {
    if (!(Test-Path -LiteralPath $archive)) {
        if (!$Download) { throw 'Client runtime missing. Run tools/install-client-runtime.ps1 -Download first.' }
        New-Item -ItemType Directory -Path (Split-Path $archive) -Force | Out-Null
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $archive
    }
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $archiveHash) { throw 'Runtime archive checksum mismatch.' }
    Expand-Archive -LiteralPath $archive -DestinationPath $engineRoot -Force
}
if ((Get-FileHash -LiteralPath $engine -Algorithm SHA256).Hash -ne $binaryHash) { throw 'Client runtime checksum mismatch. Preserve this copy and inspect it before replacing it.' }
if (!(Test-Path -LiteralPath "$gameRoot/Game.ini")) { throw 'The private Essentials game is missing.' }
# The runtime reads this config in its own directory, then changes to gameFolder.
# Keep stdlib and other runtime resources beside its executable. Do not replace
# Game.exe or copy copyrighted game assets into the runtime package.
$config = @{
    gameFolder = $gameRoot.Replace('\', '/')
    execName = 'Game'
    rgssVersion = 1
    syncToRefreshrate = $false
    fixedFramerate = 60
    subImageFix = $true
    # Use rendered glyph height; nominal RGSS height can clip font descenders.
    fontHeightReporting = 1
    # Avoid ANGLE's D3D11 swap chain (DXGI_ERROR_DEVICE_HUNG on some PCs).
    # Official mkxp-z renderer=2 selects OpenGL; do not change system drivers.
    renderer = 2
    enableBlitting = $false
}
# MIDI needs a SoundFont in mkxp-z. Reuse local assets when present; never
# download or redistribute a bank as part of this source update.
$soundFonts = @(
    (Join-Path $gameRoot 'soundfont.sf2'),
    (Join-Path $gameRoot 'Audio/BGM/GMGSx.sf2'),
    (Join-Path $gameRoot 'Audio/GMGSx.sf2'),
    (Join-Path $gameRoot 'GMGSx.sf2'),
    (Join-Path $engineRoot 'GMGSx.sf2'),
    (Join-Path $engineRoot 'soundfont.sf2')
)
$originalConfigPath = Join-Path $gameRoot 'mkxp.json'
if (Test-Path -LiteralPath $originalConfigPath) {
    try {
        $originalConfig = Get-Content -LiteralPath $originalConfigPath -Raw | ConvertFrom-Json
        if ($originalConfig.midiSoundFont) {
            $configuredFont = [string]$originalConfig.midiSoundFont
            if (![IO.Path]::IsPathRooted($configuredFont)) { $configuredFont = Join-Path $gameRoot $configuredFont }
            $soundFonts = @($configuredFont) + $soundFonts
        }
    } catch { Write-Verbose 'Original game config is not strict JSON; checking standard SoundFont locations.' }
}
$selectedFont = $soundFonts | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if ($selectedFont) { $config.midiSoundFont = $selectedFont.Replace('\', '/') }
[IO.File]::WriteAllText((Join-Path $engineRoot 'mkxp.json'), ($config | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
$manifest = @{ repository='https://github.com/mkxp-z/mkxp-z'; commit=$commit; artifactUrl=$url; archiveSha256=$archiveHash; executableSha256=$binaryHash }
[IO.File]::WriteAllText((Join-Path $engineRoot 'arena-runtime.json'), ($manifest | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
Write-Host 'Client runtime ready: official mkxp-z 37a04d1 (original Game.exe retained).'
