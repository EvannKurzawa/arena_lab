param([ValidateSet('primary','guest')][string]$Instance = 'primary', [switch]$ValidateOnly)
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot/install-client-runtime.ps1"
$engineRoot = Join-Path $PSScriptRoot 'runtime/mkxp-official-test'
$engine = Join-Path $engineRoot 'mkxp-z.x86_64.exe'
$env:RUBY_THREAD_VM_STACK_SIZE = '16777216'
Remove-Item Env:ARENA_DIAGNOSTICS -ErrorAction SilentlyContinue
Remove-Item Env:PEMK_GUEST -ErrorAction SilentlyContinue
if ($Instance -eq 'guest') { $env:PEMK_INSTANCE = 'guest' } else { Remove-Item Env:PEMK_INSTANCE -ErrorAction SilentlyContinue }
if ($ValidateOnly) {
    Write-Host "Validated $Instance client: $engine (instance=$env:PEMK_INSTANCE)."
    exit 0
}
# Essentials opens its own console; redirecting stdout/stderr can produce EBADF.
$startInfo = New-Object Diagnostics.ProcessStartInfo
$startInfo.FileName = $engine
$startInfo.Arguments = 'debug'
$startInfo.WorkingDirectory = $engineRoot
$startInfo.UseShellExecute = $true
$process = [Diagnostics.Process]::Start($startInfo)
Write-Host "Started $Instance game client (PID $($process.Id))."
