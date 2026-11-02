# Setup and implementation status

## Device visuals, sliding and directional Tesla — 2026-11-02 (0.23.0, local)

Supersedes device behavior below: conveyors and magnetic attraction freeze the
walking pattern; conveyors hide the active follower throughout the chain,
restore its prior visibility afterwards and relay an empty follower descriptor
to peers while hidden. Blindness expires after 60 seconds using monotonic time;
room exit/editor reset still clears it early.

Tesla coils now always block. Each new coil records a chosen D/L/R/U adjacent
spark tile, separately rendered and blocked until its linked button is pressed.
The button changes to its pressed sprite. Spark tiles are reserved against
furniture placement and ground editing. Server movement and Strength validation
respect live sparks; shared disabled state, late entry and empty-room reset
remain authoritative. Protocol is now **14**, requiring both clients/server.
Legacy undirected coils choose the first free adjacent tile.

Installed Gary Shaw's CC-BY-SA conveyor animation, CC0 rune, generated antenna,
coil and two button states, plus outlined white web and animated spark. HGSS
pad screenshot and sound are installed only into the ignored private runtime;
no proprietary HGSS binary was added to source. Sources, credits, exact prompts
and installation are in docs/ARENA_DEVICE_ASSETS.md. Added asset installation
to normal Prepare and native device checks.

Executed: arena_devices_rules_test.rb **4 runs/49 assertions**;
arena_devices_server_test.rb **16/360**; arena_relief_test.rb **20/960**;
arena_relief_server_test.rb **7/118**. All passed. Native --devices:
**31 checks passed**, including actual catalog, slides with frozen walk pattern,
continuous follower hiding/restoration, timers, teleport, pair inventory and
solid coil after button. Screenshots inspected in tools/runtime; no save read
or written. No manual two-GUI-client playtest or full battle executed.
Restart Play-Arena.bat; no commit/push performed.

Additional verification: remote_follower_test.rb **3 runs/9 assertions**, passed.
The PowerShell installer could not be validated end-to-end in this tool session:
PowerShell produced no output and the isolated invocation exceeded 30 seconds.
The native runner independently copied all graphics/audio and successfully
rendered/played the new resources. Normal Prepare is wired to the installer;
its download branch remains unexecuted (sources were downloaded separately).

## National roster capped at 650 and furniture picker crash — 2026-11-02 (0.23.0, local)

User clarified the game stops at generations 1-5 plus Dark Lugia. The previous
0.22.0 national ordering retained later generations after entry 650; this is
superseded. `PokedexRoster.supported?` now filters `each_species` to the 649
native Gen 1-5 base species plus DARKLUGIA last. National lists and seen/owned
counts cap at 650, including when saved flags exist for Chespin/Calyrex. Native
post-Gen-5 data remains internal for engine/save compatibility. Added a native
evolution-check wrapper that excludes unsupported targets while preserving
supported evolution checks. Existing expedition generation already limits
wild species to generations 1-5.

The reported picker crash was a lexical constant lookup: `DeviceCatalogArt`
referenced unqualified `DeviceArt`. It now calls `ArenaDemo::DeviceArt`.
Previous probes covered world rendering but not this preview path. Added
coverage through material_catalog_preview for all six device entries and a
real choose_material_catalog opening/selection/cancel cycle. Captured and
visually inspected tools/runtime/devices-native-catalog.png.

Executed `tools/test-native-dark-lugia.py`: **61 native checks passed**,
including exactly 650 entries in the actual national menu, completion counters
at 650 despite later-generation records, 249/649/650 numbering and supported/
excluded evolutions. `--devices`: **26 native checks passed**, including actual
picker UI and all existing movement/pair/button/darkness checks. No player save
was read/written, no complete battle or manual two-client session was executed.
Installed current 0.23.0 scripts/cache locally. README, game-mod README and
device docs updated. Restart Play-Arena.bat to load; protocol remains 13.
No commit/push. Existing unrelated user files remain untouched.

## Interactive arena devices and Dark Lugia national 650 — 2026-11-02 (0.22.0, local)

Read README/status and existing editor, placement wire, CS overlay, native
movement/darkness and Pokedex sources. Added standalone shared rules plus
096/097/098 sidecars for six devices, native pixel artwork and Bag previews.
Conveyors push along the chosen direction; magnets pull along one selected
half-line, stopping beside the antenna or at an intervening collision. Native
movement/passability is retained, including void/relief limits. Webs multiply
native step duration by four. Teleporter kits use two atomic endpoints, a
rotation/shrink/arrival animation, an arrival latch and follower transfer.
Tesla kits contain a blocking spark and a red floor button; deactivation is
server-authoritative and shared with late entrants, resetting only when the
main room is empty. The blindness rune uses the native no-Flash radius and
fade profile, with a circle centered on the player; it clears on room exit or
offline Custom mode. Pair removal returns one kit; cancelled drafts reconcile
kit quantities instead of counting their two component records separately.

Placement wire remains four primitives. Direction is encoded in registered
item variants; pair links follow preserved placement order. Protocol raised
from 12 to **13** for floor traversal, exact paired teleport exceptions and
shared disabled-coil state. Client handshake, readiness probe and test fixtures
updated. Both clients and server must restart with this code. No live server
or user account was reset.

Dark Lugia is now independent species `DARKLUGIA`, inserted after Genesect in
each_species/Pokedex order: national **650**, with native Lugia still **249**.
The installed base has 898 species, so the later generations remain in the
database and move one position later in this custom national order. The legacy
LUGIA_1 registry entry is removed; party/PC instances migrate in place, keeping
nickname/item/HP/experience/owner/manual moves. Legacy remembered Lugia forms
are cleared so entry 249 displays normal Lugia. Native Lugia metrics/cry are
retained. Layout-8 importer makes independent-species graphic aliases, while
094 reuses the recolored GIFs. Species data registers even without optional
art, allowing saves/received Pokemon to load; missing art falls back to Lugia.

Executed targeted tests, all passing:
- arena_devices_rules_test.rb: 3 runs / 29 assertions.
- arena_devices_server_test.rb: 15 runs / 348 assertions (includes existing
  field-state checks through the shared harness/inherited tests).
- arena_relief_server_test.rb: 7 / 118.
- arena_relief_test.rb: 20 / 960.
- dark_lugia_assets_test.rb: 4 / 63.
- debug_party_test.rb: 6 / 29.
- field_transfer_test.rb: 3 / 17.
Total executed: **58 test runs / 1,564 assertions**, no failures/errors/skips.

`tools/test-native-dark-lugia.py`: **55 native checks passed**, including actual
Pokedex 650, independent species, cry, missing-art data registration, party/PC
migration and GIF/follower/Pokedex rendering. `--devices`: **24 native checks
passed**, covering real movement/collisions/void, quarter-speed traversal,
teleport latch and active follower transfer, Tesla button/collision, atomic
pair placement/removal/cancellation and native darkness cleanup. Screenshots
of all device art and the centered darkness mask inspected. The native probes
use disposable in-memory profiles and do not read/write player saves. Server
tests use actual PEMK TCP/reactor behavior with injected authentication, not a
manual two-window or two-computer session. No complete battle was played.

Intermediate failures were resolved: Following EX aliases captured the new
update_move wrapper and caused recursion, fixed by deferring hook installation
until plugins finish loading; the native database initially assigned new
species 899, fixed by the explicit custom national order; the first storage
fixture inserted a legacy Pokemon after the one-time scan, corrected to
simulate the initial loaded-storage state. The initial native darkness mask
centered on the window rather than the player; the inspected final mask tracks
the player at the actual runtime size.

Teleport audio: user explicitly chose to keep the installed `Anim/Teleport`
sound; this is the final behavior. No external audio is required or bundled.
Earlier research consulted the Warp panel reference, ENLS HGSS album, The
Sounds Resource and a public HGSS content-pack file index. The attempted asset
lookup failed Python certificate verification and was stopped at the user's
direction; no audio file was installed. Details in docs/ARENA_DEVICES.md.

Installed updated scripts and layout-8 aliases in the private local runtime;
no commit or push. Manual use: close/relaunch Play-Arena.bat; use Custom mode
Meubles, choose direction, or select two endpoints for a lot. Save normally
after Dark Lugia migration. Restart the host server and update both PCs before
testing protocol-13 multiplayer. Original PNG and all generated assets remain
ignored under local runtime; unrelated handoff document/PowerPoint preserved.

## v9.1 publication snapshot — 2026-11-01

Release includes Strength contact pushing/interpolation, complete trainer
preview frames, animated Gen 1-5 battlers and supported alternate forms, local
XD001 artwork/importer and Dark/Flying custom learnset, plus the one-time
six-member level-100 debug party migration. Arena Demo version 0.21.4; network
protocol unchanged. External images, private runtime, saves and unrelated
presentation are excluded. XD001 requires the original local sheet per PC.

Final targeted checks: debug party 6/29; XD001 importer 4/59; battler scale 2/5;
field-state server 6/152; field transfer 3/17. Total **21 tests / 262 assertions**,
all passed. Latest XD001 native run: 48 checks passed without player save I/O.
Additional full alternate-form fixture run (`tools/test-native-battlers.py`)
timed out after 180 seconds following plugin loading; no native assertion
results were produced, so this final extended run is not counted as passed.
Its process was terminated and temporary junctions detached by the runner.
Commit message requested: `v9.1`; destination: `origin/main`.

## Dark Lugia Dark/Flying typing and custom learnset — local follow-up

User requested Dark/Flying and the proposed dark-themed level-up list without
Dark Void. Updated `095_DarkLugia.rb`: Astonish/Leer/Whirlwind/Dragon Rush (1),
Mist (9), Taunt (18), Nasty Plot (27), Dark Pulse (36), Recover (45), Aeroblast
(54), Shadow Ball (63), Dream Eater (81), Oblivion Wing (90). No move at level
72 and no Dark Void. Normal Lugia retains its Psychic/Flying typing and native
learnset; XD001 still inherits Lugia's stats/abilities.

Level-100 gifts and existing party XD001 receive Aeroblast / Dark Pulse /
Nasty Plot / Oblivion Wing once. Lower-level instances reset to the form's
native level-up moves. The per-Pokemon saved marker preserves future manual
move choices; stored instances migrate when moved into the party. No automatic
save or healing is performed by this conversion. Save normally after relaunch.

Ruby syntax passed. `tools/test-native-dark-lugia.py`: **48 native checks
passed**, covering all requested move IDs, type/form separation, level-36
learning, level-100 moves, conversion of an existing instance without healing,
Marshal persistence of the one-time marker and preservation of manual choices.
Existing GIF, follower and Pokédex checks also passed. Installed current plugin
in the private runtime and refreshed its compiled plugin cache. No player save
was read/written by the test; no complete battle or multiplayer test for this
change. README and game-mod README updated. No commit/push.

## Dark Lugia complete GIF animation and uncut wings — local

User chose normal Lugia's animation recolored with Dark Lugia's palette. Import
layout 7 changes GIF palette bytes only: all 60 front / 120 back frames, timing,
transparency and disposal remain unchanged. Source hashes match the pinned pack.
094 prefers these local GIFs; preparation installs base GIFs before the importer.
Static back crop now starts at x=128 and uses a 208x208 canvas to keep the entire
left wing. All eight follower crops now contain their full connected silhouettes.
The source sheet remains the icon/Pokedex/follower art. All assets stay ignored.

4 importer tests / 59 assertions passed, including exact wing silhouette areas
and unchanged GIF bytes outside palettes. Isolated native run: 42 checks passed
for frame counts, changed GIF pixels, battle sizes, follower and Pokedex. Both
local runtime and fixture assets regenerated. No player save or shared cache
modified by the test. No commit or push.

## XD001 party icon and coherent back view — local follow-up

Importer layout 5 removes the icon's one-pixel margin and scales both poses
at 2x (the source silhouettes are 31/32 pixels wide, fitting 62/64 pixels exactly,
like native Lugia). The two back drawings have different framing: one close-up
and one full wing/body view. Back animation now uses only the full-body drawing
with a two-pixel vertical hover; silhouette, scale and framing stay identical.
No wing-flap interpolation is claimed for this two-frame idle animation.
Regenerated local game and fixture assets. Importer tests: 3 runs / 44 assertions
passed, including exact doubled icon pixel area and back-frame pixel identity
after translation. The isolated native run also passed 42 checks, including
actual changed back-pose pixels, follower/Pokedex compatibility and battle sizes.
README updated. No commit/push.

## Dark Lugia animation and battle sprite scale — local

Dark Lugia importer layout 4 fixes frame-dependent integer scaling: both party
icon poses use 1x, all follower poses use 2x. Follower frames now hold A,A,B,B
instead of A,B,A,B, halving the wing-cycle frequency with native follower timing.
The local source's three front/two back combat poses produce native animated
PNG strips (front four frames at 0.2s, back two frames at 0.4s), both at fixed 2x.
094 resolves these for XD001 without substituting ordinary Lugia artwork.

Battle GIFs now retain 2x source pixels, growing their transparent canvas while
preserving the native bottom padding and anchor. Removed the old width/height
clamp responsible for undersized back views and Origin Giratina. Local XD001
PNG strips are already enlarged and use 1x playback. Regenerated actual local
runtime and isolated fixture images from the verified source sheet.

Ruby checks: dark_lugia_assets_test.rb 3 runs / 42 assertions and
animated_battler_scale_test.rb 2 runs / 5 assertions passed. Pixel checks cover
constant icon scaling and duplicated follower holds. Isolated native XD001 probe
passed 42 checks, including actual front/back pose pixel changes, full-size
canvases, follower/Pokedex compatibility, and native GIF scale for
Lugia/Zekrom/White Kyurem backs and Origin Giratina front/back.
No player save or shared plugin cache
was modified by the isolated native runner. No commit or push.

## Requested level-100 party — local

038_DebugParty migration version 2 now creates White Kyurem (form 1), the local
Dark Lugia via its existing factory, Zekrom, native Lugia (form 0), Origin
Giratina (form 1 with GRISEOUSORB), and Mew with CUT/SURF/ROCKSMASH/STRENGTH.
All six are level 100 and healed. Runs once per profile on a safe map frame and
saves through the existing migration path. Existing original-party backup is
retained; a version-indexed backup also preserves the immediately previous party.
Save failure rolls back party, migration marker and backups. Missing Dark Lugia
assets abort before changing party or saving. No player save edited directly.

Portable Ruby game-mod/test/debug_party_test.rb: 6 runs / 29 assertions, all
passed, covering exact order/forms/levels/CS, one-time application, prior-version
upgrade, save rollback and missing Dark Lugia. No native game launch for this
change. Relaunch Play-Arena.bat to install and apply. No commit or push.

## Dark Lugia XD001 local form — 2026-11-01 (Arena Demo 0.21.4)

Used the user-provided `xd001.png` (SHA-256
`c86232a4d11d709d2606d8ad15e258253402496c6964d6383963a9715e670864`). The
source artwork is credited to ShadowGate31 at the supplied DeviantArt page;
the page's redistribution terms could not be verified, so neither the source
sheet nor generated images are tracked or published. Added a hash-checked,
stdlib-only Ruby PNG importer and a local preparation hook. It writes form-1
front/back, two icon frames and a four-direction two-frame follower under the
private game Graphics folders. The root source image is ignored by Git.

`095_DarkLugia.rb` registers `LUGIA_1` as the cosmetic form **Dark Lugia
(XD001)** of native Lugia #249. Native types, stats, moves and abilities are
inherited. Pause menu offers Pokédex view and an optional level-100 gift; the
gift is not added automatically. This does not implement XD Shadow status or
purification.

Validation: `game-mod/test/dark_lugia_assets_test.rb` — 3 runs / 20 assertions,
all passed, including SHA refusal, missing-optional-source handling, expected
PNG dimensions and idempotent reuse. Imported the corrected layout to the
private v21.1 runtime and ran `tools/test-native-dark-lugia.py`: **23 native
checks passed** for form registration/data inheritance, native battler images,
follower resolver and Pokédex selector/entry. The disposable probe did not read
or write a player save. No complete battle, manual GUI input, multiplayer test,
or redistribution permission was established. Restart through `Play-Arena.bat`
after preparation. No commit or push was made.

## Trainer menu frames and animated battlers — 2026-11-01 (local)

Added isolated sidecars 093_ArenaTrainerCatalogFrames.rb and
094_AnimatedBattlers.rb. No changes to 009 trainer profiles, 036/039 field-move
work, metadata version or network protocol. README/status notes from the other
session preserved. Only shared preparation change: two lines invoking the new
installer after existing move-effect installation.

Trainer previews now crop the true 4-column frame (48x48 for Biker/Cueball),
then fit it inside 44x48; ordinary 32x48 trainers retain the complete pose.
Battlers use native animated GIF playback with the original canvas/baseline.
Gen 1-5 front/back, shiny and available female variants are installed separately;
unsupported forms/generations, shadow/egg/alterBitmap cases keep native art.

Inspected Essentials AnimatedBitmap, species-file and BattlerSprite sources;
researched APS/DBK v21.1 but avoided their broader battle overhaul dependency.
Read PokeAPI/sprites README and LICENCE.txt, pinned commit
1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64. Images are explicitly proprietary
despite the repository's CC0 statement; images remain ignored local runtime
assets. Metadata-only manifest pins 2,980 SHA-256 values and species mappings.
See docs/ANIMATED_BATTLERS.md for source links and scope.

Executed git clone --depth 1 --filter=blob:none --sparse, then sparse-checkout
of sprites/pokemon/versions/generation-v/black-white/animated. Initial sandbox
network failure was retried with authorized network access. Installer tested
with -SourceRoot in tools/runtime/battler-assets: all 2,980 files verified;
second invocation detected the installed pack. Moved one disposable fixture
sprite aside, ran -Repair without SourceRoot: HTTP retrieval and checksum passed.
Verified four sets of 649 primary sprites plus 384 female variants. Installed
the verified pack in the local game via additive robocopy (exit 1 = copied).

Ran tools/test-native-battlers.py against an isolated Essentials/mkxp-z copy:
25 native checks passed, including actual changed pixel frames, original canvas
geometry, complete trainer frames and static fallbacks. Earlier sandbox native
launch timed out; authorized native launch succeeded. The first native test
before asset installation failed its expected availability check; final run
with installed assets passed. Ruby syntax check of 094 passed. No complete
battle or two-client session executed for this change. No commit or push.

Manual use: close and relaunch Play-Arena.bat to copy the new plugins and compile
them through normal preparation. On another PC the first preparation downloads
the pack automatically once these code changes are published. For interrupted
or missing art use the documented -Repair command. Existing sprites are retained.

## Animated Gen 1–5 forms — local

Expanded the pinned animation manifest from 2,980 to 3,316 verified GIF destinations. The form table covers 84 Essentials form numbers over 23 species, including Kyurem White/Black and glowing battle forms 3/4, Origin Giratina, other listed BW2-era forms, and normal/back/shiny variants. Pixel inspection confirmed every added GIF has multiple frames. Pichu Spiky-eared has no animated GIF in this source and keeps native art. Later forms, Shadow Pokémon, eggs and Spinda spots retain native rendering.

The extended native probe exposed and fixed a missing map in its fixture. Its current run still exceeds 180 seconds before producing results, so native validation of every alternative form is not claimed. The earlier 25-check native probe passed for ordinary battlers. `094_AnimatedBattlers.rb` passes Ruby syntax validation. Images remain local, outside Git. No commit or push.

## Strength activation, contact pushing and shared interpolation — 2026-11-01 (0.21.3)

Read README/status. User requests Action only to activate Strength, followed by
contact pushes, with actual visible movement rather than shared-state snapping.
Retained all trainer edits and the unrelated untracked PowerPoint. Protocol 12
and server validation unchanged; plugin version 0.21.3. Local, not yet published.

036_FieldObstacles binds Strength boulders to Action while strengthUsed is false,
then enables native trigger 2 on all boulders after confirmation. Refresh retains
contact mode while Strength is active; solo room resets restore Action. Cut and
Rock Smash remain Action-only. A shared request temporarily disables contact
until its authoritative state is applied (or timeout), avoiding continuously
restarting an interpreter that would starve the safe-frame state updater.
Local shared-rule validation also stops pushes into blocked terrain without
repeated network requests; the server still validates every submitted move.

039_FieldMoveEffects.push applies accepted shared boulder coordinates using
native event real-coordinate interpolation and Strength push audio. The player
is locked for the animation and unlocked in ensure, preserving an existing lock.
Animation stops if the active map/scene changes. Live accepted state changes
animate on either client; snapshots, resets, rejections and duplicates do not.
Solo pushing retains the actual Essentials Interpreter#pbPushThisEvent motion.
Canonical layout, inventory and shared temporary-reset rules remain unchanged.

Executed portable Ruby game-mod/test/field_state_server_test.rb: 6 tests /
152 assertions passed, and field_transfer_test.rb: 3 / 17 passed.
Executed C:/msys64/mingw64/bin/python.exe tools/test-native-visuals.py: final
3,082 native checks passed, auditing 740 moves. Added native checks cover:
no contact prompt before activation; contact enabled after confirmation even
against blocked terrain; persistent contact mode on refresh; Action restored
on reset; intermediate real coordinates during solo and received shared pushes;
player unlock; duplicate suppression; actual Game_Player contact triggering the
real event interpreter and a second request without Action; no repeated request
while awaiting approval; the second accepted push; no request for blocked ground.
Existing follower, ice, object-reset, NPC and battle playback checks passed.

Initial shared-animation fixture failed because advancing Graphics let the real
offline pump close its simulated visit. Stubbed only that pump during injected
room frames and restored it afterward. A blocked-ground fixture initially used
the editor, which correctly refuses changes while visiting; configured that
fixture's snapshot records directly. Both fixture failures were corrected before
the final successful run. No user's save read or written; no manual two-window
multiplayer session claimed. Probe removed; sources/meta and compiled cache
installed locally at 0.21.3 by the final runner. README and field-move docs updated.
Close the game and restart Play-Arena.bat locally; other PCs require publication
and client updates. No commit/push performed for this task.

## Release v9.0.2 preparation — 2026-11-01

User requested another push after editing the trainer catalogue. Inspected the
009_ArenaCustomMode.rb diff: new PICNICKER profiles, revised PAINTER names and
one indentation change. User edits preserved exactly; Ruby syntax check passed.
This release also includes the preceding, fully tested local CS/follower and
ice presence corrections (details/results below), plugin version 0.21.2,
protocol 12. README now documents v9.0.2 and normal both-client update steps.
Historical "local/unpublished" statements below describe the pre-release state.
No native test repeated for the trainer-data/publication step. The existing
3,069 native checks and 12 targeted tests cover the unchanged gameplay fixes.
Commit name selected as v9.0.2 after v9.0.1; normal push targets origin/main.
The unrelated title_screen_design.pptx and all private runtime files remain
outside the commit. Commit ID/push result are reported after Git completes.

## Multiplayer CS follower displacement and ice snapback — 2026-11-01 (0.21.2)

Read README/status; retained the user's published trainer additions (v9.0.1)
and the untracked PowerPoint. No upstream or server authority changes. Protocol
remains 12; plugin version now 0.21.2. Changes remain local/unpublished.

Reproduced the CS failure in the native engine with Following Pokemon EX active:
its pbHiddenMoveAnimation choreography moves the player backwards and turns
towards the follower. The subsequent arena_field_request therefore fails the
server's facing-adjacency check and returns the existing "state updated" notice.
036_FieldObstacles.with_native_access temporarily sets EX's documented-in-code
no_follower_field_move flag. The native Pokemon banner and object effects remain;
only the displacing follower choreography is skipped during the arena action.
Both that flag and badge-access scope restore previous values in ensure, also
on nested actions or exceptions. No dependency on the flag if EX is absent.

