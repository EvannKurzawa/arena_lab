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
if (!(Test-Path -LiteralPath $titleSource)) {
    # Older updater EXEs did not copy root-level title art. Repair those installs
    # from the already-published, tracked image without downloading game assets.
    $titleTemp = Join-Path $runtimeRoot ('arena-title-' + [guid]::NewGuid().ToString('N') + '.png')
    try {
        Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/EvannKurzawa/arena_lab/d5ba6b9ac0e432e4d9f0948494e0956e14ef8d77/title_screen.png' -OutFile $titleTemp
        if ((Get-FileHash -LiteralPath $titleTemp -Algorithm SHA256).Hash -ne '810E7FAC8CE653F2CC938E7528F0B38D61F69D12C8D53909B2430D58C0571CF1') { throw 'Title image checksum mismatch.' }
        Move-Item -LiteralPath $titleTemp -Destination $titleSource -Force
    } finally {
        if (Test-Path -LiteralPath $titleTemp) { Remove-Item -LiteralPath $titleTemp -Force }
    }
}
if (Test-Path -LiteralPath $titleSource) {
    New-Item -ItemType Directory -Path "$GameRoot/Graphics/Titles" -Force | Out-Null
    Copy-Item -LiteralPath $titleSource -Destination "$GameRoot/Graphics/Titles/arena_title.png" -Force
}
$musicSource = Join-Path $runtimeRoot 'arena-title.mp3'
if (Test-Path -LiteralPath $musicSource) {
    Copy-Item -LiteralPath $musicSource -Destination "$GameRoot/Audio/BGM/Arena Title.mp3" -Force
}
