# Play together on two computers

Two-computer communication was previously confirmed with one prepared host and
one GitHub-installed client using the old manual-address/invitation flow. The
updated automatic-discovery/request flow works in-game on one computer, but has
not yet been retested between two computers. The client installer does not
install the host's PostgreSQL/Ruby server stack.

## Second computer: install the client

1. Download the [Pokémon Essentials v21.1 pack](https://luka-sj.com/essentials/resources/PE21/download) and extract it. Select the folder containing `Game.ini`, `Data`, and `Graphics` later.
2. Download the [v21.1 Hotfixes plugin](https://www.mediafire.com/file/znhw2jk5judt3ga/v21.1_Hotfixes.zip/file), extract it, and put the folder containing `meta.txt` and its scripts inside `PE21/Plugins/`. The final plugin folder should be `PE21/Plugins/v21.1 Hotfixes/`.
3. Download [ArenaLab-Setup.exe](https://github.com/EvannKurzawa/arena_lab/releases/download/v3.3/ArenaLab-Setup.exe). Choose an empty Arena Lab install folder, then select the extracted `PE21` game folder when prompted. The installer downloads the pinned Arena Lab client dependencies.
4. Open the Arena Lab install folder and double-click `Play-Arena.bat`. Start a new game if prompted and choose **Skip intro** to reach Arena Town.

## Connect to the host

1. On the host computer, open `Play-Arena.bat`, talk to the arena entrance attendant, and choose **Host online**. Leave that game running.
2. On the second computer, talk to its entrance attendant and choose **Find an arena to visit**. Select the discovered host and choose **Request to visit**.
3. Log in or create a separate account on the second computer. The host receives the request and accepts it at their entrance attendant. No IP address or account ID needs to be typed or exchanged.

Both computers must be on the same local network. If the client cannot connect,
allow the host's Ruby service through Windows Firewall on private networks, UDP
port `9997` for discovery and TCP port `9998` for the game connection. The
database stays private on the host computer.

For this updated flow, both Arena Lab installs need the latest source files from
GitHub. Close the games and run `ArenaLab-Update.exe` on each existing install
before the playtest.

## What this test establishes

The user confirmed that the GitHub-installed second-computer client communicated
with the prepared host over the local network using the previous address/invite
flow. The updated discovery and request flow has only been tested on one
computer so far. The current installer prepares a client to play offline or
join. Installing the host backend on any clean computer, and using either
computer as host or client without extra preparation, is a later milestone.