Ice already respects the void collision locally. However, Essentials skips
on_player_step_taken during forced movement, which is the callback PEMK uses
for position emission. Its final nonadjacent position is rejected by the arena
server and corrected to the pre-slide tile. New 040_ArenaStepPresence emits from
the lower-level on_step_taken for the local player on map 100. Existing PEMK
auth/visit gating and position deduplication remain in effect. Every ice tile
now reaches the unchanged adjacent-step authority; no teleport exception or
relaxed collision rule is added. Other maps/NPCs/offline sessions are unaffected.

Executed portable Ruby 3.3.12:
- game-mod/test/field_state_server_test.rb: 6 tests / 152 assertions passed,
  using real reactor/wire codec and two TCP peers; rapid ice path, edge/void
  rejection at the last ice tile, subsequent adjacent Cut and peer relay added.
- game-mod/test/field_transfer_test.rb: 3 / 17 passed, including nested/exception
  restoration of follower animation and temporary badge-access flags.
- game-mod/test/forced_step_presence_test.rb: 3 / 5 passed using actual upstream
  Presence build/key/emit code; all intermediate steps, no duplicate normal
  step frames, and offline/NPC/other-map gating checked.
- C:/msys64/mingw64/bin/python.exe tools/test-native-visuals.py: 3,069 native
  checks passed, including active-follower Cut/Rock Smash, original facing
  coordinates, object effects, real movement over five ice tiles to void,
  clearing forced movement, all intermediate emitted positions, and return
  along the ice in the opposite direction. Existing shared-state presentation,
  NPC/follower checks, 740-move audit and battle playback also passed.

The initial active-follower regression failed before the production correction,
confirming the displacement. Initial ice fixtures froze movement with in_menu
and were also blocked by the visit emission gate; corrected the fixture to run
real miniupdates with movement enabled and bypass only auth/visit emission in
the disposable process, retaining actual Presence build/key/emit behavior.
TCP authority is tested separately; no manual two-window visit is claimed.
No user save read or written. Probe removed and compiled local cache restored.
README and animation/field docs describe the pending patch and restart steps.
No commit/push performed for these changes. Both clients need the correction
after distribution; the server protocol/validation do not need to change.

## Release v9 — 2026-11-01

User requested README/status consolidation, commit named exactly `v9`, and push.
Release branch: main; plugin version: 0.21.1; visit protocol: 12. Includes all
pending gameplay fixes, shared temporary CS state, debug Mew, animation pack
installer/OpenGL settings, French wording and the furniture catalogue/selector.
README now identifies v9 as current, removes a duplicated CS section and gives
both-PC update/server restart instructions. Earlier local/unpublished notes below
describe the state at the time of each task, before this release preparation.

Only project source, tests, scripts and documentation belong in this release.
The unrelated title_screen_design.pptx remains untracked. Private runtime data,
downloaded assets, local saves and credentials remain excluded. Existing native
and network results are recorded in the corresponding task entries below;
no new manual two-window multiplayer session is claimed for the publication.
Publication uses `git commit -m v9` followed by a normal push of main, without
rewriting history. The actual commit ID and push result are reported to the user
after Git completes.

Release checks rerun successfully with portable Ruby: furniture_catalog_test.rb
(26 tests / 1,200 assertions), battle_animation_install_test.rb (2 / 16), and
french_battle_wording_test.rb (98 checks), expedition_world_test.rb (12 / 1,709).
All 35 changed/added Ruby files pass syntax checks; staged diff whitespace check
passes. No native test repeated for this
documentation/publication step; the latest 3,061-check result below still applies.

## Field prompts, Action-only Strength and object effects — 2026-11-01 (0.21.1)

Read README/status and retained existing uncommitted work. No dependency change;
visit protocol remains 12. New 092_FrenchFieldWording overrides the exact native
message keys for Cut/Rock Smash/Strength before interpolation. Reference checked:
https://github.com/abcboy101/poke-corpus/blob/main/corpus/HeartGoldSoulSilver/fr_msg.txt
(text file 211). French game text is preserved with modern accent/spacing and
line wrapping; Strength's combined game dialogue is split to match Essentials.
The reference corpus was downloaded only to ignored tools/runtime using curl;
the sandbox network attempt failed, the approved retry succeeded.

036_FieldObstacles binds all three objects to trigger 0 (Action). Touching a
Strength boulder cannot start its interpreter; Enter still starts it. New
039_FieldMoveEffects replaces native direction-only disappearance with a white
slash and separating tree halves, or six rotating rock fragments, over 0.5 s.
Fragments reuse the existing character frame; sounds remain Cut/Rock Smash.
Sprites, owned bitmaps and viewport are disposed in ensure; event transparency
is restored before native erase/shared overlay application. These are locally
implemented effects inspired by the games, not imported official animations.
Live authoritative shared destruction plays on each client in the main room;
initial snapshots, late entry, rejected actions and duplicate state do not
replay it. Reentrant network processing is blocked during the effect.

Executed with portable Ruby 3.3.12:
- french_battle_wording_test.rb --disable-gems: 98 checks passed using the actual
  Essentials lookup and installed French messages, including all three prompts.
- field_transfer_test.rb: 2 runs / 8 assertions passed.
- field_state_server_test.rb: 5 runs / 132 assertions passed (two real TCP peers).
  An initial --disable-gems invocation of the transfer test could not load
  minitest; rerunning with normal gem loading passed.
- C:/msys64/mingw64/bin/python.exe tools/test-native-visuals.py: 3,061 native
  checks passed, including Enter/touch behavior, real multi-frame Cut/Rock Smash
  rendering, shared destruction/duplicate suppression and existing battle tests.
  Native multiplayer presentation uses injected authoritative frames; no two
  GUI clients were manually exercised. No player save read or written.

The native runner installed the current plugin sources and rebuilt the local
compiled cache; probe removed afterward. README, status, plugin version and
focused tests updated. No commit or publication performed. Restart the game
to use the installed changes; remote Arena Update users need publication first.

## Temporary shared field objects and debug Mew — 2026-11-01 (0.21.0)

Read README/status. Supersedes 0.20.0's permanent furniture removal/refund and
offline-only CS behavior. Retained other existing work, including concurrent
French wording and furniture catalogue files; did not stage or commit them.
Essentials/PEMK/Following EX dependencies unchanged. Visit protocol is now **12**;
client/server/ping and relevant fixture handshakes updated together.

New pure 000_FieldStateRules encodes a bounded temporary overlay keyed by the
canonical furniture slot: nil means hidden; [x,y] means a moved boulder.
036_FieldObstacles never edits arena_demo_placements or credits the Bag after
Cut/Rock Smash. Native animations/Strength movement are retained. Refresh draws
canonical placements plus the overlay and removes stale native slot metadata.
Solo transfers out of map 100 clear the overlay. Entering custom mode clears it
before the draft is made, even on cancellation. Loaded maps also start fresh;
the saved plan and inventory stay unchanged. Non-arena Strength state is spared.

Server-owned room field state/revision is independent of the canonical frozen
visit snapshot. Requests require room membership, map 100, facing adjacency,
correct object/move, current integer revision and valid target geometry. Pushes
reject hazards, void, stairs/walls, reserved cells, objects and either player.
Accepted states go to both members, including the hub; late join snapshots and
room entry also carry current state. Movement collision authority uses the live
overlay. State resets only when no connected member remains in map 100, including
a last guest disconnect. A quick out/back emits both presence frames immediately
to avoid losing the empty-room transition to heartbeat throttling. A revision
prevents simultaneous/stale pushes applying twice. Client processing waits for
safe overworld frames, ignores old/foreign-room packets, and clears pending
actions when a newer coalesced authoritative state supersedes their revision.

New 038_DebugParty is an explicit one-time debug migration for every local
profile/new game using this release. On the first safe map frame it builds one
native Mew, level 100, with exactly CUT/SURF/ROCKSMASH/STRENGTH, replaces the party
and saves normally. Previous party objects are retained in
PokemonGlobalMetadata#arena_debug_party_backup; version marker is 1. Failed saves
restore the previous party and metadata. Menus/battles/transfers/interpreters
delay migration; the follower refreshes after successful migration. No repeat
reset after captures or map changes. Native probe environments disable automatic
migration saving and explicitly verify it in memory. No user's real save was
read or written during this task: actual profiles migrate on next game launch.

Executed portable Ruby commands, all passing:
- game-mod/test/field_state_server_test.rb: 5 runs / 132 assertions. Real upstream
  reactor/wire codec and two local TCP clients: Cut/Smash/Strength relay, live
  collisions, one-player return retaining changes, both leaving resetting,
  hub/late arrivals, stale/concurrent requests, malformed/mismatched actions,
  player blocking and last-occupant disconnect. Fixture auth, no accounts/DB.
- arena_visits_server_test.rb: 6 runs / 98 assertions.
- arena_relief_server_test.rb: 7 runs / 118 assertions.
- debug_party_test.rb: 4 runs / 19 assertions (exact party/moves, backup,
  per-profile one-time behavior, rollback and automatic safe-frame saving).
- field_transfer_test.rb: 2 runs / 8 assertions (rapid shared roundtrip emits
  both maps without local reset; solo exit clears state).
- arena_relief_test.rb: 20 runs / 960 assertions.
Total **44 tests / 1,335 assertions**; no failures/errors.

Executed C:/msys64/mingw64/bin/python.exe tools/test-native-visuals.py:
**3,058 native checks passed**. Actual CS animations/collisions, no item refund
or canonical edits, hidden objects surviving refresh, original coordinates in
save metadata, cancellation of actual custom editor resetting everything, and
real Scene_Map exit/re-entry restoring objects. Client shared-state tests inject
server-shaped frames into the real FieldObstacles module and render hidden/
moved/reset objects; request serialization, delayed movement until approval,
coalesced revisions, fresh-cache arrivals and old/foreign messages checked.
Native Mew level/party size/four moves/backup/idempotence checked without saving.
All 740 move animations and prior follower/NPC playback checks also passed.
First new native fixture waited in the editor; fixed it to simulate Back and
Cancel. Next transfer fixture lacked PokemonEncounters; initialized it before
the real transfers. These were fixture failures, corrected before final success.

Executed tools/test-native-relief.py --picker: **417 checks passed** (native
Surf, editor, relief, disposable disk save/reload and actual transfers).
Probes/disposable save removed, local scripts/cache restored to 0.21.0. Reports
remain ignored under tools/runtime. This is not a manual two-window GUI session.

Changed this task: new 000_FieldStateRules and 038_DebugParty, 036 overlay/
lifecycle, 005 network dispatch/state, arena_visits.rb authority/occupancy,
protocol checks/fixtures, metadata, new server/transfer/migration tests, native
visual probe, README and animation/field-move docs. git diff --check passes.
No new assets, credentials or user save committed. Code remains local/unpublished;
Arena Update on other PCs fetches GitHub main and needs these changes published.

Manual use after distribution: close both games, update both clients and restart
the host for protocol 12, then launch Play-Arena.bat. Each profile receives the
one-Mew debug team once on its first safe frame. Retest a visit with both players
entering/leaving the main room; no manual GUI multiplayer result is claimed.

## Complete battle animations, OpenGL and field obstacles — 2026-11-01 (0.20.0)

Read README/status first. Retained preceding 0.19.3/0.19.4 changes and unrelated
concurrent French wording work (090_FrenchBattleWording, its tests/docs/audit).
No user save, trainer roster, upstream checkout or visit protocol change (11).

General animation investigation: the installed base had only 211 direct player
move mappings for 740 moves. A successful generic fallback is not proof of a
dedicated animation. Located the author's Gen 9 Move Animation Project, explicitly
compatible with Essentials 20.1/21.1, with installation instructions and credits:
https://eeveeexpo.com/resources/1480/ . No battle-engine plugin was required.
Downloaded the linked public Drive archive locally (53,537,466 bytes), SHA256
931691C2E0B4B7817AA891AAA6653FEBDD7C7D0870DC657DAD331F16752AF24B.
The first request returned Drive's HTML confirmation; followed its UUID form,
verified the ZIP/hash and inspected archive entries. The ZIP contains animation
data, graphics and SE, no plugin/license/readme file. Credits and personal-use
limits are recorded in docs/ANIMATIONS_AND_FIELD_MOVES.md. Third-party resources
remain ignored/private; no blanket redistribution permission is assumed.

Added install-battle-animations.ps1, hooked into Prepare-Clients, and the Ruby
install_battle_animation_data.rb helper. Executed archive extraction and the
helper against the local game: 1,532 contiguous pack records appended, preserving
original IDs and unique custom animations; named single-frame placeholders
suppressed; move2anim.dat rebuilt. Asset conflicts and original data backed up.
Field/follower Data/Animations.rxdata was not replaced. Installed coverage is
**738/740 dedicated animations**; SECRETPOWER/NATUREPOWER delegate to other move
effects. The 035 fallbacks now defer to dedicated pack entries. New 037 seeds
nil transition state, addressing the author's documented v21.1 fade issue via
an extension rather than a core patch. Repeat installation was executed and
reported already installed without duplicating data.

GPU error: Microsoft identifies 0x887A0006 as DXGI_ERROR_DEVICE_HUNG:
https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-error .
Verified renderer=2 selects OpenGL in the exact official mkxp-z 37a04d1 config:
https://github.com/mkxp-z/mkxp-z/blob/37a04d14413454551a7b6aadbb4e93e67168accb/mkxp.json .
install-client-runtime.ps1 now persists renderer=2 and enableBlitting=false.
Applied the same settings to the private local mkxp.json, then exercised actual
battle playback under that configuration. This avoids the reported D3D11 path;
the original device hang was not reproduced. No driver, registry or TDR edits.
Some direct PowerShell script invocations stalled before output and were stopped;
download/extraction/helper installation and local config write were executed
separately with approved commands. PowerShell installer syntax checks passed;
a clean-PC end-to-end preparation through its wrapper is not claimed.

New 036_FieldObstacles binds the three placed furniture types to native-named
event scripts. Cut and Rock Smash use native checks/messages/field animations,
erase the obstacle, remove its placement and return the owned item to the Bag.
Strength uses native activation and Interpreter#pbPushThisEvent, updates the
saved placement only after an actual move, and rejects hazards, stairs, void,
occupants and relief edges. Trigger 2 supports both Action and collision entry.
Slot rebinding clears stale native erased/moved records to protect the next
occupant. The three HMs are supplied once on first interaction; a party Pokémon
must know the move. Story badge exemption is scoped to these arena interactions;
no DEBUG switch or global badge/progression changes. Standard game saving stores
the updated placement/inventory. Online/visit mutations are explicitly refused
because protocol 11 does not relay these actions. Village scenery and natural
relief are not converted into the editor's three interactive furniture types.

Commands/checks executed:
- Portable Ruby game-mod/test/battle_animation_install_test.rb: 2 runs / 16
  assertions, passing (backups, asset conflicts, contiguous variants, empty
  placeholders, idempotence, preservation of later edits and field animations).
- Portable Ruby game-mod/test/arena_relief_test.rb: 20 runs / 960 assertions,
  passing. Ruby syntax/PowerShell parser checks passed for the new scripts.
- C:/msys64/mingw64/bin/python.exe tools/test-native-visuals.py: **3,041 checks
  passed**. Audits all 740
  moves on both sides and exercises native field moves, cancellation, missing
  capability, inventory return, lava/relief blocks, push persistence, online
  refusal and dedicated animation precedence. Actual native battle playback:
  Mud-Slap and Fusion Bolt on both sides, boosted Fusion Bolt, Memento,
  Swords Dance, Earthquake, Surf and Flamethrower. All passed under OpenGL.
- tools/test-native-relief.py --picker: **417 checks passed**, including actual
  Surf, native collisions/picker, disposable disk save/reload and transfers.

Native probes use memory-only state or a disposable save, never a user's save.
Runners restore the plugin cache and remove temporary probe files. Reports,
pack, assets and backups stay ignored under tools/runtime. Changed this task:
036/037, furniture labels in 009, metadata, native visual tests, new installer
helper/test/PowerShell wrapper, preparation hook, runtime config template,
README, new animation/field-move docs and this status. No commit/push requested.

Manual steps: close all game clients and launch Play-Arena.bat. First preparation
on another PC needs Internet to fetch the verified animation pack. Teach the
provided HMs to compatible party Pokémon, then interact with placed obstacles
offline. Retest the combat that produced the GPU hang; no long-session or
second-PC GPU stability certification or new manual two-client test is claimed.

## Surf corners, idle NPCs and move effects — 2026-11-01 (0.19.4)

Read README/status and retained the uncommitted 0.19.3 work from the preceding
task. Essentials 21.1, PEMK and Following Pokemon EX 2.5.1 unchanged; visit
protocol remains 11. No user saves, trainer profiles or upstream files changed.

Surf root cause: EX's follow_leader detects a can_surf terrain change and calls
change_sprite directly even while active? is false. The earlier appearance
guard alone was insufficient. 011 now installs a guard on the actual sprite
writer after EX loads, at map setup and frame updates. Surf clears both live
event and follower-data graphic names; dismount and user toggle stay native.

NPC root cause: generated pages used frame 1, a walking pose in Essentials'
four-frame charsets. build_arena_map.rb writes frame 0. New 034_StaticNpcIdle
normalizes stationary human pages on project maps (also expedition guides)
before Game_Event construction, including older installed templates. Placed
trainers in 009 reset current/original patterns to 0 and stepping-on-the-spot
to false. Walking animations and turning remain available.

User examples: MUDSLAP (Coup de Boue), FUSIONBOLT (Éclair Croix). Native audit
found 311 animation records, mappings for 211 player and 18 opponent moves,
and no dedicated mapping for either reported move. Native fallbacks previously
selected TACKLE / THUNDERPUNCH. New 035_BattleAnimationFallbacks selects local
SANDATTACK dust / THUNDERBOLT electricity, checking candidate frames and image.
Future dedicated Move/OppMove entries retain priority, including native phase
selection. No new artwork/download, combat mechanics or global option change.

Files changed this follow-up: 009, 011, new 034/035, meta.txt, map builder,
new native_visual_boot_probe.rb, tools/test-native-visuals.py, README/status.
Unrelated title_screen_design.pptx left untouched. No commit/push requested.

Executed portable Ruby:
- game-mod/test/arena_relief_test.rb: 20 runs / 960 assertions, passing.
- game-mod/test/following_ownership_test.rb: 4 runs / 12 assertions, passing.
- game-mod/test/remote_follower_test.rb: 3 runs / 9 assertions, passing.
- Ruby -c on 011, 034, 035 and build_arena_map.rb: all Syntax OK.
Total focused Ruby suite: 27 tests / 981 assertions.

Executed C:/msys64/mingw64/bin/python.exe tools/test-native-visuals.py:
**1,960 native checks passed**, with 740 moves resolved on both sides,
including available bitmaps and preservation of all authored mappings. Actual
pbAnimation playback ran for both reported moves on both sides. Native tests
also verify map 100/101/102 NPC idle/turn/refresh, placed trainer idle after a
completed scripted step/editor rebuild, actual EX water-to-land follow_leader
in 4 directions while Surf remains active, event/data graphics hidden after
direct and queued refresh, and follower restoration on dismount.

Executed tools/test-native-relief.py --picker: **417 native checks passed**,
including real Surf entry/exit, save/reload, collisions, picker and actual
village/arena transfers. Both runners removed temporary probes; compiled local
cache restored to 38 Arena Demo scripts, version 0.19.4. Reports remain ignored
under tools/runtime/native-visual-probe.log and native-material-picker-probe.log.
No user's save read or written; visual probe uses memory only, relief probe
uses a disposable save. Early visual fixture failures exposed Game_Event's
non-public step_anime field and a pending EX forced route; corrected the field
access and cleared that transient route before exercising follow_leader.

Manual steps: close the old game and relaunch Play-Arena.bat. No new manual
playthrough, review of every move's appearance or two-client session claimed.

## Surf follower and expedition arrivals — 2026-11-01 (0.19.3)

Read README and setup history before changes. Existing Essentials 21.1, PEMK
and Following Pokemon EX 2.5.1 integration retained; no upstream checkout,
dependency, credentials, user trainer catalogue or visit protocol change (11).

Added an early, uniquely named following_pkmn_appear guard: all followers hide
while surfing, including the sole Water/Flying party member. Native EX Surf
entry/exit refreshes and the user's follower toggle remain responsible for
recall/restoration. The multiplayer descriptor is empty while surfing too.
The guard must have its own key because EX loads after Arena Demo and would
overwrite a replacement registered under EX's :surfing key.

Sector crossings previously retained the lateral entry lane at depth one,
although the destination's generated path can bend immediately after its edge.
Arrival now uses the nearest interior cell in the center-connected component,
excluding cliff/water/lava and scenery. This also handles old saved layouts
without regenerating geography. Loading on an obstacle, scenery or isolated
dry patch uses the same recovery. SafeMapTransfer now settles movement before
and after expedition transfers, as already done for village/arena transfers.

Changed 011_ArenaFollowingIntegration.rb, 016_ExpeditionWorld.rb,
032_ArenaTravelSafety.rb, meta.txt, expedition_world_test.rb,
native_relief_boot_probe.rb, README and this report.

Executed with tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe:
- game-mod/test/expedition_world_test.rb: 12 runs / 1,709 assertions, passing.
  Covers all 3 entry lanes / 4 directions in snow, volcano, canyon and crystal,
  plus saved blocked/isolated/occupied positions and unchanged saved geography.
- game-mod/test/following_ownership_test.rb: 4 runs / 12 assertions, passing.
- game-mod/test/remote_follower_test.rb: 3 runs / 9 assertions, passing.
- game-mod/test/player_controls_test.rb: 10 runs / 35 assertions, passing.
- Ruby syntax checks for all three changed gameplay scripts: passing.
- git diff --check: passing.
Total: 29 tests / 1,765 assertions. An initial --disable-gems test invocation
could not load minitest; tests were rerun normally. A new recovery fixture
initially compared state before lazy encounter initialization; fixed the fixture
to initialize encounters before taking its geography snapshot, then reran the
complete expedition suite successfully.

Native verification uses C:/msys64/mingw64/bin/python.exe
tools/test-native-relief.py --picker and a disposable save. Sandbox initially
denied writing the installed plugin; escalated retry installed the scripts.
Early native attempts exposed a missing map scene in the test fixture (timeout
in EX movement waits, then missing spriteset for recall animation) and the
handler-key loading issue above. The fixture now creates an actual Scene_Map
and spritesets for the Surf entry/exit sequence.

Final native run passed **417 checks** (exit 0), including sole-party Squirtle
hidden with an empty sprite/remote descriptor during actual Surf, restored on
the bank, and a manually disabled follower staying disabled. Also covers
native collisions, disk save/reload, picker and real village/arena transfers.
After the Surf checks the fixture leaves its follower disabled for later
scene-less probes; an intermediate run had exposed that fixture isolation gap.
The runner removed its probe/disposable save and restored the 36-script cache
with installed Arena Demo 0.19.3. Report remains ignored at
tools/runtime/native-material-picker-probe.log. Expedition entry coverage above
is Ruby integration testing; no manual walk through all wilderness biomes is
claimed. No real user's save was loaded or written by the native probe.

Manual steps: close the current game and relaunch Play-Arena.bat. Existing
expeditions are supported; a saved blocked position is recovered on loading.
No new manual playthrough or two-window multiplayer session is claimed.

## Livraison v8.4 — 2026-10-30

User requested README/status update, commit message v8.4 and push to origin/main.
Game source release consolidates all changes since v8.3: updater v6.2.7 WMI
check fix and v6.2.8 automatic French preparation, missing-title repair,
arena-native Surf without story progression, raised liquids and animated
south cascades, seamless joins/corners, adjacent/wall-mediated style inheritance,
safe map transfers and held-Enter text acceleration. Plugin remains 0.19.2,
visit protocol 11. User trainer profiles are preserved. Upstream dependencies
unchanged. README now distinguishes game source v8.4 from installer v6.2.8.

