param(
    [ValidateSet('Check', 'Server', 'Test', 'Prepare', 'Ready', 'RepairGems')]
    [string]$Action = 'Check'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$runtimeRoot = Join-Path $projectRoot 'tools/runtime'
$rubyExe = Join-Path $runtimeRoot 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$pgBin = Join-Path $runtimeRoot 'postgresql/pgsql/bin'
$serverRoot = Join-Path $runtimeRoot 'pemk-workspace/server'
$gameRoot = Join-Path $runtimeRoot 'essentials-v21.1-base'
$pgData = Join-Path $runtimeRoot 'pgdata'
$env:GEM_HOME = Join-Path $runtimeRoot 'bundle/ruby/3.3.0'
$env:GEM_PATH = $env:GEM_HOME
$env:PATH = "$(Split-Path $rubyExe);$pgBin;$env:PATH"
$env:PEMK_BIND = '127.0.0.1'
$env:PEMK_PORT = '9998'
$env:DATABASE_URL = 'postgres://postgres@127.0.0.1:55432/pemk'

function Invoke-Ruby([string[]]$RubyArguments) {
    & $rubyExe @RubyArguments
    if ($LASTEXITCODE -ne 0) { throw "Ruby command failed (exit $LASTEXITCODE)." }
}

function Start-LocalDatabase {
    & "$pgBin/pg_isready.exe" -h 127.0.0.1 -p 55432 -U postgres -d pemk -q
    if ($LASTEXITCODE -eq 0) { return }
    if (!(Test-Path -LiteralPath "$pgData/PG_VERSION")) { throw 'Local PostgreSQL cluster is missing. See SETUP_STATUS.md.' }
    Start-Process -FilePath "$pgBin/postgres.exe" -ArgumentList @('-D', "`"$pgData`"", '-p', '55432', '-h', '127.0.0.1') -WindowStyle Hidden -RedirectStandardOutput "$runtimeRoot/postgres.stdout.log" -RedirectStandardError "$runtimeRoot/postgres.stderr.log"
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Milliseconds 500
        & "$pgBin/pg_isready.exe" -h 127.0.0.1 -p 55432 -U postgres -d pemk -q
        if ($LASTEXITCODE -eq 0) { return }
    }
    throw 'PostgreSQL did not become ready. See tools/runtime/postgres.stderr.log.'
}

function Prepare-Clients {
    $pluginTarget = Join-Path $gameRoot 'Plugins/ArenaDemo'
    New-Item -ItemType Directory -Path $pluginTarget -Force | Out-Null
    $legacyFix = Join-Path $pluginTarget '000_RuntimeInputFix.rb'
    if (Test-Path -LiteralPath $legacyFix) {
        if ((Get-FileHash -LiteralPath $legacyFix -Algorithm SHA256).Hash -ne '7BF737189495BEC3151427C019C8E44B724EAC0D876E0D1D1C0D373F19463DCE') { throw 'The temporary input fix was modified locally; preserve and inspect it before removing it.' }
        Remove-Item -LiteralPath $legacyFix -Force
    }
    Copy-Item -Path "$projectRoot/game-mod/Plugins/ArenaDemo/*.rb" -Destination $pluginTarget -Force
    Copy-Item -LiteralPath "$projectRoot/game-mod/Plugins/ArenaDemo/meta.txt" -Destination $pluginTarget -Force
    # Repair only the generated local junction after moving the workspace.
    $linkPath = Join-Path $gameRoot 'server'
    $link = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
    if ($link -and ($link.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        if ([IO.Path]::GetFullPath($linkPath) -ne [IO.Path]::GetFullPath((Join-Path $runtimeRoot 'essentials-v21.1-base/server'))) { throw 'Unexpected junction path.' }
        if ($link.Target -ne $serverRoot) { [IO.Directory]::Delete($linkPath) }
    } elseif ($link) {
        throw 'The local game server path is a real directory. Leave it intact and review its export configuration.'
    }
    if (!(Test-Path -LiteralPath $linkPath)) { New-Item -ItemType Junction -Path $linkPath -Target $serverRoot | Out-Null }
    foreach ($name in @('mmo_config.txt', 'mmo_config_guest.txt')) {
        $configPath = Join-Path $gameRoot $name
        # Never overwrite existing configuration or saved credentials.
        if (!(Test-Path -LiteralPath $configPath)) { Set-Content -LiteralPath $configPath -Value "host = 127.0.0.1`nport = 9998" -Encoding ASCII }
    }
    & "$PSScriptRoot/install-client-runtime.ps1"
    Invoke-Ruby @("$projectRoot/game-mod/tools/build_arena_map.rb", $gameRoot)
    Write-Host 'Clients prepared. Use a different account in each game window; existing accounts are retained.'
}

if (!(Test-Path -LiteralPath $rubyExe)) { throw 'Bundled Ruby is missing.' }
if (!(Test-Path -LiteralPath "$serverRoot/bin/pemk_server.rb")) { throw 'The local PEMK server workspace is missing.' }
Write-Host "Arena Lab folder: $projectRoot"
if ($Action -eq 'Ready') { Invoke-Ruby @("$PSScriptRoot/ping_multiplayer.rb"); exit 0 }
if ($Action -eq 'RepairGems') {
    if (!(Test-Path -LiteralPath 'C:/msys64/ucrt64/bin/gcc.exe')) { throw 'Install the MSYS2 UCRT compiler first (see README.md).' }
    $env:PATH = "$(Split-Path $rubyExe);C:/msys64/ucrt64/bin;C:/msys64/usr/bin;$env:PATH"
    Invoke-Ruby @("$(Split-Path $rubyExe)/gem", 'pristine', 'bcrypt', 'bigdecimal', '--extensions', '--install-dir', $env:GEM_HOME)
    exit 0
}
if ($Action -eq 'Prepare') { Prepare-Clients; exit 0 }
Start-LocalDatabase
if ($Action -eq 'Check') { Invoke-Ruby @("$PSScriptRoot/check_multiplayer.rb"); exit 0 }
if ($Action -eq 'Test') {
    # Upstream tests DELETE account rows. Always use the isolated test database.
    $env:DATABASE_URL = 'postgres://postgres@127.0.0.1:55432/pemk_test'
    Invoke-Ruby @("$PSScriptRoot/migrate-local.rb", $serverRoot)
    Invoke-Ruby @("$serverRoot/test/auth_test.rb")
    Invoke-Ruby @("$serverRoot/test/server_auth_test.rb")
    Invoke-Ruby @("$serverRoot/test/server_presence_test.rb")
    Invoke-Ruby @("$projectRoot/game-mod/test/multiplayer_arena_test.rb")
    Invoke-Ruby @("$projectRoot/game-mod/test/login_connection_test.rb")
    exit 0
}
Invoke-Ruby @("$PSScriptRoot/check_multiplayer.rb")
Invoke-Ruby @("$PSScriptRoot/migrate-local.rb", $serverRoot)
Write-Host 'PEMK local server: 127.0.0.1:9998. Press Ctrl+C to stop.'
Write-Host "Server log: $runtimeRoot/pemk-server.log"
Push-Location $serverRoot
try { Invoke-Ruby @("$PSScriptRoot/run-local-server.rb", $serverRoot, "$runtimeRoot/pemk-server.log") } finally { Pop-Location }
