# Pokémon Arena Manager — Codex Project Brief

## Current snapshot: v3 (plugin 0.7.0)

## Windows installers

The Windows build has two self-extracting EXE packages available from the
[latest GitHub release](https://github.com/EvannKurzawa/arena_lab/releases/latest).
`ArenaLab-Setup.exe`
sets up a clean client, and `ArenaLab-Update.exe` replaces Arena Lab source files
from GitHub `main` in an existing install. Build them with
`powershell -NoProfile -ExecutionPolicy Bypass -File tools/package-deliverables.ps1`;
the self-extracting EXEs are written to ignored `dist/` and are intended to be
attached to a GitHub release, not committed to source history.

Setup downloads pinned Arena Lab/PEMK source plus Ruby and mkxp-z, and asks the
player to select their own complete Essentials v21.1 game folder. The Essentials
README does not provide a public download, and PEMK says game builds containing
Nintendo-derived assets are for private tests, so these assets are never bundled
in the installer. The first installer prepares the offline/join client; it does
not provision PostgreSQL and the native server dependencies required for a new
computer to host. Existing installations keep their assets, runtime, saves,
credentials and local server data during source updates. See `SETUP_STATUS.md`
for the package checks and limitations.

The user completed one full arena visit successfully using two game windows on
the same computer. **The next acceptance test is two physical computers on the
same network.** This confirmation supersedes the earlier pending same-PC GUI
checks in the historical notes below; it does not establish two-PC connectivity.

**`Play-Arena.bat` is the only root BAT file.** Every launch opens another player
window with its own local profile, initially offline. The first uses the primary
profile, the second the guest profile; profiles are reused when windows close.
Up to eight local players are supported. No separate server window is needed.

At the arena entrance, talk to the attendant:
- **Host online:** starts/reuses the internal PEMK service, connects this player
  and opens their arena. The game shows join addresses.
- **Join a host:** enter `127.0.0.1` for another window on this PC, or the host's
  displayed network IPv4 address for another computer. Use different accounts.
- Once connected, talk again for **Invites and arena visits** or **Go offline**.
  The host invites the guest's account ID; the guest accepts at their attendant.

Two windows on one PC: open **the same Play-Arena.bat twice**, Host online in the
first, Join a host -> `127.0.0.1` in the second, then invite/accept.
Two PCs on the same network: use the same launcher on each; Host on one and Join
its displayed IPv4 on the other. Windows Firewall must permit the host's Ruby
service on the private network, TCP 9998. The database stays loopback-only.
Internet/NAT setup across different networks is not automated by this update.

Connecting/disconnecting happens **in place with the same character, Pokemon,
arena and local save**. No title/profile switch or cloud-world replacement.
Accounts identify players; progression stays local. Existing `_offline` saves
continue to be used. Historical server saves are preserved but not loaded or
overwritten. Visitors still access only the entrance room and arena.

Only the first launch prepares shared files; later launches wait for compilation
and skip rebuilding. Merely launching starts neither a server nor a database;
hosting is requested in-game. Internal PowerShell/Ruby helpers are not additional
player launchers. Managed servers stop after ten minutes without logged-in users.

Host online automatically replaces an older idle background server after checking
that it belongs to this exact project and has no connected players. It refuses
to stop an unrelated process or an active host, so no manual hidden-server cleanup
is needed for a verified idle project service.

Validation: **56 Ruby tests / 398 assertions and 24 PowerShell checks passed**.
Includes real wildcard-bound reactor sockets with loopback clients, local save
protection and multi-instance leases. Same-PC full-visit success is user-reported;
Codex did not operate those game windows. Two-PC connectivity/firewall traversal
remain pending. See SETUP_STATUS.md for the next manual playtest.

If an older Offline/Online chooser was still visible, close all game windows
and relaunch this BAT. Preparation now explicitly synchronizes ArenaDemo's
compiled plugin-cache entry, preserving the other plugins and a backup of the
old cache. The preparation log records version 0.7.0 and its source checksum.

## Previous launcher design (0.6.0 history; superseded)

Close existing game windows, then use **`Play-Arena.bat`**. It prepares the game,
opens one player window and starts/reuses the local development server in the
background. A running game is detected before rebuilding. Backend startup failure
leaves offline play available. The other BAT files are developer tools, including
the two-window multiplayer test; they are no longer the normal entry point.

The game asks **Offline / Online** before any stored-token login. Offline keeps
the network disconnected, even if the local server is running. In the pause menu,
choose **Connection -> Go online / Go offline** to save and switch at the title
screen inside the same application. Close an active arena visit before switching.
Online switches wait for the current server save acknowledgment when connected.
The menu also shows connection/hosting/visiting status.

This version uses separate offline and online profiles. Online loads the server
account; offline uses `Game_offline.rxdata` (or `Game_guest_offline.rxdata` for
the test guest). On first mode selection, any legacy local save is copied to the
offline slot without overwriting either an existing offline slot or the original.
Offline catches are not automatically merged into an online account. Failed or
cancelled online login explicitly falls back to the offline slot.

48 automated tests / 324 assertions passed, including profile/save-switch tests.
The new launcher and actual in-game switching still need a GUI playtest: this
execution environment cannot read the private game data reliably. This remains
the development desktop runtime, not a newly packaged standalone executable.
See SETUP_STATUS.md for results and exact manual checks.

## Arena visits and first catching route (plugin 0.5.0 history)

The next steps are implemented in source: an arena-only **Customize arena** pause
menu, an entrance-room multiplayer attendant, temporary private visits for one
invited guest, and an offline catching route with a short keeper story.
The arena medic now heals and explains the menu instead of editing objects.

Offline: run `Launch-ArenaDemo.bat`, choose offline, New Game and the intro skip.
Talk to the town keeper for 10 Poke Balls, then the nearby trail scout to enter
Founders' Path. Catch Rattata, Caterpie or Spearow in the grass and return to the
keeper for the story reward. The entrance PC uses normal Essentials storage.
Customize inside the arena before opening it to visitors.

For a local visit, stop the old server console with Ctrl+C and restart
`Launch-Multiplayer-Server.bat`, then `Launch-Multiplayer-Clients.bat` with two
different accounts. Both players now enter their own town and walk to their
entrance-room attendant. The attendant shows each account ID. The host chooses
**Open arena to visitors**, then **Invite a friend** and enters the guest's ID.
The guest talks to their attendant and accepts within 60 seconds. The guest
arrives in the host's entrance room and can access that room and arena only.
Both clients use the host's frozen object selection, arrangement and trainer
difficulty. Each player keeps their own party and PC storage.

Customization locks before the open request is sent and stays locked while open,
invited, visiting or awaiting a close reply. Leaving guests return to their own
entrance room. Hosts remain open until they explicitly close the arena; closing
or disconnecting the host ends the visit. Offline layouts remain saved locally.
Readiness now detects an old server that lacks the visit extension.

This is still loopback development for two accounts on this PC. Online arena
storage, public hosting, remote internet setup and arbitrary furniture placement
are outside this update. Founders' Path encounters and story rewards are offline.
The generated foyer still uses temporary rock boundaries.

Validation: 41 tests / 291 assertions passed, including real loopback protocol
tests through PEMK's reactor and synthetic map generation. Protocol test account
identities were injected; production login, private-map installation/rendering,
actual captures and two-window battles were not retested. Private game-data
access still stalls here. Details and manual playtest steps are in SETUP_STATUS.md.

## Initial world step (historical, superseded by 0.5.0)

Offline quick start now enters Arena Town. Walk into the building immediately
north of the spawn to reach the entrance room. Its PC opens Essentials' normal
Pokemon storage; interact with the north door to enter the training arena.
Walk through the arena's south opening to return, then through the entrance
room's south opening to reach town. Existing saves outside the demo can enter
through the Arena Demo pause-menu entry. In town/entrance, that entry offers a
return to the previous location.

Close the game and run `Launch-ArenaDemo.bat` to install the source changes and
generate maps 100-102. Keep a backup of private saves before testing. New Game
with the intro skip is recommended because existing saves can retain old maps.
The town reuses local Lappet Town artwork and one existing building as an arena
placeholder; story, catching routes and a final visual design come later.

Authenticated quick start still enters the tested shared arena directly.
Invitations, visitor restrictions and custom-layout synchronization are pending.
This update passed 24 automated tests / 130 assertions, including map generation
against synthetic fixtures. Real private-map generation and GUI playtesting
could not be completed here; see SETUP_STATUS.md.

## Current snapshot: v2.1

If the multiplayer launcher times out despite a server “listening” message, press
Esc in the server console to clear any selected text and retry the clients. The
readiness check now reports the failed network stage and visible port-9998 process
IDs. Keep that output if it still fails; a listening log alone is not a health check.

2026-10-28: the user verified that local multiplayer launch, text rendering and
battles now work, including the previously reported battle synchronization issue.
`v2.1` includes local peer collision checks, mirrored win/loss and singles speed
ties, earlier battle RNG delivery, rendered font heights, and clearer readiness
diagnostics. Player collision is also user-verified;
simultaneous movement can overlap because tiles are not reserved server-side.
Use the root multiplayer launchers. The server launcher reuses a responding PEMK
instance instead of binding twice. See CHANGELOG.md and SETUP_STATUS.md for checks
and the earlier investigation history.

`v2` contains the enclosed arena, expanded offline customization, local PEMK setup, player battle-request interactions, and the native-runtime click-crash fix. See [CHANGELOG.md](CHANGELOG.md) for the update summary and [SETUP_STATUS.md](SETUP_STATUS.md) for exact versions, commands, results, and limitations.

The arena and customization, GUI account creation, click-crash fix, multiplayer launch, text rendering and battles have been user-confirmed. This repository contains source and setup tools; ignored private game assets, runtime binaries, accounts, saves, and credentials are not part of this snapshot. Use the root BAT launchers with the existing local setup; a clean clone requires the private prerequisites described in the setup report.

## 1. Vision

Build a **personal, non-commercial Pokémon fan game** based on an existing Pokémon RPG engine rather than creating the battle engine, Pokémon data, and core RPG systems from scratch.

The intended game is an **arena-management game** with a visual and gameplay feel inspired by Pokémon games:

- Build and decorate a battle arena with furniture, obstacles, walls, and puzzle-like layouts.
- Recruit and configure trainers and their Pokémon teams.
- Let visitors challenge trainers and, eventually, other players.
- Support private multiplayer with friends.
- Preserve as much of the existing Pokémon Essentials battle engine, Pokémon/move data, and game systems as practical.
- Start with a small, playable vertical slice, then expand.

This is not intended to be a conventional story-and-badges adventure. The arena-management loop is the core custom feature.

## Running the local demo

The manager now preserves your position when changing objects or presets. If an edit would place an obstacle on your tile, it asks you to step aside. The user confirmed the new arena and trainer/customization work in-game; this teleport correction has automated regression coverage.

## Local multiplayer (first version)

Runtime fix (0.4.1): use the root BAT launchers. They now select the official mkxp-z Windows build pinned to `37a04d1`, which the user confirmed no longer exits on clicking the game. The original bundled `Game.exe` is retained, but its direct `PlayMMO-*.bat` launchers still use the old crashing runtime. Existing accounts and saves are retained. The replacement runtime and license stay under ignored `tools/runtime/mkxp-official-test/`; its configuration points to the existing private game assets. To restore a missing runtime, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/install-client-runtime.ps1 -Download`.

Version 0.4.0: face another player in the arena and press **Z/Enter/Space**, then choose **Challenge to battle**. The other player receives PEMK's accept/decline prompt; close their pause menu if it is open. Players on the same tile can also interact. **Arena Demo → Players in arena** (or **Battle Player**) lists players by name and account ID. Escape closes these menus without sending a request or leaving the arena; leaving requires choosing **Leave the arena**. Restart both game clients after installing this update. GUI login is now user-confirmed; full PvP battle completion is still awaiting a playtest.

Account-form timeout fix (0.3.1): PEMK expires unauthenticated sockets after 30 seconds. The ArenaDemo extension now reconnects after you finish typing, immediately before submitting login/registration. Restart the game to load it. The client launcher waits for a real PEMK ping reply before opening the games, and both launchers print their project folder to catch use of an older copy. Server output/crash diagnostics are saved privately in `tools/runtime/pemk-server.log`.

1. Close existing game windows.
2. Run `Launch-Multiplayer-Server.bat` and leave it running.
3. Run `Launch-Multiplayer-Clients.bat`. It installs the plugin, rebuilds the arena, and opens the normal and guest clients using PEMK's separate instance settings.
4. Create **two different accounts**, one in each window. For new accounts, choose the intro skip to enter the arena. Existing accounts use the Arena Demo pause-menu entry.
5. Walk around the same arena. PEMK provides player presence and its **Battle Player** pause-menu challenge flow. Actual two-window rendering and PvP battle completion still need an in-game check.

Authenticated players use a fixed Sidelines layout with all six objects so their obstacles agree. Personal offline layouts remain saved; online arena editing, friend-owned arena visits, and shared layout persistence are not implemented. The server binds only to `127.0.0.1:9998`; PostgreSQL uses `127.0.0.1:55432`. This version is for two clients on this PC.

The native Windows bcrypt crash was fixed by rebuilding bcrypt/bigdecimal with the matching MSYS2 UCRT compiler. Backend account/login and presence tests now pass, including two authenticated protocol clients entering, moving on, and leaving arena map 100. This is distinct from a two-window GUI playtest. Current details and exact results are in `SETUP_STATUS.md`; older dated setup notes below are historical.

Diagnostics (PowerShell, from this folder):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Test
```

`Test` uses the isolated `pemk_test` database; upstream tests clear its account records. Play accounts stay in `pemk`. If native gems need rebuilding, first install the matching compiler with `C:\msys64\usr\bin\pacman.exe -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc`, then run the script with `-Action RepairGems`. WSL remains unavailable in this environment; these launchers use the existing project-local Windows runtimes and upstream PEMK server without modifying its authentication code.

## Offline demo launcher

The updated demo generates a compact 25x19 enclosed training yard. Speak to the Youngster at the north end to battle. The manager near the south entrance offers six object slots, three arrangements, clear/light/full presets, trainer difficulty, and team healing. Close the game before rebuilding; use a fresh New Game and the intro skip to avoid loading the old village map stored in an existing save. The earlier village demo's object toggles and menu battle were confirmed working by the user.

Double-click [Launch-ArenaDemo.bat](Launch-ArenaDemo.bat). It copies the current plugin into the private game, rebuilds the arena map from the local Essentials data, then launches the client. Start a fresh game and choose **Skip intro and start Arena Demo** to bypass the Essentials story intro. Choose **Play the full intro** to keep the original opening. In gameplay, click the game window to give it keyboard focus (the separate Essentials Output Window is only a log). Arrow keys move, Z/Enter/Space interact or confirm, X/Esc cancel or go back, and Essentials' mapped Action key (A in RGSS, commonly Shift) opens the pause menu. Existing saves can enter through the **Arena Demo** pause-menu item.

## 2. Chosen starting point

Evaluate and integrate these projects first:

1. **Pokémon Essentials** — https://github.com/Maruno17/pokemon-essentials
   - The base RPG framework and Pokémon-specific systems.
   - Essentials is built around RPG Maker XP and Ruby/RGSS, not Phaser or a browser stack.
   - Use the version required by the multiplayer project, not the latest version by assumption.

2. **Pokémon Essentials MMO Kit (PEMK)** — https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit
   - Candidate multiplayer client/server foundation for Essentials.
   - The project has been associated with Pokémon Essentials v21.1. Verify the current README, branches, dependencies, and compatibility before proceeding.
   - Do not assume that the repositories work together merely because both are public.

Official and project documentation:
- Essentials: https://essentialsdocs.fandom.com/wiki/Essentials_Docs_Wiki
- PEMK repository: https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit

### Compatibility rule

**The first task is to clone the projects and get them working together.** Do not start building the arena game before a basic Essentials + PEMK setup is running.

If the expected versions are incompatible:
- Identify the exact version/commit mismatch and error.
- Check the project's documented supported version and installation steps.
- Prefer using the supported Essentials version or a documented compatible branch.
- Do not blindly upgrade/downgrade dependencies or rewrite the networking layer.
- If integration cannot be completed in the current environment, leave a reproducible setup and a concise blocker report, including the commands run and exact errors.

## 3. Target platform and technical constraints

- **Initial target:** a downloadable desktop game, not a browser game.
- Use the engine's intended tooling: RPG Maker XP/RGSS and Ruby as required by the projects.
- Do not port the project to Phaser, Unity, Godot, or the browser.
- Do not create a new battle engine. Reuse Essentials' existing battle systems and data.
- Do not add unrelated web stacks or dependencies.
- Respect the existing architecture and conventions of both repositories.

Codex must first inspect the current repository and local environment. Determine whether RPG Maker XP and the required runtime/editor are available. If a proprietary editor or Windows-specific tool is required and unavailable, do not pretend a full game launch was tested. Complete the parts that can be verified and document what must be done manually.

## 4. Milestone 1 — clone and integrate the projects

This is the **first and highest-priority task**.

1. Inspect the current working directory and available tools.
2. Clone the official Essentials repository and PEMK repository into clearly named directories or use the layout their setup instructions recommend.
3. Read each repository's README, installation instructions, version requirements, license, and known issues.
4. Establish the exact supported Essentials version/commit for PEMK.
5. Follow the documented setup to integrate PEMK with that Essentials version.
6. Configure the server and client using local development settings.
7. Keep secrets, passwords, private keys, and local-only configuration out of version control. Provide an example configuration file if needed.
8. Run the smallest documented single-player test, then the smallest possible local multiplayer test (two clients if supported).
9. Record every command and manual step needed to reproduce the working setup.
10. Write a short `SETUP_STATUS.md` containing:
    - Repository URLs and checked-out versions/commits.
    - Required software and versions.
    - Files changed and why.
    - Commands used.
    - Tests attempted and their actual results.
    - Remaining manual steps or blockers.

Do not claim success unless the relevant test was actually run. Clearly distinguish “code/configuration reviewed”, “server started”, “client started”, and “two clients successfully connected”.

### Repository layout

Use the layout recommended by the projects if they specify one. Otherwise, keep the work organized, for example:

```text
project-root/
  README.md
  AGENTS.md
  SETUP_STATUS.md
  upstream/
    pokemon-essentials/
    pokemon-essentials-mmo-kit/
  game-mod/
    # Our custom plugin/scripts/assets, if the engine architecture supports this
  config/
    # Example configuration only; no secrets
```

Avoid copying entire upstream repositories into nested directories if their own setup instructions require a different structure. Do not modify upstream files unnecessarily; isolate custom changes in a plugin, patch, or clearly documented mod directory wherever feasible.

## 5. Milestone 2 — a small playable demo

Only after the base game and multiplayer integration have been tested, build a minimal demo that proves the intended direction.

### Demo scope

- A small, custom arena map.
- A player character that can move around and collide with walls/objects.
- A small set of placeable or pre-placed arena objects.
- At least one trainer/NPC that can be interacted with.
- A trainer with a configurable sample team using the existing Essentials Pokémon data and battle system.
- A battle that starts and finishes using the existing battle engine.
- A simple arena-management interaction, such as changing the layout or placing/removing a limited set of objects. If runtime editing is too large for the first demo, implement a small in-game management menu or a clearly documented first approximation.
- A clear entry point from the existing game into the demo map.
- If PEMK integration is working, verify that two local clients can connect and that the supported multiplayer behavior remains functional in the demo. Do not assume this means remote arena visiting is already implemented.

### Not required in the first demo

- A complete arena editor.
- Persistent player-owned arenas shared across sessions.
- Visiting and challenging other players' custom arenas.
- Full online progression, matchmaking, ranking, trading, or moderation.
- A complete Pokédex overhaul or new battle mechanics.
- Public hosting or production deployment.

Keep the demo small but genuinely playable. Avoid creating fake UI controls or unimplemented buttons.

## 6. Later milestones (not part of the first task)

Potential future work, only after the initial setup and demo succeed:

1. A grid-based arena editor with placement validation.
2. Saving and loading player-owned arena layouts.
3. Trainer recruitment and team configuration.
4. A private arena browser/list and challenge flow.
5. Server-side persistence and validation of arena data.
6. Inviting friends to a private server.
7. More sophisticated puzzles, obstacles, and arena rules.

Multiplayer architecture must be checked before designing arena synchronization. Do not assume PEMK automatically synchronizes arbitrary custom maps, furniture placement, trainer teams, or battles in player-owned arenas.

## 7. Pokémon assets and non-commercial use

This is intended for **personal, non-commercial use**. The developer wants to make use of the existing Pokémon engine, data, and graphics rather than recreating everything.

- Preserve assets that are already legitimately part of the chosen local Essentials installation and follow that project's installation and licensing instructions.
- Verify the license and terms for each repository, extension, plugin, and third-party asset.
- Do not assume that personal ownership of a Pokémon game automatically authorizes extracting or redistributing its assets.
- Do not bundle or publish copyrighted Pokémon assets, ROM contents, or third-party materials unless the applicable permissions allow it.
- Do not upload private game files or proprietary RPG Maker assets to public repositories.
- Keep any local-only assets and secrets out of public commits.
- Never describe this as an official Pokémon product.

The goal is to make the local personal project work, not to distribute a prepackaged game containing unlicensed assets.

## 8. Coding and change-management rules

- Read the upstream docs before modifying code.
- Keep upstream changes minimal and explain each change.
- Prefer documented plugin/script extension points over patching core engine files.
- Make backups or use version control before substantial modifications.
- Do not commit generated binaries, local save files, credentials, or large copyrighted assets.
- Keep setup instructions accurate and reproducible.
- Report failed tests honestly.
- If a requirement cannot be met, implement the closest safe, testable slice and state the limitation.

## 9. Definition of done for the first task

The first task is complete when:

- Both repositories have been cloned or a specific access/tooling blocker is documented.
- The required versions and compatibility relationship have been verified from project documentation or repository metadata.
- Integration follows documented instructions.
- A local server/client startup has been tested where the environment supports it.
- A two-client local multiplayer test has been attempted if supported by the available tools.
- `SETUP_STATUS.md` records exact versions, commands, results, and remaining steps.

## 10. Definition of done for the first demo

The demo is complete when:

- The custom arena can be entered and explored.
- Movement and collision work.
- The player can interact with a trainer.
- A trainer battle uses the existing Essentials battle system.
- At least one meaningful arena-management interaction works.
- The game can still start using the documented setup.
- If multiplayer integration works, its effect on the demo is tested and documented.
- The README and `SETUP_STATUS.md` reflect reality.

## Initial instruction to Codex

**Task 1 — do this first:** clone Pokémon Essentials and PEMK, inspect their documentation and versions, and get them working together. Do not start building the custom arena demo until this integration has been attempted and its status is recorded in `SETUP_STATUS.md`.

**Task 2 — only after Task 1:** implement the small playable arena-management demo described above, reusing Essentials' Pokémon data and battle system. Keep the scope small, run all tests that are possible in the environment, and document manual editor/runtime steps that cannot be automated.

## Current workspace status (2026-10-26)

Both upstream repositories are checked out under `upstream/`; the checked versions agree at Essentials v21.1. WSL Debian was inaccessible, so I set up a local Windows Ruby 3.3.12 + PostgreSQL 17.11 environment instead. The PEMK server starts on loopback port 9998. A private v21.1 game package is assembled under the ignored `tools/runtime/essentials-v21.1-base/` folder with PEMK and ArenaDemo installed. Two raw TCP sockets connected, but those were not authenticated game clients. Two non-auth PEMK tests pass; the authentication test crashes inside Windows bcrypt, and the full test suite did not complete. See [SETUP_STATUS.md](SETUP_STATUS.md) for exact commits, commands, test output, and blockers.

The client package includes Essentials maps/assets and the mkxp-z runtime in the ignored local test copy, so it can be launched without installing RPG Maker XP. The Ruby map generator derives Map100 from Essentials' walkable Lappet Town map (map 2), reads the Player's House exit transfer to choose the town spawn, and installs the arena trainer, manager, and three object events. The previous attempt mistakenly used map 3, which is the Player's House, and left the player on a mostly empty area. The pause-menu entry transfers into the demo; the saved object menu toggles fixed object slots and collision. The corrected map still needs in-game movement and battle confirmation. See [game-mod/README.md](game-mod/README.md).
