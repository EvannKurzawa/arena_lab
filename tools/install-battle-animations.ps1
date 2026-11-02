param(
    [Parameter(Mandatory=$true)][string]$GameRoot,
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$ArchivePath = '',
    [switch]$Download
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$runtime = Join-Path $ProjectRoot 'tools/runtime'
$marker = Join-Path $GameRoot 'Data/ArenaLab-BattleAnimations-Gen9.txt'
if (Test-Path -LiteralPath $marker) {
    $parts = (Get-Content -LiteralPath $marker -Raw).Trim().Split(' ')
    if ($parts.Length -eq 3 -and (Get-FileHash -LiteralPath (Join-Path $GameRoot 'Data/PkmnAnimations.rxdata') -Algorithm SHA256).Hash -eq $parts[1]) {
        Write-Host 'Gen 9 move animations already installed.'
        return
    }
    & (Join-Path $runtime 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe') --disable-gems (Join-Path $ProjectRoot 'game-mod/tools/install_battle_animation_data.rb') $GameRoot --verify-installed
    if ($LASTEXITCODE -eq 0) { return }
    if ($LASTEXITCODE -ne 2) { throw 'Battle animation content could not be verified. Preserve local edits and review before reinstalling.' }
    # Legacy two-field receipt: the verified archive and pre-install backup
    # allow Ruby to reconstruct the original content without reinstalling it.
}
if (!$ArchivePath) { $ArchivePath = Join-Path $runtime 'downloads/gen9-move-animations.zip' }
$expectedHash = '931691C2E0B4B7817AA891AAA6653FEBDD7C7D0870DC657DAD331F16752AF24B'
if (!(Test-Path -LiteralPath $ArchivePath)) {
    if (!$Download) { throw 'Move animation pack missing. Run preparation with -Download.' }
    New-Item -ItemType Directory -Path (Split-Path $ArchivePath) -Force | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # KRLW890's official download, linked by https://eeveeexpo.com/resources/1480/.
    $url = 'https://drive.usercontent.google.com/download?id=1UoN6RCVmFFwakJb7T93MlTxxiuozeFQT&export=download&confirm=t'
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $ArchivePath
    if ((Get-Item -LiteralPath $ArchivePath).Length -lt 10000) {
        $page = Get-Content -LiteralPath $ArchivePath -Raw
        $match = [regex]::Match($page, 'name="uuid" value="([a-fA-F0-9-]+)"')
        if (!$match.Success) { throw 'Animation pack download is unavailable; no game files changed.' }
        Invoke-WebRequest -UseBasicParsing -Uri ($url + '&uuid=' + $match.Groups[1].Value) -OutFile $ArchivePath
    }
}
if ((Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash -ne $expectedHash) {
    throw 'Unexpected move animation archive checksum; no game files changed.'
}
$stage = [IO.Path]::GetFullPath((Join-Path $runtime ('battle-pack-' + [guid]::NewGuid().ToString('N'))))
$prefix = [IO.Path]::GetFullPath($runtime).TrimEnd('\') + '\'
if (!$stage.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid battle pack staging path.' }
try {
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $stage
    & (Join-Path $runtime 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe') --disable-gems (Join-Path $ProjectRoot 'game-mod/tools/install_battle_animation_data.rb') $GameRoot (Join-Path $stage 'Data/PkmnAnimations.rxdata')
    if ($LASTEXITCODE -ne 0) { throw 'Battle animation data installation failed; retained backups are in Data.' }
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
}