Latest already-executed focused checks (documented in entries below):
- arena_relief_test.rb: 20 runs / 960 assertions, passing.
- player_controls_test.rb: 10 runs / 35 assertions, passing.
- arena_relief_server_test.rb: 7 runs / 118 assertions, passing.
- arena_visits_server_test.rb: 6 runs / 98 assertions, passing.
- tools/test-native-relief.py --picker: 411 native checks, passing.
- tools/test-updater.ps1, test-french-install.ps1 -Network,
  test-title-install.ps1 and French compiler path checks: passing.
43 Ruby tests / 1,211 assertions total. These checks were executed during the
preceding implementation turns; not rerun for this documentation-only release
commit. Release validation: reviewed current metadata/worktree/history and
git diff --check. No new manual two-client visit or second-PC playtest claimed.

This commit changes README and status only; implementation commits are already
on main. Excludes unrelated title_screen_design.pptx, local runtime assets,
captures, saves and credentials. No new GitHub installer release created.
Delivery: use existing ArenaLab-Update.exe v6.2.8 on both PCs (fetches main),
restart Play-Arena.bat and updated host for protocol 11.

## Inheritance through walls and held-Enter dialogue — 2026-10-30 (0.19.2)

New extensions now resolve an adjacent south-wall cell to the summit north
of that wall, so a cell one wall away also inherits the existing theme/base
floor. A platform placed directly over a wall takes that wall owner's style
before considering differently styled side neighbors. Other neighbor majority
and tie rules remain. No room format, movement or protocol change (still 11).

Added 033_ArenaDialogueSpeed.rb using Window_AdvancedTextPokemon#updateInternal.
Holding physical Return temporarily divides positive character delay by four;
ensure restores original delay each update. Native wait timers, explicit
pauses, Input trigger edges and choice confirmation remain unchanged. Releasing
Enter restores the configured pace immediately; no global text-speed setting
is modified and zero-delay text remains instant.

Executed portable Ruby game-mod/test/arena_relief_test.rb: 20 runs / 960
assertions, passing (wall-distance inheritance and owner-style priority).
Executed portable Ruby game-mod/test/player_controls_test.rb: 10 runs / 35
assertions, passing. Executed C:/msys64/mingw64/bin/python.exe
tools/test-native-relief.py --picker: 411 checks passed. Actual native message
window verifies held Enter reveals more letters, preserves configured speed,
slows down on release, and stays at an explicit pause. Native editor verifies
wall-distance and direct wall placement inheritance. Input held state simulated
only in the disposable probe. No manual multi-client session claimed.
Probe/disposable save cleaned; local plugin/cache restored to 0.19.2 (36 scripts).
git diff --check passed. Changed 027, new 033, metadata, focused editor/native
tests, README/material docs and this status. No user trainer/save changes.
Existing v6.2.8 updater fetches these source changes; relaunch Play-Arena.bat
on both PCs. No new EXE, server protocol or upstream dependency required.

## Liquid joins, all-material cascades and inherited extensions — 2026-10-30 (0.19.1)

Screenshot showed internal rims between raised water cells and rounded notches
where a lower summit abutted a south wall. Render joins used foot-movement
checks, which reject liquid source cells. Rendering now tests height/stair
geometry independently of movement permissions. Corner masks include adjacent
wall faces without turning them into traversable summits. Animated cached
variants preserve those masks. Reproduced screenshot geometry in native probe
and visually inspected liquid-joins.png: continuous water strip and solid
plateau/wall contact. Existing outer rounded silhouettes retained.

Shared CASCADE_GROUNDS covers water, lava, marsh_water, toxic and mud. Painting
these on existing summits retains height/style; all five draw animated south
flows with material-colored highlights/foam, including mud. Mud surface remains
solid/walkable; lava/toxic remain blocked and water/marsh require Surf. Flows
remain impassable walls. Quicksand unchanged. Client/server snapshot validation
supports these raised materials; protocol bumped to 11 in readiness and tests.

New platform/stair cells touching existing elevated cells inherit their theme
and theme's base floor. They do not copy liquid painted on a neighbor. Majority
style wins; ties use N/E/S/W order. Isolated cells and edits to existing raised
cells retain prior behavior. User trainer profiles unchanged.

Executed portable Ruby:
- game-mod/test/arena_relief_test.rb: 19 runs / 949 assertions, passing.
- game-mod/test/arena_relief_server_test.rb: 7 runs / 118 assertions, passing.
- game-mod/test/arena_visits_server_test.rb: 6 runs / 98 assertions, passing.
Includes inherited theme/dry extension, all-material raised snapshot decode and
actual TCP snapshot relay. No new manual two-GUI-client session claimed.
Executed C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker:
405 native checks passed. Covers internal seam pixels, filled wall-adjacent
corner, all five raised surfaces and distinct downward-flow frames, plus prior
Surf/save/transfer coverage. Visually inspected native-material-picker-probe-
liquid-joins.png and -all-cascades.png. Only disposable save used; probe removed
and local plugin/cache restored as 0.19.1 (35 scripts).

Changed 000/005/009/027/031/meta, server/ping, focused Ruby/native tests,
readiness fixtures, README/material docs and status. Upstream/dependencies
unchanged. Existing updater v6.2.8 fetches main: update both PCs, relaunch
Play-Arena.bat and restart host for protocol 11. No separate EXE needed.

## Title repair, arena Surf, raised water and safe transfers — 2026-10-30 (0.19.0)

User reported absent custom title on second PC, silent Surf interaction for
both players, water flattening platforms and intermittent void traversal on
return to foyer. Updater's root copy list omitted title_screen.png. Added it;
launcher also downloads the tracked image at d5ba6b9 when absent, verifies
SHA256 810E7FAC8CE653F2CC938E7528F0B38D61F69D12C8D53909B2430D58C0571CF1
and installs it. Older updater EXEs can fetch these launcher scripts and repair
their missing root image. No private music or game assets downloaded.

Native pbSurf silently refuses missing story badge/move prerequisites. Arena
shore interaction now offers Surf without that progression, using native
pbStartSurfing, vehicle, follower restriction and dismount. Party Surf check
is similarly scoped to arena; outside maps retain native restrictions. No
debug mode, added badges or changed party needed.

Painting water on a summit now retains height and wall style. Geometry/render
rules preserve raised water, and an exposed south wall below water draws an
animated cascade over the retained rock face. Interior water has no cascade.
The wall remains impassable even when surfing. Other liquid restrictions and
occupant protection remain. Shared server validation accepts raised water;
visit protocol 10 in client/server/ping/test fixtures rejects outdated peers.
Snapshot/disk round trips retain height. Previously flattened tiles cannot
have their former height inferred automatically.

Added 032_ArenaTravelSafety.rb around native Scene_Map transfers involving
maps 100/101/102. Clears forced routes/ice/waterfall state and old movement/jump
timers and origins, then synchronizes real position and terrain at landing.
This prevents the previous map's partial-step interpolation crossing the void.
User trainer catalogue in 009 is untouched (only water-height edit changed).

Executed portable Ruby:
- game-mod/test/arena_relief_test.rb: 17 runs / 907 assertions, passing.
- game-mod/test/arena_relief_server_test.rb: 6 runs / 107 assertions, passing.
- game-mod/test/arena_visits_server_test.rb: 6 runs / 98 assertions, passing.
Server checks use real sockets, not a new two-window visit.
Executed C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker:
393 checks passed, including actual shore Surf with DEBUG false and no move/
badges, elevated Surf, blocked cascade, save/reload, and two real Scene_Map
round trips with a deliberately unfinished old step and ice sliding. Visually
inspected native-material-picker-probe-waterfall.png. Only disposable save used;
probe removed, plugin cache restored (35 scripts), local plugin 0.19.0 installed.
Native fixture first used Game.load with a path instead of SaveData hash;
corrected that fixture. Extended runner deadline from 55 to 90 seconds for
the additional scenes, round trips and image exports after initial timeout.
Executed tools/test-title-install.ps1: real missing-art download/hash/install
in isolated fixture, then cached run with networking stubbed to fail; passed.
Executed tools/test-updater.ps1 and git diff --check: passed.

Changed README/material docs, 000/005/009/027/030/meta, new 032, visit server,
ping, focused tests, updater root copy list, title-preparation script, native
runner deadline, new title installer test and this status. Upstream versions
unchanged. No new manual launch on friend's PC or manual two-client visit.
Update source on both PCs, close/relaunch Play-Arena.bat and restart the host
for protocol 10. Existing v6.2.8 updater can fetch source and title repair.

## Automatic French data preparation, installer v6.2.8 — 2026-10-30

Second PC updated with v6.2.7 but launch failed because French data was absent.
Added install-french-data.ps1 called by Update, Setup and missing-data launcher
preparation. Downloads author YusukyDelta's Essentials v21.1 pack 1.2 directly
from Eevee Expo resource 1860 -> MediaFire. SHA256 pinned to
DC6857B594FB7AFE95DBAADE09BB1345116EE24056BE9831A5FBC32095F0A940.
Stages/extracts/compiles before installing Data/messages_french_core.dat.
Existing nonempty compiled data preserved; pack not redistributed in repo/EXEs.
Resource https://eeveeexpo.com/resources/1860/ inspected; author/version
confirmed. No separate licence file in downloaded pack.

Executed tools/test-french-install.ps1 -Network: real fresh download, checksum,
10,691 entries compiled in disposable folder, Ruby verification of Bulbizarre
and script messages, existing data hash preserved on repeat, modified archive
rejected. Fixture cleaned; no real save/game overwritten. Initial verification
fixture failed on Ruby -e Windows quoting; temporary Ruby file fixed it and
full rerun passed. tools/test-updater.ps1 also passed.

Publisher and README updated for v6.2.8. Build: package-deliverables.ps1;
publish: publish-installers.ps1 -Tag v6.2.8. Run the new Update on affected PC,
then Play-Arena.bat. No second-PC launch or full GUI update claimed here.
No changes to trainer catalogue or game rules.

## Installer publication v6.2.7 — 2026-10-30

User authorized publishing the fixed updater on GitHub as v6.2.7, with rebuilt
Setup. Publisher default/release notes distinguish installer v6.2.7 from game
source v8.3. Validation: tools/test-updater.ps1 and package-deliverables.ps1;
publication command: tools/publish-installers.ps1 -Tag v6.2.7. Setup is pinned
to the release source commit, updater fetches current main. Artifacts remain
in ignored dist. Release URL:
https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2.7 .
Earlier local hashes below describe the pre-publication build only. No changes
to game, trainers, assets or saves in this release. Affected PC must retry;
no successful end-to-end update claimed there.

## Updater failure after folder selection — 2026-10-30

User reports the generic Windows error after selecting an installation and
pressing OK in published v6.2.6 updater. Inspection finds the next operation
is Get-CimInstance Win32_Process; WMI/CIM failure is the probable cause,
not confirmed on the affected PC. Replaced this check with Get-Process plus
literal case-insensitive executable-path boundary matching. Unknown or
unreadable game paths block update with a close-game instruction. Added
step-specific failure dialogs and timestamped TEMP diagnostic files. Added
optional -InstallDirectory, disposed folder picker and explicit wrapper -STA.

Executed powershell -NoProfile -ExecutionPolicy Bypass -File tools/test-updater.ps1:
passed parser/live listing/empty list/literal case-insensitive paths/sibling
directory/unknown path/access-denied fixtures and absence of WMI dependency.
Executed powershell -NoProfile -ExecutionPolicy Bypass -File tools/package-deliverables.ps1:
both wrappers compiled; local dist/ArenaLab-Update.exe SHA256
2983C31BB20073F106853D21E2D9ABCF0A0961F9504D3CDE251F736FBE4A8BEE.
Setup remains pinned to d5ba6b9ac0e432e4d9f0948494e0956e14ef8d77.
No real installation overwritten, no full GUI/network update performed, and no
reproduction on the second PC. GitHub published updater not replaced here.
Transfer local dist/ArenaLab-Update.exe to the affected PC, close games, retry;
if still failing, read the new step and diagnostic log. Changes: updater,
wrapper, new focused PowerShell test, README and status. No game/save changes.

## Livraison v8.3 — 2026-10-30

Release combines interactive/animated floors (Arena Demo 0.18.1), native Surf,
quicksand trap/audio, Basalte nocturne, Ice cleanup and the user's expanded
trainer profiles in 009_ArenaCustomMode.rb. User trainer names, sprites and
teams preserved as supplied. Catalogue: 27 floors plus void, 11 platform styles.
Visit protocol 9 requires updating both clients and server together.
Upstream versions/dependencies unchanged.

Release checks executed with portable Ruby:
- ruby.exe -c game-mod/Plugins/ArenaDemo/009_ArenaCustomMode.rb: Syntax OK.
- ruby.exe game-mod/test/arena_relief_test.rb: 16 runs / 895 assertions, passing.
- ruby.exe game-mod/test/arena_relief_server_test.rb: 5 runs / 94 assertions, passing.
- ruby.exe game-mod/test/arena_visits_server_test.rb: 6 runs / 98 assertions, passing.

Earlier native floor probe passed 376 checks (below); it predates the latest
user trainer additions and was not rerun for release. No manual battles of
every new team or new two-GUI-client visit claimed. README/status updated.
Release includes plugin, server, ping helper, tests and material documentation.
Local assets, saves, generated captures and title_screen_design.pptx excluded.
User requested commit v8.3 and push to origin/main. Close game, update source
and restart Play-Arena.bat on both computers and restart the updated server.

## Animated liquids and subtle traps — 2026-10-30 (0.18.1)

Basalte nocturne replaces Dalles hantées (same saved type_ghost ID), with
matching staggered blue-black joints, without eyes or the large crack.
Online reference: https://sohaib9211.itch.io/dark-dungeon-stone-tileset ;
no external asset copied. Four liquids reuse native Sea deep animation frames
at individual timings, through cached shared bitmaps updated while stationary.
Quicksand uses the exact Sand texture darkened by 4%, without a spiral,
and plays native Player fall at volume 80/pitch 70. Central Ice crack removed.
Surf/collisions and visit protocol 9 unchanged.

Executed bundled Ruby game-mod/test/arena_relief_test.rb: 16 runs,
895 assertions, zero failures/errors/skips. Executed
C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker:
376 native checks passed, including distinct frames, live stationary animation,
exact sand darkening, crack removal, actual trap callback, Surf and disposable
save/load. Visually inspected generated repeated 3x3 floor atlas. Sound call
verified by unit fixture and executed natively; no listening assessment claimed.
No new manual two-client visit. No private save used by probe.

Sandbox writes/native install initially denied; rerun with approved escalation.
Ruby --disable-gems could not load minitest; reran without it. Initial unit
failures required a sound stub and updated renamed-label expectations; final
results above pass. Changed 000/009/027/028/030, new 031_ArenaLiquidAnimation,
metadata, focused tests, README, material catalogue and status. Native runner
installed 0.18.1 and restored compiled cache (34 scripts). Upstream/tool versions
unchanged. No commit/push. Close and restart Play-Arena.bat to load changes.

## Sols interactifs, liquides et futuristes — 2026-10-30 (0.18.0)

Added five ground IDs at the end of the stable catalogue: toxic, marsh_water,
steel_blue, holo_hex and quicksand. The catalogue now has 43 compatible IDs,
27 visible floors plus void, and the existing 11 visible platform styles.
Toxic waste is fluorescent yellow with bubbles and stays impassable even with
Surf. Marsh water is brown, distinct from solid mud. Water and marsh water now
use Essentials' native Surf terrain, shore interaction, party-menu gate,
entry/dismount and vehicle, preserving normal move/badge/follower conditions.
No standalone Surf system or terrain-tag number was added.

Removed Ice's dark tile border; all four bitmap edges share the continuous
blue fill while its Ice terrain/gliding remains native. Replaced type_ghost's
Ardoise mauve art/label with Dalles hantées: dark bevelled slabs, cracks and
small spectral lights, keeping the saved ID. Added steel-blue bevelled panels
and cyan holographic honeycomb, usable at ground level or on platform tops.
Online visual references inspected: Kenney Modular Space Kit, Kokoro
Reflections Cosmic Explorer and NASA ISS Panels. Links are recorded in
docs/ARENA_MATERIALS.md; no external asset downloaded or redistributed.

030_ArenaInteractiveFloors.rb hooks the native step callback. Quicksand spins
the player through four directions, lowers/fades their sprite for 1.25 seconds,
then returns them to map_start, resets vehicles/followers and restores controls
and sprite state. Ice sliding is cancelled. Transient state is protected by
ensure, including interrupted animation/access checks. No HP/money loss.
Quicksand cannot hold furniture, trainers, relief, stair access or fixed exits.

Visit protocol is now 9 in client, server, readiness/ping and socket fixtures.
Room presence checks surfable water against the reported movement mode; lava
and toxic remain blocked. The only nonadjacent in-map return permitted is
from a quicksand tile of the room snapshot to the reserved arena entrance.
Trap rotations and return emit presence. Layout/save IDs remain compatible;
both clients and server must be updated together. No new manual two-GUI-client
visit was executed; network checks below use actual TCP clients and PEMK's
reactor/codec with fixture authentication.

Executed portable Ruby (tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe):
- game-mod/test/arena_relief_test.rb: 16 runs / 894 assertions, passing.
- game-mod/test/arena_relief_server_test.rb: 5 runs / 94 assertions, passing.
- game-mod/test/arena_visits_server_test.rb: 6 runs / 98 assertions, passing.

Executed C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker:
369 native checks passed. Covers all 43 ground arts/collisions, native Surf
party gate, shore prompt, actual Surf entry/dismount, toxic immunity to Surf,
real timed quicksand step animation/return/input restoration, borderless Ice,
all five new floors on disk save/load, legacy snapshots, relief joins,
placement/removal and visual picker. Actual floor atlas, hologram picker and
three sink animation captures visually inspected. Probe boot failures were
test-fixture issues (uninitialized boot Scene_Map/encounters), corrected by
isolating the boot scene and initializing native encounters. Initial network
fixture accidentally used a reserved guide tile/stair approach and reopened
outside reception; corrected without weakening runtime validation.

Local plugin installed as 0.18.0, cache restored to 33 Arena Demo scripts;
temporary probe and disposable save removed. No private save read or written.
Changed 000/005/009/027/028/029, new 030, server, ping, metadata, focused tests
and documentation. Upstream versions/dependencies unchanged; no commit/push
for this change. Restart Play-Arena.bat on both clients and restart the server.

## Livraison v8.2 — 2026-10-30

Release groups the accumulated relief/editor/material changes: two logical
heights on one map, four stair directions with compatible joins, blocked edges,
rounded summit/wall corners, furniture/trainers on platforms, whole-platform
styling, flat visual material selector, 22 selectable floors plus void and 11
selectable styles. Includes latest bridge-like Wood, Industrial and Crystal
artwork, renamed labels and retired floor/style choices. Internal plugin version
is 0.17.4; visit protocol is 8. Legacy catalogue IDs remain readable.

README and material documentation describe final behaviour and restart steps.
Release includes plugin code, server validation/relay, shared test harness,
focused relief tests and native probe runner. Local runtime assets, generated
captures, saves and unrelated title_screen_design.pptx are excluded.

Verification executed with tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe:
- game-mod/test/arena_relief_test.rb: 14 runs / 820 assertions, passing (latest art change).
- game-mod/test/arena_relief_server_test.rb: 4 runs / 70 assertions, passing (release check).
- game-mod/test/arena_visits_server_test.rb: 6 runs / 98 assertions, passing (release check).

Native runner C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker:
315 checks passed during the latest art change; Wood picker visually inspected.
Socket tests exercise the actual PEMK reactor/codec with fixture authentication;
they do not establish a new manual two-GUI-client session. No upstream version,
dependency, credential or private save change is part of this release.

User requested commit message v8.2 and push to origin/main. Restart
Play-Arena.bat after closing the game; update both clients and server together
for protocol 8 visits. Previous integration evidence and manual limits follow.

## Planches de pont et simplification des sols — 2026-10-30 (0.17.4)

Removed Métal et grilles from the floor selector (22 floors plus void remain).
Renamed Sol habituel to Sol de base and Plaques rivetées to Plaques métalliques.
The full 38 ground keys, 12 historical style IDs and protocol 8 remain stable;
the industrial platform and old saved metal floors still render normally.

Wood no longer samples the gym parquet or draws staggered brick-like joints.
It samples clean timber grain from the installed Outside bridge tiles (bridge
terrain tag 15, first tile 1616), recomposing four continuous horizontal boards
with dark gaps and small nail heads. The Wood platform shares this deck and
has a darker front with posts, beams and diagonal timber braces. Art is composed
in memory; installed source atlases are untouched. Picker and map share art.

Executed bundled Ruby game-mod/test/arena_relief_test.rb: 14 runs, 820 assertions,
zero failures/errors/skips. Executed C:/msys64/mingw64/bin/python.exe
tools/test-native-relief.py --picker: 315 native relief checks passed, including
continuous opaque wood boards without parquet overlays, wall contrast, filtered
picker, collision/stair joins, placement/removal, disposable save/load and
legacy snapshot round trips. Visually inspected the actual Wood picker capture
at tools/runtime/native-material-picker-probe-picker-wood.png. No manual
two-client multiplayer session was executed for this visual/catalogue change.

Changed 000 catalogue, 028 art, meta.txt, focused editor/native tests and docs.
Local plugin installed as 0.17.4; probe and disposable save removed and compiled
cache restored to 32 Arena Demo scripts. No personal save read or written.
No new dependency, upstream version change, commit or push. Close the game and
relaunch Play-Arena.bat to load the updated plugin.

## Tatami, noms et refonte des murs/cristal — 2026-10-30 (0.17.3)

Removed the inherited parquet diagonal overlay from Tatami while retaining its
horizontal/vertical weave. Retained former monotype floors now display material
names: Améthyste, Quartz rose, Ardoise mauve, Obsidienne, Plaques rivetées, plus
Tatami. Saved ground keys and wire IDs remain unchanged. Arène de combat is
retired from style selection using RETIRED_STYLES/VISIBLE_STYLES, leaving **11
visible styles** and compatibility with the old twelfth style in saved layouts.

Industrial and Wood now have distinct vertical front faces: native texture
grain/seams turned upright, stronger shadow than the summit, upper/lower beams,
steel panels/bolts or timber posts. The collider, lip and rounded silhouette
are unchanged. Crystal floor/wall replace large diamond symbols with dark blue
native stone and three discreet cyan cores/halos per tile. An internal legacy
crystal source preserves Améthyste's existing base texture rather than changing
that floor as an unintended effect of the crystal redesign. Shared assets are
untouched; all rendering/palette composition is in memory.

Executed bundled Ruby arena_relief_test.rb: **14 tests / 818 assertions**, passing
including material labels, removed style and all legacy data round trips.
`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker`: **313
native checks passed**. Includes no parquet motif in Tatami, exactly three bright
cyan crystal cores and no large crystal motif, measured front/summit contrast
for Wood/Industrial, exclusion of Arena from the selector, actual picker choices
and cleanup, save/load, all original terrain/stair collisions and compact UI.
Real picker screenshots for Industrial, Wood and Crystal and the visible-floor
contact sheet were visually inspected. Private files remain under
tools/runtime/native-material-picker-probe-picker-{industrial,wood,crystal}.png.
Only disposable save data was used; temporary probe/save cleaned and cache
restored (32 Arena Demo scripts). No personal save read or written.

Changed catalogue labels/style visibility, 028 material art, 029 style picker,
metadata 0.17.3, focused editor/native tests and docs. Protocol 8, upstream
versions/dependencies and collision/save formats unchanged. Local test game
updated. Close the game and relaunch Play-Arena.bat. No commit/push/publication
or manual two-GUI-client visit claimed.

## Liste de sols simplifiée et suppression des motifs — 2026-10-30 (0.17.2)

