$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$ruby = Join-Path $PSScriptRoot 'runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$work = Join-Path $env:TEMP ('Arena-Update-Plugins-' + [guid]::NewGuid().ToString('N'))
$game = Join-Path $work 'game [other PC]'
try {
    New-Item -ItemType Directory -Path "$game/Data","$game/Plugins/ArenaDemo","$game/Plugins/PEMK" -Force | Out-Null
    [IO.File]::WriteAllText("$game/Data/messages_french_core.dat", 'existing French data')
    [IO.File]::WriteAllText("$game/Plugins/ArenaDemo/007_ConnectionMode.rb", 'old runtime script')
    [IO.File]::WriteAllText("$game/Plugins/PEMK/meta.txt", "Name = PEMK`nVersion = 0.1.0`n")
    [IO.File]::WriteAllText("$game/Plugins/PEMK/core.rb", 'module PEMK; end')
    foreach ($name in @('Game.rxdata','mmo_config.txt','account.dat')) {
        [IO.File]::WriteAllText((Join-Path $game $name), 'keep personal data')
    }
    $probe = Join-Path $work 'probe.rb'
    [IO.File]::WriteAllText($probe, @'
require 'zlib'
game, source, mode = ARGV
cache = File.join(game, 'Data/PluginScripts.rxdata')
if mode == 'seed'
  File.binwrite(cache, Marshal.dump([['Arena Demo', { version: 'old' }, [['007_ConnectionMode.rb', Zlib::Deflate.deflate('old cache')]]]]))
else
  entries = Marshal.load(File.binread(cache))
  raise 'PEMK missing or late' unless entries.map(&:first) == ['PEMK', 'Arena Demo']
  arena = entries.last
  arena[2].each do |name, compressed|
    raise "Stale cache #{name}" unless Zlib::Inflate.inflate(compressed) == File.binread(File.join(source, name))
  end
  raise 'Connection script missing' unless arena[2].any? { |name, _| name == '007_ConnectionMode.rb' }
end
'@)
    & $ruby --disable-gems $probe $game (Join-Path $project 'game-mod/Plugins/ArenaDemo') seed
    if ($LASTEXITCODE -ne 0) { throw 'Could not seed stale cache' }
    # This is the exact helper call made by the already released updater EXE.
    & "$PSScriptRoot/install-french-data.ps1" -GameRoot $game -ProjectRoot $project -Download
    & $ruby --disable-gems $probe $game (Join-Path $project 'game-mod/Plugins/ArenaDemo') verify
    if ($LASTEXITCODE -ne 0) { throw 'Updater left stale compiled scripts' }
    $cacheHash = (Get-FileHash -LiteralPath "$game/Data/PluginScripts.rxdata").Hash
    & "$PSScriptRoot/install-french-data.ps1" -GameRoot $game -ProjectRoot $project -Download
    if ((Get-FileHash -LiteralPath "$game/Data/PluginScripts.rxdata").Hash -ne $cacheHash) { throw 'Repeat update changed identical cache' }
    foreach ($name in @('Game.rxdata','mmo_config.txt','account.dat')) {
        if ([IO.File]::ReadAllText((Join-Path $game $name)) -ne 'keep personal data') { throw "Personal file changed: $name" }
    }
    if (!(Test-Path -LiteralPath "$game/arena-plugin-backups")) { throw 'Old runtime script backup missing' }
    Write-Host 'Released updater helper test passed: existing French data, stale runtime/cache, absent PEMK cache, matching current scripts, repeat update, personal data preserved.'
} finally {
    if ([IO.Path]::GetFullPath($work).StartsWith([IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}
