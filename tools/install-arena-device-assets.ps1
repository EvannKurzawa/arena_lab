param([Parameter(Mandatory=$true)][string]$GameRoot, [string]$LocalSource = '')
$ErrorActionPreference = 'Stop'
$destination = Join-Path $GameRoot 'Graphics/ArenaDevices'
New-Item -ItemType Directory -Force -Path $destination | Out-Null
Copy-Item -Path "$PSScriptRoot/../game-mod/Graphics/ArenaDevices/*.png" -Destination $destination -Force
$audio = Join-Path $GameRoot 'Audio/SE'
New-Item -ItemType Directory -Force -Path $audio | Out-Null
$entries = @(
  @('device-src-hgss-gym.jpg', (Join-Path $destination 'hgss-map.jpg'), 'https://www.media.pokekalos.fr/img/jeux/hgss/arenes/safrania.jpg', 'd4263ef3a5026bd7ab8b191e2de7ce17638b5e5531c648c16c77c7bc25c1eacc'),
  @('device-src-hgss-teleport.wav', (Join-Path $audio 'Arena HGSS Teleport.wav'), 'https://raw.githubusercontent.com/JappaWakka/P3DToolsAndContentPacks/d5f82265d24f20dba94fb83cf1fb4a7344114d49/ContentPacks/HGSSMusicPack/Sounds/Teleport.wav', '1073cfca273f9698bd59fee86dc77680ef94ae1110b35a656e141ac3efcdfb5b')
)
foreach ($entry in $entries) {
  if ((Test-Path -LiteralPath $entry[1]) -and (Get-FileHash -LiteralPath $entry[1] -Algorithm SHA256).Hash.ToLowerInvariant() -eq $entry[3]) { continue }
  $source = if ($LocalSource) { Join-Path $LocalSource $entry[0] } else { '' }
  if ($source -and (Test-Path -LiteralPath $source)) { Copy-Item -LiteralPath $source -Destination $entry[1] -Force }
  else { Invoke-WebRequest -Uri $entry[2] -OutFile $entry[1] -UseBasicParsing }
  if ((Get-FileHash -LiteralPath $entry[1] -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry[3]) { throw "Unexpected asset hash: $($entry[0])" }
}
Write-Host 'Arena device graphics and HGSS teleport sound installed.'
