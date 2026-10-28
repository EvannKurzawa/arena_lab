$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms
trap { [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Arena Lab setup failed') | Out-Null; exit 1 }

$repo = 'EvannKurzawa/arena_lab'
$appCommit = 'd87071996ab82a6d846abf77a7cc274a2aedbf2b'
$pemkCommit = '9a24034bca241c095b81ea8069607f6cdfa6a57d'
$pemkZipHash = '2B75D1CCD2F0D67650EBBAA259D4342B03760137FE13A0AE28A3299C7D79DB73'
$rubyUrl = 'https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.12-1/rubyinstaller-3.3.12-1-x64.7z'
$rubyHash = 'F8D534A44E47E5B72ABE557497763128B93E9356BD91397A3D7B9E0A11572943'
$root = Join-Path $env:LOCALAPPDATA 'ArenaLab'
$dialog = New-Object Windows.Forms.FolderBrowserDialog
$dialog.Description = 'Choose where to install Arena Lab. Your selected Essentials game is copied locally and is never uploaded.'
$dialog.SelectedPath = $root
if ($dialog.ShowDialog() -ne [Windows.Forms.DialogResult]::OK) { exit 1 }
$root = [IO.Path]::GetFullPath($dialog.SelectedPath)
$gamePicker = New-Object Windows.Forms.FolderBrowserDialog
$gamePicker.Description = 'Select your own Pokémon Essentials v21.1 game folder (must contain Game.ini, Data and Graphics). The installer will copy it into Arena Lab.'
if ($gamePicker.ShowDialog() -ne [Windows.Forms.DialogResult]::OK) { exit 1 }
$sourceGame = [IO.Path]::GetFullPath($gamePicker.SelectedPath)
foreach ($required in @('Game.ini','Data/Scripts.rxdata','Graphics')) {
    if (!(Test-Path -LiteralPath (Join-Path $sourceGame $required))) { throw "Selected folder is missing $required. Select the complete Essentials v21.1 game folder." }
}
$settings = Join-Path $sourceGame 'Data/Scripts/001_Settings.rb'
if (Test-Path -LiteralPath $settings) {
    $settingsSource = Get-Content -LiteralPath $settings -Raw
    if ($settingsSource -notmatch 'VERSION\s*=\s*["'']21\.1["'']') {
        throw 'The selected extracted Essentials scripts do not identify version 21.1. Use the v21.1 base required by PEMK.'
    }
} else {
    # Resource packs may ship compiled Scripts.rxdata without extracted Ruby
    # sources. The required v21.1 scripts.rxdata and user-selected base remain.
    Write-Host 'No extracted 001_Settings.rb found; keeping the supplied compiled Essentials scripts.'
}
if (Test-Path -LiteralPath (Join-Path $root 'tools/runtime/essentials-v21.1-base')) {
    throw 'Arena Lab already has a game folder here. Use ArenaLab-Update.exe for an existing installation.'
}
if (Test-Path -LiteralPath $root -and (Get-ChildItem -LiteralPath $root -Force | Select-Object -First 1)) {
    throw 'The install folder is not empty. Choose an empty folder, or use ArenaLab-Update.exe for an existing Arena Lab install.'
}
$work = Join-Path $env:TEMP ('ArenaLab-Setup-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null
try {
    $appZip = Join-Path $work 'arena-source.zip'
    Invoke-WebRequest -UseBasicParsing -Uri "https://codeload.github.com/$repo/zip/$appCommit" -OutFile $appZip
    $pemkZip = Join-Path $work 'pemk.zip'
    Invoke-WebRequest -UseBasicParsing -Uri "https://codeload.github.com/SamDreamsMaker/pokemon-essentials-mmo-kit/zip/$pemkCommit" -OutFile $pemkZip
    if ((Get-FileHash $pemkZip -Algorithm SHA256).Hash -ne $pemkZipHash) { throw 'PEMK source checksum mismatch; setup stopped.' }
    $rubyArchive = Join-Path $work 'ruby.7z'
    Invoke-WebRequest -UseBasicParsing -Uri $rubyUrl -OutFile $rubyArchive
    if ((Get-FileHash $rubyArchive -Algorithm SHA256).Hash -ne $rubyHash) { throw 'Ruby runtime checksum mismatch; setup stopped.' }

    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $appStage = Join-Path $work 'app'
    Expand-Archive -LiteralPath $appZip -DestinationPath $appStage
    $appFolder = Get-ChildItem -LiteralPath $appStage -Directory | Select-Object -First 1
    Get-ChildItem -LiteralPath $appFolder.FullName -Force | Copy-Item -Destination $root -Recurse -Force
    $runtime = Join-Path $root 'tools/runtime'
    $gameRoot = Join-Path $runtime 'essentials-v21.1-base'
    New-Item -ItemType Directory -Path $gameRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $sourceGame -Force | Copy-Item -Destination $gameRoot -Recurse -Force

    $pemkStage = Join-Path $work 'pemk-source'
    Expand-Archive -LiteralPath $pemkZip -DestinationPath $pemkStage
    $pemkFolder = Get-ChildItem -LiteralPath $pemkStage -Directory | Select-Object -First 1
    $pemkRoot = Join-Path $runtime 'pemk-workspace'
    New-Item -ItemType Directory -Path $pemkRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $pemkFolder.FullName -Force | Copy-Item -Destination $pemkRoot -Recurse -Force
    $rubyRoot = Join-Path $runtime 'ruby-portable'
    New-Item -ItemType Directory -Path $rubyRoot -Force | Out-Null
    & tar.exe -xf $rubyArchive -C $rubyRoot
    if ($LASTEXITCODE -ne 0) { throw 'Could not unpack the verified Ruby runtime.' }

    & (Join-Path $root 'tools/install-client-runtime.ps1') -Download
    if ($LASTEXITCODE -ne 0) { throw 'The official mkxp-z client runtime did not install.' }
    & (Join-Path $root 'tools/local-multiplayer.ps1') -Action Prepare
    if ($LASTEXITCODE -ne 0) { throw 'Arena game preparation did not complete; see tools/runtime/desktop-prepare*.log.' }
    [IO.File]::WriteAllText((Join-Path $root 'arena-install.json'), (@{ appCommit=$appCommit; essentials='user-provided v21.1'; pemkCommit=$pemkCommit; installedUtc=[DateTime]::UtcNow.ToString('o') } | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
    [Windows.Forms.MessageBox]::Show("Arena Lab is installed at:`n$root`n`nUse Play-Arena.bat to play offline or join your friend's host. This package prepares a client; it does not include the private PostgreSQL host service.", 'Arena Lab setup complete') | Out-Null
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