User requested specific floor removals, Tatami naming, plain backgrounds for
five materials and direct access to the preview list. Changer le sol now calls
the visual picker immediately, with **23 floors plus void** and no family menu.
Hidden from that list: parquet, moss, court tiles, type_normal, type_fire,
type_water, type_ice, type_electric, type_grass, type_ground, type_flying,
type_bug, type_rock, type_dragon and type_fairy. Actual blocked water, sliding
ice and ordinary rock remain. type_fighting displays Tatami. Poison, Dark,
Ghost and Psychic labels no longer advertise removed motifs.

Removed the added mud rings and all foreground motifs from Poison/Dark/Ghost/
Psychic. For those four tinted floors, base-material motif overlays are also
disabled, so a crystal diamond or ruin/paving overlay does not remain behind
the removed type emblem. Native texture/color remain; preview and map share
the same renderer. Styles/placed objects/geometry/collisions unchanged.

Retirement affects the floor picker, not existing saved placements. The full
38-key catalogue and original wire IDs stay stable for old saves, snapshots
and platform-style dependencies. VISIBLE_FLOORS/RETIRED_FLOORS define visibility.
All 12 platform styles remain available. Protocol remains 8.

Executed bundled Ruby arena_relief_test.rb: **14 tests / 816 assertions**, all
passing. Includes direct one-step choice/cancel, exact retained/retired menu,
Tatami label, water and sliding ice, plus round trips for every legacy/new ID.
`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker` passes
**297 native checks**: no foreground draw calls for the five requested floors,
the flat list has only the retained entries, real picker selection/scrolling/
cancel in regular and compact windows, preview disposal, unchanged metadata
while browsing, save/load and legacy catalogue/render/collision coverage.
Poison, Dark and the retained-floor contact sheet were visually inspected;
private captures remain under tools/runtime/native-material-picker-probe*.
Only a disposable save was used; temporary probe/save removed and normal cache
restored (32 Arena Demo scripts). No personal save read/written.

Changed shared catalogue labels/visibility, 009 ground entry, 028 motif drawing,
029 filtered picker, metadata 0.17.2, editor/native tests and docs. No upstream
or shared asset changes, no commit/push/publication and no new two-GUI-client
visit claimed. Local game updated. Close the game and relaunch Play-Arena.bat.

## Sélecteur visuel des sols et plateformes — 2026-10-30 (0.17.1)

User requested previews while choosing floors, similar to furniture/trainers.
Added 029_ArenaMaterialPicker.rb using native Window_CommandPokemon windows:
each row has a thumbnail, and selection shows a larger repeated-floor sample
on the right. Platform styles show both summit and wall in that preview.
Descriptions distinguish ordinary, sliding and blocked floors, including
future-Surf water versus walkable type-water ceramic. Ground family menus stay;
the second-level lists and all platform styles use the visual picker.
Furniture/trainer pickers are unchanged. Enter confirms and X/Back cancels.

Uses the actual material rendering helpers and a bounded shared cache of 51
96x96 previews (38 floors, void, 12 styles). Interface windows, sample canvas,
backdrop and viewport are disposed in ensure; cached art survives closing so
it can still be used by the next picker. Browsing does not change metadata,
inventory or saves. Names wrap onto two lines, the list uses whole rows and
its outer width is fixed to avoid overlap with the right panel. The compact
512x384 view uses smaller list text; the regular 640x480 view keeps larger text.
No map/collision/save format or visit protocol change (still protocol 8).

Executed with bundled Ruby 3.3.12:
`game-mod/test/arena_relief_test.rb` passes **14 tests / 811 assertions**,
including ground/style selection and cancellation, complete preview metadata
and correct water/ice descriptions alongside existing material tests.

`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py --picker` passes
**306 native engine checks**: all 51 previews, actual picker confirmation after
scrolling, cancellation, window disposal and live cached artwork, unchanged
arena metadata while browsing, separate list/preview areas and complete rows,
plus compact 512x384 selection. Only confirm/cancel input is injected in those
UI checks; the real native picker/window/drawing methods run. Map frames are
disabled during the disposable UI portion. Screenshots of Dragon, Snow platform,
blocked Water and compact Dark floor were visually inspected:
tools/runtime/native-material-picker-probe-picker-{ground,style,water,compact}.png.
This includes the existing native material/collision/save-load regression.
It is not a manual keyboard/two-game-client playthrough.

The first native export failed with Errno::EINVAL while overwriting the old
floor-atlas diagnostic PNG, after its UI checks passed. The runner's --picker
option gives these tests separate report/capture paths; subsequent exports pass.
No personal assets/saves were removed to resolve that diagnostic write failure.
The temporary probe/save were cleaned, plugin cache restored (32 Arena Demo
scripts), and the local game contains 0.17.1.

Changed 009_ArenaCustomMode.rb and 027_ArenaRelief.rb selectors, new 029 picker,
plugin metadata, editor/native tests, native runner and docs. No upstream or
third-party resources changed. No commit/push or publication. Close the game
and relaunch Play-Arena.bat to use the previews; existing saves are compatible.

## Catalogue complet, monotypes et eau — 2026-10-30 (Arena Demo 0.17.0)

User requested all eight proposed platform themes, all proposed materials,
water reserved for future Surf, and original monotype floors. Added **38 floors
and 12 platform styles**, including the previous four. New platforms: Desert,
Forest, Ancient ruins, Crystal, Industrial, Wood, Swamp and Battle arena. Added
pavers, parquet, metal, packed dirt, moss, planks, mud, roots, ruins/crystal/court
tiles and one decorative mosaic for each of the 18 standard types. Dragon has
mineral scales, Dark obsidian crescents, Electric circuits, Psychic rings, etc.
Natural/material/monotype/hazard menu families keep floor selection navigable.
Full French catalogue and behavioral distinctions: docs/ARENA_MATERIALS.md.

Water is a dedicated `water` material, visible but blocked like lava/void.
It cannot receive placements, platforms or stair landings. Even an active
Essentials surfing flag cannot bypass this until Surf is implemented. The
saved identity is reserved for that future feature; no Surf travel was enabled.
Decorative type_water ceramic remains walkable; decorative type_ice is not
slippery. Monotype mosaics do not change battles, encounters or type bonuses.

ArenaMaterials in 000_ReliefRules.rb shares immutable IDs/catalogue with the
server. Protocol **8** uses bounded 10,000-byte alphanumeric grids (all previous
0-8 surface and 0-3 style codes retained) to accommodate the expanded catalogue.
Unknown surface/style bytes and hazard placements/reserved cells are rejected.
Every material/style round-trips through snapshots; existing saves retain their
string keys without manual conversion. Snapshot rooms remain transient.

028_ArenaMaterialsArt.rb reuses installed Essentials autotiles and Gyms/Factory
floor art with in-memory palettes, small mosaics and wall finishes. All 12 styles
have distinct summit and wall artwork, with existing rounded geometry/blocked
faces unchanged. No shared graphic was overwritten and no third-party assets
downloaded, bundled or committed. The first wood preview included a metal edge
from Gyms tile 425; inspection selected the plain native wood tile 426 instead.
Overview colors include new materials and monotype palettes.

Executed with bundled portable Ruby 3.3.12:

- arena_relief_test.rb: **13 tests / 798 assertions**, passing. Every floor and
  style round-trips, including letter codes; grouped styling, occupied summit
  painting, menu families/cancellation, water identity and walkable type-water
  ceramic, protected stairs/occupants, invalid IDs and Marshal persistence.
- arena_relief_server_test.rb: **4 / 70**, passing via actual PEMK wire/reactor
  and TCP peers with fixture authentication. Expanded mixed-surface snapshots,
  style B, water correction and reserved/occupied hazard refusal are covered.
- arena_visits_server_test.rb: **6 / 98**, passing with protocol-8 fixtures.
- save_recovery_audio_test.rb: **3 / 11**, passing.
- french_title_test.rb: all reported checks passing.

`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py`: **240 native checks
passed**. It exercises every
floor's artwork, editor paint and actual player collision, every platform tool,
native save/load and snapshot preservation, standing geometry and zoom. Water
remains blocked with surfing=true. It exports/visually verifies the 12-platform
contact sheet and all 38 floor samples, with an index, plus the real player frame.
Files remain ignored under tools/runtime/native-relief-probe{,-floors,-player}.*.
Only a disposable game/save is used. Probe/save removed and normal cache restored
(31 Arena Demo scripts). No personal save loaded/written. No new manual
two-GUI-client visit or publication is claimed.

Changed shared rules/catalogue, 009/027 editor/render integration, new 028 art,
visit client/server/readiness protocol, metadata 0.17.0, focused editor/network/
native tests, docs/ARENA_MATERIALS.md and README files. Upstream versions/licenses
and dependencies unchanged. Close the game and launch Play-Arena.bat; update
both clients and restart the server for protocol 8. No commit/push performed.

## Arrondis des murs, lave et style volcanique — 2026-10-30 (0.16.0)

Read project instructions/current status and inspected the user's close-up.
The previous summit alpha exposed a duplicate summit texture on layer 0,
masking the round-over; the wall cap also remained square. Raised cells now
keep the lower base field underneath the overlay, and the low-floor snow/ice
renderer skips raised cells. Matching 6-pixel outside alpha arcs continue into
both exposed wall ends, including the upper cap and lower corner. Connected
middle segments remain seamless and the existing blocked face footprint stays.

Added ground choices Lave (infranchissable) and Sol volcanique (walkable).
Lava uses the existing expedition lava palette on installed Sea deep native
artwork. It is visible while following void collision/placement rules, cannot
replace occupied/fixed/spawn cells or an active stair support/landing, and
cannot receive furniture/trainers or platforms. Painting lava, like void,
clears the cell's elevation/stair. Volcanic ground uses native Red cave floor
with a charcoal/red palette. Whole-platform style Volcanique paints the joined
summits and wall material while preserving placements and stair geometry.
Native sources are not overwritten; no assets downloaded or committed.

Visit protocol **7** adds surface codes 7 volcanic / 8 lava and style 3 volcano.
Shared validation treats lava as blocked for raised supports/landings; client
and server reject lava placements/reserved cells, and the authoritative presence
audit corrects attempts to enter it. Snapshot/Marshal round trips preserve both
new surfaces and the style. Update and restart both clients and server together.

Executed with bundled portable Ruby 3.3.12:

- arena_relief_test.rb: **11 tests / 576 assertions**, passing. Includes lava
  visibility/state, four approach directions, strict standing checks, protected
  occupants/guide/landing, replacing lava with volcanic ground, whole-volcano
  styling, snapshot and Marshal round trips.
- arena_relief_server_test.rb: **3 / 57**, passing. Actual PEMK reactor/wire/TCP
  with fixture authentication: lava movement correction, lava placement/spawn/
  landing refusal and volcanic style/surface relay.
- arena_visits_server_test.rb: **6 / 98**, passing with protocol-7 fixtures.
- save_recovery_audio_test.rb: **3 / 11**, passing.

`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py`: **94 native
checks passed**. Actual Game_Player cannot move into lava; volcanic ground is
walkable. Real frame pixels verify visible lava and underlying ground at the
rounded wall cap, in addition to summit painting, save/load, renderer zoom and
all stair orientations. Every style's wall ends are transparent at the outer
corners while connected middle wall pixels remain opaque. Comparison preview
(Herbe/Montagne/Neige/Volcanique, with lava below the volcanic wall) and actual
player frame were visually inspected under ignored tools/runtime. Probe/save
cleaned and normal plugin cache restored (30 Arena Demo scripts). No personal
save was read/written. No manual two-GUI-client visit or public push is claimed.

Changed shared rules, surface/editor/renderer plugin integration, relief art,
style metadata 0.16.0, server adapter/readiness protocol, native/editor/network
tests and docs. Local runtime updated. Close the game and launch Play-Arena.bat;
existing platforms repaint automatically, with no save conversion required.

## Coins arrondis, sols et styles de plateforme — 2026-10-30 (0.15.0)

User confirmed 0.14.2's direction and requested rounded corners, editable summit
floors and a whole-platform floor/wall style tool. Implemented small 6-pixel
outside arcs with native rim colors: standing centers/feet remain on the summit,
and the separate blocked wall footprint is unchanged. No resized cave corner
caps or large diagonal cut-outs were reintroduced.

The renderer now honors each raised cell's stored ground: plain, grass, desert,
rock, ice and new snow. Snow uses installed White path and ordinary walking;
ice retains the existing terrain-tag sliding. Painting individual floors leaves
the selected wall material intact. Existing saved ground choices become visible.

New editor category Style de plateforme entière selects Herbe/Montagne/Neige.
An iterative bounded flood fill visits only cardinally connected raised cells,
including stairs; disconnected/diagonal-only islands and ordinary ground stay
unchanged. It changes every selected cell's ground and platform_style in the
existing draft, retaining occupants, height and stairs. Cancel restores the
original draft/save; normal validation saves all fields. Grass uses native
Light grass over warm earth faces, Mountain uses Gravel and a grey palette of
the native rock family, Snow uses White path and the installed Caves snow family.
All modifications are in-memory composition; no source bitmap is overwritten.

Visit protocol **6** adds a 10,000-byte styles grid alongside surface and relief.
Shared pure validation rejects unknown codes, malformed grids and styles on low
cells. Server relays the frozen style snapshot; guest records retain both floor
and wall style without overwriting the guest's personal arena. Added snow surface
code 6. Clients/server/readiness CLI and their fixtures require protocol 6.
No upstream dependency/version/license changes or external art downloads.

Executed checks with bundled portable Ruby 3.3.12:

- arena_relief_test.rb: **10 tests / 547 assertions**, passing. Includes grouped
  style changes, stairs, occupied summit floor painting, diagonal island isolation,
  unchanged height/placement data, invalid selections, Marshal persistence and
  snapshot round trips with styles and mixed floors.
- arena_relief_server_test.rb: **2 / 40**, passing over actual PEMK wire/reactor
  and TCP peers with fixture authentication: snow surface/style relay, malformed
  styles rejection, authoritative wall/stair movement and visit closure.
- arena_visits_server_test.rb: **6 / 98**, passing with updated v6 fixtures.
- save_recovery_audio_test.rb: **3 / 11**, passing.
- french_title_test.rb: all reported checks pass.

`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py`: **81 native checks
passed** through mkxp-z and the real PluginManager, including whole-style tools,
draft isolation, individual grass painting while retaining snow walls, actual
Game.save/Game.load to a disposable path, renderer/zoom, all stair directions,
player movement before the face and a pixel check of the real frame's repainted
summit. Checks also compare distinct floor and wall colors for all three styles
and rounded corners that leave the standing center/foot position intact.
The comparison preview (left to right Herbe/Montagne/Neige) and real player frame
were visually inspected: tools/runtime/native-relief-probe.png and -player.png.
Reports/assets remain ignored. Temporary probe/save removed, normal plugin cache
restored (30 Arena Demo scripts). No personal save read/written.

Changed 000_ReliefRules.rb, 005_ArenaVisits.rb, 009_ArenaCustomMode.rb,
027_ArenaRelief.rb, metadata 0.15.0, server/arena_visits.rb, readiness CLI,
editor/network/native tests, fixture harness and README files. Local test game
updated. Close the game and relaunch Play-Arena.bat; no save conversion needed.
Update both computers and restart the server for visits. No commit/push, public
publication or new manual two-GUI-client visit is claimed. Scope remains one map
and two heights; touching raised cells form one group for the whole-style tool.

## Surface praticable et paroi séparées — 2026-10-30 (0.14.2)

The user's second screenshot showed that 0.14.1 still looked wrong: reduced
corner caps made artificial notches, and a playable cell contained the south
cliff face, letting the player's feet stand over the drop. Alpha/mask tests
alone did not verify that the visible summit matched the playable footprint.

Replaced that composition in 027_ArenaRelief.rb. Summit cells now contain full
32x32 native stone floor with thin, unscaled stone lips. Removed all resized
corner caps and diagonal holes. The full-size native south wall is drawn in
the lower cell, with a lip extending beyond the last standing position.
That derived wall cell is blocked from the summit, below and either side;
stairs replace it with their usable passage. Adjacent wall segments join at
native size. There is no character sprite offset or change to saved heights.

000_ReliefRules.rb and the server use the same derived wall footprint. New
construction cannot cover fixed/spawn cells, furniture/trainers or the player
with a wall; wall cells cannot receive placements. Native occupancy recovery
handles a saved player standing in a newly reserved wall cell. Client/server
visits now require protocol **5**, since the collision meaning has changed.
Update and restart the host/server and all clients together.

Executed editor tests: **9 / 515 assertions**, network relief **2 / 36** with
two real TCP peers and authoritative correction at the summit/ground face,
historical server visits **6 / 98**. Native probe passes **68 checks** and executes actual Game_Player
movement at the last summit row, strict occupancy and ground/side approaches,
all staircase directions, save/load, the actual TilemapRenderer and player
Sprite_Character. The new report includes a real Graphics.snap_to_bitmap
frame, not only tile composition: tools/runtime/native-relief-probe-player.png.
That frame and the stepped-shape composition were visually inspected. The
player's feet stay on the summit before the wall. The existing all-mask checks
now require full summit corners rather than alpha holes.

Commands: bundled ruby game-mod/test/{arena_relief_test,
arena_relief_server_test,arena_visits_server_test}.rb and
C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py.
Only a disposable game/save was used; temporary probe/save cleaned and plugin
cache restored. No personal save, shared asset or upstream engine was edited.
Updated local plugin 0.14.2, shared rules/server protocol/readiness CLI, editor
placement guard, regression tests and documentation. No commit/push and no
manual two-GUI-client visit claimed. Close the game and relaunch Play-Arena.bat;
existing platforms repaint without conversion. The case below a south edge is
now reserved for its wall; objects there can be removed with the editor.

## Coins des plateformes et libellés — 2026-10-30 (0.14.1)

User screenshot reproduced two defects in 0.14.0: the cave atlas has opaque
black outside cliff silhouettes, and the four-cardinal quarter selection
ignored missing diagonal neighbors at inside corners. The earlier native
preview also used a matching cave floor, which did not adequately reveal the
ground/relief boundary. These visual issues were not caught by those checks.

027_ArenaRelief.rb now keys only exact black pixels in its private 96x96 native
cliff crop, leaving shared expedition sources and dark rock intact. Relief is
rendered as a transparent layer-1 overlay over the normal layer-0 ground; its
z order is retained when the screen scrolls. Native quarter end caps join the
four missing-diagonal inside corners. Stairs/rails use the same keyed crop.
Menu entries and active-tool labels now say haut/droite/bas/gauche, retaining
the direction IDs, saves, collisions and visit protocol 4.

Tests: arena_relief_test.rb passes **8 tests / 501 assertions**, including the
four menu labels and their original direction mapping. The native probe passes
**62 checks**. It now loads the renderer's actual tileset/autotiles as Scene_Map
does, checks the opaque native ground below the overlay, scans all 256 neighbor
masks for opaque black, and checks the four missing-diagonal inside corners.
The exported stepped platform resembles the user screenshot on the installed
arena floor; its preview was visually inspected. The initial native retry
exposed a missing tileset registration in the probe fixture, now corrected.
Commands use the bundled Ruby and
`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py`.
Native report/preview remain ignored under tools/runtime/native-relief-probe.*;
the temporary probe/save were removed and plugin cache restored by the runner.
No personal save was read or written, and no upstream assets were changed.

Changed 027_ArenaRelief.rb, metadata (0.14.1), editor/native tests and README
files. Close the game and relaunch Play-Arena.bat. Existing platforms repaint
automatically; no rebuilding or save conversion is required. Local installation
updated; no commit/push and no new two-GUI-client visit test.

## Plateformes et escaliers — 2026-10-30 (Arena Demo 0.14.0)

Read AGENTS.md, README.md and this status before inspecting the current editor,
visit adapter, Essentials collision/renderer code and installed Caves/Outside
artwork. The Priority 1 integration attempt recorded below remains completed;
upstream checkouts, licenses, server dependencies and credentials are unchanged.
No new engine, art download, upstream patch or production service was added.

Map 100 retains one coordinate plane and now supports logical heights 0/1.
The editor has platform add/remove and four ascent directions. A one-cell stair
must have flat ground below and a platform above. Parallel stair cells connect
laterally to form wide stairs; exposed sides block passage. Native stone cliff
quarters join neighboring platforms and native cave steps are rotated in memory.
Furniture/trainers use the existing event slots on raised tiles. Stair cells,
fixed arena events, the spawn and the player's current tile remain protected.
Changing a support/low landing into void or removing a stair support is refused
until the stair is removed. Existing saves default to height zero. Relief uses
the editor's existing draft/cancel/commit/save-failure restoration path.

Visit protocol 4 includes a 10,000-byte relief grid, validated by client and
server. Invalid directions, missing supports, void relief, reserved elevated
tiles and stair occupants are rejected. Guest snapshots drive rendering and
collision without overwriting personal arena records. Server position auditing
checks the same stair ports and edges before relaying presence. Heights derive
from coordinates; no persistent online storage or stacked maps were introduced.
Both clients and the server must update together. The readiness CLI checks v4.

Files changed: 000_ReliefRules.rb (shared pure rules), 005_ArenaVisits.rb,
009_ArenaCustomMode.rb (editor/persistence/snapshot integration),
027_ArenaRelief.rb (tools, native artwork, map collision, renderer/overview),
meta.txt, server/arena_visits.rb, tools/ping_multiplayer.rb, README files,
this status, editor/server/native regression tests, tools/test-native-relief.py.
The existing server-test reactor helpers were extracted to arena_visit_harness.rb
and their old protocol-2/uncentered-map fixtures updated to the current map/v4.

Executed with tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe:

- `game-mod/test/arena_relief_test.rb`: **7 tests / 488 assertions**, passing.
  Includes all four ascents/descents, edge rejection, side joins/removal,
  invalid edits, furniture/trainer placement/removal, Marshal persistence,
  malformed snapshots, guest isolation and version mismatch rejection.
- `game-mod/test/arena_relief_server_test.rb`: **2 / 31**, passing with real
  PEMK reactor/wire and two TCP clients, injected authentication (no database).
  Verifies snapshot relay, actual stairs, correction of a side-entry attempt,
  malformed layout rejection, placed objects and visit closing.
- `game-mod/test/arena_visits_server_test.rb`: **6 / 98**, passing after fixing
  obsolete fixtures. A first unfiltered run exposed those old fixtures and an
  inherited-test duplication; the shared harness removes that duplication.
- `game-mod/test/save_recovery_audio_test.rb`: **3 / 11**, passing.
- `game-mod/test/player_controls_test.rb`: **10 / 35**, passing.
- `game-mod/test/entrance_refresh_test.rb`: **2 / 5**, passing.
- `game-mod/test/french_title_test.rb`: all reported checks passed.

`C:/msys64/mingw64/bin/python.exe tools/test-native-relief.py` boots the actual
installed mkxp-z and Essentials PluginManager, with local Following Pokemon EX.
The native probe passes **54 checks**: actual editor methods and native player
collision in all four orientations, furniture and trainer event placement,
Game.save to Data/arena-relief-probe-save.rxdata, SaveData disk read, Game.load
and map reconstruction, TilemapRenderer artwork/zoom/removal, plus native bitmap
composition exported for inspection. The fixture save and temporary plugin are
removed, and the normal cache restored (30 Arena Demo scripts). The player's
save is neither loaded nor written. Private report/preview:
tools/runtime/native-relief-probe.log and .png.

The first native run found Following Pokemon EX's alias of Game_Character#passable?
recursing through a prepend. Removed that character hook and use Game_Map's
normal/strict collision methods instead; subsequent native checks pass.
Void recovery now uses direction 0 (occupancy), so an impassable south edge
does not relocate a player correctly saved on a platform. The first elevated
shell could not resolve Python; the explicit installed executable works.

