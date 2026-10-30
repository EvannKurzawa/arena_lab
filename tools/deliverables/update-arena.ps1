param([string]$InstallDirectory = '')
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms
$stage = 'Selecting installation folder'
trap {
    $failure = $_
    $message = "Step: $stage`n`n$($failure.Exception.Message)"
    try {
        $log = Join-Path $env:TEMP ('ArenaLab-Update-error-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
        [IO.File]::WriteAllText($log, "$message`r`n$($failure.Exception.ToString())`r`n$($failure.InvocationInfo.PositionMessage)`r`n$($failure.ScriptStackTrace)")
        $message += "`n`nDiagnostic: $log"
    } catch { }
    [Windows.Forms.MessageBox]::Show($message, 'Arena Lab update failed') | Out-Null
    exit 1
}

function Get-ArenaActiveGame {
    param([string]$InstallRoot,
          [scriptblock]$ReadProcesses = { Get-Process | Where-Object { $_.ProcessName -in @('mkxp-z.x86_64', 'Game') } })
    $prefix = [IO.Path]::GetFullPath($InstallRoot).TrimEnd('\') + '\'
    foreach ($process in (& $ReadProcesses)) {
        try { $path = $process.Path } catch { $path = $null }
        if (!$path) {
            throw "Cannot check the location of running game PID $($process.Id). Close all Game/mkxp-z windows and retry. No files were changed."
        }
        if ($path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { $process }
    }
}

if (!$InstallDirectory) {
$picker = New-Object Windows.Forms.FolderBrowserDialog
$picker.Description = 'Select the existing Arena Lab folder (the one containing Play-Arena.bat). Close all game windows first.'
try {
    if ($picker.ShowDialog() -ne [Windows.Forms.DialogResult]::OK) { exit 0 }
    $InstallDirectory = $picker.SelectedPath
} finally { $picker.Dispose() }
}
$stage = 'Validating installation folder'
$root = [IO.Path]::GetFullPath($InstallDirectory)
if (!(Test-Path -LiteralPath (Join-Path $root 'Play-Arena.bat')) -or !(Test-Path -LiteralPath (Join-Path $root 'tools/play-arena.ps1'))) { throw 'That folder is not an Arena Lab installation.' }
$stage = 'Checking running games'
$active = @(Get-ArenaActiveGame -InstallRoot $root)
if ($active.Count) { throw 'Close Arena Lab game windows before updating. No files were changed.' }
$repo = 'EvannKurzawa/arena_lab'
$stage = 'Creating update workspace'
$work = Join-Path $env:TEMP ('ArenaLab-Update-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null
$backup = Join-Path $root ('update-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
try {
    $stage = 'Downloading source from GitHub'
    $zip = Join-Path $work 'latest.zip'
    Invoke-WebRequest -UseBasicParsing -Uri "https://codeload.github.com/$repo/zip/refs/heads/main" -OutFile $zip
    $stage = 'Extracting source archive'
    Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $work 'source')
    $source = Get-ChildItem -LiteralPath (Join-Path $work 'source') -Directory | Select-Object -First 1
    $topLevel = @('.gitignore','AGENTS.md','CHANGELOG.md','Play-Arena.bat','README.md','SETUP_STATUS.md')
    $files = [Collections.Generic.List[string]]::new()
    foreach ($item in $topLevel) { if (Test-Path -LiteralPath (Join-Path $source.FullName $item)) { $files.Add($item) } }
    foreach ($directory in @('game-mod','tools')) {
        $base = Join-Path $source.FullName $directory
        if (Test-Path -LiteralPath $base) {
            Get-ChildItem -LiteralPath $base -File -Recurse | ForEach-Object {
                $files.Add($_.FullName.Substring($source.FullName.Length + 1))
            }
        }
    }
    $stage = 'Backing up and replacing source files'
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    $updated = [Collections.Generic.List[string]]::new()
    foreach ($item in $files) {
        $from = Join-Path $source.FullName $item
        $to = Join-Path $root $item
        if (Test-Path -LiteralPath $to -PathType Leaf) {
            $saved = Join-Path $backup $item
            New-Item -ItemType Directory -Path (Split-Path $saved -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $to -Destination $saved -Force
        }
        New-Item -ItemType Directory -Path (Split-Path $to -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $from -Destination $to -Force
        $updated.Add($item)
    }
    [IO.File]::WriteAllText((Join-Path $root 'arena-install.json'), (@{ updatedUtc=[DateTime]::UtcNow.ToString('o'); source='GitHub main'; backup=(Split-Path $backup -Leaf); files=$updated } | ConvertTo-Json -Depth 4), [Text.UTF8Encoding]::new($false))
    [Windows.Forms.MessageBox]::Show("Arena Lab files updated from GitHub main.`n`nBackup: $backup`nYour game assets, runtime, saves, accounts and local server data were left in place. Run Play-Arena.bat to prepare the update.", 'Arena Lab update complete') | Out-Null
} catch {
    if (Test-Path -LiteralPath $backup) { Get-ChildItem -LiteralPath $backup -File -Recurse | ForEach-Object { $relative = $_.FullName.Substring($backup.Length + 1); Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $root $relative) -Force } }
    throw
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
