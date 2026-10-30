$ErrorActionPreference = 'Stop'
$tokens = $null
$parseErrors = $null
$file = Join-Path $PSScriptRoot 'deliverables/update-arena.ps1'
$ast = [Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw ($parseErrors -join '; ') }
$function = $ast.Find({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-ArenaActiveGame' }, $true)
. ([scriptblock]::Create($function.Extent.Text))
$target = 'C:\Games\Arena [test]'
if (@(Get-ArenaActiveGame $target { @() }).Count) { throw 'Empty process list must allow update' }
$found = @(Get-ArenaActiveGame $target { @(
    [pscustomobject]@{Id=10;Path='c:\games\arena [test]\tools\runtime\Game.exe'},
    [pscustomobject]@{Id=11;Path='C:\Games\Arena [test] other\Game.exe'},
    [pscustomobject]@{Id=12;Path='C:\Other\Game.exe'}
) })
if ($found.Count -ne 1 -or $found[0].Id -ne 10) { throw 'Must match exact installation boundary, case-insensitively and literally' }
try {
    Get-ArenaActiveGame $target { [pscustomobject]@{Id=13;Path=$null} }
    throw 'Missing path unexpectedly allowed'
} catch { if ($_.Exception.Message -notlike '*Close all Game/mkxp-z*') { throw } }
$denied = [pscustomobject]@{Id=14}
$denied | Add-Member ScriptProperty Path { throw 'Access denied' }
try {
    Get-ArenaActiveGame $target { $denied }
    throw 'Unreadable path unexpectedly allowed'
} catch { if ($_.Exception.Message -notlike '*Close all Game/mkxp-z*') { throw } }
$live = @(Get-ArenaActiveGame 'C:\nonexistent-arena-test')
if ($live.Count) { throw 'Unexpected live fixture match' }
if ((Get-Content -LiteralPath $file -Raw) -match 'Get-CimInstance') { throw 'Updater still depends on WMI/CIM' }
Write-Host 'Updater checks passed: syntax, empty/live process listing, exact paths, unknown/denied paths, no WMI/CIM.'
