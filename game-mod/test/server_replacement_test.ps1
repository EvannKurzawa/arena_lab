$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../tools/desktop-session.ps1"
$root = 'C:\arena test'
$checks = 0
function Assert-Replacement([bool]$Condition, [string]$Message) {
    if (!$Condition) { throw $Message }
    $script:checks++
}
function New-ServerRecord {
    $paths = @(
        "$root/tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe",
        "$root/tools/run-local-server.rb", "$root/tools/runtime/pemk-workspace/server",
        "$root/tools/runtime/pemk-server.log"
    ) | ForEach-Object { [IO.Path]::GetFullPath($_) }
    [pscustomobject]@{ ProcessId = 1234; CreationDate = [datetime]'2026-10-28T11:24:28Z'; ExecutablePath = $paths[0]; CommandLine = (($paths | ForEach-Object { '"' + $_ + '"' }) -join ' ') }
}
$record = New-ServerRecord
Assert-Replacement (Test-ArenaServerIdentity $record $root) 'Quoted workspace paths were not recognized.'
$record.CommandLine = $record.CommandLine.Replace('\', '/')
Assert-Replacement (Test-ArenaServerIdentity $record $root) 'Mixed path separators were not recognized.'
$record.ExecutablePath = 'C:\other\ruby.exe'
Assert-Replacement (!(Test-ArenaServerIdentity $record $root)) 'An unrelated Ruby executable was accepted.'
$record = New-ServerRecord
$record.CommandLine += ' --unexpected'
Assert-Replacement (!(Test-ArenaServerIdentity $record $root)) 'Extra command-line arguments were accepted.'
$record = New-ServerRecord
$record.CommandLine = $record.CommandLine.Replace('run-local-server.rb', 'unrelated.rb')
Assert-Replacement (!(Test-ArenaServerIdentity $record $root)) 'An unrelated Ruby script was accepted.'
$record = New-ServerRecord
Assert-Replacement (!(Test-ArenaServerIdentity $record 'C:\another arena')) 'A different workspace was accepted.'
$script:stoppedId = $null
$script:record = New-ServerRecord
$script:rows = @([pscustomobject]@{ State = 'LISTENING'; ProcessId = 1234 })
$parameters = @{
    ProjectRoot = $root
    ReadConnections = { $script:rows }
    ReadProcess = { param($targetId) $script:record }
    StopVerified = { param($verified) $script:stoppedId = $verified.ProcessId }
}
Stop-ArenaLegacyService @parameters
Assert-Replacement ($script:stoppedId -eq 1234) 'The verified idle service was not selected.'
$script:stoppedId = $null
$script:rows += [pscustomobject]@{ State = 'ESTABLISHED'; ProcessId = 1234 }
$refused = $false
try { Stop-ArenaLegacyService @parameters } catch { $refused = $true }
Assert-Replacement ($refused -and !$script:stoppedId) 'A service with active players was stopped.'
$script:rows = @([pscustomobject]@{ State = 'LISTENING'; ProcessId = 1234 })
$script:record = New-ServerRecord
$script:record.ExecutablePath = 'C:\unknown.exe'
$refused = $false
try { Stop-ArenaLegacyService @parameters } catch { $refused = $true }
Assert-Replacement ($refused -and !$script:stoppedId) 'An unverified listener was stopped.'
$script:record = New-ServerRecord
$script:reads = 0
$parameters.ReadProcess = {
    param($targetId)
    $script:reads++
    $snapshot = $script:record.PSObject.Copy()
    if ($script:reads -gt 1) { $snapshot.CreationDate = $snapshot.CreationDate.AddSeconds(1) }
    $snapshot
}
$refused = $false
try { Stop-ArenaLegacyService @parameters } catch { $refused = $true }
Assert-Replacement ($refused -and !$script:stoppedId) 'A reused process ID was stopped.'
$parameters.ReadProcess = { param($targetId) $script:record }
$script:networkReads = 0
$parameters.ReadConnections = {
    $script:networkReads++
    $script:rows
    if ($script:networkReads -gt 1) { [pscustomobject]@{ State = 'ESTABLISHED'; ProcessId = 1234 } }
}
$refused = $false
try { Stop-ArenaLegacyService @parameters } catch { $refused = $true }
Assert-Replacement ($refused -and !$script:stoppedId) 'A newly connected player did not prevent replacement.'
Write-Output "PASS: $checks idle-server ownership/replacement checks; no real process was stopped."
