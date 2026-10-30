"""Exercise relief in the installed Windows mkxp-z, using only a disposable save."""
from pathlib import Path
import os
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
game = root / 'tools/runtime/essentials-v21.1-base'
ruby = root / 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
probe = game / 'Plugins/ArenaDemo/099_NativeReliefProbe.rb'
report_name = 'native-material-picker-probe.log' if '--picker' in sys.argv else 'native-relief-probe.log'
report = root / 'tools/runtime' / report_name
engine = root / 'tools/runtime/mkxp-official-test'
if probe.exists():
    raise SystemExit('A relief probe already exists; inspect it before retrying.')
report.unlink(missing_ok=True)
process = None
try:
    for source in (root / 'game-mod/Plugins/ArenaDemo').iterdir():
        if source.is_file():
            shutil.copy2(source, probe.parent / source.name)
    shutil.copy2(root / 'game-mod/test/native_relief_boot_probe.rb', probe)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
    env = os.environ.copy()
    env['ARENA_RELIEF_PROBE'] = str(report)
    for key in ('ARENA_READY_FILE', 'ARENA_CONTROL_DIR', 'ARENA_AUTO_CONTINUE', 'ARENA_LOCALE_PROBE'):
        env.pop(key, None)
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    process = subprocess.Popen([str(engine / 'mkxp-z.x86_64.exe'), 'debug'], cwd=engine, env=env, startupinfo=info)
    process.wait(timeout=55)
    output = report.read_text(encoding='utf-8') if report.exists() else 'No native relief report.'
    print(output)
    if process.returncode != 0 or 'native relief checks passed' not in output:
        raise SystemExit('Native relief checks failed.')
finally:
    if process and process.poll() is None:
        process.terminate()
        process.wait(timeout=10)
    probe.unlink(missing_ok=True)
    (game / 'Data/arena-relief-probe-save.rxdata').unlink(missing_ok=True)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
