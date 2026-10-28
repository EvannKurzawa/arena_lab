# Play together on two computers

This guide describes the tested setup: one prepared host computer and one
GitHub-installed client on the same home network. The client installer does not
yet install the host's PostgreSQL/Ruby server stack.

## Second computer: install the client

1. Download the [Pokémon Essentials v21.1 pack](https://luka-sj.com/essentials/resources/PE21/download) and extract it. Select the folder containing `Game.ini`, `Data`, and `Graphics` later.
2. Download the [v21.1 Hotfixes plugin](https://www.mediafire.com/file/znhw2jk5judt3ga/v21.1_Hotfixes.zip/file), extract it, and put the folder containing `meta.txt` and its scripts inside `PE21/Plugins/`. The final plugin folder should be `PE21/Plugins/v21.1 Hotfixes/`.
3. Download [ArenaLab-Setup.exe](https://github.com/EvannKurzawa/arena_lab/releases/download/v3.3/ArenaLab-Setup.exe). Choose an empty Arena Lab install folder, then select the extracted `PE21` game folder when prompted. The installer downloads the pinned Arena Lab client dependencies.
4. Open the Arena Lab install folder and double-click `Play-Arena.bat`. Start a new game if prompted and choose **Skip intro** to reach Arena Town.

## Connect to the host

1. On the host computer, open `Play-Arena.bat`, talk to the arena entrance attendant, and choose **Host online**. Leave that game running and note the address shown as **Other PC on your network**.
2. On the second computer, talk to its entrance attendant and choose **Join a host**. Enter the host's displayed network IP, such as `192.168.1.127`. Do not enter `127.0.0.1`; that address only refers to the same computer.
3. Log in or create a different account on the second computer. The host can invite that account ID; accept the invitation at the second computer's attendant.

Both computers must be on the same local network. If the client cannot connect,
allow the host's Ruby service through Windows Firewall on private networks, TCP
port `9998`. The database stays private on the host computer.

## What this test establishes

The user confirmed that the GitHub-installed second-computer client communicated
with the prepared host over the local network. The current installer prepares a
client to play offline or join. Installing the host backend on any clean
computer, and using either computer as host or client without extra preparation,
is a later milestone.
