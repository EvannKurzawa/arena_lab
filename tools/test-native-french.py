"""Run the French regression probe through mkxp-z's real plugin loader (Windows)."""
from pathlib import Path
import os
import shutil
import subprocess

root = Path(__file__).resolve().parent.parent
game = root / 'tools/runtime/essentials-v21.1-base'
ruby = root / 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
probe = game / 'Plugins/ArenaDemo/099_NativeLocaleProbe.rb'
report = root / 'tools/runtime/native-locale-probe.log'
engine = root / 'tools/runtime/mkxp-official-test'
if probe.exists():
    raise SystemExit('A native probe plugin already exists. Inspect it before retrying.')
report.unlink(missing_ok=True)
process = None
try:
    subprocess.run([str(ruby), '--disable-gems', str(root / 'game-mod/tools/audit_french_messages.rb')], cwd=root, check=True)
    shutil.copy2(root / 'game-mod/test/native_french_boot_probe.rb', probe)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
    env = os.environ.copy()
    env['ARENA_LOCALE_PROBE'] = str(report)
    env.pop('ARENA_READY_FILE', None)
    env.pop('ARENA_CONTROL_DIR', None)
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    process = subprocess.Popen([str(engine / 'mkxp-z.x86_64.exe'), 'debug'], cwd=engine, env=env, startupinfo=info)
    process.wait(timeout=55)
    output = report.read_text(encoding='utf-8') if report.exists() else 'No native probe report.'
    print(output)
    if process.returncode != 0 or 'native engine checks passed' not in output:
        raise SystemExit('Native French checks failed.')
finally:
    if process and process.poll() is None:
        process.terminate()
        process.wait(timeout=10)
    probe.unlink(missing_ok=True)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
