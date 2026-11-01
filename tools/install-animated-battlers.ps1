param(
    [Parameter(Mandatory=$true)][string]$GameRoot,
    [string]$SourceRoot = '',
    [switch]$Repair
)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $PSScriptRoot 'animated-battlers-manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$manifestHash = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash
$targetRoot = Join-Path $GameRoot 'Graphics/Pokemon/ArenaAnimated'
$marker = Join-Path $targetRoot 'installed.txt'
if (!$Repair -and (Test-Path -LiteralPath $marker) -and (Get-Content -LiteralPath $marker -Raw).Trim() -eq $manifestHash) {
    Write-Host 'Animated battle sprites already installed.'
    return
}
Add-Type -AssemblyName System.Net.Http
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = New-Object Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromSeconds(60)
$pending = @()
$completed = 0
function Save-CheckedSprite($Download) {
    $data = if ($Download.Task) { $Download.Task.GetAwaiter().GetResult() } else { $Download.Bytes }
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = [BitConverter]::ToString($sha.ComputeHash([byte[]]$data)).Replace('-', '') } finally { $sha.Dispose() }
    if ($hash -ne $Download.Hash) { throw "Animated sprite checksum mismatch: $($Download.Destination)" }
    $temporary = $Download.Destination + '.' + [guid]::NewGuid().ToString('N') + '.part'
    try {
        [IO.File]::WriteAllBytes($temporary, [byte[]]$data)
        Move-Item -LiteralPath $temporary -Destination $Download.Destination -Force
    } finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary } }
}
try {
    foreach ($entry in $manifest.files) {
        $relative = [string]$entry[0]
        if ($relative -notmatch '^(back/)?(shiny/)?(female/)?([1-9][0-9]*)(-[a-z0-9-]+)?\.gif$') { throw "Invalid sprite path: $relative" }
        $isBack, $isShiny, $isFemale, $number = $Matches[1], $Matches[2], $Matches[3], [int]$Matches[4]
        $folder = if ($isBack) { 'back' } else { 'front' }
        if ($isShiny) { $folder += '-shiny' }
        $name = [string]$manifest.species[$number - 1]
        if ($entry.Count -eq 3) {
            $formName = [string]$entry[2]
            if ($formName -notmatch ('^' + [regex]::Escape($name) + '_[1-9][0-9]*$')) { throw "Invalid form destination: $formName" }
            $name = $formName
        } elseif ($relative -match '-[a-z]') { throw "Unmapped form sprite: $relative" }
        if ($isFemale) { $name += '_female' }
        $destination = Join-Path $targetRoot "$folder/$name.gif"
        $expected = [string]$entry[1]
        if ((Test-Path -LiteralPath $destination) -and (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -eq $expected) { continue }
        New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
        if ($SourceRoot) {
            $bytes = [IO.File]::ReadAllBytes((Join-Path $SourceRoot $relative))
            $task = $null
        } else {
            $url = "https://raw.githubusercontent.com/PokeAPI/sprites/$($manifest.commit)/$($manifest.path)/$relative"
            $task = $client.GetByteArrayAsync($url)
            $bytes = $null
        }
        $pending += [pscustomobject]@{ Task=$task; Bytes=$bytes; Destination=$destination; Hash=$expected }
        if ($pending.Count -ge 8) {
            foreach ($download in $pending) {
                Save-CheckedSprite $download
                $completed++
            }
            $pending = @()
            if ($completed % 128 -eq 0) { Write-Host "Animated battle sprites: $completed / $($manifest.files.Count)" }
        }
    }
    foreach ($download in $pending) {
        Save-CheckedSprite $download
    }
    [IO.File]::WriteAllText($marker, $manifestHash)
    Write-Host "Installed $($manifest.files.Count) animated battle sprites (Gen 1-5)."
} finally { $client.Dispose() }
