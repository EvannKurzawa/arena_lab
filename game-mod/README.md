# Arena Demo

Project snapshot v2.1 / plugin 0.4.2: the user verified multiplayer launch, full
text rendering, battle synchronization/completion and player collisions. The new
`004_MultiplayerFixes.rb` adds arena peer blocking, mirrored win/loss and singles
speed-tie draws, and RNG delivery before replacement/end messages. Simultaneous
moves can overlap without server tile reservations. The runtime installer uses
rendered font height; readiness failures show their network stage and TCP entries.
Use the root launchers; accounts and saves are retained. Earlier pending checks
below describe historical versions.


Version 0.4.1 selects an official checksum-pinned mkxp-z Windows build (`37a04d1`) in the root launchers. Native debugging located the old executable's click crash in Input.update's key-repeat division. Configuration/Ruby timing workarounds failed and were removed; the replacement passed the user's physical click test. Essentials v21.1, PEMK, existing accounts/assets and the battle engine are retained. `004_LoadDiagnostics.rb` only records save-load failures and optional short progress messages, with the heavy boot tracing removed. Use the root launchers rather than the private package's original BAT files. Runtime provenance and exact validation limits are in SETUP_STATUS.md.


Version 0.4.0 adds `003_PlayerInteraction.rb`. Essentials' `:on_player_interact` hook opens an adjacent player's battle-challenge dialog using the normal interact key, after normal NPC/event interaction has had priority. Same-tile players are supported because PEMK remote characters are passable. Arena Demo's **Players in arena** menu provides a name/account-ID list; PEMK's **Battle Player** menu uses the same entry point inside map 100. Requests use the existing PEMK challenge/consent/team-exchange flow. The receiver must accept; no trade, chat, custom networking, or shared arena editing is added.

All ArenaDemo choice menus now use Essentials' negative cancel return (`-1`). The old positive cancel argument was one off: Escape in the main arena dialog selected Leave, and Escape in some customization dialogs selected an unintended action. Only the explicit Leave choice transfers out now. Dialogs restore the enclosing menu state and defer incoming UI/battle launch until they close. Restart both clients after running the existing multiplayer preparation launcher; no new account or save reset is needed.

Version 0.3.1 adds `002_PEMKLoginFix.rb`: an optional PEMK extension that opens a fresh connection before unauthenticated login/registration, after completing the text prompts. This fixes the expired pre-auth socket when filling the form takes over 30 seconds. Authenticated gameplay/resume connections are preserved. The metadata's optional PEMK dependency ensures the patch loads after PEMK, and both preparation launchers install every ArenaDemo Ruby file. A real-socket test reproduces the failure without the fix and passes registration/login with it.

## Multiplayer and manager correction (0.3)

The user confirmed the generated arena works. The manager no longer moves the player when accepting object, preset, or arrangement changes. Overlapping edits are rejected with a request to step aside; the saved layout is unchanged on rejection.

Root `Launch-Multiplayer-Server.bat` starts the existing native PEMK backend on loopback. `Launch-Multiplayer-Clients.bat` prepares the local project and opens PEMK's normal and guest instances, each with separate account/session/log/save files. Use two different accounts, enter map 100 in both, and test presence and **Battle Player**. Backend authentication and arena presence have been tested with real protocol sockets; GUI peer rendering and a complete PvP battle are still unverified.

Authenticated sessions use all six objects in the fixed Sidelines layout. Personal offline selections/arrangements are retained and restored offline; the online manager offers healing. This deliberately avoids giving players inconsistent collisions while shared customization is unimplemented. The plugin uses PEMK's existing authentication and presence; it adds no networking protocol or public service. Seven customization regression tests cover position preservation, overlap rejection, and matching online obstacle layouts.

## Updated training yard (0.2)

Run `Launch-ArenaDemo.bat` with the game closed, then use New Game and the intro skip. The generator now builds a new 25x19 rock-enclosed arena using a passable ground tile stack from the private local tileset. It does not copy the village layout. Old saves can retain the previous map; a fresh game is recommended for this update.

The Youngster at (12,4) offers a repeatable Essentials trainer battle when spoken to. The offline manager at (10,16) offers six togglable obstacles, Sidelines/Slalom/Training ring arrangements, clear/light/full presets, three trainer level settings (5-6, 8-9, 12-13), and team healing. Edits preserve the player's position and reject obstacle overlaps. Settings are per-save and are not synchronized by PEMK. The original menu battle remains available.

The sections below describe the earlier prototype; this update replaces its village map and three-object limit.

The Essentials v21.1 plugin lives in `Plugins/ArenaDemo/`. It adds an **Arena Demo** pause-menu entry that transfers the player to a small dedicated map, then offers arena management and a sample trainer challenge. The generated New Game intro also offers **Skip intro and start Arena Demo** or **Play the full intro**. Quick start creates a level 10 Pikachu so the sample battle can be played immediately.

## Demo features

- A playable test map copied from Essentials' Lappet Town map (map 2), with a new map ID, its own trainer, a manager, and three object events.
- Normal Essentials walking, walls, event collisions, and map transitions.
- A saved three-slot roster for a boulder, rock, and tree. These fixed map slots can be added or removed from the arena; hidden objects stop blocking movement.
- An interactive Youngster trainer with a configurable Rattata/Ekans sample team. The battle uses Essentials' existing battle engine and Pokémon data.
- A return-to-previous-map option in the manager menu.

The map binary is generated locally from the complete project's existing Lappet Town map; the generator reads the Player's House exit transfer to choose a valid town spawn. It updates `Data/MapInfos.rxdata`, writes `Data/ArenaDemoStart.txt`, patches the new-game intro, and writes `Data/Map100.rxdata`:

```powershell
ruby game-mod/tools/build_arena_map.rb "C:\path\to\your\Essentials-v21.1-project"
```

Install `Plugins/ArenaDemo/` into the project's `Plugins/` directory and run the map generator once. It generates Map100 and patches Map001's first intro event with the skip/full-intro choice (safe to run again; it won't add duplicate choices). A local assembled test project is stored under ignored `tools/runtime/essentials-v21.1-base/` when available. It contains the Essentials v21.1 package, the PEMK plugin, the Arena Demo plugin, and a loopback-only `mmo_config.txt`. Its `PlayMMO-debug.bat` starts the bundled mkxp-z game client in debug mode.

## Controls and startup

Click the actual gameplay window so it has keyboard focus; the separate **Pokémon Essentials Output Window** is only a log. Use the arrow keys to move, Z/Enter/Space to interact or confirm, and X/Esc to cancel/back. Essentials opens its pause menu with the mapped **Action** key (A in RGSS, commonly Shift), so Esc is not the menu key. On a fresh New Game, choose **Skip intro and start Arena Demo** to bypass the long story intro. Existing saves do not replay that startup choice; use the pause menu's Arena Demo entry to enter the demo.

## Limits

- The player can toggle objects in their fixed slots; free placement and map editing are not implemented.
- The current PEMK server does not synchronize object selection or arena ownership. Authentication currently crashes in the local Windows bcrypt native extension, so online login is unverified. Choose offline mode to test the local arena while that is unresolved.
- The user confirmed the game window opens and loads both plugins, but reported a long intro with no skip and no response to Esc/other keys after it. The generator now adds a skip/full-intro startup choice. The arena transfer and battle are not yet confirmed in-game. RPG Maker XP is not installed; the map generator avoids requiring its editor for this first map.
- Keep the downloaded Essentials assets and resulting client package private. They remain under ignored local runtime files and are not part of this repository's distributable source.
