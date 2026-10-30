param([switch]$Network)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$fixture = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ('runtime/french-test-' + [guid]::NewGuid().ToString('N'))))
$boundary = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'runtime')).TrimEnd('\') + '\'
if (!$fixture.StartsWith($boundary, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid fixture path' }
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
try {
    $helper = Join-Path $PSScriptRoot 'install-french-data.ps1'
    $game = Join-Path $fixture 'game with spaces'
    $missing = Join-Path $fixture 'missing-source'
    if ($Network) {
        & $helper -GameRoot $game -TranslationDirectory $missing -Download
    } else {
        & $helper -GameRoot $game -TranslationDirectory $missing -ArchivePath (Join-Path $PSScriptRoot 'runtime/french-pack.zip')
    }
    $output = Join-Path $game 'Data/messages_french_core.dat'
    if (!(Test-Path -LiteralPath $output)) { throw 'Compiled data missing' }
    $ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
    $verify = Join-Path $fixture 'verify.rb'
    [IO.File]::WriteAllText($verify, 'm=Marshal.load(File.binread(ARGV[0])); abort "Missing translations" unless m[1]["Bulbasaur"]=="Bulbizarre" && m[24].length>100; puts "French compiled data verified"')
    & $ruby --disable-gems $verify $output
    if ($LASTEXITCODE -ne 0) { throw 'Compiled translation verification failed' }
    $hash = (Get-FileHash -LiteralPath $output).Hash
    & $helper -GameRoot $game -TranslationDirectory $missing -ArchivePath (Join-Path $fixture 'does-not-exist.zip')
    if ((Get-FileHash -LiteralPath $output).Hash -ne $hash) { throw 'Existing French data modified' }
    $badArchive = Join-Path $fixture 'bad.zip'
    [IO.File]::WriteAllText($badArchive, 'not the trusted pack')
    $badGame = Join-Path $fixture 'bad-game'
    try {
        & $helper -GameRoot $badGame -TranslationDirectory $missing -ArchivePath $badArchive
        throw 'Checksum failure unexpectedly accepted'
    } catch { if ($_.Exception.Message -notlike '*checksum mismatch*') { throw } }
    if (Test-Path -LiteralPath (Join-Path $badGame 'Data/messages_french_core.dat')) { throw 'Invalid archive installed' }
    Write-Host 'French install checks passed: fresh install, real compiled translations, existing data preserved, bad checksum rejected.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
