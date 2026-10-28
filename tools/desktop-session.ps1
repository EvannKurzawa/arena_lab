# Dot-sourcing defines helpers only; no processes are started here.
function Get-ArenaProfileNames { @('primary', 'guest', 'player3', 'player4', 'player5', 'player6', 'player7', 'player8') }
function Test-ArenaClientRecord([string]$Path) {
    if (!(Test-Path -LiteralPath $Path)) { return $false }
    try {
        $record = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        $client = Get-Process -Id ([int]$record.Pid) -ErrorAction Stop
        return $client.StartTime.ToUniversalTime().ToString('o') -eq $record.StartUtc -and $client.Path -eq $record.Executable
    } catch { return $false }
}
function Get-ArenaProfileLease([string]$Root) {
    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    $active, $available = @(), @()
    foreach ($name in (Get-ArenaProfileNames)) {
        $directory = Join-Path $Root $name
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        $stream = $null
        try {
            $stream = [IO.File]::Open((Join-Path $directory 'profile.lock'), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
            if (Test-ArenaClientRecord (Join-Path $directory 'client.json')) {
                $active += $name
                $stream.Dispose()
            } else { $available += [pscustomobject]@{ Name = $name; Directory = $directory; Handle = $stream } }
        } catch [IO.IOException] {
            if ($stream) { $stream.Dispose() }
            $active += $name
        }
    }
    if (!$available.Count) { throw 'All eight local player profiles are already running.' }
    $selected = $available[0]
    $available | Select-Object -Skip 1 | ForEach-Object { $_.Handle.Dispose() }
    $selected | Add-Member -NotePropertyName OtherActive -NotePropertyValue ($active.Count -gt 0)
    return $selected
}
function Write-ArenaControlReply([string]$Directory, [string]$Id, [bool]$Success, [string]$Message) {
    $status = if ($Success) { 'OK' } else { 'ERR' }
    $reply = $Id + "`n" + $status + "`n" + $Message.Replace("`r", ' ').Replace("`n", ' ')
    $temporary = Join-Path $Directory 'host.response.tmp'
    [IO.File]::WriteAllText($temporary, $reply, [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temporary -Destination (Join-Path $Directory 'host.response') -Force
}
function Get-ArenaHostRequest([string]$Directory) {
    $path = Join-Path $Directory 'host.request'
    if (!(Test-Path -LiteralPath $path)) { return $null }
    $id = [IO.File]::ReadAllText($path).Trim()
    # Exactly one fixed action is supported. No game-supplied command or path.
    if ($id -notmatch '\A[0-9a-f]{24}\z') { throw 'Invalid host request identifier.' }
    return $id
}

function Get-ArenaTcpEntries {
    $lines = @(netstat -ano -p tcp)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect the local TCP listener safely.' }
    foreach ($line in $lines) {
        if ($line -match '^\s*TCP\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)\s*$') {
            if ($Matches[1].EndsWith(':9998')) {
                [pscustomobject]@{ State = $Matches[3]; ProcessId = [int]$Matches[4] }
            }
        }
    }
}

function Test-ArenaServerIdentity($Process, [string]$ProjectRoot) {
    if (!$Process -or !$Process.ExecutablePath -or !$Process.CommandLine -or !$Process.CreationDate) { return $false }
    $expected = @(
        (Join-Path $ProjectRoot 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'),
        (Join-Path $ProjectRoot 'tools/run-local-server.rb'),
        (Join-Path $ProjectRoot 'tools/runtime/pemk-workspace/server'),
        (Join-Path $ProjectRoot 'tools/runtime/pemk-server.log')
    ) | ForEach-Object { [IO.Path]::GetFullPath($_) }
    if ([IO.Path]::GetFullPath($Process.ExecutablePath) -ne $expected[0]) { return $false }
    $arguments = @([regex]::Matches($Process.CommandLine, '"([^"]*)"|(\S+)') | ForEach-Object {
        if ($_.Groups[1].Success) { $_.Groups[1].Value } else { $_.Groups[2].Value }
    })
    if ($arguments.Count -ne $expected.Count) { return $false }
    for ($index = 0; $index -lt $expected.Count; $index++) {
        try { if ([IO.Path]::GetFullPath($arguments[$index]) -ne $expected[$index]) { return $false } }
        catch { return $false }
    }
    return $true
}

function Stop-ArenaLegacyService(
    [string]$ProjectRoot,
    [scriptblock]$ReadConnections = { Get-ArenaTcpEntries },
    [scriptblock]$ReadProcess = { param($targetId) Get-CimInstance Win32_Process -Filter "ProcessId = $targetId" -ErrorAction Stop },
    [scriptblock]$StopVerified = {
        param($record)
        $targetProcess = Get-Process -Id $record.ProcessId -ErrorAction Stop
        try {
            # CIM creation timestamps have microsecond precision; process start
            # timestamps may retain the final 100 ns digit.
            if ([Math]::Abs($targetProcess.StartTime.ToUniversalTime().Ticks - ([datetime]$record.CreationDate).ToUniversalTime().Ticks) -gt 10) {
                throw 'Server process identity changed before replacement.'
            }
            Stop-Process -InputObject $targetProcess -Force -ErrorAction Stop
            if (!$targetProcess.WaitForExit(3000)) { throw 'The old server did not exit.' }
        } finally { $targetProcess.Dispose() }
    }
) {
    $rows = @(& $ReadConnections)
    $listeners = @($rows | Where-Object State -eq 'LISTENING' | Select-Object -ExpandProperty ProcessId -Unique)
    if (!$listeners.Count) { return }
    if ($listeners.Count -ne 1) { throw 'Multiple listeners use port 9998; automatic replacement was refused.' }
    $targetId = $listeners[0]
    if (@($rows | Where-Object { $_.ProcessId -eq $targetId -and $_.State -eq 'ESTABLISHED' }).Count) {
        throw 'The earlier host still has connected players. Disconnect those players, then try Host online again.'
    }
    $record = & $ReadProcess $targetId
    if (!(Test-ArenaServerIdentity $record $ProjectRoot)) {
        throw "Port 9998 belongs to an unverified process (PID $targetId). No process was stopped."
    }
    # Re-read ownership and TCP state immediately before the stop. Never stop
    # another application, a changed PID, or a known active game connection.
    $again = & $ReadProcess $targetId
    if (!(Test-ArenaServerIdentity $again $ProjectRoot) -or $record.CreationDate -ne $again.CreationDate) {
        throw 'Server ownership changed during inspection; replacement was refused.'
    }
    $current = @(& $ReadConnections)
    if (@($current | Where-Object { $_.State -eq 'LISTENING' -and $_.ProcessId -ne $targetId }).Count -or
        @($current | Where-Object { $_.State -eq 'ESTABLISHED' -and $_.ProcessId -eq $targetId }).Count) {
        throw 'The old service changed or a player connected; replacement was refused.'
    }
    & $StopVerified $again
}
