param([Parameter(Mandatory=$true)][string]$GameRoot, [string]$LocalSource = '')
$ErrorActionPreference = 'Stop'
$destination = Join-Path $GameRoot 'Graphics/ArenaDevices'
New-Item -ItemType Directory -Force -Path $destination | Out-Null
Copy-Item -Path "$PSScriptRoot/../game-mod/Graphics/ArenaDevices/*.png" -Destination $destination -Force
Copy-Item -LiteralPath "$PSScriptRoot/../game-mod/Graphics/ArenaDevices/device-art-style.txt" -Destination $destination -Force
$ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
& $ruby --disable-gems "$PSScriptRoot/../game-mod/tools/build_device_audio.rb" $GameRoot
if ($LASTEXITCODE -ne 0) { throw 'Device audio generation failed' }
$audio = Join-Path $GameRoot 'Audio/SE'
New-Item -ItemType Directory -Force -Path $audio | Out-Null
$entries = @(
  @('device-src-electricity-charge.mp3', (Join-Path $audio 'Arena Tesla Button.mp3'), 'https://www.myinstants.com/media/sounds/electricity-charge-sound-effect.mp3', '3cde7eb720b5418cf315907cbb02c88dc6aeae1917edf2fbbbb43ea506a119f4'),
  @('device-src-hgss-gym.jpg', (Join-Path $destination 'hgss-map.jpg'), 'https://www.media.pokekalos.fr/img/jeux/hgss/arenes/safrania.jpg', 'd4263ef3a5026bd7ab8b191e2de7ce17638b5e5531c648c16c77c7bc25c1eacc'),
  @('device-src-hgss-teleport.wav', (Join-Path $audio 'Arena HGSS Teleport.wav'), 'https://raw.githubusercontent.com/JappaWakka/P3DToolsAndContentPacks/d5f82265d24f20dba94fb83cf1fb4a7344114d49/ContentPacks/HGSSMusicPack/Sounds/Teleport.wav', '1073cfca273f9698bd59fee86dc77680ef94ae1110b35a656e141ac3efcdfb5b')
)
foreach ($entry in $entries) {
  if ((Test-Path -LiteralPath $entry[1]) -and (Get-FileHash -LiteralPath $entry[1] -Algorithm SHA256).Hash.ToLowerInvariant() -eq $entry[3]) { continue }
  $source = if ($LocalSource) { Join-Path $LocalSource $entry[0] } else { Join-Path $PSScriptRoot "runtime/$($entry[0])" }
  if ($source -and (Test-Path -LiteralPath $source)) { Copy-Item -LiteralPath $source -Destination $entry[1] -Force }
  else { Invoke-WebRequest -Uri $entry[2] -OutFile $entry[1] -UseBasicParsing }
  if ((Get-FileHash -LiteralPath $entry[1] -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry[3]) { throw "Unexpected asset hash: $($entry[0])" }
}
Write-Host 'Arena device graphics and HGSS teleport sound installed.'
$runeSource = Join-Path $PSScriptRoot 'runtime/device-src-rune-cecite.mp3'
$sharedRune = Join-Path $PSScriptRoot '../game-mod/SharedAssets/Audio/SE/Arena Blind Rune.mp3'
if (Test-Path -LiteralPath $sharedRune) { $runeSource = $sharedRune }
if (Test-Path -LiteralPath $runeSource) {
  Copy-Item -LiteralPath $runeSource -Destination (Join-Path $audio 'Arena Blind Rune.mp3') -Force
} else {
  Write-Host 'Optional personal rune sound absent: tools/runtime/device-src-rune-cecite.mp3'
}
