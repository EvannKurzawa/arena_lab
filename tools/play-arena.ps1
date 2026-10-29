param()
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/desktop-session.ps1"
$runtimeRoot = Join-Path $PSScriptRoot 'runtime'
$controlRoot = Join-Path $runtimeRoot 'desktop-sessions'
$taskHash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($PSScriptRoot.ToLowerInvariant()))).Replace('-', '').Substring(0, 20)
$startupMutex = New-Object Threading.Mutex($false, "Local\ArenaStart-$taskHash")
$serviceMutex = New-Object Threading.Mutex($false, "Local\ArenaService-$taskHash")
$lease, $client = $null, $null
$startupHeld = $false

function Start-ArenaService {
    $held = $false
    try {
        try { $held = $serviceMutex.WaitOne(30000) } catch [Threading.AbandonedMutexException] { $held = $true }
        if (!$held) { throw 'Another player is starting the host service. Try again shortly.' }
        $rubyPath = Join-Path $runtimeRoot 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
        & $rubyPath --disable-gems "$PSScriptRoot/ping_multiplayer.rb" 0 arena lan
        $probe = $LASTEXITCODE
        if ($probe -eq 0) { return }
        if ($probe -eq 2 -or $probe -eq 3) {
            Stop-ArenaLegacyService -ProjectRoot (Split-Path $PSScriptRoot -Parent)
        }
        Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSScriptRoot/local-multiplayer.ps1`"",
            '-Action', 'Server', '-ListenAddress', '0.0.0.0', '-Managed'
        ) -RedirectStandardOutput "$runtimeRoot/desktop-server-$PID.stdout.log" -RedirectStandardError "$runtimeRoot/desktop-server-$PID.stderr.log" | Out-Null
        # Cold database startup, dependency checks and migrations can exceed
        # fifteen seconds. Keep one startup attempt under the service mutex.
        & $rubyPath --disable-gems "$PSScriptRoot/ping_multiplayer.rb" 90 arena lan
        if ($LASTEXITCODE -ne 0) { throw "Host service failed to become ready. See desktop-server-$PID.stderr.log and pemk-server.log under tools/runtime." }
    } finally {
        if ($held) { $serviceMutex.ReleaseMutex() }
    }
}

try {
    try { $startupHeld = $startupMutex.WaitOne(120000) } catch [Threading.AbandonedMutexException] { $startupHeld = $true }
    if (!$startupHeld) { throw 'The first game is still preparing. Wait for its title screen and try again.' }
    $lease = Get-ArenaProfileLease $controlRoot
    if (!$lease.OtherActive) {
        $prepareLog = Join-Path $runtimeRoot "desktop-prepare-$PID.log"
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/local-multiplayer.ps1" -Action Prepare *> $prepareLog
        if ($LASTEXITCODE -ne 0) { throw "Game preparation failed. See $prepareLog." }
    }
    # No shared map/plugin/config writes while another client is using them.
    foreach ($file in @('host.request', 'host.response', 'host.response.tmp', 'game.ready', 'client.json')) {
        $path = Join-Path $lease.Directory $file
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
    }
    $env:ARENA_CONTROL_DIR = $lease.Directory
    $env:ARENA_READY_FILE = Join-Path $lease.Directory 'game.ready'
    $client = & "$PSScriptRoot/launch-client.ps1" -Instance $lease.Name -SkipRuntimeSetup -PassThru
    if (!$client) { throw 'The client process was not created.' }
    @{ Pid = $client.Id; StartUtc = $client.StartTime.ToUniversalTime().ToString('o'); Executable = $client.Path } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $lease.Directory 'client.json') -Encoding UTF8
    # Signal is written after compilation and Game.set_up_system, not just after
    # process creation: the second client must not race the first compilation.
    $readyDeadline = [DateTime]::UtcNow.AddSeconds(90)
    while (!(Test-Path -LiteralPath $env:ARENA_READY_FILE) -and !$client.HasExited) {
        if ([DateTime]::UtcNow -gt $readyDeadline) { throw 'Game startup is unfinished. Close this game before starting another player.' }
        Start-Sleep -Milliseconds 200
        $client.Refresh()
    }
    $startupMutex.ReleaseMutex()
    $startupHeld = $false
    $lastRequest = $null
    while (!$client.HasExited) {
        $request = Get-ArenaHostRequest $lease.Directory
        if ($request -and $request -ne $lastRequest) {
            $lastRequest = $request
            try {
                Start-ArenaService
                $addresses = @()
                try { $addresses = @([Net.Dns]::GetHostAddresses([Net.Dns]::GetHostName()) | Where-Object { $_.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork -and ![Net.IPAddress]::IsLoopback($_) } | ForEach-Object { $_.ToString() }) } catch { }
                $lanHint = if ($addresses.Count) { $addresses -join ', ' } else { 'No local network IPv4 address was detected.' }
                Write-ArenaControlReply $lease.Directory $request $true "Host ready on port 9998. Same PC: 127.0.0.1. Other PC on your network: $lanHint"
            } catch { Write-ArenaControlReply $lease.Directory $request $false $_.Exception.Message }
        }
        Start-Sleep -Milliseconds 200
        $client.Refresh()
    }
} catch {
    New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
    $_ | Out-String | Add-Content -LiteralPath "$runtimeRoot/desktop-launcher-$PID.log"
    Add-Type -AssemblyName System.Windows.Forms
    [Windows.Forms.MessageBox]::Show("Arena could not finish starting. $($_.Exception.Message)`nSee tools/runtime/desktop-launcher-$PID.log.", 'Arena') | Out-Null
} finally {
    if ($client -and !$client.HasExited) { $client.WaitForExit() }
    if ($startupHeld) { $startupMutex.ReleaseMutex() }
    if ($lease) { $lease.Handle.Dispose() }
    $startupMutex.Dispose()
    $serviceMutex.Dispose()
}
