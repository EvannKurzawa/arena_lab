"""Native XD001 validation using disposable in-memory profile data."""
from pathlib import Path
import os
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
game = root / 'tools/runtime/essentials-v21.1-base'
ruby = root / 'tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
engine = root / 'tools/runtime/mkxp-official-test'
devices = '--devices' in sys.argv
probe = game / ('Plugins/ArenaDemo/099_DevicesProbe.rb' if devices else 'Plugins/ArenaDemo/099_DarkLugiaProbe.rb')
report = root / ('tools/runtime/devices-native.log' if devices else 'tools/runtime/dark-lugia-native.log')
if probe.exists():
    raise SystemExit('A Dark Lugia probe already exists; inspect it before retrying.')
process = None
try:
    report.unlink(missing_ok=True)
    if devices:
        shutil.copytree(root / 'game-mod/Graphics/ArenaDevices', game / 'Graphics/ArenaDevices', dirs_exist_ok=True)
        shutil.copy2(root / 'tools/runtime/device-src-hgss-gym.jpg', game / 'Graphics/ArenaDevices/hgss-map.jpg')
        shutil.copy2(root / 'tools/runtime/device-src-hgss-teleport.wav', game / 'Audio/SE/Arena HGSS Teleport.wav')
    for source in (root / 'game-mod/Plugins/ArenaDemo').iterdir():
        if source.is_file():
            shutil.copy2(source, probe.parent / source.name)
    shutil.copy2(root / ('game-mod/test/native_devices_boot_probe.rb' if devices else 'game-mod/test/native_dark_lugia_boot_probe.rb'), probe)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
    env = os.environ.copy()
    for key in list(env):
        if key.startswith('ARENA_'):
            env.pop(key)
    env['ARENA_DEVICES_PROBE' if devices else 'ARENA_XD001_PROBE'] = str(report)
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    process = subprocess.Popen([str(engine / 'mkxp-z.x86_64.exe'), 'debug'], cwd=engine, env=env, startupinfo=info)
    process.wait(timeout=75)
    output = report.read_text(encoding='utf-8') if report.exists() else 'No native report.'
    print(output)
    expected = 'native device checks passed' if devices else 'native Dark Lugia checks passed'
    if process.returncode != 0 or expected not in output:
        raise SystemExit('Native Dark Lugia checks failed.')
finally:
    if process and process.poll() is None:
        process.terminate()
        process.wait(timeout=10)
    probe.unlink(missing_ok=True)
    subprocess.run([str(ruby), '--disable-gems', str(root / 'tools/sync-plugin-cache.rb'), str(game)], check=True)
