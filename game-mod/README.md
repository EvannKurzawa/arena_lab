# Arena Demo

Repository snapshot **v5**, plugin **0.8.6 in source**: the previous manual-IP
arena visit was confirmed between two physical computers. The updated automatic
discovery flow still needs its two-computer retest. Follow the v4 test guidance
in `SETUP_STATUS.md`. The first offline custom mode is implemented; the user
confirmed the trainer recruitment heading displays fully, while the full editor
loop still needs testing.
The Bag keeps eight tabs: Mail and Battle Items are merged into Items, with
Key Items retained before Arena Furniture and Recruited Trainers. Existing Bag
saves migrate when opened.

Plugin **0.7.0** replaces the previous launcher/profile-switch design. Only
`Play-Arena.bat` remains at the project root; each launch acquires a different
profile lease (primary, guest, player3-8). The resident hidden supervisor holds
the lease until its game exits, protects orphaned live processes with PID/start
records, serializes compilation/startup, and skips shared writes for later games.
Game.set_up_system writes a readiness marker after compilation. Host requests use
nonce-correlated local files; the game cannot supply shell commands or paths.

Every boot is offline. At the entrance attendant, Host online requests the native
PEMK backend on all IPv4 interfaces; Find an arena to visit uses LAN discovery
and a host-approved request. Game traffic uses TCP 9998 and LAN discovery uses
UDP 9997. Joining does not start a local backend. PostgreSQL remains loopback-only.
Managed servers stop after ten idle minutes; Windows Firewall private-network
access is a manual machine prerequisite. Cross-network internet setup is not
automated.

Online/offline is a live transport change with one persistent local character,
party, map and save. Historical server blobs/economy are not hydrated; local-world
progression syncing is disabled and the server rejects account-save uploads from
these connections. Existing local saves/old server data are preserved. Upstream
account authentication, peer-body validation, room isolation and battle consent
remain; reconnect resets progression gates while retaining peer validation mode.
Credentials are separated by player and remote endpoint. Old 0.6 title-switch
tests are replaced by live-connection tests. Same-PC full-visit GUI validation is
user-confirmed; two-PC validation is pending.

The older sections below are historical and do not describe the current entry point.

Offline arena customization now uses the **Custom mode** option at the Arena
Guide. It provides tile-by-tile placement with separate Bag pockets for
furniture and recruited trainers. Map 100 is regenerated during player
preparation to add reusable placement event slots. This editor is source-only
until its in-game playtest is completed; online arena visits still use the
existing fixed multiplayer layout snapshot.

Plugin **0.6.0** adds `007_ConnectionMode.rb` and the normal root
`Play-Arena.bat` / `tools/play-arena.ps1` entry point. The local backend runs in
the background; the game asks Offline/Online before token login. The Connection
pause command saves and switches via the existing title/load flow without
relaunching the process. Active visits must close before switching.

Offline uses a separate `_offline` filename per instance. Legacy local data is
forked once with exclusive binary creation before either mode overwrites its
cache. Online retains authoritative account loading. Cancelled/failed login
refreshes the offline slot, so a preloaded online cache cannot become the offline
world. Logout clears identity, transport, reconnect, sync and checkpoint state.
Connected switches await acknowledgment of the specific outgoing online save.

The old BATs remain developer/test helpers. Offline and online progression are
separate profiles; this is stated in the switching dialog. GUI testing is pending.

Plugin **0.5.0** adds `005_ArenaVisits.rb`, `006_FoundersPath.rb`, and the external
server adapter `game-mod/server/arena_visits.rb`. The root server wrapper loads
the adapter after upstream PEMK; the client preparation launcher installs the
plugin files and generates maps 100-103. Restart the server and both clients.
The readiness probe refuses an old server instead of launching incompatible clients.

Customization lives in the arena pause menu and is guarded at every mutation,
including after blocking selection prompts. The former manager is a medic.
The entrance attendant opens/closes a room, invites one online account by ID,
and accepts/declines a pending invitation. Opening locks immediately; closing
unlocks only after server confirmation. Invite expiration does not close the host.

Room state is temporary and belongs to PEMK's reactor. A server-created token
isolates presence and addressed battle/trade frames. Snapshots allow only the six
existing object slots, three existing arrangements and trainer difficulty; they
contain primitives and never load remote map binaries. Guests reuse local maps
100/102 with the host snapshot and retain their own saved layout. Both the server
and engine transfer hook restrict active visits to these rooms. Disconnects and
replaced connections close visits. Transfers wait for a safe overworld frame;
obsolete position corrections are cleared when the room changes.

Offline map 103, Founders' Path, uses local tall-grass artwork and the normal
Essentials `PokemonEncounters` Land table. The town keeper gives one supply grant
and one completion reward; the trail scout leads to the route. No battle or
capture mechanics were recreated. Entering town sets the entrance as the healing
return point. Online route entry/encounters/rewards are disabled for this slice.

Automated checks cover source menus/locks, guest layout restoration, real socket
room behavior using injected authenticated identities, existing battle fixes,
readiness and synthetic map generation. Real assets/rendering, authenticated
server startup and GUI captures/two-window battles still need the playtest in
SETUP_STATUS.md because private game-data access stalls in this session.

The notes below are historical snapshots.

2026-10-28 world-path step: generator map 101 is an offline town using local
Lappet Town tiles with tutorial events removed. Its original house doorway
leads to a new compact entrance room (102), containing an Essentials storage PC
and a north door into the existing arena (100). South exits lead back through
the entrance room to town. The foyer uses local indoor floor/PC artwork with
temporary rock boundaries. Quick start enters town offline and retains direct
arena entry online. Management remains in the arena's existing menu/NPC for now.

Use the root launcher with the game closed to install and generate the maps.
New Game plus intro skip avoids cached maps in existing saves. The generation
test uses synthetic Marshal fixtures, checks reruns, transitions, preserved
object IDs, and refusal to overwrite unrelated map IDs. This does not establish
real map rendering, navigation, PC UI or two-window gameplay. Those require a
local playtest; private game-data access stalled in this execution session.
Friend invitations, visitor permissions, layout sharing and catching routes
remain subsequent steps.

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
