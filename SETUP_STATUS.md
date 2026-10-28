# Setup and implementation status

## v3 - 2026-10-28: same-PC full visit verified by the user

The user reported: "i have completed one full visit and it worked." This was the
two-window, same-computer flow described immediately before the report. Record
it as a successful user-run full arena visit, not a Codex-operated GUI test or a
two-computer connection. It supersedes the earlier pending same-PC visit checks
below. The user explicitly identified **two computers as the remaining test**.

v3 includes the town/entrance/arena path and storage PC; arena pause-menu
customization and session locks; private invited visits with frozen host layouts;
offline Founders' Path and keeper story; one repeatable Play-Arena.bat launcher;
independent local player profiles; live host/join/offline changes preserving the
local character; guarded replacement of an old idle background server; and
explicit plugin-cache synchronization. ArenaDemo metadata remains 0.7.0; v3 is
the repository snapshot/commit name, not an upstream version change.

Upstream versions/compatibility/licensing and runtime pins are unchanged from
the integration reports below: Essentials v21.1 at
8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b, PEMK at
9a24034bca241c095b81ea8069607f6cdfa6a57d. No upstream assets, native binaries,
database contents, credentials, save files or generated maps belong in v3.
The ignored private setup is still required; this is not a self-contained game
installer or an internet-hosting deployment.

Release validation: 56 Ruby tests / 398 assertions, plus 24 PowerShell checks
(13 launcher/profile/IPC and 11 server-replacement checks). These cover source
behavior, temporary/synthetic maps and caches, real socket reactor/relay behavior
with injected account identities, and mocked live-connection engine interactions.
No authenticated DB integration suite or two-PC GUI test is claimed. The user's
full-visit confirmation supplies the separate same-PC GUI result.

Next manual acceptance test:
1. Keep the host PC and second PC on the same private network, each with the
   prepared private game/runtime prerequisites and the v3 source installed.
