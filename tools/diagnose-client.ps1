param([ValidateSet('primary', 'guest')][string]$Instance = 'primary', [switch]$AutoClick, [switch]$OfficialRuntime = $true)
$ErrorActionPreference = 'Stop'
$runtimeRoot = Join-Path $PSScriptRoot 'runtime'
$gameRoot = Join-Path $runtimeRoot 'essentials-v21.1-base'
$env:RUBY_THREAD_VM_STACK_SIZE = '16777216'
$env:ARENA_DIAGNOSTICS = '1'
if ($Instance -eq 'guest') { $env:PEMK_INSTANCE = 'guest' } else { Remove-Item Env:PEMK_INSTANCE -ErrorAction SilentlyContinue }
$startInfo = New-Object Diagnostics.ProcessStartInfo
$startInfo.FileName = "$gameRoot/Game.exe"
$startInfo.Arguments = 'debug'
if ($OfficialRuntime) {
    $startInfo.FileName = Join-Path $runtimeRoot 'mkxp-official-test/mkxp-z.x86_64.exe'
    $startInfo.Arguments = 'debug'
}
$startInfo.WorkingDirectory = $gameRoot
if ($OfficialRuntime) { $startInfo.WorkingDirectory = Join-Path $runtimeRoot 'mkxp-official-test' }
$startInfo.UseShellExecute = $true
$client = [Diagnostics.Process]::Start($startInfo)
Write-Host "Client PID: $($client.Id). Console handles are unchanged; save-load diagnostics go to the instance's mmo log."
Start-Sleep -Seconds 8
$client.Refresh()
if (!$client.HasExited) {
    Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class ArenaClientFocus { [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd); }'
    [ArenaClientFocus]::SetForegroundWindow($client.MainWindowHandle) | Out-Null
    Start-Sleep -Seconds 2
    $client.Refresh()
}
if ($AutoClick -and !$client.HasExited) {
    1..2 | ForEach-Object {
        & "$PSScriptRoot/capture-client.ps1" -ClientPid $client.Id -Click
        Start-Sleep -Seconds 3
    }
    $client.Refresh()
    Write-Host "Automated held-click test: exited=$($client.HasExited)"
}
if (!$client.HasExited) {
    Write-Host "Client still running. Window: $($client.MainWindowTitle). Monitoring until it exits."
    $client.WaitForExit()
}
Write-Host "Client exited: $($client.ExitCode)"