Local source is installed in the ignored test game. No commit/push or installer
publication performed. Manual remaining check: close game windows, launch
Play-Arena.bat, open Personnalisation → Plateformes et escaliers, make a small
plateau and a wide staircase, walk around it, save/continue, then host a visit
from an equally updated second computer. The executed two-socket test is not
a two-GUI-client visual playthrough. This limited version has a stone platform
top and no overlapping floors or automatic route/reachability guarantees.

## v8.1 follow-up: distribute the title PNG (2026-10-30)

The user explicitly requested including their title_screen.png in the commit
so other players receive it. Added the PNG to tracked source. The existing
install-french-title.ps1 preparation step already copies the root PNG into
Graphics/Titles/arena_title.png, so an updater pull followed by Play-Arena.bat
now delivers the artwork automatically. README and the title-plugin comment
were corrected. This supersedes the PNG exclusion in the historical v8.1
snapshot below. The design PPTX, music, runtime files and French source pack
remain local. No game behavior or plugin version changed in this follow-up.

Verification: inspected the existing installer copy path and staged file list;
the follow-up commit includes the PNG and excludes the PPTX/private runtime.

## v8.1 source snapshot (Arena Demo 0.13.4, 2026-10-30)

Requested commit message: `v8.1`; branch: `main`; destination: `origin/main` at
https://github.com/EvannKurzawa/arena_lab.git. This source snapshot contains the
custom title integration, French catalogs/compiler, native regression runner
and per-template audit described below. It is not a new installer build.

Current behavior: direct custom title with centered start prompt and local music;
normal Continue/New Game menu; original battle button graphics; French guides,
NPC/follower dialogs, inventory/escape wording; ability popup shows its name
alone. Existing save/network identifiers are preserved.

Recorded passing checks: 3,310 Essentials literal templates with zero documented
audit failures; 304 follower and 131 PEMK keys; 66 missing English core messages;
standalone French title/format regression; 23 real native mkxp-z boot checks.
The native runner loads/writes no save, substitutes the final NPC message UI
sink and cleans up its temporary plugin/cache entry. No new two-client or full
visual playthrough is claimed. The compiler path regression also passed again
before this release commit (both slash formats and source paths with spaces).

Excluded from source: private runtime files/caches, downloaded tools/audio, the
French pack, title_screen.png and title_screen_design.pptx. Each other computer
needs the separately supplied assets listed in README. Close game windows,
update source, provide those files, then launch Play-Arena.bat.

Upstream versions and dependencies are unchanged. Detailed commands, failed
attempts and corrections follow in the historical entries; the v8.1 README
describes the current behavior.

## v8 source snapshot (Arena Demo 0.12.2, 2026-10-30)

This snapshot combines the new procedural wilderness, generation 1-5 visible
encounters with a five-species limit per zone, Shift running, Space pause,
three rolling-day outings, the 20-minute timer, and the 0.12.1/0.12.2 startup
fixes below. Commit label: `v8`; target branch: `origin/main`.
The updater fetches GitHub `main`. After it updates both computers, close all
game windows and launch `Play-Arena.bat` to prepare local maps and plugin cache.
The user reported the two errors fixed in source below, but an embedded-runtime
launch of 0.12.2 and a full expedition/capture/reload playtest are still pending.
No private saves, licensed game assets, runtime binaries, or credentials belong
in this source snapshot.
Release checks with bundled portable Ruby 3.3.12: the full outing/world suite
passed **25 tests / 1,724 assertions**, controls passed **10 / 35**, terrain
passed **4 / 1,012**, and map-template generation passed **2 / 100**. The
`--disable-gems` startup smoke test passed, all five new plugin scripts passed
`ruby -c`, and the staged diff passed `git diff --cached --check`. These are
fixture and source checks, not an embedded-game GUI playtest.

## Following Pokemon scene-update recursion fix (0.12.2, 2026-10-30)

The user launched 0.12.1 and reported `SystemStackError: stack level too deep`
with alternating `018_ExpeditionLimits.rb`, `019_PlayerControls.rb`, and
`[Following Pokemon EX] Refresh.rb:122` frames. Following Pokemon EX aliases
`Scene_Map#update` after Arena Demo loads. Its alias captured Arena Demo's
prepended update hooks, causing `super` to re-enter Following's wrapper.
Both Arena Demo scene-update hooks now use class-level aliases, so Following's
wrapper reaches the prior method once. The separate `call_menu` hook remains a
prepend. This changes the hook mechanism only; the outing timer and controls
still run around the native scene update.

Verification with portable Ruby 3.3.12: player control tests simulate the
Following Pokemon alias and pass 10 tests/35 assertions; outing tests also
simulate the alias and pass 15 tests/264 assertions, including expiry through
`Scene_Map#update` and one return transfer. The no-stdlib startup smoke test
passes. `git diff --check` reports no whitespace errors (only Git's existing
CRLF conversion warnings). A fresh embedded-game launch remains to be verified
by the user; no successful GUI launch is claimed here. The normal
`Play-Arena.bat` preparation step copies the updated plugin and cache on start
when no other client is running.

## Embedded Ruby startup fix (0.12.1, 2026-10-30)

The 0.12.0 game startup reported `LoadError: cannot load such file -- json`
in `018_ExpeditionLimits.rb`. The embedded runtime does not provide the `json`
standard library; `fileutils` was also an unnecessary runtime dependency.
The outing ledger now uses Ruby's built-in Marshal format, as Essentials does
for saves, in `SaveData::FILE_PATH + '.expeditions.dat'`. The save directory
already exists when Essentials selects its save path. Malformed records still
block departures instead of silently resetting the daily allowance.
No successful GUI launch has been claimed for this fix; the user must retry
the game and report any later startup error.
Verified locally with portable Ruby 3.3.12:
`ruby --disable-gems game-mod/test/expedition_boot_smoke.rb` passed while
all `require` calls were rejected; the plugin loaded, recorded an outing,
reloaded the deadline and allowance, and retained the ended state.
`ruby game-mod/test/expedition_limits_test.rb --name /Outing/` passed
14 tests/262 assertions. `ruby game-mod/test/player_controls_test.rb` passed
9 tests/34 assertions. `git diff --check` found no whitespace errors.
These checks use portable Ruby and fixtures, not the embedded mkxp-z game process.
`Play-Arena.bat` runs Prepare on next start when no other client is active;
Prepare copies these plugin files and refreshes the local plugin cache.

## Running, timed allowance and five-species zones (0.12.0, 2026-10-30)

Implemented in this working copy. Essentials v21.1, PEMK pins, the shipped
mkxp-z binary, visit protocol and procedural terrain version 2 are unchanged.
No new dependencies, services, payments, asset downloads or release publication.

Hold either Shift/Maj while moving to use Essentials' native running movement
and animation, without needing the running-shoes unlock. Terrain, bump/jump,
scripted-route and battle/menu restrictions remain. Space now queues the pause
menu after the current step, without also firing overworld interaction; Enter/Z
still interact. Dialogues/battles retain native confirm/cancel. The obsolete
Default Movement option is removed. This uses a scoped Input adapter and player/
scene hooks, rather than replacing core engine files or F1 bindings.

Each local profile has three free departures in a rolling 86,400 seconds. Each
used slot replenishes exactly 24 hours after its departure. A cancelled prompt,
failed generation/write/transfer does not consume an outing. Returning early
still counts. OutingLedger persists timestamps and session deadlines atomically
in `SaveData::FILE_PATH + '.expeditions.dat'`; loading an older save cannot restore
slots or reopen an ended trip. An initially zero bonus-outing balance and credit
method prepare for future extra outings; no payment or purchase UI is present.

Each outing gets a 1,200-second absolute real-clock deadline after generation.
A map HUD shows remaining time. Menus and closing the game do not stop time.
After expiry, new voluntary movement, crossings and visible wild battles stop;
ordinary menus unwind through cancel input. Running NPC scripts, capture/reward/
evolution processing and active NPC/wild battles finish before return. Both the
native in_battle/menu/message flags and the visible-wild busy flag are checked.
Return occurs automatically before its acknowledgement dialog, not after waiting
for confirmation. Normal blackout/healing travel also closes the outing.

New generation resolves at most five weighted distinct generation 1-5 species
per zone, without replacement, using a private seed derived from outing/zone.
The selected weighted tables persist in the outing and are the only spawn pool
for subsequent visits/reloads/respawns. Six visible individuals can still coexist
because several may share a species. Legacy zone tables backfill deterministically.
Old untimed saves receive one recorded twenty-minute migration outing, using an
available slot, rather than a fresh timer on every load. No saved Pokemon are
deleted. Rules and migration details: docs/EXPEDITION_RULES.md.

Files for this revision: new 018_ExpeditionLimits.rb, 019_PlayerControls.rb,
expedition_limits_test.rb, player_controls_test.rb and docs/EXPEDITION_RULES.md;
updated 014_VisibleWildPokemon.rb, 016_ExpeditionWorld.rb, meta.txt, the existing
world test fixtures, root/game-mod READMEs, generation documentation and this
status. Earlier uncommitted terrain/world work remains intact.

Executed with bundled Ruby 3.3.12:

- `ruby game-mod/test/expedition_limits_test.rb`: **21 tests / 1,711 assertions
  passed**, comprising the 10 existing world regressions and the initial limit
  tests. Covers full-world navigation, generation, save continuity and encounters
  alongside the quota/timer integration.
- After final expiry-message ordering and additional failure/allowance cases,
  `ruby game-mod/test/expedition_limits_test.rb --name /Outing/`:
  **14 / 262 passed**. Covers exact rolling-day boundaries, profile isolation,
  record reload/corruption/write failures, free/bonus refunds, declined/exhausted
  departures, real-time save reload, active-battle/post-battle-script deferral,
  movement/message deferral, automatic return before notice, closed/legacy-save
  replay and frozen weighted five-species rosters over 100 respawns.
- `ruby game-mod/test/expedition_world_test.rb --name /failed_transfer/`:
  **1 / 3 passed** after adding the explicit quota-refund assertion.
- `ruby game-mod/test/player_controls_test.rb`: **9 / 34 passed**. Runs the real
  upstream Scene_Map input polling body with hardware-state fixtures; verifies
  both Shift keys, Space versus Use priority, moving-menu queuing, Enter/Z,
  terrain/scene/script locks, input-scope cleanup and expired-menu cancellation
  without cancelling battle or NPC follow-up commands.
- Other targeted regressions: visible_wild_test **9 / 126**,
  expedition_map_build_test **2 / 100**, expedition_terrain_test filtered to
  ExpeditionTerrainTest **4 / 1,012**, remote_follower_test **3 / 9** and
  following_ownership_test **4 / 12**, all passed. Across these runs, **55 distinct
  tests** were exercised; overlapping reruns above are not additional tests.
- Syntax checks passed for 014, 016, 018 and 019; `git diff --check` passed.
- Local upstream can_run?/Scene_Map/menu/battle lifecycle code was inspected.
  The raw keyboard API was checked against the primary mkxp-z development source;
  web fetches of the exact pinned commit failed with cache misses, and no runtime
  upgrade was made. References are recorded in docs/EXPEDITION_RULES.md.

These are automated engine-state/input/filesystem fixtures, not an actual
keyboard, twenty-minute live battle or two-client GUI playtest. No client/server
was launched, and no commit/push/updater upload was performed for this revision.

Manual verification: close the games and run Play-Arena.bat from this working
copy. Check Shift+movement, release-to-walk and Space pause while stationary or
mid-step; use Enter/Z for NPCs/catching. At the village guide check allowance,
decline a departure and confirm it stays unchanged. Depart and check the HUD,
revisit a zone and reload a save to verify the same five-species selection and
original deadline. Check menu expiry closes cleanly, and a wild battle spanning
the deadline finishes capture/rewards before automatic return. NPC-battle grace
also needs a real trainer-in-expedition check when such an NPC is placed. After
three departures, check that another is denied and its next free time is shown.
Existing untimed outings migrated on first load count as one outing. All timing
uses the computer's real clock; allowance remains local to the profile.

## Native-art terrain and generations 1-5 (0.11.0, 2026-10-30)

The user rejected the 0.10.0 appearance. Replaced its ellipse stamping and
rectangle-drawn textures with version 2 generation and native Essentials art.
Existing Essentials v21.1/PEMK pins and multiplayer protocol are unchanged. The
fixed biome rarity table remains unchanged. No web map pack or third-party
generation library was imported; the researched procedural option was chosen.
Sources, algorithm details and limits are in docs/EXPEDITION_GENERATION.md.

Generation now uses independently seeded, warped, multi-octave value-noise
fields for elevation, moisture and route costs; quantiles control biome feature
coverage. Small components are pruned. A minimum spanning tree plus terrain-aware
A* joins exits/camp/clearings with offset waypoints and necessary bridges. Paths
are no longer a fixed central cross. Scenery blockers participate in encounter
reachability checks. Native quarter-tile autotile tables choose shore/path/low
vegetation edges. Native cliff faces surround separate summit interiors; actual
full conifers replace the cuttable-shrub graphic used by the first version.
Snow rocks, crystals, industrial floors and ruins use the installed artwork.
Palette grading adapts native vegetation to snow/dry/ash and water to lava.
Generation shows progress rather than leaving a frozen map with no feedback.

Wild pools now require base species generations 1-5. Tests explicitly include
matching generation 6/7/8 candidates and verify rejection. Existing trainer
rosters, starter and local gifts were inspected and already use generations 1-5.
Engine definitions/assets and previously caught Pokemon are retained for save
compatibility; no destructive save cleanup was performed.

Existing saved expedition plans retain their geography. Return to the village
and depart again to create the version 2 layout. The new renderer supports the
old terrain codes as well. Per-profile plans, map IDs and local-only scope remain.

Files for this revision: 015_ExpeditionLayout.rb, 016_ExpeditionWorld.rb,
017_ExpeditionTerrain.rb, meta.txt (0.11.0), expedition_world_test.rb,
expedition_terrain_test.rb, README.md, game-mod/README.md and this status;
new docs/EXPEDITION_GENERATION.md and game-mod/tools/expedition_preview.rb.
The other uncommitted changes listed below belong to the preceding 0.10.0 task
and were preserved. No upstream code, assets, saves or credentials were deleted.

Executed with bundled Ruby 3.3.12:

- `ruby game-mod/test/expedition_terrain_test.rb`: **14 tests / 2,470 assertions
  passed**, including 10 world-generation/save/encounter tests. Eight complete
  worlds were checked for path and encounter reachability with blocking scenery;
  all 15 biome configurations were checked for meaningful terrain features.
- After the final native scenery guard/prop adjustment,
  `ruby game-mod/test/expedition_terrain_test.rb --name /ExpeditionTerrainTest/`:
  **4 tests / 1,012 assertions passed**. Covers all native masks, source bounds,
  scrolling, asset disposal and full-tree framing, including player/follower
  characters without Game_Event's name method.
- `ruby game-mod/test/visible_wild_test.rb`: **9 / 126 passed**.
- `ruby game-mod/test/expedition_map_build_test.rb`: **2 / 100 passed**.
- `ruby game-mod/test/remote_follower_test.rb`: **3 / 9 passed**;
  `ruby game-mod/test/following_ownership_test.rb`: **4 / 12 passed**.
  These are targeted fixture tests, not a new two-client game test.
- Syntax checks passed for the three expedition scripts and preview tool.
  `git diff --check` passed (Windows line-ending notices only).
- The original old-table fixture failed after excluding gen 8 and was updated to
  use gen 5 Roggenrola as its allowed Rock species, plus explicit gen 6-8 rejects.
  The old fixed saved coordinate became rock under the new layout; its fixture
  now uses the guaranteed camp clearing, preserving the save-continuity check.
- Research consulted primary algorithm articles, the JCGT value-noise paper page
  and the original WFC repository. No downloaded map/art pack was installed.
- Native assets were read via the filesystem tool and copied only to ignored
  `dist/expedition-qa` for independent visual verification. The production preview
  tool rendered all 15 biome configurations to `dist/expedition-preview` with
  full-sector and viewport images plus summary.json. All completed successfully.
  Final snow/crystal prop crops were re-rendered under dist/expedition-final-preview.
  These are deterministic renders of production terrain code, not game screenshots.

No actual game/server/two-client session was launched for this revision, and no
commit/push/updater publication was performed. The earlier private-runtime shell
preparation stall is recorded below; this revision verified native artwork with
read-only input copies rather than claiming a successful game launch.

Manual steps: close the games, run Play-Arena.bat from this working copy, load
the save, return to the village if outside, and leave through the south gate.
Check full tree layering/collision, biome art/weather, grass contact/capture,
sector crossings, bridges, save/reload, return home and another new departure.
Existing owned Pokemon should remain intact; new wilderness spawns should be
generations 1-5 only. Further authored landmarks and in-game aesthetic feedback
remain useful; forest/bamboo still share woodland art and sectors fade on travel.

## Procedural wilderness expeditions (0.10.0, 2026-10-30)

Implemented in source; **not a user-confirmed GUI snapshot**. Existing Essentials
v21.1 and PEMK repository/version pins below are unchanged. No new dependencies,
downloaded assets, upstream patches, server protocol changes or release uploads.

The south village gate starts a new offline expedition with 16 connected 64x64
sectors, covering 256x256 tiles. The starting camp is grassland. Each other sector
independently rolls the fixed percentages in README: grassland 52, forest 12,
desert 5, volcano/snow/lake 4 each, swamp/canyon/meadow 3 each,
crystal/ruins/storm/coast 2 each, bamboo/power station 1 each (total 100).
Repeats are allowed; an outing need not contain every special biome. Grass is
the most likely biome, rather than an enforced minimum count on every outing.

Plans contain a version, seed, resolved biome choices, compact terrain strings
and scenery coordinates in PokemonGlobal. Crossing sectors/loading retains the
same plan; only a confirmed village departure replaces it. Runtime generation
uses Essentials' on_game_map_setup hook. Per-player layouts never overwrite
shared map files, so separate local profiles retain separate expeditions. The
return guide and Expedition pause command return home; the existing healing
return is set before departure. Generation carves connected clear paths and
removes unreachable encounter grass from the spawn pool.

Visible encounters now support these maps, scan nearby grass rather than all
65,536 world tiles, and cap active wilderness Pokemon at six. Pools are selected
from the installed generation 1-8 base species by habitat types, favoring the
primary type and lower stat totals. Legendary/Mythical/Ultra Beast flags and
Sea/Rare habitats are excluded from ordinary spawns. Levels scale from 3-7 at
camp to 23-27 farthest away. Existing pbGenerateWildPokemon, walking-sprite/icon
fallback and WildBattle retain battle/capture behavior. Populations are transient
and not saved. The existing village table and cap of four remain.

Source files changed: README.md, game-mod/README.md, this file, the map builder,
014_VisibleWildPokemon.rb and meta.txt; new 015_ExpeditionLayout.rb,
016_ExpeditionWorld.rb and 017_ExpeditionTerrain.rb. Added expedition_world_test.rb,
expedition_map_build_test.rb and expedition_terrain_test.rb; extended visible wild
tests. Two older sign/audio fixtures now explicitly create temporary directories
inside the workspace because this sandbox cannot reliably enumerate files in
the system temp folder. Their initial failures were reproduced and then passed
with the fixture location corrected; production sign/audio behavior is unchanged.

Commands/results (bundled tools/runtime/ruby-portable/rubyinstaller-3.3.12-1-x64/bin/ruby.exe,
Ruby 3.3.12; tests are lightweight engine fixtures, not a running RGSS game):

- `ruby game-mod/test/expedition_terrain_test.rb`: **11 tests / 1,682 assertions
  passed**, including the nine expedition world tests. Covers fixed rarity
  intervals, deterministic plans, eight complete generated worlds' path/grass
  reachability, save round trips/load recovery, new outing/cancel/online guards,
  transfer rollback, runtime events, hazard collision, species pools, terrain
  differentiation, shoreline masks and bitmap caching/disposal.
- `ruby game-mod/test/expedition_map_build_test.rb`: **2 / 100 passed**. Executes
  the production builder twice on renderable synthetic Marshal fixtures, checks
  template/palette/village generation, original-map preservation and reserved-ID
  collision refusal. This does not establish real map rendering.
- `ruby game-mod/test/visible_wild_test.rb`: **9 / 126 passed**, including nearby
  expedition population, movement/cleanup, habitat delegation and contact battle.
- Existing targeted regressions: save_recovery_audio_test **3 / 11**,
  entrance_refresh_test **2 / 5**, remote_follower_test **3 / 9**,
  following_ownership_test **4 / 12**, sign_graphic_test **3 / 3**,
  online_npc_audio_test **2 / 6**, all passed. Combined final targeted results:
  **39 tests / 1,954 assertions**, counting the world tests only once.
- Syntax checks passed for the changed runtime/generator scripts. Terrain
  primitives were rendered with the test drawing surface to the ignored
  `dist/expedition-terrain-preview.png` and visually inspected. This preview
  confirms distinct colors/textures; it is not a screenshot of the running game.
- `ruby game-mod/tools/build_arena_map.rb C:/arena-lab/tools/runtime/essentials-v21.1-base`
  was attempted against the real private game. Local runtime/graphics access
  stalled with no output; an elevated retry also stalled. The attempts were
  cancelled without a successful completion result. Temporary inspection helpers
  were removed. No successful local installation or client launch is claimed.

Remaining limits: first-pass procedural art and themed cave/ruin/factory sectors
without separate interiors; water/lava/cliffs are barriers, with no Surf or island
travel; fixed crossing paths rather than seamless scrolling across sector edges.
No multiplayer wilderness synchronization. No server, authenticated client or
two-client playtest was run for this change; previous v7 reports remain below.
No commit/push or installer publication was performed.

Manual verification required: close all game windows, run Play-Arena.bat from
this working copy, load the existing save, walk south to the gate and confirm.
Check scenery, biome names/weather, hazard collision and sector crossings; touch
or interact with a visible Pokemon and catch it. Save outside, quit/relaunch and
check the same geography and position. Use Expedition -> Return to village,
check the retained catch, then leave again and check the changed geography.
Check an offline battle loss returns to the normal healing location. Repeat the
existing LAN arena visit flow after returning home; expeditions themselves are
offline. The updater will not contain this source until a later push/release.

## v7 — user-confirmed working snapshot (2026-10-29)

After the outdoor fixes at `cefc527`, the user reported: "now everything works."
This supersedes the pending user-playtest status for the recent reported issues.
The recent test cycle included LAN discovery/visits between the host and visiting
PC, PvP and follower ownership, placed trainer battles online, area music and
door sounds, entrance objects, saved movement recovery and visible village wild
Pokemon. The confirmation is a user report, not an independently observed Codex
GUI test or a claim that all possible multiplayer scenarios are bug-free.

v7 labels the source snapshot with Arena Demo plugin 0.9.32, Essentials 21.1 and
the existing PEMK pins. Visit protocol remains 3. No engine, dependency, asset,
save or credential changes are part of this documentation update. The exact
upstream URLs/commits and integration procedure remain recorded below.

Automated results are unchanged: the latest targeted outdoor-fix run passed
25 tests / 155 assertions, including actual upstream grass callback execution.
The preceding broader regression run passed 38 tests / 193 assertions. These
are separate recorded runs, not a single combined suite. The broader stale-fixture
limitations documented below have not been rerun or declared resolved.

Updated README to present v7, remove the accumulated pre-title patch notices,
document current visible encounters/update instructions and replace the outdated
LAN-flow pending statement. Earlier status sections remain the historical record
of what was inspected, executed and unverified at each point.

Commands for this documentation update: read README/status, inspect git status
and recent commits, run `git diff --check`, review the documentation diff, commit
with message `v7`, then push to `origin main`. No game/client/server or new tests
were launched for this documentation-only change.

