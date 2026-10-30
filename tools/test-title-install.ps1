$ErrorActionPreference = 'Stop'
$fixture = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ('runtime/title-test-' + [guid]::NewGuid().ToString('N'))))
$boundary = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'runtime')).TrimEnd('\') + '\'
if (!$fixture.StartsWith($boundary, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid fixture path' }
try {
    $scripts = Join-Path $fixture 'tools'
    $runtime = Join-Path $scripts 'runtime'
    $game = Join-Path $runtime 'game'
    New-Item -ItemType Directory -Path (Join-Path $game 'Data') -Force | Out-Null
    # Sentinel compiled-data file prevents unrelated French preparation here.
    [IO.File]::WriteAllText((Join-Path $game 'Data/messages_french_core.dat'), 'fixture-only')
    $helper = Join-Path $scripts 'install-french-title.ps1'
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'install-french-title.ps1') -Destination $helper
    & $helper -GameRoot $game
    $expected = '810E7FAC8CE653F2CC938E7528F0B38D61F69D12C8D53909B2430D58C0571CF1'
    foreach ($image in @((Join-Path $fixture 'title_screen.png'), (Join-Path $game 'Graphics/Titles/arena_title.png'))) {
        if ((Get-FileHash -LiteralPath $image).Hash -ne $expected) { throw 'Title repair failed' }
    }
    function Invoke-WebRequest { throw 'Cached title should not download again' }
    & $helper -GameRoot $game
    Write-Host 'Title install checks passed: missing root image downloaded/verified, game title installed, cached launch works offline.'
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
