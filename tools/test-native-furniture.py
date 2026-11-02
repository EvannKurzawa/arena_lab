"""Furniture QA in a disposable game/engine, never the shared native cache."""
from pathlib import Path
import json
import os
import shutil
import stat
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
runtime = root / 'tools/runtime'
source = runtime / 'essentials-v21.1-base'
engine_source = runtime / 'mkxp-official-test'
ruby = runtime / 'ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
fixture = Path(tempfile.mkdtemp(prefix='furniture-native-', dir=runtime))
game, engine = fixture / 'game', fixture / 'engine'
report = runtime / 'furniture-native-report.log'
report.unlink(missing_ok=True)
links = []
process = None
try:
    game.mkdir()
    # Private fixture files, not hard links: native compilers may rewrite Data.
    shutil.copytree(source / 'Data', game / 'Data', ignore=shutil.ignore_patterns('*probe*', '*backup*', '*before*'))
    shutil.copytree(source / 'Plugins', game / 'Plugins', ignore=shutil.ignore_patterns('099*.rb'))
    plugins = game / 'Plugins/ArenaDemo'
    for plugin in (root / 'game-mod/Plugins/ArenaDemo').iterdir():
        if plugin.is_file() and not plugin.name.startswith('099'):
            shutil.copy2(plugin, plugins / plugin.name)
    shutil.copy2(root / 'game-mod/test/native_furniture_boot_probe.rb', plugins / '099_FurnitureProbe.rb')
    shutil.copy2(source / 'Game.ini', game / 'Game.ini')
    for name in ('Graphics', 'Audio', 'Fonts'):
        target = source / name
        if not target.is_dir():
            continue
        if name == 'Graphics':
            graphics = game / name
            graphics.mkdir()
            for child in target.iterdir():
                if child.name == 'ArenaFurniture':
                    continue
                destination = graphics / child.name
                if child.is_dir():
                    subprocess.run(['cmd.exe', '/c', 'mklink', '/J', str(destination), str(child)], check=True, capture_output=True)
                    links.append(destination)
                else:
                    shutil.copy2(child, destination)
            shutil.copytree(root / 'game-mod/SharedAssets/Graphics/ArenaFurniture', graphics / 'ArenaFurniture')
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
    env['ARENA_FURNITURE_PROBE'] = str(report)
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    process = subprocess.Popen([str(engine / 'mkxp-z.x86_64.exe'), 'debug'], cwd=engine, env=env, startupinfo=info)
    process.wait(timeout=90)
    if not report.exists():
        error_log = game / 'errorlog.txt'
        if error_log.exists():
            print(error_log.read_text(encoding='utf-8', errors='replace')[-6000:])
    result = report.read_text(encoding='utf-8') if report.exists() else 'No furniture native report.'
    print(result)
    if process.returncode or 'native furniture checks passed' not in result:
        raise SystemExit('Native furniture checks failed.')
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
    shutil.rmtree(fixture, onerror=remove_readonly)
