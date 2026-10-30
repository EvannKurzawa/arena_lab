param([string]$Tag = 'v6.2.7')
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$repo = 'EvannKurzawa/arena_lab'
$assets = @(
    (Join-Path (Split-Path $PSScriptRoot -Parent) 'dist/ArenaLab-Setup.exe'),
    (Join-Path (Split-Path $PSScriptRoot -Parent) 'dist/ArenaLab-Update.exe')
)
foreach ($asset in $assets) { if (!(Test-Path -LiteralPath $asset)) { throw "Build package missing: $asset. Run tools/package-deliverables.ps1 first." } }
if ($Tag -notmatch '^v[0-9]+\.[0-9]+(?:\.[0-9]+)?$') { throw 'Use a semantic version tag such as v6.2.7.' }

# Reuse the user's existing Git credential without displaying or writing it.
$credentialText = "protocol=https`nhost=github.com`n`n" | & git credential fill
if ($LASTEXITCODE -ne 0) { throw 'Git could not retrieve the existing GitHub credential.' }
$username = $null
$password = $null
foreach ($line in $credentialText) {
    if ($line -match '^username=(.*)$') { $username = $Matches[1] }
    if ($line -match '^password=(.*)$') { $password = $Matches[1] }
}
if (!$username -or !$password) { throw 'No GitHub credential is available through Git Credential Manager.' }
$pair = [Text.Encoding]::UTF8.GetBytes("$username`:$password")
$headers = @{
    Authorization = 'Basic ' + [Convert]::ToBase64String($pair)
    Accept = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
    'User-Agent' = 'ArenaLab-release-publisher'
}
$credentialText = $null; $password = $null; $pair = $null
$api = "https://api.github.com/repos/$repo"
try {
    $existing = Invoke-RestMethod -Method Get -Uri "$api/releases/tags/$Tag" -Headers $headers -ErrorAction Stop
    $release = $existing
} catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
    $releaseBody = @"
Windows client bootstrap and source updater for Arena Lab $Tag (game source v8.3).

ArenaLab-Setup.exe installs the client from pinned public source/runtime dependencies and asks for the player's own Essentials v21.1 game folder. It does not contain Pokémon-derived assets or provision a fresh PostgreSQL host.

ArenaLab-Update.exe downloads current GitHub main while preserving local assets, saves, accounts and server data. This release replaces the WMI/CIM running-game check that could fail immediately after selecting an installation folder. It also adds explicit STA mode for folder dialogs and step-specific errors with a diagnostic log in TEMP. The original failure has not been reproduced on the affected computer; process-check tests pass and both EXEs compile successfully.

Close all game windows before updating, then launch Play-Arena.bat. For multiplayer, update both clients and restart the updated host (visit protocol 9). The game source includes animated liquids, native Surf, quicksand traps and the expanded trainer catalogue from v8.3.
"@
    $payload = @{
        tag_name = $Tag
        target_commitish = 'main'
        name = "$Tag - Arena Lab setup and updater"
        body = $releaseBody
        draft = $false
        prerelease = $false
    } | ConvertTo-Json
    $payloadBytes = [Text.Encoding]::UTF8.GetBytes($payload)
    $release = Invoke-RestMethod -Method Post -Uri "$api/releases" -Headers $headers -ContentType 'application/json; charset=utf-8' -Body $payloadBytes
}
try {
    foreach ($asset in $assets) {
        $assetName = Split-Path $asset -Leaf
        if (@($release.assets | Where-Object name -eq $assetName).Count) { Write-Host "Already uploaded: $assetName"; continue }
        $name = [Uri]::EscapeDataString($assetName)
        $uploadUri = $release.upload_url -replace '\{.*\}$', ''
        $response = Invoke-RestMethod -Method Post -Uri "$uploadUri`?name=$name" -Headers $headers -ContentType 'application/octet-stream' -InFile $asset
        Write-Host ("Uploaded {0}: {1:N0} bytes, SHA256 {2}" -f (Split-Path $asset -Leaf), (Get-Item $asset).Length, (Get-FileHash $asset -Algorithm SHA256).Hash)
    }
    Write-Host "Release published: $($release.html_url)"
} catch {
    Write-Error "Asset upload failed after release creation. Remove or finish draft $($release.html_url) and rerun with a new tag. $($_.Exception.Message)"
    throw
} finally {
    $headers.Authorization = $null
    $headers = $null
}