2. Open Play-Arena.bat on each. At the entrance attendant, Host online on the host;
   Join a host on the second PC, entering the host's displayed LAN IPv4 address
   (192.168.1.127 was shown in the user's latest session; use the current address).
   127.0.0.1 is only for windows on the same PC.
3. Use different accounts on the same host service. Host invites the guest's
   displayed account ID; guest accepts through Invites and arena visits.
4. Verify host layout/collisions and visitor room restrictions, complete a battle,
   leave/go offline, and confirm the guest's personal layout/party/save remain.
5. If the join fails, check Windows Firewall private-network permission for the
   host Ruby executable on TCP 9998. PostgreSQL stays loopback-only. Record the
   exact error and both private launcher/server logs; no two-PC success yet.

README, CHANGELOG and game-mod README now identify v3 and distinguish user GUI
verification from automated tests and the pending physical two-PC test. Earlier
setup problems and superseded launcher designs remain historical records.


## Old background host replacement - 2026-10-28

User received the old/loopback-service message without manually opening a server.
Read-only inspection found PID 8156 listening on 127.0.0.1:9998. Sandbox CIM
inspection was denied; approved inspection confirmed this workspace's bundled
Ruby executable running tools/run-local-server.rb with this workspace's server
and log paths (created 11:24:28 local time). No established clients were found.
After source tests, an approved invocation of Stop-ArenaLegacyService verified
ownership/creation time and zero connected players again, then stopped that one
process successfully. No game process or PostgreSQL service was stopped.

Host online now replaces an older idle service automatically only if the listener
belongs to the exact expected executable, wrapper, server root and log arguments.
It refuses unknown executables/scripts/workspaces, extra arguments, multiple
listeners, changed process identities or established clients. Identity/TCP state
are re-read immediately before stopping. Native process start time is checked
with one-microsecond tolerance for CIM timestamp precision. Existing active hosts
and unrelated port owners are not automatically stopped. Probe messages now
describe verification rather than instructing players to manage a hidden server.

Changed tools/desktop-session.ps1, tools/play-arena.ps1, tools/ping_multiplayer.rb;
added game-mod/test/server_replacement_test.ps1. Replacement policy: 11 checks
passed with injected process/connection records and no real process stopped by
the tests. Existing 13 launcher checks passed. PowerShell parsing/whitespace
checks passed. The real verified legacy-process stop is separate from these
tests and did execute; a replacement production server/GUI playtest is not claimed.
Player can retry Host online in the still-running game; the now-free port allows
its supervisor to start the current service without relaunching the game.


## Startup screen follow-up - 2026-10-28

While testing, the user saw the old Offline/Online chooser and then closed that
window. That indicates old behavior was still running; the exact cause (already
open window, stale cache, or another copy) was not established. Attempts to inspect
private launcher logs and installed plugin/cache files stalled both inside and
outside the sandbox; those sessions were cancelled. No successful private read,
installation, game launch or GUI repair is claimed by the agent.

Added `tools/sync-plugin-cache.rb`, called by Prepare after map generation. It
rebuilds only the Arena Demo entry in an existing trusted local compiled cache
from installed Ruby files and metadata, independently of source/cache mtimes.
Other plugin entries are retained; original cache bytes are backed up once per
version and the replacement is atomic. It logs version, script count and checksum
to `tools/runtime/desktop-prepare-<PID>.log`. Missing first-install caches are left
to the native debug compilation path. It runs only during first-window preparation,
not while another leased game is using shared files.

New `game-mod/test/plugin_cache_test.rb`: **3 tests / 18 assertions passed** for
a future-dated 0.6 cache becoming 0.7, unchanged upstream plugin contents, binary
backup/idempotence, malformed-format refusal and missing-cache handling. Initial
fixture run failed to find scripts; using Dir.glob with an explicit base directory
fixed enumeration and the rerun passed. PowerShell parsing passed.
Total validated suites: **56 Ruby tests / 398 assertions plus 13 PS checks**.
Other results below are unchanged. User should reopen the exact root Play-Arena.bat
with all older windows closed; the new game starts offline without that chooser.


## One repeatable launcher, live host/join - 2026-10-28

Implemented the user's corrected model in source as plugin **0.7.0**. There is
exactly one root BAT, `Play-Arena.bat`. Removed the three older Launch-*.bat files.
The same BAT can be opened twice on one PC, or on two prepared PCs. Every game
starts offline; the entrance attendant offers Host online / Join a host / Go
offline. This supersedes 0.6's single-instance guard, title switch and separate
offline/online progression profiles.

Upstream versions remain Essentials v21.1 commit
`8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b`
(https://github.com/Maruno17/pokemon-essentials), and PEMK commit
`9a24034bca241c095b81ea8069607f6cdfa6a57d`
(https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit).
Runtime remains the previously pinned mkxp-z build. No dependencies, engine
mechanics, third-party assets, upstream files or credentials were added/changed.
Existing license findings and private asset exclusions still apply.

Launcher implementation:
- `tools/play-arena.ps1` stays resident, hidden, while its game runs. The shared
  `desktop-session.ps1` helper leases primary/guest/player3-8 profiles, each with
  separate existing PEMK save/config/login conventions. Profiles are reused after
  their clients close. Exclusive file handles plus PID/start-time/executable
  records protect against both simultaneous launches and orphaned live clients.
- A workspace-specific startup mutex serializes preparation/compilation. Only
  when no other game is active are maps/plugins/runtime configuration rebuilt.
  The first game signals readiness after Compiler.main and Game.set_up_system;
  later launches do not write shared game files while another client uses them.
- A per-profile nonce-only file request asks the supervisor to start/reuse the
  native PEMK backend. No game-provided executable, shell command or path is
  accepted. The game pumps frames while waiting. Responses correlate the nonce.
  Hosting requests are serialized with a service mutex. Merely launching the app
  starts neither PostgreSQL nor the server; joining starts neither locally.
- Host requests use `local-multiplayer.ps1 -Action Server -ListenAddress 0.0.0.0
  -Managed`, hidden. PostgreSQL stays on 127.0.0.1:55432; PEMK listens on TCP 9998.
  The supervisor displays local IPv4 join addresses, and 127.0.0.1 for same-PC
  clients. Capability/bind probes reject an old loopback-only service instead of
  killing an unknown process. Managed services stop after 600 seconds with no
  logged-in accounts. Existing unauthenticated/account rate limits remain.

Live game behavior:
- Boot loads the same per-player local `_offline` save used by 0.6, preserving
  existing offline progress. Legacy local files are forked once in exclusive
  binary mode; original cache files and historical cloud saves are untouched.
- Connecting saves locally, authenticates on the selected host and handshakes
  the arena service without Game.load, title transition or character-ID stamping.
  Current character, party (including offline catches), arena and map remain.
  Network account ID is distinct from the persistent trainer ID.
- Historical server blobs are stripped before native Auth.apply_login can
  deserialize them; server economy/inventory restoration is not applied. Native
  MMO progression sync/flush/blob upload is disabled for this local-world mode.
  Checkpoints can still write the current local file. The server latches the
  local-world flag at arena hello and refuses account-save uploads on that link.
  No automatic offline/cloud merge is claimed or attempted.
- Native authentication/token storage, private-room validation, invitation
  consent, battle relay and peer-body checks remain. Progression gates are reset
  after login/relogin while preserving the advertised peer validation mode.
  Remote endpoint credentials are separated by player and IPv4 address.
- Host online connects locally then opens the arena. Join a host only connects;
  invitation/acceptance still selects the host's arena. Go offline closes the
  visit, saves locally, drops identity/transport/reconnect state, and continues
  in the same world. Guest return remains safely deferred by the visit layer.
  Outside the entrance, Connection directs the player to its attendant.

Files changed this turn: Play-Arena.bat; removed Launch-ArenaDemo.bat,
Launch-Multiplayer-Clients.bat, Launch-Multiplayer-Server.bat;
tools/{play-arena,desktop-session,launch-client,local-multiplayer}.ps1;
tools/ping_multiplayer.rb; game-mod/Plugins/ArenaDemo/{005_ArenaVisits,
007_ConnectionMode}.rb and meta.txt; game-mod/server/arena_visits.rb;
game-mod/test/{live_connection_test.rb,desktop_launcher_test.ps1,
arena_visits_server_test.rb}; removed superseded connection_mode_test.rb;
README, game-mod README, CHANGELOG and this report.

Validation: **53 Ruby tests / 380 assertions passed**, plus **13 PowerShell
launcher checks passed**. Ruby breakdown: live mode 10/66; combined customization,
visit client/server, route and synthetic maps 37/297; multiplayer fixes 5/16;
readiness 1/1. Syntax compilation and PowerShell parsing passed; whitespace check
passed. No dependencies were installed for tests.

Live-mode tests use engine/PEMK doubles: verify actor/party/map/save identity,
offline boot, binary legacy preservation, rejected login/service/address/location,
no cloud restoration/upload, retained peer validation, remote credential isolation,
Host vs Join actions, request correlation, deferred closing and readiness signal.
PowerShell tests execute real profile lease/file operations in a bounded temporary
directory: two identical launches receive separate profiles; an existing guest
blocks primary rebuilds; orphaned live clients remain protected; exhausted slots
are rejected; IPC cannot carry commands; only one root BAT remains. No GUI or
backend is launched by these tests.

Socket tests start the actual upstream reactor on **0.0.0.0 with an ephemeral
port**, and connect through loopback. Native wire/frame/zone/guarded-battle-relay
methods execute with injected account identities, not password login or DB setup.
The tests additionally verify advertised bind address, refused local-world save
uploads, and managed idle-stop logic. Wildcard binding is executed; a packet from
a second physical computer and Windows Firewall traversal are NOT tested.

Exact new test commands (PowerShell, C:/arena-lab):

```powershell
$arenaRuby = 'C:/arena-lab/tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$arenaMinitest = 'C:/arena-lab/tools/runtime/bundle/ruby/3.3.0/gems/minitest-5.27.0/lib'
& $arenaRuby --disable-gems -I $arenaMinitest -e 'eval(File.read(%q{C:/arena-lab/game-mod/test/live_connection_test.rb}), TOPLEVEL_BINDING, %q{C:/arena-lab/game-mod/test/live_connection_test.rb})'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File game-mod/test/desktop_launcher_test.ps1
```

Reran the previously documented combined source/socket suite, multiplayer-fixes
and readiness commands. Ruby syntax used RubyVM::InstructionSequence.compile on
the changed production files; PowerShell Language.Parser.ParseFile checked all
four changed PS scripts. `git -c safe.directory=C:/arena-lab diff --check` passed.

Execution limits: no actual game/production backend/DB was started or configured
by Codex in this turn, no runtime asset/map installation or actual save migration
was executed, and no authenticated two-window battle or two-PC GUI session is
claimed. The earlier private game-data access issue remains unresolved in this
agent environment; tests use temporary/synthetic files. Windows denied direct
replacement/deletion of some generated source files; approved file-copy/cleanup
operations completed. Temporary staging source was removed.

Manual acceptance test:
1. Close older game windows and any old manual/0.6 background server once. Run
   Play-Arena.bat twice. Confirm both start offline with independent local saves,
   and that the second launch waits until the first finishes compilation.
2. In window one, walk to the entrance attendant -> Host online. Log in/create an
   account. Confirm the service becomes ready, the same character stays in place,
   join addresses appear, and the arena opens without a separate BAT/console.
3. In window two, attendant -> Join a host -> 127.0.0.1. Use a different account.
   Read its account ID. Host: Invites and arena visits -> Invite a friend -> that
   ID. Guest: talk again -> Invites and arena visits -> accept within 60 seconds.
4. Verify identical host objects/difficulty and room-only access; complete PvP.
   Go offline at the attendant. Verify local party/layout/progress remain and
   customization unlocks after closing/returning. Save/reopen and verify persistence.
5. On a second prepared PC, run the SAME BAT, Join the host's displayed LAN IPv4
   with a different account, then repeat invite/accept. Permit the host Ruby
   executable on Windows Firewall's private network for TCP 9998 if required.
   Do not expose PostgreSQL. Firewall rules were not automatically changed.

The same-network client/host path is implemented; two-PC operation is pending
that manual test. Different-network internet routing/NAT discovery/relay and a
redistributable installer are not implemented. Prerequisite private Essentials
assets and native runtimes are still needed on both PCs. Public production
hosting, matchmaking and persistent online arena storage remain outside scope.


## One launcher and explicit connection modes - 2026-10-28

User requested one app with offline/online selection. Plugin **0.6.0** adds
`Play-Arena.bat`, `tools/play-arena.ps1`,
`game-mod/Plugins/ArenaDemo/007_ConnectionMode.rb` and
`game-mod/test/connection_mode_test.rb`. Metadata, README, game-mod README,
CHANGELOG and this report updated. Upstream versions, licenses, dependencies and
the pinned runtime remain unchanged from the preceding report.

Implemented behavior:
- One normal launcher prepares the client, detects an existing game process,
  probes PEMK arena capability and starts a hidden local server helper if needed.
  It opens one primary player window. Backend startup failure leaves offline play
  available. Private service logs: `tools/runtime/desktop-server-<launcher PID>.*.log`.
  The backend may stay running for later launches or developer test guests.
  Old BATs remain developer/test helpers; none were removed.
- Offline/Online selection precedes load-screen initialization and stored-token
  login. Offline blocks automatic transport startup and clears identity, sync,
  checkpoint and reconnect state. A running server does not make the window online.
- Connection pause menu reports current status and offers Go online/offline.
  Switching saves the current profile and uses the existing title/load flow in
  the same process. Active visits must close first. Save failure cancels switching.
  When connected online, the exact outgoing save must be acknowledged within a
  five-second frame-pumped wait; otherwise the current session stays open.
- Profiles remain separate because PEMK loads authoritative account saves.
  Offline inserts `_offline` in the current per-instance filename. Legacy local
  data is copied once with exclusive binary creation before either mode can
  overwrite its cache. Existing offline and original files are preserved. Offline
  catches are not merged into an online account. Failed/cancelled online login
  announces fallback and refreshes the offline slot instead of the preloaded cache.

Validation: **48 tests / 324 assertions passed**. New profile tests: 7 / 33;
existing source/map/socket tests: 35 / 274; multiplayer fixes: 5 / 16;
real-reactor readiness: 1 / 1. New tests cover no offline token/transport activity,
independent slots, legacy binary preservation (including online-first selection),
failed-login fallback, failed saves/unconfirmed acknowledgments, confirmed
same-process switching, visit guards and cancellation. Profile tests use engine/
PEMK doubles; socket tests keep the earlier injected-identity limitation.
Ruby syntax, PowerShell parsing and `git diff --check` passed.

New test command (other regression commands are in the preceding report):

```powershell
& 'C:/arena-lab/tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe' --disable-gems -I C:/arena-lab/tools/runtime/bundle/ruby/3.3.0/gems/minitest-5.27.0/lib -e 'eval(File.read(%q{C:/arena-lab/game-mod/test/connection_mode_test.rb}), TOPLEVEL_BINDING, %q{C:/arena-lab/game-mod/test/connection_mode_test.rb})'
```

Reviewed actual upstream Session, Auth, PersistHooks, Sync, NetStatus, Checkpoint,
SaveData, load-screen initialization and Scene_Map title behavior. This is a
controlled title/profile switch, not a live account merge. Normal launch still
uses the existing debug-capable development runtime so changed plugins compile;
it is not a newly packaged executable.

No production app/server was launched, no real save migrated and no private
client installation executed this turn. The private game-data access limitation
recorded below is unresolved and prevents GUI verification. No production
credentials, accounts or assets changed. The new launcher is source-implemented
and statically checked, not claimed as user-tested.

Manual checks:
1. Close current clients; run Play-Arena.bat. Confirm one player window opens and
   no manual server console is needed. The game must offer Offline/Online even
   when account credentials were previously saved.
2. Choose Offline while the server runs. Connection should say Offline and no
   invitations should arrive. Continue, catch a Pokemon and save the offline game.
3. Connection -> Go online: confirm save/title transition in the same app, then
   verify the correct online account loads. Close active visits before switching
   back; confirm the offline Pokemon/progress returns.
4. Cancel/fail an online login: verify explicit fallback to the offline slot.
5. Open Play-Arena again while playing: it should avoid rebuilding/opening another
   primary window. The old two-client helper remains available for developer tests.


## Arena menu, private visits and Founders' Path - 2026-10-28

Implemented proposed source steps 2-5, plugin **0.5.0**. Essentials remains v21.1
at `8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b`
(https://github.com/Maruno17/pokemon-essentials); PEMK remains at
`9a24034bca241c095b81ea8069607f6cdfa6a57d`
(https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit).
Existing compatibility/license findings and private asset exclusions still apply.
No upstream files, dependencies, production accounts, saves or databases changed.

Behavior:
- An arena-only Customize arena pause command replaces NPC customization. It is
  hidden while opening, hosting, visiting, closing or returning home. Every edit
  also checks permissions, including after blocking prompts. The manager is now
  a medic. Personal closed arenas can be edited while connected to the service.
- The entrance attendant shows the account ID, opens/closes hosting, invites one
  online account by ID and accepts/declines invitations. Opening locks before the
  send; closing unlocks after acknowledgment. Invitations expire in 60 seconds;
  the host stays open and locked until explicitly closed.
- Temporary one-guest rooms belong to PEMK's reactor. Server-created tokens scope
  presence and existing addressed relay messages. Validated primitive snapshots
  contain selected object slots, arrangement and trainer difficulty. Both clients
  use local map data with the host snapshot; no remote binaries are loaded.
  Guest personal layouts/saves are untouched; PCs use each player's own storage.
- Server presence checks and a Scene_Map transfer extension restrict active visits
  to maps 100/102. Town/route presence is private per updated account. Room position
  checks use the frozen layout plus fixed NPC/PC blocks and boundaries, replacing
  upstream static position checks only during a visit. Other maps retain upstream
  behavior. Local peer blocking includes the foyer. Simultaneous movement still
  has no server tile reservation guarantee.
- Disconnects, replaced connections and host closure end visits. Guest returns
  wait until menus/events/battles finish; old position-correction queues are
  cleared on room changes. A departing guest leaves the host open and locked.
- Offline Founders' Path (103) uses local terrain-tag-2 grass and Essentials Land
  encounters: Rattata 3-5, Caterpie 3-4, Spearow 4-6. A keeper gives 10 Poke Balls
  once and rewards ownership of a route species with 3 Great Balls once. Full
  bags preserve unclaimed grants. The scout leads to the route. Route entry,
  encounters and rewards are offline only. Town entry sets the foyer as the
  normal healing return point. No battle/capture mechanics were recreated.
- Root server wrapper loads our adapter after PEMK. Ping advertises arena service
  v1; readiness and server reuse reject an old healthy server with a restart
  instruction instead of binding a duplicate server.

Changed/added files for this step:
`game-mod/Plugins/ArenaDemo/{001_ArenaDemo,003_PlayerInteraction,
004_MultiplayerFixes,005_ArenaVisits,006_FoundersPath}.rb`, `meta.txt`;
`game-mod/server/arena_visits.rb`; `game-mod/tools/build_arena_map.rb`;
customization/multiplayer-fixes tests and new client/server visit, route and
synthetic-map tests; `tools/{run-local-server.rb,ping_multiplayer.rb,
local-multiplayer.ps1}`; README, game-mod README, CHANGELOG and this report.
Generator changes include the medic/attendant, reachable keeper/scout placement,
local grass route, explicit PC housing collision, map 103 registration, and
preservation of native Tone/Color payloads when rewriting the intro.

Validation with Ruby 3.3.12: **41 tests / 291 assertions passed**.
- Combined source/map/protocol tests: 35 tests / 274 assertions.
- Existing multiplayer-fixes tests: 5 / 16, including foyer peer collision.
- Upstream-reactor readiness test: 1 / 1.
- Syntax compilation of all nine changed production Ruby files, PowerShell
  parsing of the launcher and `git diff --check`: passed (line-ending notices only).

Real TCP tests use upstream reactor, wire codec, frame gate, zones and guarded
challenge/accept/battle-choice relay. Account identities are injected by the test
harness; password login and DB startup are not exercised. Tests cover matching
snapshots, outsider isolation, rejected town access/obstacle positions, consent,
decline, expiry/replay, two isolated hosts, explicit close and disconnect cleanup.
This is not two-window GUI verification or a new battle-completion result.
Synthetic map generation ran twice against temporary Marshal fixtures, checking
connections, grass, stable object IDs, conflicting map IDs, original intro Tone
bytes and exactly one skip choice. Source tests cover lock timing, failed sends,
menu visibility, post-prompt permission checks, personal layout restoration,
deferred returns, stale corrections and one-time story rewards.

Exact successful PowerShell test commands, from `C:/arena-lab`:

```powershell
$arenaRuby = 'C:/arena-lab/tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe'
$arenaMinitest = 'C:/arena-lab/tools/runtime/bundle/ruby/3.3.0/gems/minitest-5.27.0/lib'
& $arenaRuby --disable-gems -I $arenaMinitest -e 'ARGV.each { |path| require path }' C:/arena-lab/game-mod/test/arena_visits_client_test.rb C:/arena-lab/game-mod/test/founders_path_test.rb C:/arena-lab/game-mod/test/world_maps_test.rb C:/arena-lab/game-mod/test/arena_visits_server_test.rb
& $arenaRuby --disable-gems -I $arenaMinitest -e 'eval(File.read(%q{C:/arena-lab/game-mod/test/multiplayer_fixes_test.rb}), TOPLEVEL_BINDING, %q{C:/arena-lab/game-mod/test/multiplayer_fixes_test.rb})'
& $arenaRuby --disable-gems -I $arenaMinitest -e 'eval(File.read(%q{C:/arena-lab/tools/test_readiness.rb}), TOPLEVEL_BINDING, %q{C:/arena-lab/tools/test_readiness.rb})'
```

Syntax used the same executable with `--disable-gems -e 'ARGV.each { |path|
RubyVM::InstructionSequence.compile(File.read(path)); puts path }'` and the nine
changed Ruby paths. PowerShell check used `Language.Parser.ParseFile` on
`tools/local-multiplayer.ps1`. Whitespace: `git -c safe.directory=C:/arena-lab diff --check`.

Execution limitations: normal Ruby startup still stalls here unless RubyGems is
disabled and minitest explicitly supplied. A direct `--disable-gems -e` file-size
query of private `tools/runtime/essentials-v21.1-base/Data/Map002.rxdata` again
stalled without output inside and outside the sandbox; both sessions were
cancelled. Windows initially refused creating `game-mod/server`; approved
directory creation succeeded but did not resolve private game-data access.
No successful real-map build/plugin installation, production server startup,
GUI launch, capture or two-client GUI test was executed this turn. Full upstream
and DB/auth integration suites were not rerun. Prior user confirmation below
applies to v2.1, not the new visit flow.

Manual validation with the user's private setup:
1. Close clients; stop the old server console with Ctrl+C. Restart the root server
   launcher and confirm `private arena visits v1 enabled` in its log. Run the
   two-client launcher to install plugin 0.5.0 and build maps 100-103. Resolve any
   private-data access failure before playing.
2. Offline New Game + skip: keeper supplies, scout -> route, walk in grass and
   catch a species using Essentials' battle UI. Return south, collect the keeper
   reward once, use the entrance PC. Inspect artwork, doors and collisions.
3. Customize from the arena pause menu; check medic healing and trainer battle.
   Return to the entrance before opening hosting.
4. Log in with different accounts in two windows; walk to both attendants. Read
   guest ID, host opens/invites, guest accepts within 60 seconds. Check matching
   host objects/difficulty, both rooms, room-only access, hidden customization,
   player collisions and one completed PvP battle.
5. Guest leaves: their personal layout returns and host remains open/locked.
   Host closes: customization returns. Repeat with host disconnect; guest must
   return home after any active battle/menu finishes.

Still loopback-only development. No internet setup/public hosting, persistent
online arena storage, arbitrary placement or expanded trainer-roster syncing.
The foyer keeps temporary rock boundaries. Layout synchronization covers the
existing six slots, three arrangements and trainer difficulty only.


## Offline town / arena entrance step - 2026-10-28

Implemented step 1 of the proposed world organization in source. No upstream
engine/server changes or dependency/version changes were made. Essentials stays
at `8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b` (v21.1); PEMK stays at
`9a24034bca241c095b81ea8069607f6cdfa6a57d`. Repository URLs, compatibility and
license evidence remain in the original integration report below.

Changes:
- `game-mod/tools/build_arena_map.rb`: generates offline Arena Town (101), using
  the private town artwork and original house entrance, and Arena Entrance (102),
  using private indoor floor and PC artwork. Removes upstream tutorial events
  from the new town; connects town -> entrance -> existing arena (100), with
  return exits. Retains arena object IDs. Rejects conflicting map IDs and keeps
  source maps 2/3/9 intact. Writes `Data/ArenaDemoTownStart.txt` locally.
- `game-mod/Plugins/ArenaDemo/001_ArenaDemo.rb`: offline quick start and external
  pause-menu entry now enter town. Entrance PC calls Essentials' `pbPokeCenterPC`
  (reviewed in upstream `016_UI/019_UI_PC.rb`), including normal box storage and
  last-able-Pokemon safeguards. Existing authenticated quick start/entry stays
  on shared map 100; online exit retains the saved return destination.
- `game-mod/test/arena_customization_test.rb`, new `world_maps_test.rb`, root
  README and game-mod README updated. No assets, saves, accounts or secrets added.

Executed checks with local Ruby 3.3.12:
- Customization/interaction tests: **17 tests / 94 assertions, pass**.
- Existing multiplayer fixes: **5 tests / 15 assertions, pass**.
- Synthetic-map generator tests: **2 tests / 21 assertions, pass**. The generator
  actually ran twice against temporary Marshal fixtures; connected script events,
  original-map preservation, stable object IDs and map-ID conflict refusal passed.
- RubyVM syntax compilation of both changed production Ruby files: **pass**.

Normal Ruby script startup stalled without output. Disabling RubyGems and using
the explicit local minitest library allowed source tests to run. Exact successful
PowerShell test pattern (replace TEST with each of the three filenames above):

```powershell
& 'C:\arena-lab\tools\runtime\ruby-portable\rubyinstaller-3.3.12-1-x64\bin\ruby.exe' --disable-gems -I C:/arena-lab/tools/runtime/bundle/ruby/3.3.0/gems/minitest-5.27.0/lib -e 'eval(File.read(%q{C:/arena-lab/game-mod/test/TEST}), TOPLEVEL_BINDING, %q{C:/arena-lab/game-mod/test/TEST})'
```

Syntax command: same Ruby executable with `--disable-gems -e
'ARGV.each { |p| RubyVM::InstructionSequence.compile(File.read(p)); puts p }'`
and the two production source paths as arguments.

Attempted `ruby game-mod/tools/build_arena_map.rb
tools/runtime/essentials-v21.1-base`, then retries with RubyGems disabled,
explicit paths and approved execution outside the sandbox. Private game-data
access still stalled without output; even a direct file-size query for private
Map002 did not finish. Stalled command sessions were cancelled. No successful
real-map generation, plugin installation, server start, client launch or
two-client test is claimed for this change. Exact cause is unresolved. Prior
user-confirmed multiplayer results below apply to v2.1, not this new map path.

Manual validation required:
1. Close clients, back up private saves, run `Launch-ArenaDemo.bat` from this folder.
   Confirm output says maps 101 and 102 were built; launch failure requires checking
   local private-data accessibility before proceeding.
2. Choose offline, New Game, intro skip. Walk into the building immediately north
   of spawn. Check the foyer PC opens storage, inspect boxes/party, cancel out.
3. Enter the north door, test movement/trainer/customization, then walk through
   the south opening back into the foyer and out to town. Inspect artwork and
   collisions; the foyer currently uses placeholder rock boundaries.
4. Run the existing multiplayer launchers with two different accounts. Confirm
   direct arena entry, identical fixed obstacles, presence and a complete battle.

Next scope remains moving customization into the arena menu, multiplayer NPC and
session lock, then actual private visits/layout synchronization, then a catching
route/story. The welcome NPC is explanatory only; it has no fake invite controls.


## v2.1 - 2026-10-28: user verification

The user verified multiplayer launch, full text rendering, battle synchronization
and completion, and player collisions. These are user-run GUI results; Codex did
not run the two-window GUI test. Earlier pending checks and installation stalls
below are historical and superseded by this confirmation. Console selection was
a suspected timeout cause, not separately confirmed.

ArenaDemo 0.4.2 adds local peer blocking, mirrored client outcomes and singles
speed ties, and RNG flushing before replacement/end messages. The runtime uses
rendered font height. Startup reuses a healthy server; readiness failures identify
their network stage and visible TCP entries/PIDs. Accounts and saves are retained.

Release checks rerun: customization 16 tests / 90 assertions; multiplayer fixes
5 tests / 15 assertions; real upstream-reactor ping 1 test / 1 assertion. All
22 tests / 106 assertions passed. Ruby syntax passed. The full upstream suite was
not rerun. No play account/database changes or GUI launch were made by Codex.

Simultaneous moves may overlap without server tile reservations. General replay
for all ability/item combinations is not established. No shared arena editing or
public hosting was added. Upstream versions/licenses and private asset exclusions
remain unchanged. README, CHANGELOG, game-mod README and metadata reflect v2.1.


## Readiness timeout investigation — 2026-10-28

User supplied a newer server log ending in `reactor: listening on 127.0.0.1:9998`
while the client launcher's PEMK probe timed out. Listening alone does not establish
that a ping was accepted/answered. No new successful GUI launch is claimed.

Inspected the shared wire encoder, server ping handler, reactor start/run loop,
local server wrapper and both launchers. The probe's split framing matches the
server handler. Added `tools/test_readiness.rb`: a fresh, real upstream reactor on
an ephemeral loopback port answers the same split ping (PASS: 1 test / 1 assertion,
Ruby 3.3.12; no database/accounts touched). Its initial run reached the assertion
but failed cleanup due to a test-variable scope error; that was fixed and rerun.

The port-9998 probe timed out inside and outside the sandbox, and netstat/process
inspection showed no visible matching listener/Ruby process from this agent's
session. The revised probe uses bounded TCP connect and labels its failure stage;
the actual result here is `connect: Errno::ETIMEDOUT`. This cannot establish the
state of the server shown in the user's separate console. Do not infer a corrupt
database or broken authentication from this output.

Changed `tools/ping_multiplayer.rb` to distinguish connect/send/header/body failures
and allow five seconds for an exchange; `tools/local-multiplayer.ps1 -Action Ready`
now prints port entries/PIDs on failure instead of a generic Ruby exception.
Ruby syntax, PowerShell parsing and git diff --check passed. README updated.

Next user-side check: press Esc in the existing server console to clear any text
selection, then rerun Launch-Multiplayer-Clients.bat with that server still open.
Console selection is a possible cause, not a verified diagnosis. If still failing,
the new probe stage plus TCP entries/PID and latest server log are needed to
distinguish an inaccessible listener from a connected but unresponsive server.


## Multiplayer follow-up — 2026-10-28

User-tested status: both game windows work, player interaction sends a challenge,
the other player can accept, and the battle starts. Battle completion is NOT
validated: the user reports different end states/HP bars. Text is clipped across
its lower half and remote players can overlap. These results supersede the older
snapshot's untested challenge/acceptance status, not its unresolved PvP completion.

The supplied server log confirms Ruby 3.3.12, bcrypt 3.1.22 hash/verify PASS,
PostgreSQL schema 48 PASS, 70 maps and 1,237 species/forms loaded. That startup
then failed with EADDRINUSE on loopback 9998: another listener occupied the port.
This does not prove the other listener was a healthy PEMK server. On this turn,
`ruby tools/ping_multiplayer.rb 0` timed out both inside and outside the sandbox.
No server process was stopped or database/account altered.

Changes: `004_MultiplayerFixes.rb` adds arena-only local collision checks (shared
spawn tiles can still be exited), reverses received host win/loss codes for the
client perspective, mirrors the first singles priority-shuffle draw so equal-speed
Pokemon keep the same physical turn order, and flushes host RNG before replacement
menus and end-of-battle messages. These are targeted repairs, not proof of general
deterministic replay for every ability/item combination. Simultaneous movement is
not reserved server-side, so local collisions cannot prevent all overlap races.
PEMK intentionally battles on party copies; original party HP after PvP is expected.

`install-client-runtime.ps1` now sets `fontHeightReporting = 1`, using rendered
glyph height rather than nominal height. This is a candidate fix requiring visual
verification; see the upstream mkxp-z configuration's fontHeightReporting option:
https://github.com/mkxp-z/mkxp-z/blob/dev/mkxp.json . The server launcher probes PEMK
before migrating/binding and reuses a healthy instance. A quiet probe failure
continues normal startup. An unrelated/unresponsive listener can still block bind.

Executed from C:/arena-lab using
`tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe`:

- `game-mod/test/multiplayer_fixes_test.rb`: PASS, 5 tests / 15 assertions.
- `game-mod/test/arena_customization_test.rb`: PASS, 16 tests / 90 assertions.
- `-c game-mod/Plugins/ArenaDemo/004_MultiplayerFixes.rb`: Syntax OK.
- PowerShell parser on both changed .ps1 files: no errors.
- `git -c safe.directory=C:/arena-lab diff --check`: PASS, line-ending notices only.

The new tests isolate extension behavior with engine stubs; they do not launch
RGSS or prove two-client HP synchronization. Runtime log reads and attempted
installation through `tools/install-client-runtime.ps1` stalled, including an
outside-sandbox retry. No successful installation or GUI retest is claimed here.
Upstream checkouts/versions remain as recorded below; no upstream source edited.

Manual steps: close both game windows, run Launch-Multiplayer-Server.bat once
(keep the healthy original server running if already present), then run
Launch-Multiplayer-Clients.bat to install the plugin/config and restart both.
Verify full text in dialogs, menus and battle; walking into a stationary peer
should stop, and adjacent Enter should challenge. Finish battles with each player
winning, including equal-speed teams and a faint requiring replacement. Compare
each hit's HP on both screens and verify both return to the arena. If Prepare
stalls, installation remains blocked; do not treat the source tests as a GUI pass.


## v2 snapshot — 2026-10-27

The `v2` source snapshot includes the enclosed arena/customization, local multiplayer launchers, account fixes, player battle-request interactions, Escape-menu correction, and the pinned native-runtime replacement. [CHANGELOG.md](CHANGELOG.md) summarizes the changes; the sections below retain exact commands, source commits, failures, and verification evidence. Final targeted regressions passed **17 tests / 108 assertions**. GUI account creation and the replacement runtime's click test were user-confirmed; a full GUI PvP battle and post-switch movement remain to be checked. Private runtime assets, credentials, accounts, databases, saves, and generated logs/maps are excluded from this commit. This snapshot does not bundle a ready-to-distribute game or claim complete multiplayer validation.

## Current runtime stability result (2026-10-27, v0.4.1)

Final verification: cleaned Prepare succeeded with the pinned runtime and rebuilt Map100; primary/guest launcher validation and PowerShell syntax parsing passed. Arena customization/interaction tests passed 16/90 and the real-backend arena challenge test passed 1/18 (17 tests, 108 assertions total). The lightweight Ruby load logger passed syntax checking and git diff --check passed with line-ending notices only. No extra game window was launched or existing account reset during final cleanup.

The user reported both clients exiting on a click. Both logs authenticated and stopped after restoring server saves; no normal Essentials errorlog was produced. A monitored legacy launch captured native exit **-1073741676 / 0xC0000094** (integer divide by zero). GDB stopped the RGSS thread on SIGFPE at a `divl` with a zero divisor. At the stop, `rb_eval_string` wrote Ruby callers to ignored `native-ruby-stack.log`: **Input.update**, inside the low-battery message displayed during Scene_Map#createSpritesets. The map-rendering suspicion was therefore narrowed to native key-repeat polling, before the player-interaction code ran.

Fixed-60 rendering settings and then a Ruby Graphics.frame_rate input-timer guard both failed against the packaged executable; the user reproduced the same native exit. Those failed workarounds and their implementation-only tests were removed. One diagnostic attempt introduced a separate **Errno::EBADF in DebugConsole.echo** by redirecting console handles. This was acknowledged and corrected: diagnostics and normal launchers now use shell execution without stdout/stderr redirection. No account or save was reset to work around the crash.

### Tested official runtime

- Repository: https://github.com/mkxp-z/mkxp-z, using its documented Automatic Builds.
- Source commit: **37a04d14413454551a7b6aadbb4e93e67168accb**, branch `dev`.
- Successful push run **37110075912**, artifact **mkxp-z.windows.cross.x86_64.dev-37a04d1**, artifact ID **11271805100**.
- Download: `https://nightly.link/mkxp-z/mkxp-z/actions/runs/37110075912/mkxp-z.windows.cross.x86_64.dev-37a04d1.zip` (official Actions artifact served by nightly.link).
- Archive SHA-256: `F9438D765F608CD99186EABF92C3BE9D7B2EDA0F93D83D51CA45BFE9D53C3B59`.
- Executable SHA-256: `3ACB84AEACEC93F80D40372B041F2774E454F63454561BDD90AF173A62760768`.
- Private installation: ignored `tools/runtime/mkxp-official-test/`, including its executable, stdlib, LICENSE.txt, generated mkxp.json and arena-runtime.json provenance manifest. It is a pinned development build, not a tagged release. The public repo currently has no GitHub Releases. Hosted Actions artifacts can expire; the verified archive is also cached locally.
- Checked the artifact license and upstream README (GPL v2+ with the README's OpenSSL/GPLv3 qualification). Runtime binaries, proprietary/third-party game assets, logs, tokens and account data remain ignored and were not added to source control.

The original private Game.exe is preserved. Failed edits to its local timing config have the backup `mkxp.json.before-input-timing-fix`; the replacement instead uses its own config. That config sets gameFolder to the existing private Essentials project, execName=Game, RGSS version 1, fixedFramerate=60 and syncToRefreshrate=false. It starts from its own directory so config, stdlib and Game.ini resolution agree. Early isolated launches without this explicit setup said "no script has been specified"; that test-setup issue was corrected before the successful click test.

Primary documentation inspected: [mkxp-z input implementation](https://github.com/mkxp-z/mkxp-z/blob/37a04d14413454551a7b6aadbb4e93e67168accb/src/input/input.cpp), [configuration](https://github.com/mkxp-z/mkxp-z/blob/37a04d14413454551a7b6aadbb4e93e67168accb/mkxp.json), and the upstream README/Automatic Builds workflow. Essentials v21.1 and PEMK source commits remain those recorded below; neither their game data nor their battle engine was replaced or ported.

### Commands and actual results

1. `ruby tools/client-diagnostics.rb` inspected local client logs. Windows application-event queries did not provide the crash. Some PowerShell runtime reads stalled and were interrupted; the Ruby log reader worked.
2. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/diagnose-client.ps1` monitored legacy launches; after correcting console handling it captured native exit 0xC0000094. User credentials were not requested or printed.
3. `C:/msys64/mingw64/bin/gdb.exe --batch -x tools/runtime/client-crash.gdb --args ./Game.exe debug`, from the private game folder, captured SIGFPE. The command file/native traces remain ignored diagnostics.
4. Queried official GitHub metadata, downloaded/extracted the pinned artifact separately, and verified both SHA-256 values above. A sandbox GitHub request failed; approved retry succeeded. An attempted historical short-commit source URL returned 404 and was not used as evidence.
5. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/diagnose-client.ps1 -OfficialRuntime -AutoClick` used existing game assets and the existing account. Automatic clicks did not reliably reproduce the user's physical focus change, so they were not counted as decisive proof. The user then physically clicked and confirmed **"now it doesnt exit"**. This verifies click survival in the tested window, not a completed PvP battle or all gameplay.
6. Added `tools/install-client-runtime.ps1` (pinned hashes, optional download, relocatable config), `tools/launch-client.ps1`, and routed both root client BAT launchers through the tested executable. Primary and guest retain distinct PEMK instance settings. The launcher does not silently fall back to the known-crashing Game.exe.
7. Installer plus `launch-client.ps1 -Instance primary -ValidateOnly` and `-Instance guest -ValidateOnly` **passed**, selecting the pinned executable with primary instance unset and guest=`guest`. These checks do not open additional game windows.
8. Removed temporary timing source/test files and the heavy TracePoint boot tracer. Kept only a lightweight save-load failure logger plus opt-in diagnostic tools. Preparation removes our old installed temporary input guard only when its SHA-256 matches; edited copies are preserved for inspection.
9. Final source regression: bundled Ruby `game-mod/test/arena_customization_test.rb` **16 tests / 90 assertions, all passed**. The trimmed save-load logger passes `ruby -c`. Final launcher/install/diff checks and the protocol regression are recorded in the verification note below.

The user-tested game window was left open. For subsequent launches, close existing clients, start root `Launch-Multiplayer-Server.bat` if needed, then root `Launch-Multiplayer-Clients.bat` from C:/arena-lab. Keep existing accounts. Root `Launch-ArenaDemo.bat` uses the same preparation/runtime for one client. Avoid the private game's old PlayMMO-debug/guest BAT files because they still target the preserved old executable. To reconstruct a missing runtime: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/install-client-runtime.ps1 -Download`.

Movement and a full PvP battle remain separate GUI checks. The full PEMK suite was not rerun for this native-runtime switch. No public listener, account reset, or new battle/network engine was introduced.


## Player interaction and Escape menu correction (2026-10-27, v0.4.0)

Final v0.4.0 installation: the approved Prepare command copied all three ArenaDemo scripts and regenerated Map100 successfully. Final client tests pass (16 tests/90 assertions), with peer map filtering checked against the actual Game_Character map API; the real-backend arena challenge test passes (1 test/18 assertions). No server changes or GUI battle-completion claim. Restart both clients through the existing multiplayer launcher to load the update.

The user confirmed GUI account creation now works, then requested player interaction and reported Escape in Arena Demo teleporting them home. The menu passed a zero-based cancel index to Essentials' one-based positive `cmdIfCancel`. Verified in upstream `011_Messages.rb`: positive cancellation returns `cmdIfCancel - 1`; the old main-menu value therefore selected Leave. All ArenaDemo choice menus now use `-1` for Escape. Explicit Leave remains available and is regression-tested separately.

Added `game-mod/Plugins/ArenaDemo/003_PlayerInteraction.rb`, using Essentials' existing `:on_player_interact` hook (called after normal map event interactions). Facing an adjacent remote player, or sharing their tile, opens **Challenge to battle / Cancel**. Added **Players in arena** to the Arena Demo menu with sanitized names and account IDs. PEMK's Battle Player pause menu delegates to this list on arena map 100. The sender validates connection, current same-map peer, and an able Pokemon, records the target in PEMK's own challenge state, and sends its existing `:challenge` frame. Upstream accept/decline, consent gate, team exchange, deferred battle launch, and networking remain in use without modifying upstream files. The interaction is restricted to map 100; offline/other-map/far-away direct interactions do not start anything. The player-list menu can reach any peer on this arena map.

Player dialogs retain/restore `$game_temp.in_menu` to avoid launching incoming challenge UI or a pending battle inside another blocking dialog. No trade, chat, custom protocol, online arena editing, or friend-owned arenas were implemented. Plugin version is 0.4.0; existing wildcard-copy launchers install the new script. Existing accounts/saves can be retained.

Validation commands: bundled Ruby `game-mod/test/arena_customization_test.rb` — **16 tests / 90 assertions**, all passed. The expanded tests cover actual Essentials cancel semantics, explicit Leave versus Escape/Close, all customization cancellations, facing/same-tile/player-list interaction, offline/other-map/distant peers, lost connection/stale peer/no able team/send failure, correct outgoing peer consent, and incoming accept/decline before team exchange. Actual upstream `PEMK::Challenge` code is loaded in these tests; RGSS rendering/game state are stubbed.

With the existing project-local gem bundle and `DATABASE_URL=postgres://postgres@127.0.0.1:55432/pemk_test`, bundled Ruby `game-mod/test/multiplayer_arena_test.rb` — **1 test / 18 assertions**, all passed against an isolated real backend. Two authenticated protocol clients entered map 100, exchanged positions/movement, declined one challenge, accepted another, relayed a battle-choice frame, and received battle-end/leave on disconnect. An initial expectation incorrectly assumed leave would arrive first after the newly added accepted battle; corrected the test to verify PEMK's real battle-end-then-leave behavior. This is protocol verification, not a rendered or completed PvP battle.

The new script passes Ruby syntax checks; `git diff --check` passed with line-ending notices only. Private-runtime installation was attempted with the existing Prepare action using owner permissions; result recorded below. No server/authentication configuration was changed this turn. Actual GUI interaction, acceptance prompt, and complete PvP battle remain to be verified after restarting both clients.

Manual check: close both games, launch the existing server if needed, then `Launch-Multiplayer-Clients.bat`. Keep both accounts in map 100, face each other, press Z/Enter/Space, choose Challenge, and accept in the other window (with its pause menu closed). Also verify Arena Demo → Escape stays in the arena, and explicit Leave still exits. No account recreation is needed.

## Registration "no response" correction (2026-10-27)

Final registration-fix checks: approved Prepare installed both ArenaDemo Ruby scripts and rebuilt Map100. Customization tests still pass (7 tests, 36 assertions); extension syntax and git diff checks pass. The readiness probe passed with a running server and returned nonzero with an actionable error after stopping the test server. The GUI registration fix still needs the user to restart and try it. No user credentials or play accounts were used.

The user reported that creating an account from the game returned "no response from the server". Initial inspection found PostgreSQL running but no PEMK listener on port 9998; this alone does not prove what happened during their earlier request. Reads of old client logs stalled in both sandboxed and approved contexts and were interrupted; no historical client-log diagnosis is claimed. An asynchronous question asked which workspace copy was launched and what the server window showed; no answer was available during implementation.

Found and reproduced a separate concrete client/server mismatch: upstream `server/lib/pemk/reactor.rb` expires unauthenticated sockets after 30 seconds, while `AuthUI.register` waits for email, password, and confirmation before using the same original socket. A user taking more than 30-45 seconds at the form can therefore submit on a server-closed connection. The previous backend tests submitted immediately and did not cover this delay.

Added optional `game-mod/Plugins/ArenaDemo/002_PEMKLoginFix.rb`, version 0.3.1. It prepends a small wrapper around `PEMK::Auth.send_and_wait`, reconnecting the existing client object immediately before a pre-login `register` or `login` request. It does not replay an already-submitted registration, alter authentication, change the server timeout, or reconnect authenticated gameplay/resume requests. `Optional = PEMK, 0.1.0` uses Essentials' documented metadata parser to load this extension after PEMK when present. Upstream source remains unchanged. Both the offline BAT and multiplayer preparation now copy all ArenaDemo Ruby files.

Added `tools/ping_multiplayer.rb` and helper action `Ready`: bounded real-protocol ping/pong before launching GUI clients, with an actionable failure instead of launching against an absent server. Added `tools/run-local-server.rb` to retain server messages and native stderr under ignored `tools/runtime/pemk-server.log`; the server still runs in the launcher's foreground. Launchers print their resolved project folder, preserve error status, and retain the window on failure. Removed a duplicate `server_auth_test.rb` invocation from the test action.

Validation: `game-mod/test/login_connection_test.rb` loads actual upstream NetClient/MessageCodec/Auth with an isolated real PEMK backend and test database. It ages the server-side unauthenticated socket by 60 seconds and invokes the real idle sweep (no long sleep). Unpatched registration reproduces nil/no response; with the extension installed, expired-connection registration and subsequent login succeed and authenticated ping keeps the same socket. Final result: **1 test, 10 assertions, zero failures/errors/skips**. Two initial fixture runs failed because the test's RGSS configuration stub omitted codec bounds; the complete upstream-equivalent bounds fixed the fixture. These were test-fixture errors, not passing registration results.

`powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Server` passed bcrypt/PostgreSQL checks, migrated schema 48, and reached the real listener on 127.0.0.1:9998 using the new logging wrapper. `-Action Ready` then returned **PEMK server READY** using ping/pong. Ruby syntax checks for both new tools passed. Runtime installation and remaining launcher checks are recorded below. GUI registration after the fix remains unverified until the user restarts a client and tries it.

## Current result: manager correction and local multiplayer (2026-10-27)

The user confirmed that the new arena, trainer interaction, and customization work in-game. They reported that accepting manager edits moved them several tiles. Removed the three unconditional entrance teleports. Object/arrangement/preset changes now keep the player in place, or reject an edit that would place an obstacle on their current tile. No saved layout mutation occurs for a rejected edit.

### Multiplayer work completed

- Reused the checked-out PEMK authentication, persistence, presence, and PvP features; no networking protocol, battle engine, or authentication bypass was added. The upstream commits/version evidence in the original report below remains applicable; upstream source was not modified.
- Identified the native dependency mismatch: Ruby is `x64-mingw-ucrt`, but the original native gems were built using `C:/msys64/mingw64/bin/gcc.exe` (MSVCRT). The old bcrypt build log/Makefile also contained the workspace's former accented OneDrive path. Rebuilding with the matching UCRT compiler fixed the reproducible bcrypt hashing failure.
- Installed MSYS2 package `mingw-w64-ucrt-x86_64-gcc` (14.1.0-3) and its dependencies. Several configured mirrors returned 404/timeouts for the older package database, but pacman ultimately completed successfully (exit 0). No server password logic or hash cost was weakened.
- Rebuilt bcrypt `3.1.22` and bigdecimal `4.1.2` in the ignored project-local gem bundle with the UCRT compiler. A first `gem pristine` invocation without an explicit install directory did not rebuild the project bundle; the explicit-directory invocation did.
- Started the existing PostgreSQL 17.11 local cluster on `127.0.0.1:55432`. The sandbox initially could not remove its stale `postmaster.pid`; an approved outside-sandbox start recovered the existing cluster. Both `pemk` and `pemk_test` remain schema version 48. No play account tables were cleared.
- Added native Windows server/client launchers and a relocatable PowerShell helper. They use local-only addresses, retain existing configs/credentials, and use PEMK's separate normal/guest client instances. Configs, tokens, native binaries, DB files, and private game assets remain under ignored `tools/runtime/`.
- Prepared the private runtime successfully: installed ArenaDemo 0.3.0, repaired its generated `server` junction to `C:/arena-lab/tools/runtime/pemk-workspace/server`, created a guest loopback config if absent, and rebuilt Map100. This required approved outside-sandbox execution because overwriting the installed plugin was denied to the sandbox account.
- Online sessions display a single fixed Sidelines layout with all six obstacles. Offline object/arrangement selections remain saved and are not overwritten. The online manager offers healing; shared arena editing/ownership/visits/persistence are still outside this first version. This prevents differing local obstacle configurations from being presented as synchronized multiplayer.
- Started the actual PEMK server on `127.0.0.1:9998`; logs confirmed PostgreSQL, 70 world maps, 1,237 species/forms, and `reactor: listening`. Stopped this test server afterward and confirmed port 9998 closed, so the user can start it using the launcher. The local PostgreSQL process remains available. Existing upstream enforcement defaults remain unchanged (position audit-only, no public listener).

### Exact commands and results

Commands below ran from `C:/arena-lab` unless noted. Native Ruby is `tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe`.

1. `wsl --status` still returned `Wsl/EnumerateDistros/Service/E_ACCESSDENIED`; the maintained WSL path remains unavailable to this account.
2. `C:/msys64/usr/bin/pacman.exe -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc` — completed, exit 0 after mirror errors/fallbacks.
3. Set `GEM_HOME` and `GEM_PATH` to `C:/arena-lab/tools/runtime/bundle/ruby/3.3.0`; prepend the portable Ruby bin, `C:/msys64/ucrt64/bin`, and `C:/msys64/usr/bin` to `PATH`. Then run bundled Ruby with `bin/gem pristine bcrypt bigdecimal --extensions --install-dir C:/arena-lab/tools/runtime/bundle/ruby/3.3.0` — restored both native extensions. Reproducible helper: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action RepairGems`.
4. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Check` — **PASS**, Ruby 3.3.12, bcrypt hash/verify at cost 12, PostgreSQL connection, schema 48.
5. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Test` — migrated isolated `pemk_test`; upstream `auth_test.rb`: **10 runs / 28 assertions**, upstream `server_presence_test.rb`: **16 runs / 63 assertions**, all passed. The helper was subsequently expanded to include the two further tests run individually below.
6. With `DATABASE_URL=postgres://postgres@127.0.0.1:55432/pemk_test`, bundled Ruby `tools/runtime/pemk-workspace/server/test/server_auth_test.rb` — **4 runs / 19 assertions**, all passed. This tests real socket registration/login/token reconnect and auth rejection.
7. With the same isolated test URL, bundled Ruby `game-mod/test/multiplayer_arena_test.rb` — **1 run / 11 assertions**, all passed. Two independent authenticated PEMK protocol clients registered and logged in, joined map 100, received each other's server-stamped positions, relayed a movement update, and observed a peer leave. Only the test's randomly generated accounts were cleaned up by this custom test.
8. Bundled Ruby `game-mod/test/arena_customization_test.rb` — **7 runs / 36 assertions**, all passed. Covers no teleport during normal manager edits, cancellation, overlap rejection without mutation, online edit rejection, and identical online obstacles despite different personal saves.
9. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Prepare` — **PASS** on the approved retry. Generated 25x19 Map100 at spawn 12,16,8 with trainer 12,4 and manager 10,16; copied plugin and prepared separate guest settings.
10. `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Server` — check/migration succeeded, server listening confirmed on 127.0.0.1:9998; later stopped after this verification.
11. Bundled Ruby syntax checks on the updated plugin and new Ruby helpers — `Syntax OK`. `git -c safe.directory=C:/arena-lab diff --check` — passed, with CRLF notices only. Workspace Git inspection used a command-local safe.directory exception because the sandbox account differs from the workspace owner; no global Git configuration was changed.

These results **supersede the earlier bcrypt/auth blocker reports below**. The full PEMK test suite has not been rerun; only the named targeted suites passed. The two-client arena test used real authenticated protocol sockets, **not two GUI game clients**. No two-window rendering, GUI account flow, synchronized PvP completion, trade, or server-save reload in the GUI is claimed.

### User steps and remaining validation

1. Close existing game windows, double-click root `Launch-Multiplayer-Server.bat`, and leave it running.
2. Double-click `Launch-Multiplayer-Clients.bat`; the launcher prepares the local project and opens the normal and guest game windows. Windows may need to run these as the workspace owner if its file ACLs still deny the current account.
3. Create a **different** account in each window. New accounts can choose the intro skip; existing accounts can use the Arena Demo pause entry. Do not use the same account in both windows because PEMK intentionally replaces the earlier session.
4. Enter the arena in both windows and verify each sees the other moving. Use **Battle Player** from the pause menu and accept in the other window; finish the PvP battle. Close/reopen a client to verify server-save restoration.
5. Debug startup regenerates the upstream world/battle exports through the repaired local junction when needed. If it reports regenerated exports, restart the server to load that refreshed data. Do not enable stricter upstream enforcement without checking the generated arena data and dynamic trainer compatibility.
6. Offline, confirm changing manager options keeps the player beside the manager. Shared online obstacle editing is not implemented; offline customization remains available.

Files changed this turn: `game-mod/Plugins/ArenaDemo/{001_ArenaDemo.rb,meta.txt}`, `game-mod/test/{arena_customization_test.rb,multiplayer_arena_test.rb}`, `tools/{local-multiplayer.ps1,check_multiplayer.rb,migrate-local.rb}`, `Launch-Multiplayer-{Server,Clients}.bat`, `README.md`, `game-mod/README.md`, and `SETUP_STATUS.md`. Existing arena map-generator edits from the preceding turn were retained. Native gems, installed game plugin, generated maps, local junction/config, and database/log changes are private ignored runtime changes.

---

The sections below are the earlier setup history.

## Arena expansion (2026-10-27)

Final verification: bundled Ruby `-c game-mod/Plugins/ArenaDemo/001_ArenaDemo.rb` and `-c game-mod/tools/build_arena_map.rb` both returned `Syntax OK` on the final sources. `git -c safe.directory=C:/arena-lab diff --check` passed (line-ending notices only). Actual map-generation attempts, including an outside-sandbox retry, stalled without output and were interrupted; no successful generation or installation into the private runtime is claimed. The existing launcher will install the plugin and attempt generation on the user's next launch. If it also stalls there, the runtime file-access/build issue still needs diagnosis.

The user confirmed that the village demo launches, the three objects can be removed/restored, and the menu starts a battle. These are user-tested results, not an automated GUI test.

Implemented a new 25x19 enclosed training yard generated from a passable, non-terrain ground stack in the installed Essentials tileset, with solid rock perimeter events. The trainer at (12,4) runs `ArenaDemo.challenge_trainer` via an action-button event and asks for confirmation before using the existing Essentials battle engine. The manager at (10,16) supports six objects, three arrangements, clear/light/full presets, three trainer difficulty settings, and team healing. Saved object selections remain compatible; layout and difficulty default when absent. Custom layouts remain local-only.

Changed `game-mod/Plugins/ArenaDemo/001_ArenaDemo.rb`, `meta.txt`, `game-mod/tools/build_arena_map.rb`, `README.md`, `game-mod/README.md`, and this file. Commands attempted: bundled Ruby `-c` on both Ruby sources; bundled Ruby map generator against `tools/runtime/essentials-v21.1-base`. Both sources returned Syntax OK before the final small compatibility edit; final verification is recorded below. No GUI launch or multiplayer test is claimed for this update. Close the old game, run `Launch-ArenaDemo.bat`, and use a fresh New Game with the intro skip, because existing saves can retain the old map's state. Verify movement, talk to the northern trainer and finish a battle, then try all manager presets/arrangements and save/load. Existing server authentication blockers are unchanged.

Updated 2026-10-26.

## Task 1 — Essentials + PEMK

### Repositories and compatibility

| Project | URL | Branch / checked-out commit | Version evidence |
|---|---|---|---|
| Pokémon Essentials | https://github.com/Maruno17/pokemon-essentials | `master`, `8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b` (`v21.1-23-g8c5911e4`) | `Data/Scripts/001_Settings.rb` declares Essentials `21.1`. |
| Pokémon Essentials MMO Kit (PEMK) | https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit | `master`, `9a24034bca241c095b81ea8069607f6cdfa6a57d` | PEMK README and `Plugins/PEMK/meta.txt` require Essentials `21.1`. |

The checked-out versions match PEMK's documented target. The Git repositories are source overlays rather than a complete game. The Essentials README directs users to obtain a separate v21.1 package; its repo omits graphics, audio, maps, and most game data. I obtained the v21.1 package from the credited distribution page at https://luka-sj.com/essentials/resources/PE21 and assembled a **private local test copy** at ignored path `tools/runtime/essentials-v21.1-base/`. I overlaid the cloned Essentials scripts, PEMK plugin, ArenaDemo plugin, and a local loopback server config there. This copy is outside tracked source control. The client launch has not yet been verified.

### Licenses and assets

- Both repositories' `LICENSE` files identify CC BY-NC-SA 4.0 for their covered work. PEMK separately identifies Nintendo/Game Freak-derived assets and says private testing only. Those repository licenses do not grant redistribution rights to third-party game assets.
- No ROM data, proprietary RPG Maker assets, local game saves, or credentials were added to tracked project files.
- Native runtime downloads, extracted binaries, the isolated PEMK test workspace, and local PostgreSQL data are under ignored/local-only `tools/runtime/` and are not intended for source control.
- The 65.6 MB v21.1 package is also under `tools/runtime/` only. It contains third-party Pokémon-related assets and must remain private; it is not included in any distributable project files.

### Native Windows environment

- Windows 11; Git `2.45.2.windows.1`.
- WSL is installed but unusable for this account: `wsl --status` returned `Wsl/EnumerateDistros/Service/E_ACCESSDENIED`.
- RPG Maker XP was not found. No complete Essentials client project/assets were present.
- RubyInstaller portable Ruby `3.3.12` (x64 mingw-ucrt) was extracted locally. Silent RubyInstaller setup attempts exited 5 and rolled back; portable extraction was successful. `ruby.exe --version` reported `ruby 3.3.12`.
- PostgreSQL Windows binaries `17.11` were extracted locally. `initdb --no-locale --encoding=UTF8` succeeded using the workspace's Windows 8.3 short path because the accented workspace path failed initialization. The local `pemk` and `pemk_test` databases are UTF-8.
- PostgreSQL's `pg_ctl` could not create a restricted child process (`could not create restricted token: error code 87`). Starting `postgres.exe` directly in a foreground process worked. It listens only on `127.0.0.1:55432`.
- Bundler installed the server's five Gemfile dependencies (seven resolved gems): bcrypt `3.1.22`, bigdecimal `4.1.2`, minitest `5.27.0`, pg `1.6.3-x64-mingw-ucrt`, rake `13.4.2`, sequel `5.106.0` (plus default bundler). `bundle check` succeeded.

### Commands run and outcomes

Repository inspection and clones:

1. Read the complete workspace `AGENTS.md` and `README.md` before edits.
2. `git clone https://github.com/Maruno17/pokemon-essentials.git upstream/pokemon-essentials` — initial sandbox network attempt failed to connect to GitHub; approved network retry succeeded.
3. `git clone https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit.git upstream/pokemon-essentials-mmo-kit` — succeeded on the approved network retry.
4. `git -C upstream/pokemon-essentials rev-parse HEAD` — `8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b`.
5. `git -C upstream/pokemon-essentials describe --tags --always` — `v21.1-23-g8c5911e4`.
6. `git -C upstream/pokemon-essentials-mmo-kit rev-parse HEAD` — `9a24034bca241c095b81ea8069607f6cdfa6a57d`.
7. Read both READMEs, PEMK's `docs/GETTING-STARTED.md`, `docs/INSTALL-WINDOWS.md`, `Plugins/PEMK/README.md`, `server/README.md`, conversion audit, setup scripts, configuration, metadata, and both license files.

Documented WSL setup and native fallback:

8. `wsl --status` — failed with `Wsl/EnumerateDistros/Service/E_ACCESSDENIED`; Debian and documented WSL setup scripts could not run.
9. Downloaded RubyInstaller `3.3.12-1` portable archive, Ruby installer executable, PostgreSQL binaries `17.11`, and the 7-Zip standalone extractor into local `tools/runtime/downloads/`. Silent installer attempts returned exit code 5; the Ruby archive extracted successfully and runs from a project-local path.
10. Extracted PostgreSQL `17.11` binaries locally. `initdb --no-locale --encoding=UTF8` — succeeded after changing to the 8.3 ASCII path. `pg_ctl` start — failed with `could not create restricted token: error code 87`. Direct `postgres.exe -D <workspace short path>\tools\runtime\pgdata -p 55432 -h 127.0.0.1` — started; PostgreSQL logged that it was ready to accept connections.
11. Created local trust-auth `pemk` and `pemk_test` databases. `pg_isready -h 127.0.0.1 -p 55432` — ready. `psql` confirmed both databases and UTF-8 encoding.
12. In an isolated copy under `tools/runtime/pemk-workspace/`, ran `bundle lock --add-platform x64-mingw-ucrt` and `bundle install --jobs 4 --retry 3` — succeeded. `bundle check` — succeeded. Gem lockfile changes are only in that disposable local copy.
13. Ran the migration runner directly with Sequel against `pemk_test`, then `pemk` — both reported schema version `48`.
14. Started the PEMK server using local Ruby with `PEMK_BIND=127.0.0.1`, `PEMK_PORT=9998`, and `DATABASE_URL=postgres://postgres@127.0.0.1:55432/pemk`. It remained running as a local process (PID observed `10152`) and logged `reactor: listening on 127.0.0.1:9998`; startup also reported loading 69 world maps and battle data for 1,237 species/forms.
15. Opened two independent `TcpClient` sockets to `127.0.0.1:9998` — both TCP connects succeeded. This verifies the local listening socket only; it is **not** a PEMK client login, game session, or multiplayer behavior test.
16. Downloaded the v21.1 Essentials package from `https://luka-sj.com/essentials/resources/PE21` (68,765,976 bytes; page identifies it as v21.1). `tar -tf` listed `Game.exe`, `mkxp.json`, `Game.rxproj`, `Data/Map001.rxdata`, and `Data/MapInfos.rxdata`; `tar -xf ... -C tools/runtime/essentials-v21.1-base` extracted it successfully.
17. `robocopy upstream/pokemon-essentials/Data/Scripts tools/runtime/essentials-v21.1-base/Data/Scripts /E` — copied the checked-out Essentials scripts to the local test copy. Copied `Data/Scripts.rxdata` and `Data/messages_core.dat` from that checkout.
18. Copied `upstream/pokemon-essentials-mmo-kit/Plugins/PEMK/` and `game-mod/Plugins/ArenaDemo/` into the test copy's `Plugins/`, and copied the documented `PlayMMO-debug.bat` / `PlayMMO-guest.bat` launchers. Created local `mmo_config.txt` with only `host = 127.0.0.1` and `port = 9998`; no credentials are stored there.
19. Ran `ruby game-mod/tools/build_arena_map.rb tools/runtime/essentials-v21.1-base` — wrote `Data/Map100.rxdata` and registered map ID 100 in `Data/MapInfos.rxdata`, deriving the small map from Essentials' Battle Palace arena data. Reloaded the new map with the local Ruby Marshal inspector and confirmed its tile table and five map events.
20. The package page also instructs applying the v21.1 Hotfixes plugin. Its MediaFire download attempt did not finish, so that plugin has **not** been applied. The copied Essentials scripts are from the cloned upstream `master` commit above, not from the package archive.
21. Launched `Game.exe debug`. Its `mmo.log` reports the PEMK plugin loaded (`role=auto`, port 9998), connected to `127.0.0.1:9998`, showed the in-game auth flow, then logged offline mode and disconnection. The user confirmed the window opened, selected offline mode and New Game, and reported that both plugins loaded and game data compiled successfully (70 maps processed).
22. The user-reported first compile logged two PEMK auto-export errors because the client project lacked `server/data/`. Created a local directory junction from `tools/runtime/essentials-v21.1-base/server` to `tools/runtime/pemk-workspace/server`. On the user's subsequent debug launch, `mmo.log` confirmed `world.json regenerated` for 70 maps and `battle_data.json regenerated` for 1,237 species/forms. The fix is local-only and ignored by Git.
23. The user then chose offline mode and New Game but reported no visible progress. No `errorlog.txt` was produced; the client process remains active. Inspection of map 1 shows the intended long Professor Oak/character setup intro with many messages before its transfer to map 3 (Lappet Town). The in-game arena menu/battle have still not been confirmed.

Tests attempted:

- `prng_test.rb` — **passed:** 8 runs, 2,016 assertions, 0 failures/errors/skips.
- `wire_test.rb` — **passed:** 6 runs, 30 assertions, 0 failures/errors/skips.
- `auth_test.rb` against `pemk_test` — **failed by Ruby process crash** after two test dots. The crash is a segmentation fault in bcrypt `3.1.22` at `BCrypt::Engine.__bc_salt`; no passing auth result is claimed.
- The documented `bundle exec rake test` / Rake path did not complete; a direct Rake attempt crashed with `SIGSEGV`. A direct all-tests loader also exited with Windows access violation (`-1073741819`). The full PEMK suite is therefore **not passed**.
- `ruby -c game-mod/Plugins/ArenaDemo/001_ArenaDemo.rb` — **passed:** `Syntax OK`.
- `ruby -c game-mod/tools/build_arena_map.rb` — **passed:** `Syntax OK`.
- The user confirmed the game window opened, both plugins loaded, and game data compiled. The arena entry, movement, collisions, manager, trainer interaction, and battle have not yet been reported as tested.
- No two-client game test was run. The raw TCP socket test above does not authenticate clients.

### Integration result and blockers

- **Version compatibility:** documented v21.1 match; not a full client integration test.
- **PEMK server:** started successfully on native Windows with local PostgreSQL and loopback-only binding.
- **Client/server integration:** assembled into the private local test copy; the user launched the GUI and confirmed the PEMK plugin reached its authentication flow. Account creation is blocked by bcrypt on native Windows; offline New Game works according to the user's report. Game assets are kept ignored.
- **Two actual clients:** not tested. Two raw TCP sockets connected, but they did not authenticate or speak PEMK's client protocol.
- **Windows test blocker:** bcrypt's native extension segfaults during password hashing in the isolated Windows Ruby environment; the full Rake test path also crashed. Two non-auth unit tests passed.
- The local `mmo_config.txt` contains only loopback host/port settings. No account, token, or password has been created. PEMK's client default is local `127.0.0.1:9998`.

The server and private game package have been assembled locally; no manual copying/configuration is needed. `RPG Maker XP` is not installed, but the first test map is generated by script without the editor. The `Game.exe` play runtime is bundled in the downloaded package. The user confirmed GUI boot and offline New Game. Hotfix plugin download and export after the junction fix remain unverified.

## Task 2 — arena demo

The custom demo work is in `game-mod/Plugins/ArenaDemo/` and was started only after the integration attempt and its result were recorded.

- Added an Essentials v21.1 plugin with an `Arena Demo` pause-menu entry, entry/return map transfers, object manager, and sample trainer battle.
- Added `game-mod/tools/build_arena_map.rb`. It derives map ID 100 from the Essentials Battle Palace arena, adds an interactive manager and Youngster trainer, and places three object events with local Essentials graphics. It changes `.rxdata` files only in the private project where it is run.
- Added a per-save three-slot roster for boulder, rock, and tree objects. The manager toggles their fixed map slots; hidden slots become passable.
- Added a configurable sample team using Essentials `Pokemon` data and `TrainerBattle.start`.
- Both Ruby files pass syntax checks. Map generation and Marshal reload validation passed in the private local Essentials package.
- The user confirmed the game window opens, both plugins load, and game data compiles. The generated arena map/plugin are installed in the test copy. Arena transfer, movement/collisions, object toggles, trainer interaction, and battle are **not yet verified in-game**.
- PEMK does not synchronize custom object selection or arena ownership. Server bcrypt `3.1.22` crashes during account creation in this Windows Ruby environment; choose offline mode to test the local demo.

## Root project files

Project changes: `.gitignore`, `README.md`, `SETUP_STATUS.md`, `game-mod/README.md`, `game-mod/Plugins/ArenaDemo/{meta.txt,001_ArenaDemo.rb}`, and `game-mod/tools/build_arena_map.rb`. Upstream repositories remain under `upstream/`. Local runtime binaries, game assets, generated map, database, downloaded archives, and test workspace are under ignored `tools/runtime/` and should remain untracked.

## Follow-up: intro and keyboard report (2026-10-26)

The user reported that a fresh offline New Game entered the long Essentials intro with no skip, and that Esc/other keys seemed ineffective after reaching the home/outside area. Added a startup choice to the map generator: **Skip intro and start Arena Demo** or **Play the full intro**. The quick-start path gives the player a level 10 Pikachu, records Lappet Town (map 3, 25,6) as the return point, and transfers to arena map 100. The original intro command list is retained under the second choice. The generator checks for its own `ArenaDemo.quick_start` marker to avoid duplicate patching when rerun.

Documented expected controls: arrow keys move; Z/Enter/Space interact/confirm; X/Esc cancel/back; the pause menu is on Essentials' Action binding (`Input::ACTION`, RGSS A, commonly Shift), not the cancel key. The separate Essentials Output Window is a log; keyboard focus must be on the actual gameplay window. This is a likely explanation for Esc not opening the menu, but the user's report of no movement is not yet resolved or reproduced.

Changed `README.md`, `game-mod/README.md`, `game-mod/Plugins/ArenaDemo/001_ArenaDemo.rb`, and `game-mod/tools/build_arena_map.rb`. Validation is currently blocked: the ignored local runtime directory is not readable/available in this execution context, and no system Ruby is on PATH. An attempted invocation of `tools/runtime/ruby/bin/ruby.exe` returned “not recognized”; therefore the changed Ruby has **not** been syntax-checked here, and map generation, a relaunch, keyboard input, and gameplay are **not tested**. The setup still requires restarting the local client after running the generator for the startup option to appear. No successful skip or playable arena result is claimed.

## Follow-up: arena map rendered mostly black (2026-10-26)

The user successfully ran the map generator and confirmed it wrote `Map100.rxdata` and registered map 100. They launched the client, chose the intro skip, and reported that the player could not move on a mostly dark map. Their screenshot shows only a small patch of tiled room/map data, with the player and one object over a large empty area. This is consistent with the earlier generator copying a map intended as a Battle Palace battle backdrop rather than a complete walkable exploration map.

The first attempted correction changed Map100 to map 3, but this was based on a mistaken map ID. Upstream `PBS/map_metadata.txt` identifies map 2 as Lappet Town and map 3 as the Player's House, matching the interior tiles visible in the user's screenshot. The corrected generator now derives Map100 from map 2 and reads the house exit's transfer command to determine the town spawn, writing it to `Data/ArenaDemoStart.txt`. The plugin reads this generated spawn file. These latest changes have **not yet been generated in the private runtime or tested in the game**.

Added root `Launch-ArenaDemo.bat` so the user can double-click one launcher: it copies the current ArenaDemo plugin, rebuilds the local map, and calls the existing debug launcher. The updated generator and plugin pass Ruby syntax checks. The corrected map-2 build and in-game movement have not yet been verified. PEMK's `server/data` and loopback connection errors remain separate from the offline map test.
