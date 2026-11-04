param([string]$Source = (Join-Path $PSScriptRoot '../tesla_sound.m4a'))
$ErrorActionPreference = 'Stop'
$ffmpeg = Join-Path $PSScriptRoot 'runtime/ffmpeg-9.0.2-essentials_build/bin/ffmpeg.exe'
$ffprobe = Join-Path $PSScriptRoot 'runtime/ffmpeg-9.0.2-essentials_build/bin/ffprobe.exe'
$ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$privateAssets = Join-Path $PSScriptRoot '../game-mod/LocalAssets/Audio/BGS'
$scratch = Join-Path $PSScriptRoot 'runtime/tesla-import'
New-Item -ItemType Directory -Force -Path $privateAssets,$scratch | Out-Null
$duration = & $ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $Source
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect Tesla recording' }
$seconds = [double]::Parse($duration, [Globalization.CultureInfo]::InvariantCulture)
if ($seconds -lt 0.8) { throw 'Tesla recording must be at least 0.8 seconds for the loop overlap' }
$endAt = $seconds.ToString('0.######',[Globalization.CultureInfo]::InvariantCulture)
$hum = Join-Path $privateAssets 'Arena Tesla Hum.wav'
# Crossfade the tail into the head, then rotate past the initial head. The
# resulting end continues into its first sample without fading through silence.
& $ffmpeg -hide_banner -loglevel error -y -i $Source -map_metadata -1 -ac 1 -ar 22050 -c:a pcm_s16le -filter_complex "[0:a]asplit=2[a][b];[a][b]acrossfade=d=0.2:c1=tri:c2=tri,atrim=start=0.2:end=${endAt},asetpts=PTS-STARTPTS" $hum
if ($LASTEXITCODE -ne 0) { throw 'Tesla conversion failed' }
& $ruby "$PSScriptRoot/../game-mod/tools/build_device_audio.rb" $scratch $scratch
if ($LASTEXITCODE -ne 0) { throw 'Magnet generation failed' }
$loopDuration = & $ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $hum
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect converted loop' }
& $ffmpeg -hide_banner -loglevel error -y -i $hum -stream_loop -1 -i (Join-Path $scratch 'Audio/BGS/Arena Magnet.wav') -filter_complex "amix=inputs=2:duration=first:weights=1 0.45:normalize=0,alimiter=limit=0.95:level=false:latency=true,asplit=2[a][b];[a][b]acrossfade=d=0.2:c1=tri:c2=tri,atrim=start=0.2:end=${loopDuration},asetpts=PTS-STARTPTS" -map_metadata -1 -ac 1 -ar 22050 -c:a pcm_s16le (Join-Path $privateAssets 'Arena Magnet Tesla.wav')
if ($LASTEXITCODE -ne 0) { throw 'Combined Tesla/magnet conversion failed' }
$gameRoot = Join-Path $PSScriptRoot 'runtime/essentials-v21.1-base'
if (Test-Path -LiteralPath (Join-Path $gameRoot 'Game.ini')) {
    & $ruby "$PSScriptRoot/../game-mod/tools/build_device_audio.rb" $gameRoot
    if ($LASTEXITCODE -ne 0) { throw 'Installing personal Tesla sound failed' }
    foreach ($name in @('Arena Tesla Hum.wav','Arena Magnet Tesla.wav')) {
        $sha = [Security.Cryptography.SHA256]::Create()
        try {
            $expected = [BitConverter]::ToString($sha.ComputeHash([IO.File]::ReadAllBytes((Join-Path $privateAssets $name))))
            $actual = [BitConverter]::ToString($sha.ComputeHash([IO.File]::ReadAllBytes((Join-Path $gameRoot "Audio/BGS/$name"))))
            if ($expected -ne $actual) { throw "Installed recording differs: $name" }
        } finally { $sha.Dispose() }
    }
    Write-Host 'Both installed Tesla WAV files match the personal recording overrides.'
}
Write-Host 'Personal Tesla recording imported. Play-Arena.bat installs it on each launch.'
