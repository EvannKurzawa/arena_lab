param(
    [Parameter(Mandatory=$true)][string]$GameRoot,
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    [switch]$Download,
    [string]$ArchivePath = '',
    [string]$TranslationDirectory = ''
)
$ErrorActionPreference = 'Stop'
# Compatibility entry point: released updater EXEs call this downloaded helper
# after copying main, even when French data is already present. Deploy the game
# scripts here too so their success dialog cannot leave the old runtime cache.
$pluginInstaller = Join-Path $ProjectRoot 'tools/install-game-plugins.ps1'
if (Test-Path -LiteralPath $pluginInstaller) {
    & $pluginInstaller -GameRoot $GameRoot -ProjectRoot $ProjectRoot
}
$runtime = Join-Path $ProjectRoot 'tools/runtime'
$output = Join-Path $GameRoot 'Data/messages_french_core.dat'
if ((Test-Path -LiteralPath $output) -and (Get-Item -LiteralPath $output).Length -gt 0) {
    Write-Host 'French Essentials data already installed.'
    return
}
$ruby = Join-Path $runtime 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$compiler = Join-Path $ProjectRoot 'game-mod/tools/compile_french_core.rb'
foreach ($required in @($ruby, $compiler)) {
    if (!(Test-Path -LiteralPath $required)) { throw "French preparation requires $required" }
}
$source = if ($TranslationDirectory) { $TranslationDirectory } else { Join-Path $runtime 'french-translation/Text_french.dat_core' }
$work = [IO.Path]::GetFullPath((Join-Path $runtime ('french-install-' + [guid]::NewGuid().ToString('N'))))
$runtimePrefix = [IO.Path]::GetFullPath($runtime).TrimEnd('\') + '\'
if (!$work.StartsWith($runtimePrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid French staging path.' }
New-Item -ItemType Directory -Path $work -Force | Out-Null
try {
    if (!(Test-Path -LiteralPath (Join-Path $source 'SPECIES_NAMES.txt')) -or
        !(Test-Path -LiteralPath (Join-Path $source 'SCRIPT_TEXTS.txt'))) {
        if (!$ArchivePath) {
            if (!$Download) { throw 'French pack missing. Run the updater to download and prepare it.' }
            # Author YusukyDelta, Essentials v21.1 pack 1.2, downloaded at source.
            # Third-party translations are never bundled in the repo or EXE.
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $page = Invoke-WebRequest -UseBasicParsing -Uri 'https://eeveeexpo.com/resources/1860/download'
            $match = [regex]::Match($page.Content, 'https://download[0-9]+\.mediafire\.com/[A-Za-z0-9_/%+().~-]+\.zip')
            if (!$match.Success) { throw 'French pack download link unavailable. See https://eeveeexpo.com/resources/1860/ and retry later.' }
            $ArchivePath = Join-Path $work 'french-pack.zip'
            Invoke-WebRequest -UseBasicParsing -Uri $match.Value -OutFile $ArchivePath
        }
        $expectedHash = 'DC6857B594FB7AFE95DBAADE09BB1345116EE24056BE9831A5FBC32095F0A940'
        if ((Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash -ne $expectedHash) {
            throw 'French pack checksum mismatch. Expected v21.1 pack 1.2; no translation installed.'
        }
        $extracted = Join-Path $work 'extracted'
        Expand-Archive -LiteralPath $ArchivePath -DestinationPath $extracted
        $source = Join-Path $extracted 'Text_french.dat_core'
    }
    $compiled = Join-Path $work 'messages_french_core.dat'
    & $ruby --disable-gems $compiler $source $compiled
    if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $compiled)) { throw 'French translation compilation failed; existing game data preserved.' }
    New-Item -ItemType Directory -Path (Split-Path $output -Parent) -Force | Out-Null
    Move-Item -LiteralPath $compiled -Destination $output -Force
    Write-Host 'French Essentials v21.1 data installed.'
} finally {
    # $work was resolved and checked against the runtime boundary above.
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
