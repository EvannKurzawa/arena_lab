param(
    [string]$OutputDirectory = (Join-Path (Split-Path $PSScriptRoot -Parent) 'dist'),
    [string]$SourceCommit = ''
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
if (!$SourceCommit) {
    $safeRoot = $repoRoot.Replace('\', '/')
    $SourceCommit = (& git -c "safe.directory=$safeRoot" -C $repoRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not determine the source commit.' }
}
if ($SourceCommit -notmatch '^[0-9a-f]{40}$') { throw 'SourceCommit must be a full Git commit hash.' }
$compiler = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
if (!(Test-Path -LiteralPath $compiler)) { throw 'The Windows .NET Framework C# compiler is required to build the installer wrappers.' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$work = Join-Path $env:TEMP ('ArenaLab-Package-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null
try {
    $sourceScript = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'deliverables/install-arena.ps1') -Raw
    $sourceScript = $sourceScript.Replace("`$appCommit = 'd87071996ab82a6d846abf77a7cc274a2aedbf2b'", "`$appCommit = '$SourceCommit'")
    if ($sourceScript -notmatch [regex]::Escape("`$appCommit = '$SourceCommit'")) { throw 'Could not pin the installer to the requested source commit.' }

    foreach ($package in @(
        @{ Name='ArenaLab-Setup'; Script='install-arena.ps1'; Body=$sourceScript },
        @{ Name='ArenaLab-Update'; Script='update-arena.ps1'; Body=(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'deliverables/update-arena.ps1') -Raw) }
    )) {
        $tokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($package.Body, [ref]$tokens, [ref]$parseErrors)
        if ($parseErrors.Count) { throw "$($package.Script) has PowerShell syntax errors: $($parseErrors -join '; ')" }
        $target = Join-Path $OutputDirectory ($package.Name + '.exe')
        $template = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'deliverables/exe-wrapper.cs') -Raw
        $payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($package.Body))
        $wrapperSource = $template.Replace('@@PAYLOAD_BASE64@@', $payload)
        $sourcePath = Join-Path $work ($package.Name + '.cs')
        [IO.File]::WriteAllText($sourcePath, $wrapperSource, [Text.UTF8Encoding]::new($false))
        & $compiler /nologo /target:winexe /reference:System.Windows.Forms.dll "/out:$target" $sourcePath
        if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $target)) { throw ".NET Framework failed to build $($package.Name).exe (exit $LASTEXITCODE)." }
        Write-Host ("{0} {1:N0} bytes SHA256 {2}" -f (Split-Path $target -Leaf), (Get-Item $target).Length, (Get-FileHash $target -Algorithm SHA256).Hash)
    }
    Write-Host "Pinned source commit: $SourceCommit"
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