Existing installations: close both games, run the existing ArenaLab-Update.exe
on both computers, then launch Play-Arena.bat. The updater downloads main. No
new installer build, release upload or Git tag is created by this commit.
Remaining scope limits include clean-install hosting prerequisites, internet/NAT
automation, online wild encounters and persistent online arena storage. The
generated village is still a functional visual placeholder for future redesign.

## Visible wild grass callback and missing village sign (0.9.32)

2026-10-29. Essentials/PEMK pins and visit protocol 3 unchanged.

Essentials' grass_rustling callback invokes event.map_id. Game_Character exposes
map but lacks map_id, and ArenaVisibleWildCharacter inherited that gap. Added
map_id to its shared ArenaRemotePokemon base, returning map.map_id; this covers
remote followers too. The regression executes the actual upstream grass callback
with a visible wild character, rather than only a replacement movement model.

Two map-generator sign paths assumed Graphics/Characters/Object sign existed.
They now reuse a source-map sign tile or an installed sign-named charset. With
neither available, the existing boundary boulder becomes a readable stone marker.
The sign interaction/text remain. No new assets are downloaded or redistributed.

Executed with bundled Ruby 3.3.12: 25 tests / 155 assertions passed across
remote_follower_test.rb, new sign_graphic_test.rb, visible_wild_test.rb,
following_ownership_test.rb and lan_discovery_retry_test.rb. Covers actual grass
callback execution, native sign tiles, absent sign charsets and installed local
sign charsets. No game GUI, private-map generation or two-computer test executed.

Changed: 011_ArenaFollowingIntegration.rb, meta.txt, build_arena_map.rb,
remote_follower_test.rb, new sign_graphic_test.rb, README and this report.
No private saves/assets edited. After push, close both games, update both PCs
with the existing updater and relaunch Play-Arena.bat to regenerate maps. Walk
outside, interact with the sign, observe roaming Pokemon in grass and complete a
visible encounter, checking for neither reported exception. Saved village maps
are refreshed from generated data by the existing load recovery.

## Partial Fiddle, PvP follower ownership and visible village encounters (0.9.31)

2026-10-29. Essentials/PEMK pins and arena visit protocol 3 remain unchanged.
The existing updater fetches main; both computers must update and restart.

The game exposes a partial Fiddle module whose Function calls can invoke missing
win32_last_error= setters. Native UDP control now checks all required error
setters before making a call; the reset-aware pure Ruby receive path remains
available. The new fixture reproduces missing win32_last_error= with DEBUG true
and verifies no native Function is constructed and no exception log is emitted.

Follower lifecycle: remote characters now have explicit owning account IDs and
separate negative character IDs. They reject another player's leader object;
remote self-echoes cannot create a second local follower. Their sprites retain
the exact owning character and remote visuals rebuild after PEMK PvP. Neighbor
map spritesets cannot steal the attachment context. Local follower creation and
remote movement pause during battles to avoid recreating a temporarily hidden
local follower. Descriptor changes are compared before replacing cached values.
These address identified lifecycle/ownership risks; the reported physical
two-computer post-PvP scene has not been reproduced in-game here.

Research read on the web:

- https://eeveeexpo.com/resources/1087/ : Voltseon's v21.1 documentation describes
  visible encounters, movement settings and recommends 4-6 active spawns to limit
  load and crowding. It requires RainefallUtils plus walking assets.
- https://github.com/VisibleOverworldWildEncounters/Visible-Overworld-Wild-Encounters-V20/blob/main/README.md
  describes contact battles, despawn, terrain restriction and spawn-cap options.
  Neither reference establishes a universal tiles-per-Pokemon density.

Implemented a small original overlay, not a copy or installation of those
third-party plugins. No third-party code/assets or additional dependencies were
redistributed. It uses Essentials terrain tags, existing encounter weights,
pbGenerateWildPokemon, PokemonIconSprite/Sprite_Character and WildBattle.start.
The player's optional walking assets are resolved locally; existing Essentials
icons are used if no walking sprite exists.

VisibleWild configuration: one spawn per 24 usable grass tiles (rounded up), cap
four, approximately two in the existing 42-tile patch before event exclusions.
This density is a project tuning choice, not a published standard. Spawns choose
Rattata/Caterpie/Spearow using the existing weights and level ranges, wander every
1.5-3.5 seconds, stay on grass, avoid blocking events/player/other spawns, and
despawn after 60 seconds. Battle/removal replacements wait eight seconds. Contact
or facing + Confirm starts a normal catchable battle against that exact generated
Pokemon. Step-based invisible encounters are suppressed only in this offline
village; other maps are unchanged. Menus/interpreters/battles defer interaction.
Spawns are transient module state, not injected into serialized map events;
leaving the map or going online disposes them. They are not synchronized online.

Tests use real production entry points with socket/engine fixtures; no graphical
walking, catch, audible sound or physical two-computer PvP test was executed.
No private saves/assets were modified. Existing wider fixture limitations remain.

Changed: 006_FoundersPath.rb, 008_LanDiscovery.rb,
011_ArenaFollowingIntegration.rb, new 014_VisibleWildPokemon.rb, plugin metadata,
discovery regression test, new following_ownership_test.rb / visible_wild_test.rb,
README and this report. Final validation: 38 tests / 193 assertions passed across
the nine Ruby regression files (discovery, follower ownership, visible wild,
remote follower movement, entrance refresh, music selection, save recovery/audio,
online NPC/audio and multiplayer fixes). Changed Ruby syntax and git diff --check
passed. Ownership tests include two remote players after rebuild, self-echo
rejection, neighbor-map context protection and local battle-spawn prevention.

Manual checks: update/restart both PCs, discover and complete a visit without
Fiddle error logs, finish PvP and move each player separately to verify ownership
on both screens. Offline in the village, observe roaming sprites, contact and
Confirm battles, catch a Pokemon, wait for replacement, save/reload and leave/
return. Without walking assets, confirm icon fallback remains visible/catchable.

## Game socket compatibility, entrance boundaries and MIDI bank (0.9.30)

2026-10-29. Essentials/PEMK pins and visit protocol 3 unchanged.
Update both PCs with the existing updater and restart Play-Arena.bat, which
configures the runtime and synchronizes compiled plugin sources.

Confirmed code causes and fixes:

- recvfrom_nonblock was unsupported in the game runtime. Discovery now uses
  recvfrom after IO.select, with one reader per owned socket, retaining quiet
  reset/refused handling and propagation of unexpected errors. The '(closed)'
  receiver can result from ensure closing the socket during error unwinding.
- CustomModeRefresh hid IDs 3 through 8 on every map. Entrance boundaries reuse
  IDs 6/7, so network refreshes hid the top-left boulders and could also hide the
  PC/attendant. Legacy hiding is now restricted to map 100. Entrance refreshes
  restore any boundaries made transparent/through by previous builds.
- The installed file listing contains essentials-v21.1-base/soundfont.sf2.
  Runtime setup omitted that name while checking GMGSx.sf2 and configured banks.
  It now detects soundfont.sf2 in the game/runtime root for MIDI playback.
- Area names without English category words can now be selected if categorized
  tracks are absent; combat/victory/evolution/title exclusions remain. Diagnostics
  include all available music filenames to diagnose any remaining silence.

Executed using bundled Ruby 3.3.12: 25 tests / 61 assertions passed across
lan_discovery_retry_test.rb, music_selection_test.rb, entrance_refresh_test.rb,
save_recovery_audio_test.rb, online_npc_audio_test.rb, remote_follower_test.rb
and multiplayer_fixes_test.rb. Socket fixtures expose only recvfrom. Entrance
tests repeat connection refreshes and verify boulders, PC, attendant, collision
and arena-only hiding. soundfont_setup_test.ps1 passed two checks using the
actual setup selection block: root soundfont.sf2 detection and explicit-bank
precedence. No game, GUI, backend or two-computer test was launched.

Private audio reads stalled, so the affected install's selected track/volume
was not inspected. The omitted MIDI bank and strict name filter are identified
causes of possible silence; audible playback is not yet verified. After updating
both PCs, check music on load, battle/return music, visible entrance boulders after
Host online, and visitor search. If silent, retain Data/ArenaAudioDiagnostic.txt
and the generated runtime mkxp.json midiSoundFont entry. Broader fixture limits
remain as recorded in earlier sections.

Changed: README, this report, 000_ArenaMusicSelection.rb, 008_LanDiscovery.rb,
009_ArenaCustomMode.rb, 013_ArenaAudio.rb, meta.txt, install-client-runtime.ps1,
discovery/music tests and new entrance_refresh_test.rb / soundfont_setup_test.ps1.
No private save or game asset was edited.

## Overworld track selection and discovery debug messages (0.9.29)

2026-10-29. Essentials/PEMK pins and visit protocol 3 unchanged.

The previous music fallback selected an arbitrary decoded file, so a battle BGM
could displace overworld MIDI. A shared selector now accepts named exploration
tracks and rejects battle/trainer/encounter/victory/fanfare/evolution/champion
tracks. Generation and runtime autoplay both use it; saved battle templates are
replaced too. Decoded audio preference applies only after the overworld filter.
If no recognized overworld file exists, autoplay stops the wrong BGM instead of
substituting another battle track. Local audio diagnostics still report selection.

Discovery already rescues reset/refused errors, but Ruby debug mode can print
rescued exceptions. The friend successfully joining is consistent with such a
message; no full trace from that computer was available to prove this. Both UDP
receive paths now use one nonblocking helper that consumes expected reset,
refused and empty-queue notifications with debug printing temporarily disabled.
It restores the previous debug flag even on failure and propagates unexpected
errors. Native reset suppression remains optional; discovery does not depend on
Fiddle support for this receive handling. No global debug setting is changed.

Executed with bundled Ruby 3.3.12: 22 tests / 55 assertions passed across
lan_discovery_retry_test.rb, music_selection_test.rb, save_recovery_audio_test.rb,
online_npc_audio_test.rb, remote_follower_test.rb and multiplayer_fixes_test.rb.
Includes captured stderr with DEBUG enabled, a reset followed by a valid reply,
unexpected receive error propagation, real Windows UDP retry/control tests,
rejection of decoded battle tracks when only overworld MIDI is available, and
the actual map autoplay wrapper replacing an older battle template.
No audible playback, game GUI or physical two-computer test was executed.

Files changed: README, this status, plugin meta.txt, 008_LanDiscovery.rb,
013_ArenaAudio.rb, new 000_ArenaMusicSelection.rb, build_arena_map.rb,
lan_discovery_retry_test.rb, save_recovery_audio_test.rb,
online_npc_audio_test.rb and new music_selection_test.rb.

After push, close both games, run the existing ArenaLab-Update.exe on both PCs,
then relaunch Play-Arena.bat. Check village/entrance/arena exploration music,
NPC battle music and the return to exploration music; search and complete a
visit. If a reset message remains, retain the complete new trace and installed
Plugins/ArenaDemo/meta.txt version (expected 0.9.29), since the reported old
line number does not identify the current receive helper. If music is absent,
inspect Data/ArenaAudioDiagnostic.txt for track selection and volume.

## Saved movement, bundled Fiddle compatibility and music playback (0.9.28)

2026-10-29. Essentials/PEMK commits and visit protocol 3 unchanged.
Both computers must run the existing updater after these changes reach main,
then relaunch Play-Arena.bat. No replacement installer required.

The reported dlopen crash is a runtime API mismatch introduced by 0.9.27:
standalone Ruby provided Fiddle.dlopen but the game's Fiddle module did not.
Socket configuration now uses Handle.new, checks native API availability and
falls back to normal reset-aware UDP without failing discovery when native
controls are unavailable. Real UCRT socket control still passes its tests.

Save recovery now runs after Game.load has finished, refreshes maps 100/101/102
instead of excluding the entrance, and clears serialized forced routes, through
mode, ice/waterfall movement flags and transient movement state before moving
the player. Arena void recovery searches the full custom map if the original
25x25 field has no valid tile. This addresses saved-state causes consistent with
the reported involuntary movement; the user's private save was not reproduced.

Music repair now runs on actual Game_Map autoplay as well as generation, so
older loaded maps receive the selected BGM too. It repairs zero map-track volume,
prefers existing decoded tracks over MIDI and preserves the player's volume
option. The runtime setup reuses a local configured or standard-location SF2
SoundFont if present. mkxp-z documents that MIDI uses a SoundFont (default none):
https://github.com/mkxp-z/mkxp-z/blob/dev/mkxp.json . No bank or audio is downloaded
or redistributed. A local Data/ArenaAudioDiagnostic.txt records the map, chosen
track, map volume, available candidates and player music volume. Private audio
directory inspection stalled here; the actual silent track/volume was not read.

Validation executed with bundled Ruby 3.3.12: 16 tests / 44 assertions passed
across lan_discovery_retry_test.rb, save_recovery_audio_test.rb,
online_npc_audio_test.rb, remote_follower_test.rb and multiplayer_fixes_test.rb.
New checks cover unavailable dlopen, optional native failures, forced movement
reset, recovery to a custom tile outside the initial field, and the real autoplay
wrapper replacing a silent MIDI template with an installed OGG fixture while
preserving player volume. These are fixture/socket tests, not audible playback.

Files changed: README, this report, 008_LanDiscovery.rb, 009_ArenaCustomMode.rb,
new 013_ArenaAudio.rb, plugin metadata, build_arena_map.rb,
install-client-runtime.ps1, lan_discovery_retry_test.rb and new
save_recovery_audio_test.rb. No user saves or private assets edited.

Manual check: update both computers and relaunch. On the host load the same
offline save and verify the player stands on a floor and stays still without
input. On the visitor search and complete a visit. Check music on startup and
through village/entrance/arena transfers and after a battle; check Music Volume
in Options if the diagnostic reports zero. If still silent, inspect the local
ArenaAudioDiagnostic.txt and retain runtime logs. MIDI-only assets without an
installed SoundFont still require that missing prerequisite; no audible music,
GUI startup or two-computer session is claimed as tested here.

## Windows discovery, released-runtime followers, online NPCs and audio (0.9.27)

2026-10-29. Upstream Essentials/PEMK pins and visit protocol 3 unchanged.
Both computers must update and restart. The existing ArenaLab-Update.exe fetches
main, so a replacement installer is unnecessary once these changes are pushed.

Changes:

- Windows UDP sockets disable SIO_UDP_CONNRESET through WSAIoctl. Ruby's ioctl
  is unimplemented on Windows, so the implementation uses Fiddle and the matching
  UCRT/MSVCRT descriptor conversion. Actual UCRT socket control was executed
  successfully. Both responder and search retain reset/refused recovery.
- Remote visual followers implement released Essentials camelCase trigger hooks
  (including pbCheckEventTriggerAfterTurning), in addition to upstream snake_case
  hooks. They do not activate map events.
- Removed the blanket online guard on recruited trainer challenges. They resolve
  the existing read-only host snapshot and start normal local Essentials NPC
  battles. Arena edits remain locked; this does not create a peer PvP battle.
- Generated maps preserve an available template BGM or select an installed
  town/city/route track (falling back to an existing BGM). Door transfers resolve
  an installed door-open/enter sound. No music, sound assets or user volume
  settings are deleted, copied into source, or replaced.

Validation: bundled Ruby 3.3.12, 11 tests / 31 assertions passed across
lan_discovery_retry_test.rb, remote_follower_test.rb, online_npc_audio_test.rb
and multiplayer_fixes_test.rb. Includes real Windows UDP with a closed-port
probe and deliberately dropped first discovery request, actual upstream blocked
movement, released callback names, connected NPC trainer entry and synthetic
installed audio fixtures. These are not full engine battle or audible playback
tests. Initial native attempts using IO#ioctl and an unavailable Ruby export
failed; those implementations were replaced before the passing run.

Sandbox commands stalled when accessing the runtime; the passing checks ran
outside the sandbox. No game window or two-computer session was operated.
The broader stale fixtures reported in the previous section remain unresolved.

Changed files: 001_ArenaDemo.rb, 008_LanDiscovery.rb,
009_ArenaCustomMode.rb, 011_ArenaFollowingIntegration.rb, meta.txt,
build_arena_map.rb, both discovery/follower regression tests, new
online_npc_audio_test.rb, README and this status report.

Manual test after updating both computers: launch Play-Arena.bat to regenerate
maps; host and request a visit once; turn/move followers against obstacles;
challenge a placed trainer as host and visitor, finish the battles and leave.
Check village/entrance/arena music, door sounds, battle music and music restoration
after battle. Audio requires the player's existing complete Essentials assets.
MSVCRT game-runtime Fiddle control and actual audio playback still need this
in-game check; the native UCRT development runtime passed.

## Multiplayer retry and follower fixes (2026-10-29, plugin 0.9.26)

Source only; not yet published in an installer. Upstream pins and visit protocol
3 remain unchanged. The published v6.2.6 installers do not contain these fixes.
The existing ArenaLab-Update.exe fetches GitHub main at execution time, so once
these changes are pushed, both computers can use the v6.2.6 updater to obtain
them without a new installer release. Close both games, run the updater on each
computer, then launch Play-Arena.bat to install plugin 0.9.26 locally.

Essentials Game_Character#move_generic calls check_event_trigger_touch on blocked
movement. ArenaRemotePokemon now implements that hook, returning false, alongside
the existing turning hook. Both callback call sites in upstream were inspected.

The host readiness wait increases from 15 to 90 seconds: database startup alone
can consume 15 seconds before checks, migrations and server loading. The game's
request wait increases from 45 to 150 seconds to include service mutex acquisition
and probes. This addresses a premature timeout consistent with the report; logs
from the affected computer were unavailable to prove its cold-start timing.

LAN discovery retries probes every 0.5 seconds over five seconds. Per-interface
send failures no longer abort the search. Local addresses are identified by IP
instead of hostname, and different hosts sharing a name are kept separate.

Changed: README, this report, plugin metadata, 007_ConnectionMode.rb,
008_LanDiscovery.rb, 011_ArenaFollowingIntegration.rb, tools/play-arena.ps1;
added remote_follower_test.rb and lan_discovery_retry_test.rb.

Executed using bundled Ruby 3.3.12:

- `ruby game-mod/test/remote_follower_test.rb`: 1 test, 4 assertions passed using
  actual upstream blocked movement in all four directions.
- `ruby game-mod/test/lan_discovery_retry_test.rb`: 1 test, 1 assertion passed
  using real UDP with a responder deliberately ignoring the first probe.
- `ruby game-mod/test/multiplayer_fixes_test.rb`: 5 tests, 16 assertions passed.
- `ruby tools/test_readiness.rb`: 1 test, 1 assertion passed with upstream reactor.
- `powershell -NoProfile -ExecutionPolicy Bypass -File
  game-mod/test/server_replacement_test.ps1`: 11 checks passed.
- Same PowerShell invocation for desktop_launcher_test.ps1: 13 checks passed.
  Initial invocations without Bypass were blocked by execution policy.

Broader attempted suites are NOT passing: arena_visits_server_test.rb has stale
protocol-2, pre-snapshot and small-map fixtures (5 failures, 1 error).
arena_visits_client_test.rb and arena_customization_test.rb fail loading because
their MenuHandlers stub lacks remove. live_connection_test.rb has 2 fixture
errors (missing LanDiscovery and request_pending?). multiplayer_arena_test.rb
and login_connection_test.rb require DATABASE_URL and did not start. No production
database was used for testing.

No game GUI, real cold host startup, authenticated clients or two-computer test
was executed. A zero-bug multiplayer claim is not supported. Manual steps:
install this updated source on both computers (or publish fresh installers),
close both games and relaunch Play-Arena.bat. Host once with the service stopped;
request a visit once from the other PC. Walk players/followers into obstacles
and boundaries, finish a visit, disconnect/reconnect and check saved arenas.
If startup still fails, retain tools/runtime/desktop-server stderr and
pemk-server.log for diagnosis. Successful protocol/socket tests do not establish
successful in-game multiplayer.

## Visitor crash, guide collision and custom arena synchronization (v6.2.6)

The reported follower exception occurred because ArenaRemotePokemon inherited
Essentials movement code that calls check_event_trigger_after_turning, a hook
that exists on event/player characters but not this visual-only Game_Character.
The remote follower now implements an empty hook so it cannot trigger map
events. The entrance guide tile is explicitly blocked by client passability and
retained in the server position audit to prevent walk-through followed by a
server correction.

Arena visits now send a 10,000-byte surface grid and up to 96 placed furniture
and trainer entries with the visit state. Server checks dimensions, allowed
tile codes, placement identifiers, overlaps, occupied map events and walkable
tiles. Each client resolves trainer/furniture sprites from its local Essentials
assets. Visitors apply a read-only snapshot to their map; it does not replace
their own saved tile edits or placements. The visit protocol is now version 3,
so all clients and the host service must be updated and restarted together.
The startup probe now detects an older arena protocol and replaces only the
verified local Arena Lab service when it is idle; active sessions are refused.

Ruby syntax checks and whitespace validation passed. The v6.2.5 core changes
were published at the [v6.2.5 GitHub release](https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2.5).
The service restart fix and refreshed installers are now published at the
[v6.2.6 GitHub release](https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2.6),
pinned to `451fe8b8e9918e31a866f0bfda4ed3bbd772a36d`. SHA-256: Setup
`FB710A30B52C431556AB1EE9073C5BE14DD5E787D6867B4B07049A68DB5183D7`; Update
`E7C3E4A55AA220952F28E2D9B88D2CA4CD34EAA44FF2B367CE25D9FDAF2E34B9`.
No live two-computer playtest has yet confirmed the follower fix or full custom
arena rendering.

## Arena visit bounce, map music and entrance attendant (v6.2.3)

Fixed the online arena position audit to match the current 100x100 arena map
with its centered 25x25 floor. The server previously validated the first arena
position using obsolete small-map coordinates, rejected the host/visitor's
first presence frame, then corrected it back to the entrance. Object collision
coordinates and the arena entry transition now use the centered-map offset.

Generated village, entrance and arena maps now explicitly enable autoplay for
the music inherited from their Essentials map templates. The entrance
attendant is restored after the entrance map reloads and if an event left it
erased or transparent. These fixes passed Ruby syntax checks; the current GUI
session was not available for a game/audio/multiplayer playtest.

The Following Pokemon EX archive at the official resource page identifies
Essentials 21.1 compatibility and requests contributor credit, but the page
does not state redistribution rights. It therefore remains out of the public
Setup EXE and GitHub assets. The installer still supports a user-provided local
archive. Both players need their own compatible installation to see followers.
Official resource: https://eeveeexpo.com/resources/516/.

Windows Setup now offers a picker for a separately downloaded follower archive
and installs it into the selected Essentials project; choosing No continues
without follower visuals.

Committed and pushed as `b9bb419c57b1234e8b14c2bd38a14e2261aac06c`.
Built and published updated executables at the [v6.2.3 GitHub
release](https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2.3).
SHA-256: Setup `E661D44F5BBDE7E79D32AFD617B56C608A999885D42E101DA74DDE960A93B199`;
Update `4A93D110D58E8A9BA329C5E3DE19D41B8931F17123163091DBAD14F61F4A986D`.
No two-computer or in-game audio/visibility retest has been performed yet.

## Cross-computer LAN discovery and follower visibility (v6.2.2)

The user reported that same-PC multiplayer worked, but two-computer discovery
failed with Windows' `recvfrom(2)` “existing connection was forcibly closed”
error. The client probes `127.0.0.1` as well as LAN broadcasts; on a remote
client with no local responder, Windows can report the loopback UDP probe as
`WSAECONNRESET`. Discovery now ignores that expected reset and keeps listening
for LAN replies. The fix passes Ruby syntax validation; it still needs a two-PC
playtest.

The friend has no follower because the third-party Following Pokemon EX archive
was not installed. It is optional for starting or multiplayer; without it that
machine renders no follower. Both players need version 2.5.1 for Essentials 21.1
plus the matching assets if they want to see each other's walking followers.
The archive is not redistributed; each player obtains it separately and puts
`Following Pokemon EX.rar` in their Arena Lab root before launching. The current
source asks for no installation when the archive is absent.

