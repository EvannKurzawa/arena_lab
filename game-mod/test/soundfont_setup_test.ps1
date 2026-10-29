$ErrorActionPreference = 'Stop'
$directory = Join-Path ([IO.Path]::GetTempPath()) ('arena-soundfont-' + [guid]::NewGuid().ToString('N'))
$gameRoot = Join-Path $directory 'game'
$engineRoot = Join-Path $directory 'engine'
New-Item -ItemType Directory -Path $gameRoot, $engineRoot -Force | Out-Null
try {
    $source = Get-Content -LiteralPath "$PSScriptRoot/../../tools/install-client-runtime.ps1" -Raw
    $start = $source.IndexOf('# MIDI needs a SoundFont')
    $finish = $source.IndexOf('[IO.File]::WriteAllText', $start)
    $selection = $source.Substring($start, $finish - $start)
    $bank = Join-Path $gameRoot 'soundfont.sf2'
    [IO.File]::WriteAllText($bank, 'fixture')
    $config = @{}
    Invoke-Expression $selection
    if ($config.midiSoundFont -ne $bank.Replace('\', '/')) { throw 'Essentials soundfont.sf2 was not selected.' }
    $customBank = Join-Path $gameRoot 'custom.sf2'
    [IO.File]::WriteAllText($customBank, 'fixture')
    [IO.File]::WriteAllText((Join-Path $gameRoot 'mkxp.json'), '{"midiSoundFont":"custom.sf2"}')
    $config = @{}
    Invoke-Expression $selection
    if ($config.midiSoundFont -ne $customBank.Replace('\', '/')) { throw 'Explicit SoundFont was not preserved.' }
    Write-Output 'PASS: 2 SoundFont selection checks; no runtime or game launched.'
} finally {
    $resolved = [IO.Path]::GetFullPath($directory)
    $temporary = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    if (!$resolved.StartsWith($temporary, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolved) -notlike 'arena-soundfont-*') { throw 'Unsafe fixture cleanup path.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
