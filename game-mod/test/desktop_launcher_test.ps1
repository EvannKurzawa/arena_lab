$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../tools/desktop-session.ps1"
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('arena-launcher-test-' + [Guid]::NewGuid().ToString('N'))
$leases = @()
$checks = 0
function Assert-ArenaTest([bool]$Condition, [string]$Message) {
    if (!$Condition) { throw $Message }
    $script:checks++
}
try {
    $first = Get-ArenaProfileLease $testRoot
    $leases += $first
    Assert-ArenaTest ($first.Name -eq 'primary') 'First launch did not get primary.'
    Assert-ArenaTest (!$first.OtherActive) 'First launch incorrectly reports another game.'
    $second = Get-ArenaProfileLease $testRoot
    $leases += $second
    Assert-ArenaTest ($second.Name -eq 'guest') 'Second identical launch did not get an isolated guest.'
    Assert-ArenaTest $second.OtherActive 'Second launch could regenerate live game files.'
    $first.Handle.Dispose()
    $third = Get-ArenaProfileLease $testRoot
    $leases += $third
    Assert-ArenaTest ($third.Name -eq 'primary') 'Released profile was not reused.'
    Assert-ArenaTest $third.OtherActive 'Reopened primary missed the still-running guest.'
    $orphanDirectory = Join-Path $testRoot 'player3'
    $current = Get-Process -Id $PID
    @{ Pid = $PID; StartUtc = $current.StartTime.ToUniversalTime().ToString('o'); Executable = $current.Path } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $orphanDirectory 'client.json') -Encoding UTF8
    $fourth = Get-ArenaProfileLease $testRoot
    $leases += $fourth
    Assert-ArenaTest ($fourth.Name -eq 'player4') 'A live client record lost its save-file protection after its supervisor exited.'
    Assert-ArenaTest $fourth.OtherActive 'Orphan recovery missed other running clients.'
    $request = 'a' * 24
    [IO.File]::WriteAllText((Join-Path $second.Directory 'host.request'), $request)
    Assert-ArenaTest ((Get-ArenaHostRequest $second.Directory) -eq $request) 'Host IPC did not read its nonce.'
    Write-ArenaControlReply $second.Directory $request $true 'Ready'
    $reply = [IO.File]::ReadAllLines((Join-Path $second.Directory 'host.response'))
    Assert-ArenaTest ($reply[0] -eq $request -and $reply[1] -eq 'OK' -and $reply[2] -eq 'Ready') 'Host response framing mismatch.'
    [IO.File]::WriteAllText((Join-Path $second.Directory 'host.request'), 'Start-Process unwanted')
    $rejected = $false
    try { Get-ArenaHostRequest $second.Directory } catch { $rejected = $true }
    Assert-ArenaTest $rejected 'Host IPC accepted a command instead of a fixed request.'
    while ($leases.Count -lt 8) { $leases += Get-ArenaProfileLease $testRoot }
    $exhausted = $false
    try { Get-ArenaProfileLease $testRoot | Out-Null } catch { $exhausted = $true }
    Assert-ArenaTest $exhausted 'Exhausted profiles could reuse a running player save.'
    $rootBats = @(Get-ChildItem -LiteralPath "$PSScriptRoot/../.." -Filter '*.bat' -File)
    Assert-ArenaTest ($rootBats.Count -eq 1 -and $rootBats[0].Name -eq 'Play-Arena.bat') 'Multiple public BAT launchers remain.'
    Write-Output "PASS: $checks launcher/profile/IPC checks; no game, backend or GUI started."
} finally {
    foreach ($lease in $leases) { $lease.Handle.Dispose() }
    $resolved = [IO.Path]::GetFullPath($testRoot)
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    if (!$resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolved) -notlike 'arena-launcher-test-*') { throw 'Unsafe test cleanup path.' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