Built and uploaded both installer EXEs pinned to
`913784bd8fc876599ca4d66536a836aff722cd8a` at the [v6.2.2 GitHub
release](https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2.2).
SHA-256: Setup `6FD107DDC046C9CBDC6D9FEDDC8156476B811B5A599B28298B822767FEE8BC61`;
Update `46170905B06C6BFDE5C4C6C687CDF18172064BE7E07FF63B529D68E895F831CD`.
The new EXEs are published; discovery still needs a user playtest across two
computers to confirm the Windows socket fix in the actual network environment.

## Optional Following Pokemon EX dependency (v6.2.1)

The user reported a friend could no longer start Play-Arena after updating from
v3 because the launcher stopped on a missing Following Pokemon EX RAR archive.
That plugin provides follower sprites, but it is not required for core play or
multiplayer, and its third-party archive cannot be redistributed. Preparation
now skips follower installation when the archive and local plugin are both
absent, and the plugin-cache sync removes any stale compiled entry in that case.
If a player supplies the compatible Essentials 21.1 archive, the existing safe
install path remains available. A conflicting installed plugin still reports
an error instead of being silently replaced.

Built and uploaded refreshed installers pinned to commit
`f723550f83c3cc92f77db549c7a939b5d8308dcc` at the [v6.2.1 GitHub
release](https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2.1).
SHA-256: Setup `3E6FD1D198E71FD6A092B4D5B65CA2736EDAD0B0350E605B51D021CDB546579F`;
Update `1C47C4044C4C880459A3CE9B6608480016E4F90A49D04C1180C7B6774850523E`.
PowerShell and Ruby syntax checks passed, and `git diff --check` passed. A full
game launch or multiplayer retest was not run in this session.

## New Arena Village and separated map exits (plugin 0.9.21)

### v6.2 status and next work

The generated map is functional but visually rough and currently ugly; treat it
as a placeholder. A finished village should be laid out manually in RPG Maker XP
using the editor, then the map events/transfers should be rechecked. The next
gameplay milestone after that is an open world extending beyond the village, with
exploration routes, lore/story and wild-Pokémon encounters. The current small
village grass patch is only a temporary proof of catching.

The Windows installer sources are kept in `tools/deliverables/`. Built
`ArenaLab-Setup.exe` and `ArenaLab-Update.exe` for source commit
`435d5c0c8c429282714e2201a48a074e5b903b3c` and uploaded both to the [v6.2
GitHub release](https://github.com/EvannKurzawa/arena_lab/releases/tag/v6.2).
The EXEs in ignored `dist/` are release assets, not repository files. The first
upload attempt exposed a Windows PowerShell JSON encoding issue; the publisher
now sends UTF-8 request bytes.

Replaced the generated Lappet Town layout with a new 32x24 Arena Village map.
It contains a central stadium, three matching house sprites, residents, paths,
trees, and a small tall-grass area. Wild encounters now use the village grass
area and remain offline-only. The entrance-room exit returns to `(16,12)`, in
front of the stadium. All generated village house events are local interactions
and have no transfers; entering the stadium still leads to Arena Entrance (102),
then Arena (100). The generator unregisters and deletes Map 103 only when its
registry name is the project's old generated `Founders' Path`. The original
Essentials map files remain in the private base project for compatibility, but
neither quick start nor the full intro now leaves the player in Lappet Town or
the old route. The full intro's final transfer is redirected to the village
and sets the entrance room as the healing return point.

Generated new matching pixel-art sprite sheets for `$ArenaFacade` and
`$VillageHouse` (both 4x4 RPG Maker XP character sheets) under
`game-mod/Graphics/Characters/`; map preparation copies them into the local
Essentials project. Updated the village encounter/story plugin, README files,
and plugin metadata to 0.9.21.

Validation: Ruby syntax checks passed for `build_arena_map.rb`,
`001_ArenaDemo.rb`, and `006_FoundersPath.rb`; `git diff --check` passed with
only Git line-ending notices. The private runtime's `Data/Map002.rxdata` path
did not respond to a filesystem probe in this session, so map generation and an
in-game visual/transfer check have **not** been run. Close the game and launch
`Play-Arena.bat` locally to regenerate maps 100-102 and test village → entrance
→ arena → entrance → stadium-front return, house interactions, and grass-only
encounters.

## Arena facade sprite and village placement correction (plugin 0.9.20)

The user reported that the first facade rendered as repeated/cropped stadiums
over the old house and sat at the village edge. The source sheet had three
columns, but RPG Maker XP expects four directional frames for a `$` character;
regenerated it as a 640x512 4x4 sheet, with each identical frame showing the
160x128-pixel (5x4-tile) facade. The generator now preserves the original home
door and places a separate arena entrance at the nearest walkable site to the
village center, requiring the entire facade footprint to be clear. The home
door remains a home; the stadium sign is placed nearby. Save-load recovery now
reloads Map 101 from generated data too, so Continue sees the new layout. Ruby
syntax and sprite dimensions/transparency were checked; an in-game retest is
still pending. Close all clients and run `Play-Arena.bat` to rebuild the map.

## Arena-style village exterior (plugin 0.9.19 history)

The user pointed out that Arena Village still used the original house exterior.
Added an original stadium facade sprite at
`game-mod/Graphics/Characters/$ArenaFacade.png` and updated the map generator to
use it for the entrance building event. The entrance interaction is preserved;
the foyer's normal door graphic is saved separately so it is not replaced by
the oversized facade. Preparation copies the sprite into the private Essentials
game and regenerates Map 101. The first sprite layout placed the building at the
original house and did not match RPG Maker XP's four-column frame convention;
the correction above supersedes that placement and layout.

## One-time Zekrom and Dialga save grant (plugin 0.9.19)

The user requested level-100 Zekrom and Dialga directly in the party. The
private save files are not readable in this execution context, so I did not
attempt to unmarshal or overwrite a guessed save path. Instead, an ignored
one-time marker at the repository root arms `012_OneTimeLegendaryGrant.rb` for
the primary offline profile only. On the next `Play-Arena.bat` launch, the game
adds both Pokémon to the party through Essentials' own `Pokemon` and save APIs,
then saves the offline profile and consumes the marker. Existing Zekrom/Dialga
are not duplicated, and a party without two free slots is left unchanged. The
grant is local-only and the marker is gitignored. It has not run yet; close all
game windows and launch `Play-Arena.bat` once to apply it. The launcher cache
sync fix from 0.9.18 ensures this new plugin script loads from an existing cache.

## Following Pokémon cache loading correction (plugin 0.9.18)

After the user launched the game and still saw no follower, inspection found the
cached plugin synchronizer only refreshed Arena Demo. If Essentials already had
`Data/PluginScripts.rxdata`, the newly installed Following Pokemon EX could be
missing from that cache and thus never load. `tools/sync-plugin-cache.rb` now
adds or updates both Arena Demo and Following Pokemon EX entries, preserving a
one-time cache backup. Deferred network hook installation also handles either
plugin load order. This is the first fix to try; no game relaunch has verified it.

## Following Pokémon in the arena and multiplayer (plugin 0.9.17 history)

The user supplied `Following Pokemon EX.rar`; its metadata was inspected and
confirms version 2.5.1 for Essentials 21.1. The RAR includes the plugin scripts,
matching walking follower sprites and animation data. It is ignored by Git and
must be supplied separately on each computer because it is third-party content.
The resource page is [Following Pokemon EX on Eevee Expo](https://eeveeexpo.com/resources/516/).

Added `tools/install-following-pokemon.ps1` to extract and install that plugin
into the private Essentials project during client preparation. It retains the
original `Data/Animations.rxdata` as
`Data/ArenaLab-Animations-before-FollowingEX.rxdata`, merges plugin animations
and remaps configured IDs rather than replacing the Essentials table. It also
disables plugin hotkeys for toggling/cycling party members, so the lead able
Pokémon remains consistent with multiplayer. The installer refuses a different
existing plugin version or conflicting local sprite files. The RAR itself and
extracted temporary files are excluded from Git.

Map generation now places a hidden follower anchor on maps 100-103. The Arena
Demo integration starts the actual Following Pokemon EX follower from that map
event, preserving its native walking, collision and sprite behavior. Presence
frames carry only a validated species/form/gender/shiny/shadow descriptor on
arena-world maps. The server validates and forwards those fields; each client
resolves the character sprite from its local plugin assets. Remote Pokémon use
an animated walking character behind their owner. This remains source-level
implementation pending in-game checks of local following, two-machine sprite
agreement, save reload and animation merge.

The archive was verified and an installation was attempted against the ignored
local Essentials runtime, but the runtime path did not return in this execution
context; therefore installation into that private game and an RPG Maker/mkxp
launch are not claimed. Run `Play-Arena.bat` after placing the RAR at the project
root; preparation installs the matching plugin on each computer.

## Visible return door and follower sprite correction (plugin 0.9.16 history)

Map generation now gives the south return tile a visible door graphic copied
from the Arena Entrance door; stepping onto it still transfers to the entrance
room. The arena building is marked by the village sign. The oversized static
Pokemon icon prototype was disabled after the user reported its size and lack
of HGSS-style movement. The user-provided `Following Pokemon EX.zip` was
inspected: its metadata identifies v2.2.3 for Essentials 20.1 and requires the
v20.1 hotfixes; it contains no overworld follower sprite sheets. It is therefore
not installed into the v21.1 project. This was superseded after the user supplied
the correct v2.5.1 Essentials 21.1 RAR. The visible return door still has no new
in-game test in this update.

## Editor text layering and catalog navigation (plugin 0.9.14)

Lowered the full-map overview below Essentials' message layer (z=99999), so
prompts should now render above it. Removed duplicate up/down handling from the
sprite catalog loop: `Window_CommandPokemon#update` already moves the selection,
and the extra adjustment caused skipped or stuck entries. Ruby syntax and
`git diff --check` passed. The user tested the game and confirmed text layering,
furniture selection, trainer selection, and the complete editor workflow work.

## Mode-based arena editor (plugin 0.9.13)

Implemented ground, trainer, and furniture editing modes. Select a surface or
owned Bag item once and apply it to multiple tiles with Enter. Placement modes
include matching-item removal, occupied tiles offer replacement or removal, and
inventory changes continue to roll back on cancel. The tile renderer now reads
the editor's draft surface records, so ice previews as ice immediately. At the
farthest zoom, dialogs leave the overview visible behind them instead of
switching to the regular map view. Ruby syntax and `git diff --check` passed;
in-game verification is recorded under plugin 0.9.14 above.

## High-zoom overview cursor (plugin 0.9.12)

The user reported that the selected tile cursor was too faint to see at the
farthest U-key zoom. The old 32x32 cursor scaled to a tile about 9 pixels wide,
making its 3-pixel border less than one screen pixel. Plugin 0.9.12 adds a
separate overview cursor sized to one overview tile, with a dark outer edge and
bright inner frame; the old 32px cursor remains for the normal and half-scale
views. The global cursor follows every arrow move and is explicitly hidden when
returning to the closer zooms. This cursor is part of the editor workflow the
user confirmed working with plugin 0.9.14.

## Zero-keypress resume from Play-Arena (plugin 0.9.11)

The user asked for existing saves to open without the two Enter presses after
launch. `tools/launch-client.ps1` now sets `ARENA_AUTO_CONTINUE=1`; the Arena Demo
plugin intercepts Essentials' load screen and loads the existing save directly.
When no save exists, the normal title/New Game menu remains. This is scoped to
the standard Arena Lab launcher, not direct `Game.exe`/mkxp launches.

Direct Prepare installed plugin 0.9.11. I launched `Play-Arena.bat` with the
existing arena save and captured the game after startup: it opened directly on
Map 100 with the floor, player and guide visible, without Continue or Enter.
Ruby syntax and PowerShell parse checks passed. The no-save New Game branch was
not tested in this run; by code path it falls through to Essentials' normal
title menu.

## Restore the centered arena after save reload (plugin 0.9.10)

The user reported that loading their arena save now shows an infinite grass
field. This confirms the direct-save reload reaches the generated floor, but the
0.9.6 full-map fallback was too broad for the intended layout. In my local
0.9.9 reproduction, loading the existing save displayed grass across the whole
map. Plugin 0.9.10
restores a visible, walkable 25x25 centered floor with void outside, both in
Map100 generation and save recovery. The 0.9.9 `Game_Map#setup(100)` recovery
remains, so direct saves rebuild from that canonical centered map. Prepare
verified a centered 25x25 ground count (625/625), and the following 0.9.11
launch confirmed the arena remains visible after direct save load.

## Direct-save arena recovery (plugin 0.9.9)

The user clarified that starting a new game outside town and entering the arena
works, while loading a save already on Map 100 produces void. I reproduced that
case in the local game: Continue loads the arena and the guide dialogue appears
over a black map. This isolates the failure to save-load of a serialized
`Game_Map`, not ordinary Map 100 generation or map transfer.

Plugin 0.9.9 now calls `Game_Map#setup(100)` after Essentials loads a save whose
current map is 100. It preserves the saved player position/direction and
PokemonGlobal arena edits, then reapplies floor edits and placements and centers
the camera. This reloads authoritative generated Map 100 data instead of
retaining the stale serialized tile Table. Local reproduction with 0.9.9 showed
that it restores the grass floor; 0.9.10 restores the centered 25x25/void
layout.

## Live RGSS map/renderer diagnosis (plugin 0.9.8)

The previous tile-ID hypothesis was not sufficient: preparation reports the
actual generated center stack as `[401, 0, 0]`, and the existing Outside tileset
image is present. Tile 401 is above Essentials' blank-ID range, so this does
not explain the user's black screen. I added a runtime diagnostic to avoid
further guesses. On the next arena load, `Data/ArenaFloorDiagnostic.txt` records
the live RGSS `Game_Map` dimensions/tileset/center stack, counts renderable
layer-0 cells, resolves the generated ground-file paths, and captures the first
nonblank tile sprite's bitmap/source rectangle from `TilemapRenderer`.

Plugin 0.9.8 passes Ruby syntax validation. It still needs one game launch on
Map 100 to produce the diagnostic. Do not claim this report is fixed until the
live renderer evidence identifies and resolves the cause.

## Renderer-level floor fix (plugin 0.9.7)

The user confirmed plugin 0.9.6 still rendered black. I traced Essentials v21.1's
`TilemapRenderer#refresh_tile_bitmap`: tile IDs 0-47 are explicitly treated as
the blank autotile block. Our earlier floor selector only rejected ID 0, so a
nonzero tile in that range could pass collision/passability checks while drawing
nothing. Plugin 0.9.7 rejects IDs below 48 in both the generator and runtime
floor validation. The map build now reads Map 100 back after serialization,
checks its center tile stack matches the selected floor, and prints those IDs.
This gives the next Prepare a direct data-level check rather than just saying
the map file was written.

The generated stack is `[401, 0, 0]`, so the <48 hypothesis does not account for
the observed black screen. Plugin 0.9.8 adds live engine diagnostics to identify
whether data or the tile bitmap is missing.

## Full floor recovery after black-map report (plugin 0.9.6)

The user confirmed the 0.9.5 fix still showed black/void ground; their screenshot
shows only the boundary boulder events and player. The prior design left 75% of
Map 100 empty by default, and runtime recovery reconstructed only the initial
25x25 field. To remove void as the implicit/default state, plugin 0.9.6 makes
all 10,000 tiles walkable with the generated base floor. Unedited tiles now
render and collide as ordinary field; only saved tile records explicitly marked
`void` become empty. Map generation and runtime recovery use the same rule. The
center remains the spawn and starting footprint.

Direct Prepare rebuilt Map 100 and verified plugin 0.9.6 in the compiled cache
(`f81174ead2ca`). Ruby syntax checks and `git diff --check` pass. No GUI launch
or in-game rendering verification has been performed. Close all game windows,
launch `Play-Arena.bat`, and load the same save. If the full map still renders
black, the next cause is the actual tile graphic/tileset mapping; inspect the
local `Data/Tilesets.rxdata` and exact ground tile IDs from the game runtime.

## Persistent void recovery (plugin 0.9.5)

The user reported that Map 100 still renders black and the global editor view
shows void after plugin 0.9.4 was prepared. Source review found two paths that
could preserve that failure: all-void saved tile edits override the default
field, and a missing/invalid generated floor could silently become an empty
`[0,0,0]` stack. Plugin 0.9.5 clears only a large, overwhelmingly void legacy
edit grid, searches for `ArenaDemoGround.txt` from the game and plugin data
directories, accepts passable terrain-tagged base floors, and never applies an
empty stack as normal ground. A missing floor now leaves the current map intact
instead of painting it empty.

This is an implementation based on source inspection, not a reproduced GUI fix.
The screenshot did not show a plugin version or log. Plugin 0.9.5 passes Ruby
syntax validation, and direct Prepare rebuilt Map 100 and verified the 0.9.5
compiled cache (`46490d4e92d5`). The player save has not been inspected and no
in-game relaunch has been performed here. Close all game windows and relaunch
`Play-Arena.bat`, then load the same save and check the normal view and U-key
overview. If it remains black, retain the new prepare log and `mmo.log` from
that launch.

## 100x100 arena editor upgrade (plugin 0.9.4)

The first launch loaded both plugins, then logged a `NameError` in the zoom
renderer because Essentials' tile size/zoom constants were unqualified. Plugin
0.9.1 fixed those references. The user then reported that the full-map view was
hard to read, the zoom return looked wrong, editor overlays covered choices,
ice looked like grass, the starting field was off-center, and occupied tiles
did not provide a usable ground-change action. Plugin 0.9.2 addresses these
reports. The next playtest then found that the player could not move, custom
mode treated the floor as void, and older painted tiles stayed at the top-left
while the base field was centered. Plugin 0.9.3 now falls back to ground from
older map data, transforms stale start points, refreshes fixed/saved objects,
recovers a player saved on void and runs a third edit-coordinate migration. The
user still found the arena void after relaunch. Inspection showed Essentials can
load the saved `Game_Map` without calling `setup`, preserving old zeroed map
data. Plugin 0.9.4 now reapplies arena data after `Game.load_map` and reads the
canonical ground tile stack generated to `Data/ArenaDemoGround.txt`. The global
overview now uses solid colors and restrained grid guides. A direct Prepare
succeeded, generated the centered Map 100 and ground data, and verified the
Arena Demo 0.9.4 compiled cache. No in-game test has been run by Codex.

Map 100 now builds at 100x100, with a centered 25x25 starting field and the
remaining tiles empty and blocked as void. Custom mode cycles normal, zoomed-out, and
full-map overview with the raw U key. Any selectable tile can be made field or
void, and field tiles can be painted with plain/concrete, grass, desert/sand,
rock, or ice. Surface edits preview immediately, save in player metadata, and
are reapplied whenever Map 100 loads. Essentials' existing ice terrain tag
drives sliding movement. Placed objects/trainers cannot be stranded in void;
the guide, sample trainer, and exit tiles are protected from being voided.

The user playtested the editor and confirmed that ice slides correctly, while
reporting the issues listed above. Plugin 0.9.3 needs in-game verification for
movement, floor/void collision, centered rendering, zoom, ground painting and
save/reload. Launcher preparation rebuilds Map 100, copies the plugin and
refreshes the compiled plugin cache. Existing saves retain arena placements and
migrate items/ground edits from the former top-left starting field into the new
centered field.

## v5 - first custom mode (2026-10-28)

Implemented the offline tile-based arena editor in plugin 0.8.6. The Arena
Guide opens Custom mode and trainer recruitment. Players can edit furniture and
recruited trainer placements, save or cancel a draft, and challenge placed
trainers. The Bag has eight tabs: former Mail and Battle Items are routed to
Items, with Key Items and the two Arena tabs retained. Existing Bag saves
migrate pocket contents and selection positions. The pause-menu Arena Demo
entry was removed.

The user opened trainer recruitment in-game and confirmed the heading now
displays fully after the catalog window height fix. The full placement,
save/reload, furniture and trainer placement, and battle loop have not all been
confirmed. This is a partial visual check, not a full custom-mode playtest.
`git diff --check` passed; no automated tests or RPG Maker launch were run by
Codex.

## Catalog heading clipping fix

Increased the custom catalog heading window from 48 to 72 pixels. Its border
left too little content height for the Essentials font's vertical offset,
clipping “Choose a trainer to recruit.” Plugin version 0.8.6 refreshes installed
copies. The visual fix needs in-game confirmation.

## Catalog row clipping fix

The catalog now uses 56-pixel rows and draws the full character frame height;
this addresses both clipped text and the half-visible trainer sprites shown in
the user's screenshot. Plugin version 0.8.5 refreshes installed copies. The
visual fix still needs in-game confirmation.

## Trainer selection text alignment

The trainer and furniture catalog renderer now applies the configured
Essentials text offset, matching the built-in command window and correcting the
clipped row labels shown in the user's screenshot. Plugin version 0.8.4
refreshes installed copies. The visual fix still needs in-game confirmation.

## Recruitment message and pause-menu cleanup

Shortened the trainer recruitment confirmation to one line and removed the
obsolete **Arena Demo** pause-menu handler. The Arena Guide remains the access
point. Plugin version 0.8.3 refreshes installed copies. This change has not
been launched in RPG Maker XP or playtested in-game.

## Bag layout consolidation

The Bag now has eight tabs: Items (including former Mail and Battle Items),
Medicine, Poké Balls, TMs & HMs, Berries, Key Items, Arena Furniture, and
Recruited Trainers. Existing saves migrate the old pocket contents and cursor
positions, including saves from the earlier ten-tab Arena Bag. Plugin version
0.8.2 causes installed copies to refresh during preparation. This source change
has not been launched in RPG Maker XP or playtested in-game.

## Arena Bag compatibility and customization access fix

The first custom Bag-tab implementation could encounter missing selection
indices in older saves when Essentials opened a newly added pocket. The plugin
now extends all pocket arrays, normalizes remembered indices, and also performs
that migration before `PokemonBag#last_viewed_index`. The obsolete pause-menu
customization entries have been removed; custom mode is available only through
the offline Arena Guide. Plugin version is now 0.8.1 to force the installed
plugin cache to rebuild on preparation.

## Offline arena custom mode - implemented in source, game playtest pending

Added **Custom mode** to the offline Arena Guide. The editor uses an overhead
tile cursor, previews furniture or trainer sprites in selection lists, edits a
draft layout, and can save the draft or discard all changes. Arena Furniture
and Recruited Trainers are separate Bag pockets. A few furniture pieces are
seeded into the Bag; two trainer profiles can be recruited, placed, challenged,
removed (kicked back to inventory), and replaced. Validated placements persist
in the player's save and use reserved runtime event slots in Map 100.

At the time of the initial implementation, the source and map generator had
not yet been tested in-game. The later partial visual check is recorded under
v5 above. A normal first launch with no other player window runs preparation
and rebuilds Map 100 with the new slots. Online visitors continue to use the
existing fixed multiplayer arena snapshot; this editor and recruitment are
offline-only. The full custom-mode loop remains to be tested.

## v4 - simplified LAN visit flow tested in-game (2026-10-28)

Implemented the requested entrance-attendant flow after the user confirmed
that the previous manual-address/account-invitation visit worked between two
computers:

- Removed the old "return to previous location" action from Arena Demo entry
  and removed the pause-menu Connection action. At v4, arena customization was
  still reachable from the arena menu; the 0.8.1 entry above moves it to the
  offline Arena Guide.
- Hosting advertises the private arena over LAN UDP port 9997. Visitors discover
  it automatically, select **Request to visit**, and the host accepts or declines
  at the attendant. No address or account ID is typed or exchanged.
- The attendant displays Offline, Hosting, Connected, or Visiting and offers a
  Disconnect action. Customization stays locked while an arena is open or a
  visit request is pending. Visitors remain restricted to the entrance and arena.
- The visit protocol readiness marker is now version 2 so the managed launcher
  can detect and replace an older idle local service; active services are not
  replaced. Game traffic remains TCP port 9998.

The user reports that the updated flow works in-game on one computer. A repeat
test between two physical computers has **not** yet been performed, so LAN
discovery and request delivery across machines remain unverified. Update both
Arena Lab installations from the same source before that test. On Windows,
allow the host's Ruby service through the private-network firewall for UDP 9997
(discovery) and TCP 9998 (game traffic). If discovery fails, inspect
`tools/runtime/desktop-server.log` and verify both computers are on the same LAN.
The clean installer still does not provision a server backend on a fresh host.

## v3.5 - first GitHub client connected from a second computer (2026-10-28)

The user confirmed that multiplayer communication worked between two physical
computers on the same local network. The second computer used ArenaLab Setup
downloaded from GitHub and its own Essentials v21.1 PE21 folder; it joined the
host running on the first, already prepared computer using that host's LAN IP.
Record this as a user-run two-machine communication check. Do not imply Codex
operated the clients or that every visit/battle flow was separately verified.

This validates the first milestone: a GitHub-installed client can communicate
with a prepared host on another computer. The clean install is still client-only;
provisioning PostgreSQL and native Ruby server dependencies so either fresh
computer can host is later work. Internet/NAT hosting is also not tested.

Added `TWO_COMPUTER_SETUP.md` with the Essentials v21.1 download and hotfix
links, client setup, LAN IP, and invitation steps. The tested steps use
`Play-Arena.bat` on each machine; the second computer enters the address shown
by the host as **Other PC on your network**, not `127.0.0.1`.

## Windows installer work - 2026-10-28

### v3.3 install-folder PowerShell fix

The user retried v3.2 and hit PowerShell treating `-and` as a `Test-Path`
parameter in the empty-destination check. Rewrote that check as an outer
`Test-Path` followed by a separate child-item check. The installer build's
embedded-script parser and .NET wrapper compilation passed. Published the
v3.3 rebuild at `https://github.com/EvannKurzawa/arena_lab/releases/tag/v3.3`
(source commit `8de45e8af0245fb24414448ea84331ec358966a6`):

- `ArenaLab-Setup.exe`: 36,864 bytes, SHA-256
  `9DFE0FF2413D4F80EED8C4553109D723D758F5CED373531CF38927B3572FE516`.
- `ArenaLab-Update.exe`: 25,600 bytes, SHA-256
  `D8D8F15AC10E637DDC611E1BA565ACDEED4C6DBDD5F359D7D715C63E9283D3F3`.

At the time of this entry, the user had not retried v3.3. The later v3.5 update
below records that Arena Lab was subsequently installed from GitHub and used to
join from a second computer.

### v3.2 PE21 folder-selection fix

The user tried the v3.1 setup with the downloaded `PE21` folder and reported
that `Data/Scripts/001_Settings.rb` was absent. The v3.1 bootstrap incorrectly
read that optional extracted source file even though a compiled Essentials pack
may provide `Data/Scripts.rxdata` without extracted sources. v3.2 now checks the
version only when `001_Settings.rb` exists; it still requires `Game.ini`,
`Data/Scripts.rxdata`, and `Graphics`. The user has not yet retried v3.2, so a
successful install is not claimed.

The rebuilt packages pin Arena Lab commit
`f3f46f10dc4b4bcaa976dd0749aedd26849b0da1` and are published at
`https://github.com/EvannKurzawa/arena_lab/releases/tag/v3.2`:

- `ArenaLab-Setup.exe`: 36,352 bytes, SHA-256
  `77FA8A28E4EB8D937E6F1E8227EAED38BB9C3330977C32385CC68EFE6963821A`.
- `ArenaLab-Update.exe`: 25,600 bytes, SHA-256
  `990D5E6547C595151D6552F99397938875CDCF632FFE775294504F6B27D11C25`.

Added two self-extracting EXE build targets using a .NET Framework wrapper
with an embedded PowerShell bootstrap, plus their PowerShell
bootstrap scripts: `ArenaLab-Setup.exe` for a clean client and
`ArenaLab-Update.exe` for updating Arena Lab source from GitHub `main`. The
builder is `tools/package-deliverables.ps1`; generated EXEs belong in `dist/`
and are gitignored. Build completed with Windows PowerShell and the .NET
Framework 4 C# compiler. The builder parsed both embedded PowerShell scripts,
compiled both wrappers, and recorded these package checksums (installer source
commit `24b2d04cd3d822abba2a77a04b373fb7c728288f`):

- `ArenaLab-Setup.exe`: 34,816 bytes, SHA-256
  `1254D7990BCA895F4FBF244107642605A9D04F0BF97AFE9F32AC7FFF4676CCDA`.
- `ArenaLab-Update.exe`: 25,600 bytes, SHA-256
  `0B7F3D8DACAE89CB2BE8C571180D163E32B161C66DA365576AA7562340EE91F2`.

These checks validate script parsing and EXE construction, not a full install or
update run. Neither EXE has been run against a recipient's game folder yet.
Both assets were uploaded to the public GitHub release
`https://github.com/EvannKurzawa/arena_lab/releases/tag/v3.1` after an initial
publisher header collision was fixed and the upload was resumed successfully.

The clean setup pins Arena Lab to the source commit embedded by the builder,
downloads the PEMK source ZIP and portable Ruby with SHA-256 checks, downloads
the official mkxp-z client through the existing checksum-pinned installer, and
copies a user-selected Essentials v21.1 game folder into the local install. The
update EXE applies only files included in the GitHub source archive and backs up
the exact files it replaces; it does not traverse `tools/runtime`. It refuses
to update while a game process for that install is open.

**Distribution limit:** this is not a legally redistributable, all-in-one game
with Pokémon graphics/audio/data. Essentials v21.1 must be obtained separately
by the player, consistent with its README; PEMK asks that builds containing
Nintendo-derived assets remain private tests. Also, fresh setup currently
prepares an offline/join client but does not provision the PostgreSQL/native
Ruby server stack needed to host from that new computer. The existing prepared
host/update path remains available. See the packaging notes in `README.md`.

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
# French title and localization — 2026-10-30 (Arena Demo 0.13.0)

Resumed the interrupted work (`020_FrenchTitle.rb`, `compile_french_core.rb`,
and title-copy preparation were already present). No upstream checkout changed.
Added French presentation using Essentials' native translation files, plus
Arena Lab dialogs, menu choices, map/item labels and variable messages. French
is loaded at startup for new and existing saves. Saved object keys, species
symbols and multiplayer protocol values remain unchanged.

The user-provided PNG is copied to `Graphics/Titles/arena_title.png`, scaled to
fit without cropping. Added a blinking French start prompt, music selection,
fade and bitmap disposal. Confirm retains Essentials' Continue/New Game flow.
Private title art and downloaded audio are not committed or bundled.

Local translation source: Essentials v21.1 French core pack 1.2, downloaded in
the earlier interrupted session from https://eeveeexpo.com/resources/1860/download
and its MediaFire link
https://www.mediafire.com/file/8fldcrs3faxseyj/Text_french.dat_core%25281.2%2529.zip/file.
Compiled 10,691 entries into the ignored runtime's
`Data/messages_french_core.dat`. Pack 1.2 contains a duplicated Darmanitan dex
translation line; the compiler repairs that exact duplicate before validating
pair counts. Third-party translations remain in the private runtime; no blanket
redistribution permission is assumed. Core coverage audit: 68 of 3,305 default
script keys absent from the pack, primarily compiler/developer diagnostics.
Original upstream sample-story map dialogs are outside this core pack. A claim
that every possible upstream/debug string is French would therefore be false.

Music source verified through YouTube oEmbed: the requested video
https://www.youtube.com/watch?v=yyhJCtAtw3g is “Pokémon Heart Gold & Soul Silver -
Title Screen (HQ)” by Volipok. Downloaded using the local yt-dlp executable:
`tools/runtime/yt-dlp.exe --no-playlist -f bestaudio -o tools/runtime/title-music.%(ext)s URL`.
Converted with local FFmpeg 9.0.2:
`ffmpeg.exe -nostdin -y -hide_banner -loglevel error -i tools/runtime/title-music.webm -codec:a libmp3lame -q:a 2 tools/runtime/arena-title.mp3`.
The MP3 is copied to `Audio/BGM/Arena Title.mp3`. Tools and audio remain ignored.

Commands/checks: bundled Ruby 3.3.12 with `--disable-gems` compiled the native
French message file; `tools/runtime/finish-title.py` copied the PNG, MP3 and
plugin scripts and ran `tools/sync-plugin-cache.rb` (23 Arena Demo scripts).
Sandbox denied the runtime Data write; the approved elevated retry succeeded.
`ruby --disable-gems game-mod/test/french_title_test.rb` verifies native French
species/moves/menu text, accents, installed assets, dialog choices, nested
variable messages, timer, multiplayer placeholders and title scene lifecycle
against the original Essentials title class with mocked graphics/audio.
This verifies code paths, not actual audio playback or rendered GUI appearance.
No new GUI launch or two-client test is claimed.

Changed files: `020_FrenchTitle.rb`, new `021_French.rb`, custom editor help
localization in `009_ArenaCustomMode.rb`, plugin metadata, French compiler,
`tools/install-french-title.ps1`, preparation hook, regression test, README,
and this report. Close game windows and launch **Play-Arena.bat**; confirm the
art/prompt/music, Continue an existing save, check Pokémon names and finish a
battle in French. For another computer, separately supply the local PNG, MP3
and French source pack described in README before launching.

### Startup fix: Windows translation paths (2026-10-30)

User reported `desktop-launcher-18440.log`: `No translated species found`.
Reproduced with the exact absolute Windows source path passed by PowerShell.
Ruby's `Dir.glob` interpreted the backslashes as escapes and found no translation
files, although `File.directory?` succeeded. Normalize the source directory with
`File.expand_path` before constructing the glob. No assets or saves changed.

Verification: the previously failing absolute Windows path now compiles all
10,691 French entries. New `game-mod/test/french_compiler_path_test.rb` passes
both slash formats with spaces in the source folder. The 14 existing checks in
`game-mod/test/french_title_test.rb` also pass. An initial regression fixture
under the system temp directory was invisible to the sandboxed child process;
the test now creates its disposable fixture under ignored `tools/runtime`.
This checks the compiler/startup preparation issue; GUI startup is not claimed.

### French presentation fixes from user playtest (2026-10-30, 0.13.1)

User reports: guides/entrance choices and talents still English, battle buttons
Fight/Run English, awkward enemy wording/past tense, no title screen. Inspection
found Essentials `pbCallTitle` returns `Scene_DebugIntro` when `$DEBUG` is true;
the launcher uses debug for compilation. Added a plugin entry hook returning
`Scene_Intro` when the custom art exists, and removed the launcher's explicit
`ARENA_AUTO_CONTINUE=1` setting. The normal Continue/New Game menu remains.

Stock battle command labels are embedded in `cursor_command.png`. New
`022_FrenchBattleMenu.rb` draws French buttons in memory, preserving the normal
sprite selection/command behavior and disposing its bitmap. No stock image or
engine source is overwritten. French presentation now also intercepts explicit
Kernel message-display/command calls; ability accessors consult the installed
French core data. Added exact narration overrides before placeholder formatting:
“Le {1} ennemi”, “Le {1} sauvage”, “{1} utilise {2} !”, “{1} est K.O. !”.

Validation: `ruby --disable-gems game-mod/test/french_title_test.rb` passes 25
checks, including the actual ability accessor, Kernel guide/entrance paths,
enemy/wild narration, debug title entry, French command sprite bitmaps and
bitmap disposal. Rendering/audio are mocked in those scene checks, so these
results do not establish a successful native GUI playthrough. The two-format
Windows compiler path regression also passes. Changed `020_FrenchTitle.rb`,
`021_French.rb`, added `022_FrenchBattleMenu.rb`, launcher, metadata (0.13.1),
regression tests and documentation. Close the current session and relaunch
Play-Arena.bat to load the updated scripts.

### Title polish, original battle buttons and dialogue audit (2026-10-30, 0.13.2)

User requested vertically centered title prompt, no stock splashes, original
battle button artwork, and a search for untranslated guide/follower text.
`020_FrenchTitle.rb` now routes stock `open_splash` straight to the custom art.
Prompt drawing uses the full 44px panel and adds Bitmap.text_offset_y, cancelling
the subtraction in Essentials' `001_MKXP_Compatibility.rb` draw_text wrapper.
`022_FrenchBattleMenu.rb` is now a no-op: retaining its filename replaces the
old redraw on existing installations, so stock button images are restored.

The actual CustomModeReception guide method now contains French dialog/choices
directly. Added `023_FrenchFollowers.rb`: follower reactions for all moods,
weather and locations, found-item dialogs and follower option descriptions.
Translations hook native MessageTypes.getFromHash before placeholders are
formatted; this covers _INTL calls inside third-party modules. New
`024_FrenchNetwork.rb` covers remaining PEMK account, battle, trade, shop and
export messages without enabling any new network feature. New
`025_FrenchEngineMessages.rb` covers all 66 missing English core messages;
the other two omissions in the pack are nonlinguistic time-format strings.

Validation executed with bundled Ruby 3.3.12 `--disable-gems`:
`game-mod/test/french_title_test.rb` passes 31 checks, including the actual guide
method/choices, native follower lookup/spinning, splash entry, baseline offset,
and absence of battle button redraw. Graphics/audio are mocked.
`game-mod/test/french_dialogue_coverage_test.rb` passes: 66 missing English core
keys covered, 304/304 literal Following Pokemon EX _INTL keys translated,
131/131 PEMK _INTL keys translated, with identical placeholder multisets.
These audits inspect installed plugin sources and execute native translation
lookup; they are not a complete GUI playthrough or verification of the original
Essentials sample-story event dialogs. No new GUI/two-client test is claimed.
Close all game windows and relaunch Play-Arena.bat to load 0.13.2.

### Actual native localization failure fixed (2026-10-30, 0.13.3)

The user's repeated report was valid: earlier standalone tests did not exercise
Essentials' real PluginManager.runPlugins preprocessing. Upstream
`001_Technical/005_PluginManager.rb:629` runs `code.gsub!("\t", "  ")` before
eval. The tab-separated heredoc tables in 021/023/024/025 were consequently
loaded as EMPTY dictionaries inside the game. This explains why unrelated
NPCs, follower dialogs and choices all stayed English together. Replaced tab
delimiters with ` ||| ` in all four catalogs. The main parser now rejects an
invalid entry instead of silently discarding it. Added `{1}'s -> Talent de {1}`
for the actual ability splash's separate name line (the second line already
uses the translated ability name).

