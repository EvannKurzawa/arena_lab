"""Battler QA in a disposable game/engine, never the shared native cache."""
from pathlib import Path
import json
import os
import shutil
import stat
import subprocess
import tempfile
import sys

root = Path(__file__).resolve().parent.parent
runtime = root / 'tools/runtime'
source = runtime / 'essentials-v21.1-base'
engine_source = runtime / 'mkxp-official-test'
ruby = runtime / 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
fixture = Path(tempfile.mkdtemp(prefix='battlers-native-', dir=runtime))
game, engine = fixture / 'game', fixture / 'engine'
report = runtime / 'battlers-native-report.log'
report.unlink(missing_ok=True)
links = []
process = None
passed = False
try:
    game.mkdir()
    # Private fixture files, not hard links: native compilers may rewrite Data.
    shutil.copytree(source / 'Data', game / 'Data', ignore=shutil.ignore_patterns('*probe*', '*backup*', '*before*'))
    # Preserve PBS too: regenerating it from runtime-registered optional species
    # would test a full data export rather than the installed game data.
    shutil.copytree(source / 'PBS', game / 'PBS')
    shutil.copytree(source / 'Plugins', game / 'Plugins', ignore=shutil.ignore_patterns('099*.rb'))
    plugins = game / 'Plugins/ArenaDemo'
    for plugin in (root / 'game-mod/Plugins/ArenaDemo').iterdir():
        if plugin.is_file() and not plugin.name.startswith('099'):
            shutil.copy2(plugin, plugins / plugin.name)
    selected_probe = 'native_dark_lugia_boot_probe.rb' if '--dark-lugia' in sys.argv else 'native_battlers_boot_probe.rb'
    shutil.copy2(root / 'game-mod/test' / selected_probe, plugins / '099_BattlerProbe.rb')
    # Capture boot failures before the main probe is loaded, without modal UI.
    (plugins / '000_000BattlersBootLog.rb').write_text('''
if ENV['ARENA_BATTLERS_PROBE']
  File.write(ENV.fetch('ARENA_BATTLERS_PROBE'), "Native test plugin loading\\n")
  module ArenaBattlersBootLog
    def print(*args)
      File.open(ENV.fetch('ARENA_BATTLERS_PROBE'), 'a') { |f| f.puts(args.map(&:to_s)) }
    end
  end
  Kernel.prepend(ArenaBattlersBootLog)
  TracePoint.new(:raise) do |event|
    File.open(ENV.fetch('ARENA_BATTLERS_PROBE'), 'a') { |f| f.puts(event.raised_exception.full_message) }
  end.enable
  at_exit do
    File.open(ENV.fetch('ARENA_BATTLERS_PROBE'), 'a') { |f| f.puts($!.inspect); f.puts($!.backtrace) if $! }
  end
end
''', encoding='utf-8')
    for name in ('093_ArenaTrainerCatalogFrames.rb', '094_AnimatedBattlers.rb', '095_DarkLugia.rb', '099_BattlerProbe.rb'):
        script = plugins / name
        if script.exists():
            script.write_text("File.open(ENV.fetch('ARENA_BATTLERS_PROBE'), 'a') { |f| f.puts('Loading " + name + "') }\n" + script.read_text(encoding='utf-8') + "\nFile.open(ENV.fetch('ARENA_BATTLERS_PROBE'), 'a') { |f| f.puts('Loaded " + name + "') }\n", encoding='utf-8')
    shutil.copy2(source / 'Game.ini', game / 'Game.ini')
    # Private Graphics tree: share existing art read-only, add isolated GIFs.
    (game / 'Graphics/Pokemon').mkdir(parents=True)
    graphics_links = [(entry, game / 'Graphics' / entry.name) for entry in (source / 'Graphics').iterdir() if entry.name != 'Pokemon']
    graphics_links += [(entry, game / 'Graphics/Pokemon' / entry.name) for entry in (source / 'Graphics/Pokemon').iterdir() if entry.name != 'ArenaAnimated']
    for target, link in graphics_links:
        if target.is_dir():
            subprocess.run(['cmd.exe', '/c', 'mklink', '/J', str(link), str(target)], check=True, capture_output=True)
            links.append(link)
        else:
            shutil.copy2(target, link)
    shutil.copytree(runtime / 'battler-assets/Graphics/Pokemon/ArenaAnimated', game / 'Graphics/Pokemon/ArenaAnimated')
    for name in ('Audio', 'Fonts'):
        target = source / name
        if not target.is_dir():
            continue
        link = game / name
        subprocess.run(['cmd.exe', '/c', 'mklink', '/J', str(link), str(target)], check=True, capture_output=True)
        links.append(link)
    shutil.copytree(engine_source, engine)
    config = json.loads((engine / 'mkxp.json').read_text(encoding='utf-8-sig'))
    config['gameFolder'] = game.as_posix()
    (engine / 'mkxp.json').write_text(json.dumps(config), encoding='utf-8')
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
    env = os.environ.copy()
    for name in ('ARENA_READY_FILE', 'ARENA_CONTROL_DIR', 'ARENA_AUTO_CONTINUE', 'ARENA_LOCALE_PROBE', 'ARENA_RELIEF_PROBE'):
        env.pop(name, None)
    env['ARENA_BATTLERS_PROBE'] = str(report)
    if '--dark-lugia' in sys.argv:
        env['ARENA_XD001_PROBE'] = str(report)
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    with (runtime / 'battlers-native-engine.log').open('w', encoding='utf-8') as engine_log:
        process = subprocess.Popen([str(engine / 'mkxp-z.x86_64.exe'), 'debug'], cwd=engine, env=env, startupinfo=info, stdout=engine_log, stderr=engine_log)
        process.wait(timeout=180)
    result = report.read_text(encoding='utf-8') if report.exists() else 'No battlers native report.'
    print(result)
    expected_result = 'native Dark Lugia checks passed' if '--dark-lugia' in sys.argv else 'native battlers checks passed'
    if process.returncode or expected_result not in result:
        raise SystemExit('Native battlers checks failed.')
    passed = True
finally:
    if process and process.poll() is None:
        process.terminate()
        process.wait(timeout=10)
    # Detach junctions non-recursively before deleting only copied fixture files.
    for link in links:
        os.rmdir(link)
    if fixture.resolve().parent != runtime.resolve():
        raise RuntimeError('Refusing fixture cleanup outside runtime')
    def remove_readonly(function, path, _error):
        os.chmod(path, stat.S_IWRITE | stat.S_IREAD | stat.S_IEXEC)
        function(path)
    if passed:
        shutil.rmtree(fixture, onerror=remove_readonly)
    else:
        print('Failed fixture retained (junctions detached):', fixture)
