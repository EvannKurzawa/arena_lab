"""Run native visual regressions without reading or writing a player's save."""
from pathlib import Path
import os
import shutil
import subprocess

root = Path(__file__).resolve().parent.parent
game = root / 'tools/runtime/essentials-v21.1-base'
ruby = root / 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
engine = root / 'tools/runtime/mkxp-official-test'
probe = game / 'Plugins/ArenaDemo/099_NativeVisualProbe.rb'
report = root / 'tools/runtime/native-visual-probe.log'
if probe.exists():
    raise SystemExit('A visual probe already exists; inspect it before retrying.')
process = None
try:
    report.unlink(missing_ok=True)
    for source in (root / 'game-mod/Plugins/ArenaDemo').iterdir():
        if source.is_file():
            shutil.copy2(source, probe.parent / source.name)
    shutil.copy2(root / 'game-mod/test/native_visual_boot_probe.rb', probe)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
    env = os.environ.copy()
    for key in ('ARENA_READY_FILE', 'ARENA_CONTROL_DIR', 'ARENA_AUTO_CONTINUE', 'ARENA_LOCALE_PROBE', 'ARENA_RELIEF_PROBE'):
        env.pop(key, None)
    env['ARENA_VISUAL_PROBE'] = str(report)
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    process = subprocess.Popen([str(engine / 'mkxp-z.x86_64.exe'), 'debug'], cwd=engine, env=env, startupinfo=info)
    process.wait(timeout=90)
    output = report.read_text(encoding='utf-8') if report.exists() else 'No native report.'
    print('\n'.join(output.splitlines()[-12:]))
    if process.returncode != 0 or 'native visual checks passed' not in output:
        raise SystemExit('Native visual checks failed.')
finally:
    if process and process.poll() is None:
        process.terminate()
        process.wait(timeout=10)
    probe.unlink(missing_ok=True)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