The first diagnostic probe itself crashed on `.encoding` of the empty table's
nil first key; the user supplied that backtrace. Removed that temporary plugin,
fixed the diagnostic and reran it. Its final implementation catches assertion
errors and writes a report, so test failures exit without an in-game error box.
No diagnostic probe is left in the installed game or compiled plugin cache.

Tests now preprocess catalog source exactly as PluginManager does before eval:
`french_title_test.rb` passes 32 checks and
`french_dialogue_coverage_test.rb` passes 66 missing English core keys plus
304/304 follower and 131/131 PEMK literal _INTL keys, preserving placeholders.
Installed the corrected source and regenerated the cache (27 Arena Demo scripts).

Executed a real, hidden mkxp-z boot through its existing Game.ini/bootstrap and
PluginManager, not a standalone Ruby substitute. Native report confirms 733
catalog entries and passes 19 checks: global/Kernel/ArenaDemo/FollowingPkmn
translation calls, ability name and popup syntax, all 435 optional-plugin keys,
actual entrance attendant and choices, inside guide, outdoor scout/resident/
house, and all four village-quest dialog branches. Only the final message UI
sink, inventory setup and test quest flags were stubbed in that disposable
process; real NPC methods and translation wrappers ran. No save was loaded or
written. This proves native text generation, not a visual walk-through of every
possible game screen or the original upstream sample-story events.

Reusable native regression: `game-mod/test/native_french_boot_probe.rb` and
`tools/test-native-french.py`. The runner installs the probe temporarily, starts
its own hidden process, checks its exit/report and restores the cache in finally.
Report: `tools/runtime/native-locale-probe.log`. Close the old game and relaunch
Play-Arena.bat to pick up 0.13.3.

### Essentials phrase audit (2026-10-30, 0.13.4)

Fixed mixed-English inventory wording by removing pre-translation of English
keys before native _INTL lookup. Added canonical matching for extraction/source
line-break differences, targeted grammar/style/format corrections and an
ability-only renderer in 026_FrenchCoreReview.rb. Resource IDs now bypass
presentation translation. Inventory uses “Vous rangez … dans la poche … du Sac.”;
successful escape uses “Vous avez pris la fuite !”.

Browsed HGSS/BW references and consulted a private BW French corpus copy for
brief wording checks. References and precise audit limitations are recorded in
docs/FRENCH_LOCALIZATION_AUDIT.md. No corpus dump was added to tracked source.

Executed audit_french_messages.rb: 3,310 literal Essentials templates individually
recorded with source paths and effective French in ignored
tools/runtime/french_messages_audit.json. Zero English/format/resource failures
under its documented checks; 47 reviewed unchanged labels. This is automated
per-template verification plus targeted semantic corrections, not manual review
of every upstream story-map event.

Installed 0.13.4 and regenerated the cache (28 Arena Demo scripts). Standalone
translation/title and plugin coverage tests pass. tools/test-native-french.py
passes 23 native checks: all 3,310 output strings, actual inventory template,
escape message, ability-only drawing calls, 304 follower/131 PEMK templates and
NPC quest branches. No save loaded/written. Probe removed and cache restored.
Close the old game and relaunch Play-Arena.bat for 0.13.4.

## Concurrent French battle/map wording review — 2026-11-01

Added isolated 090_FrenchBattleWording.rb for command prompts, recall/send-out,
selected status/healing narration and translated map names. Immediate actions
use present tense; legitimate future warnings retain their meaning. Fille Baston
is the official FRLG name; user-requested Combattante harmonizes with the other
established class label without changing CRUSHGIRL or trainer profiles. Short
battle formulations checked against the BW French corpus (abcboy101/poke-corpus);
reference remains ignored under runtime/french-battle-reference.txt only.

Game_Map#name translates all 15 biomes, Arena Demo/Arena Town and Expedition
Sector N fallback labels without touching 016, save IDs or generated maps.
New docs/FRENCH_BATTLE_WORDING.md records references and limits. Dedicated
french_battle_wording_test.rb passed 94 read-only checks using the real Essentials
lookup/interpolation and battle recall/replacement methods: five recall/four
send-out branches, placeholders, nicknames, double/triple names, biome labels
and meaningful future-event language. Earlier 72/89-check intermediate runs
also passed. audit_french_messages.rb loads the new plugin for future audits;
no global report regenerated. README/status notes appended only.

No shared gameplay file, meta version, trainer profile, pack, save, native probe
or plugin cache changed by this work. No GUI session or shared-cache mutation
performed because another agent is editing gameplay concurrently. Initial status
append was denied; retried with escalation. No commit/push performed here.
Close the game and relaunch Play-Arena.bat to prepare the new plugin.

## Isolated basic furniture catalogue — 2026-11-01

User requested 20 basic furnishings inspired by classic Pokemon decorations,
with a visual selector like floors, alongside another agent's gameplay changes.
Added 091_ArenaFurnitureCatalog.rb only for implementation: 20 new items plus
three original obstacles, two copies granted once per profile (old/new saves),
retryable partial grant counting placed copies, native one-cell furniture art
and selector integration via module prepend. Original IDs/CS behaviors retained.
New sources: Interior general native sheet crops and four local Pokemon icons
on doll bases; no external assets downloaded/distributed. Single-cell variants
of chairs, stool, armchair, sofa, desk, table, bookcase, plants, bin, console,
statues, Pikachu/Bulbasaur/Charmander/Squirtle dolls. Native art used identically
in menu and world. No patches to 009, FieldObstacles, shared metadata, existing
native probes or server. Other agent's current changes left intact.

Visual menu reuses the material selector: row thumbnails, larger preview,
quantity, confirm/cancel and remove entries. Cached images remain alive when
sprites are replaced/disposed. Register/load and extra-stock migration support
saved games. Existing visit format relays all new IDs; both clients need the
catalogue. No protocol or server code change required.

Executed portable Ruby game-mod/test/furniture_catalog_test.rb: 26 runs /
1,200 assertions, passing, including existing relief tests. Covers stock,
old/fresh/partial saves, placement/visit round-trip, art/cache and menu entries.
Executed furniture_visit_server_test.rb: 1 run / 16 assertions, passing with
real PEMK reactor/TCP relay of all 20 placements. Executed
C:/msys64/mingw64/bin/python.exe tools/test-native-furniture.py: 101 native checks
passed in a separate copied game/engine, never the shared runtime cache.
Native checks include all 20 sprites/frames/collision sizes, platform placement,
save/load, graphism replacement, CS isolation, actual selector confirmation,
cancellation and unchanged stock/layout while browsing. Visually inspected
furniture-native-report-picker-plant.png and -picker-doll.png. Private 20-object
contact sheet generated via game-mod/tools/furniture_preview.rb and inspected.

Initial QA driver needed the pure relief constants required before 009; fixed.
Native picker fixture initially had its selected index overwritten by the
selector's initialization; set the index on first update and reran successfully.
First temporary-copy cleanup hit read-only copied source directories; added
read-only cleanup support. Detached all asset junctions first. Verified and
removed the sole leftover first fixture by its exact runtime path. Subsequent
copies cleaned normally. All recursive cleanup paths checked inside runtime.
No personal save or live plugin cache modified. Only disposable fixture data
was saved/loaded. Native test input is simulated, not a manual two-client visit.

New files: plugin, furniture tests, standalone TCP test, isolated native probe,
preview tool, tools/test-native-furniture.py and docs/ARENA_FURNITURE.md.
README/status notes appended without replacing the other agent's edits. No
commit/push performed in this concurrent task. Relaunch Play-Arena.bat to prepare
new local plugin files; update both clients before visiting decorated arenas.

## Furniture picker sizing and two-line panel — 2026-11-01

User requested consistent furniture preview size and removal of the clipped
third description line. 091_ArenaFurnitureCatalog.rb now measures each sprite's
visible alpha bounds and fits it proportionally within a centered 72x72 region
of the shared 96x96 preview. This applies to new furniture and original obstacles,
both row thumbnails and enlarged samples. World sprite art/size/collisions are
unchanged. Description now contains only stock quantity and one-cell occupancy.
Updated furniture docs and appended README/status notes, preserving concurrent
agent's gameplay edits and metadata.

Isolated tools/test-native-furniture.py passed 101 checks and its temporary
copy cleaned normally. Visually inspected actual plant/doll picker screenshots:
uniform visible bounds and both description lines fully displayed. No shared
plugin cache or personal save touched. Unit run exposed random-order leakage
from prior visit tests (pending return left by Visits.reset); fixture setup now
clears Visits instance variables before resetting, matching existing relief
fixture behavior. No production visit logic changed. Reran the failing seed
13889 successfully: final furniture_catalog_test.rb run reports 26 tests /
1,200 assertions, zero failures/errors/skips. The separate furniture socket
test previously passed 1 test / 16 assertions. No new server behavior or
protocol changes required by this visual adjustment.

Documentation consolidation requested by user: README now opens with the
20-object addition (23 types including original obstacles), one-time stock,
normalized preview sizing and two-line panel, with catalogue link and exact
validation results. Clarified that changes remain local until published; Arena
Update on another PC cannot fetch unpublished work. Existing sections and the
other agent's 0.21.0 gameplay/protocol notes preserved. This documentation pass
changes README/status only; no test rerun for documentation-only edits.
