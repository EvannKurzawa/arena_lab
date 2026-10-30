param([Parameter(Mandatory=$true)][string]$GameRoot)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$runtimeRoot = Join-Path $PSScriptRoot 'runtime'
$rubyExe = Join-Path $runtimeRoot 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$translation = Join-Path $runtimeRoot 'french-translation/Text_french.dat_core'
if (Test-Path -LiteralPath $translation) {
    & $rubyExe --disable-gems "$projectRoot/game-mod/tools/compile_french_core.rb" $translation "$GameRoot/Data/messages_french_core.dat"
    if ($LASTEXITCODE -ne 0) { throw 'French translation compilation failed.' }
} elseif (!(Test-Path -LiteralPath "$GameRoot/Data/messages_french_core.dat")) {
    & (Join-Path $PSScriptRoot 'install-french-data.ps1') -GameRoot $GameRoot -Download
}
$titleSource = Join-Path $projectRoot 'title_screen.png'
if (Test-Path -LiteralPath $titleSource) {
    New-Item -ItemType Directory -Path "$GameRoot/Graphics/Titles" -Force | Out-Null
    Copy-Item -LiteralPath $titleSource -Destination "$GameRoot/Graphics/Titles/arena_title.png" -Force
}
$musicSource = Join-Path $runtimeRoot 'arena-title.mp3'
if (Test-Path -LiteralPath $musicSource) {
    Copy-Item -LiteralPath $musicSource -Destination "$GameRoot/Audio/BGM/Arena Title.mp3" -Force
}
