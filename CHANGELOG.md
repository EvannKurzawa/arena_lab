# Updates

## v6.2.3 (2026-10-29)

- Fix online visits bouncing back to the entrance: server position checks now
  use the centered 25x25 arena coordinates on the 100x100 map, including the
  correct entry tile and placed-obstacle coordinates.
- Explicitly enable the inherited map music on the generated village, entrance
  and arena maps, and restore the entrance attendant if an event left it hidden.
- Refresh the setup and update executables. Following Pokemon EX remains a
  separately supplied local archive because its resource page does not grant
  redistribution rights; setup can now select that archive during install.

## v6.2.2 (2026-10-29)

- Keep LAN arena discovery listening when Windows reports a UDP connection reset
  for the loopback probe on a computer without a local host responder.
- Clarify that both players need the optional Following Pokemon EX pack to see
  each other's following sprites; no pack means no follower visuals on that PC.

## v6.2.1 (2026-10-29)

- Make Following Pokemon EX optional during game preparation. An installation
  without the third-party archive can still launch and use multiplayer; only
  follower visuals are skipped.
- Remove stale compiled plugin-cache entries when the optional follower plugin
  is absent, and refresh the setup/updater release assets.

## v6.2 (2026-10-29)

- Mark the generated Arena Village honestly as an ugly functional placeholder;
  its final visual layout needs to be built manually in RPG Maker XP.
- Set the next world milestone to a larger explorable area with routes, lore and
  wild Pokémon beyond the village grass patch.
- Refresh the Windows setup and updater EXEs for this source commit and publish
  them as v6.2 release assets.
- Fix village return routing, replace the old playable Lappet Town layout, and
  use matching-generation temporary stadium/house sprites.

## v6 - custom update (2026-10-28)

- Confirm the mode-based arena editor works in-game, including immediate ice
  preview, dialogs above the farthest-zoom map, and selecting all furniture and
  trainer entries.
- Ship the full-map cursor and ground/trainer/furniture painting and placement
  workflow in Arena Demo plugin 0.9.14.

## Editor text layering and catalog navigation (plugin 0.9.14)

- Draw the global overview below Essentials' message windows so prompts remain
  readable in the farthest zoom.
- Let Essentials' command window handle directional navigation exactly once;
  this fixes skipped furniture rows and the trainer selector wrapping back to
  its first entry.
- Confirmed working in-game by the user.

## Mode-based arena editor (plugin 0.9.13)

- Make ice previews use the in-progress editor draft, so painted ice appears
  immediately instead of retaining the saved grass tile until leaving custom mode.
- Keep the editor overview visible behind tile dialogs when using the farthest
  zoom, preserving the same map view while choosing tools and confirming edits.
- Organize editing into ground, trainer, and furniture modes. Select a surface or
  owned item once, then press Enter on each tile to apply it repeatedly.
- Add matching trainer/furniture removal tools and per-tile replace/remove
  choices while preserving inventory refunds and cancel rollback.
- Confirmed working in-game by the user with plugin 0.9.14.

## Visible cursor in the full-map overview (plugin 0.9.12)

- Add a dedicated tile-sized overview cursor with a dark edge and bright inner
  frame. Its outline stays several screen pixels thick at the farthest zoom.
- Keep the normal cursor for the closer views; hide/show the matching cursor as
  U cycles between map and overview modes, and update it on every arrow move.

## Auto-continue existing local saves (plugin 0.9.11)

- `Play-Arena.bat` now opens an existing save directly, removing the extra title
  screen confirmation presses after launch.
- If no save exists, the normal New Game/title flow remains available.
- This addresses the user's request for zero Enter presses after launching
  their existing game.

## Restore the centered arena footprint (plugin 0.9.10)

- The user confirmed the save reload now displays grass, but the previous 0.9.6
  full-map fallback made the entire 100x100 arena look endless.
- Restore the intended 25x25 centered default floor and void outside it in both
  generated map data and runtime recovery. Explicitly edited tiles remain saved.
- Keep the 0.9.9 save-load rebuild so a direct arena save gets fresh map data.

## Rebuild serialized arena maps on save load (plugin 0.9.9)

- Re-run `Game_Map#setup(100)` when a save loads while already on Map 100. This
  replaces stale serialized map/table data with generated `Data/Map100.rxdata`.
- Preserve the player's position/direction and saved PokemonGlobal arena edits;
  then reapply the edits, placements and camera position.
- This specifically targets the user's confirmed difference: entering Map 100
  through a door works, while loading a save already on Map 100 is black.

## Runtime floor diagnostics (plugin 0.9.8)

- Record the actual RGSS map dimensions, tileset, center tile stack, count of
  renderable map cells and resolved ground-file locations on arena load.
- Record the first nonblank tile as seen by Essentials' live renderer, including
  its bitmap and source rectangle. This distinguishes bad map data from a
  tileset/rendering failure instead of guessing from the generated file.

## Renderable arena floor IDs (plugin 0.9.7)

- Essentials treats tile IDs 0-47 as blank; the old passability check allowed
  those IDs and could therefore choose an invisible floor that left the map
  black even though its tiles were technically walkable.
- Require a renderable tile ID in the generated base floor and runtime fallback.
- Verify the serialized Map 100 center tile stack during preparation and print
  the selected IDs, making a bad generated floor fail with a concrete error.

## Full arena floor by default (plugin 0.9.6)

- The user confirmed plugin 0.9.5 still showed a black/void arena. The earlier
  design left 75% of the 100x100 map void by default, so rebuild Map 100 and
  runtime recovery now paint the whole map with the validated passable floor.
- Unedited tiles now default to normal field in collision and the overview;
  only tiles explicitly marked void are void. The center remains the spawn and
  original arena footprint.
- In-game rendering still requires a fresh launch/save check.

## Persistent void recovery (plugin 0.9.5)

- Recover the generated floor when the game resolves data paths from its plugin
  folder as well as from the game root.
- Clear the identifiable legacy save corruption where at least 100 saved tile
  edits are 90% or more void, while preserving normal and small void layouts.
- Never replace a missing/invalid ground tile with `[0,0,0]`, which is empty
  space. Keep the last valid map intact until a real floor can be recovered.
- In-game confirmation is still pending.

## Saved map and overview recovery (plugin 0.9.4)

- Save the generated base-ground tile stack in `Data/ArenaDemoGround.txt`.
- Rebuild the centered field and placements after Essentials loads a save, even
  when it reuses a serialized `Game_Map` without calling `setup`.
- Ignore an all-zero cached ground stack and recover it from the generated
  floor file, preventing older saves from restoring a void arena.
- Simplify the global overview with solid terrain colors, light ten-tile guides,
  a clear starting-footprint outline and separate placement marks.

## Centered field recovery (plugin 0.9.3)

- Recover a passable base-ground tile from older top-left Map 100 copies before
  rebuilding the centered field at runtime.
- Move legacy fixed events, stale start coordinates and old tile-edit records
  into the centered 25x25 field. Track a third migration version so edits made
  at stale coordinates after the earlier migration are repaired too.
- Refresh saved object placements after migration and move a player saved on
  void to an available walkable field tile.
- Replace the noisy overview pattern with high-contrast terrain colors, subtle
  ten-tile guides, a highlighted starting footprint and clear placement marks.
- Replace the noisy overview pattern with high-contrast terrain colors, subtle
  ten-tile guides, a highlighted starting footprint and clear placement marks.

## Custom editor usability fixes (plugin 0.9.2)

- Center the starting 25x25 arena field and its fixed events within Map 100;
  shift old saved placements and terrain edits into the centered field once.
- Improve the full-map overview with crisp per-tile surface patterns and markers.
- Remove the persistent zoom/help banner and hide editor overlays while menus
  are displayed, keeping choice text in front.
- Put ground editing first on occupied tiles and render ice with a dedicated
  blue ice tile while retaining Essentials' ice terrain movement.
- Refresh the tile renderer after terrain edits and zoom changes.

## Zoom renderer constant fix (plugin 0.9.1)

- Qualify Essentials' tile size and zoom constants in the custom zoom renderer.
  Plugin 0.9.0 raised `NameError` when the renderer first refreshed tiles.

## 100x100 arena editor upgrade (plugin 0.9.0)

- Expand Map 100 to 100x100, with a 25x25 starting field and blocked void
  outside it. Let custom mode turn any selectable tile into field or void.
- Add per-tile plain/concrete, grass, desert/sand, rock and ice painting.
  Persist edits and restore them on map load; use Essentials' built-in ice
  terrain tag for sliding.
- Add three U-key zoom levels, including an overview of the full 100x100 map.
- Keep placements in player saves and protect essential arena event tiles.

## v5 - first custom mode (2026-10-28)

- Add an offline tile-based arena editor with furniture and recruited trainers,
  draft validation/cancellation, persistent placement and trainer challenges.
- Add Arena Furniture and Recruited Trainers Bag tabs while merging Mail and
  Battle Items into Items. Migrate existing Bag contents and selections.
- Remove the obsolete Arena Demo pause-menu entry; the Arena Guide is the
  entry point for editing and recruitment.
- Fix catalog text and sprite clipping. The user confirmed the recruitment
  heading displays fully in-game; the full custom-mode loop still needs testing.

## Catalog heading clipping fix

- Increase the trainer and furniture catalog heading window height to fit the
  Essentials font and its configured vertical offset. Plugin version 0.8.6
  refreshes installed copies.

## Catalog row clipping fix

- Give trainer and furniture catalog rows enough height for their contents and
  draw full-height character frames, fixing clipped labels and trainer sprites.
  Plugin version 0.8.5 refreshes installed copies.

## Trainer selection text alignment

- Apply Essentials' configured vertical text offset to the trainer and furniture
  catalog rows so their labels render fully. Plugin version 0.8.4 refreshes
  installed copies.

## Arena recruitment message and pause menu

- Shorten the trainer recruitment confirmation to one line so it fits cleanly
  in the in-game message window.
- Remove the obsolete Arena Demo pause-menu option; the Arena Guide remains
  the entry point for custom mode and trainer recruitment. Plugin version 0.8.3
  refreshes installed copies.

## Bag layout consolidation

- Remove the Mail and Battle Items tabs; both item groups now appear in Items.
- Keep Key Items and add the Arena Furniture and Recruited Trainers tabs, for
  eight total tabs. Existing saves migrate their pocket contents and cursor
  positions automatically. Plugin version 0.8.2 refreshes installed copies.

## Bag pocket migration fix and pause-menu cleanup

- Normalize older saves' Bag pocket arrays and remembered selection indices
  before Essentials reads the added Arena Furniture and Recruited Trainers tabs.
- Remove arena customization from the pause menu; use the Arena Guide instead.

## Offline arena custom mode - implemented in source, game playtest pending

- Add an overhead tile editor launched by the offline Arena Guide. Place,
  remove, or replace furniture and recruited trainers; validate to save or
  cancel to restore the previous arena and inventory.
- Add Arena Furniture and Recruited Trainers Bag pockets, starter furniture,
  recruitable trainer profiles, persistent placement, and trainer battles.
- Regenerate Map 100 with reusable furniture and trainer event slots. The new
  editor has not yet been tested in-game; online arena layout behavior remains
  on the existing multiplayer snapshot path.

## v4 - simplified connection flow (in-game test passed; two-PC retest pending)

- Remove the previous-location choice and the pause-menu Connection entry;
  the entrance attendant owns connection actions.
- Discover hosting games over the local network, then send a socket-bound visit
  request for the host to accept or decline. No IP or account ID is typed.
- Show Offline, Hosting, Connected or Visiting at the attendant, with Disconnect.
- User reports the updated flow works in-game on one computer. The updated
  two-computer discovery/request flow still needs a physical two-PC retest.
- LAN discovery uses UDP 9997; PEMK continues to use TCP 9998.

## v3.5 - 2026-10-28

- User confirmed multiplayer communication between a prepared host and a second
  computer running the GitHub-downloaded Arena Lab client on the same network.
- Add `TWO_COMPUTER_SETUP.md` with the Essentials v21.1 download, hotfix,
  installer, host IP and invitation steps.
- Record that the current installer is client-ready; clean host setup remains a
  later milestone.

## v3.3 installer fix - 2026-10-28

- Correct PowerShell condition parsing for checking that the chosen install
  directory is empty.

## v3.2 installer fix - 2026-10-28

- Allow Essentials resource packs that contain compiled `Data/Scripts.rxdata`
  without the optional extracted `Data/Scripts/001_Settings.rb` source file.
- Keep the v21.1 check when that extracted settings script is present.

## Windows packaging - 2026-10-28

- Add `ArenaLab-Setup.exe` bootstrap for a clean client and `ArenaLab-Update.exe`
  for source updates from GitHub `main`; build with `tools/package-deliverables.ps1`.
- Setup obtains pinned public source/runtime dependencies and uses the player's
  own Essentials v21.1 folder. It does not redistribute Pokémon-derived assets
  or configure the PostgreSQL/native-gem host service on a new computer.
- Updates back up only changed source files; private runtime, game assets, saves,
  account configuration and database data are not copied into the backup or
  overwritten.

## v3 - 2026-10-28

- User confirmed one successful full arena visit with two windows on the same PC.
  Two physical computers on the same network are the next acceptance test.
- One Play-Arena.bat for every player, offline by default; entrance attendant
  handles hosting, joining, invitations and going offline in the same world.
- Independent local profiles, private host layouts/collisions and customization
  locks, storage PC, and the first offline catching route/story.
- Serialize startup, synchronize the plugin cache and safely replace only a
  verified idle legacy project server; keep accounts and progress private/local.
- Release checks: 56 Ruby tests / 398 assertions and 24 PowerShell checks passed.
  Plugin remains 0.7.0; upstream versions and runtime pins are unchanged.
- Private assets, runtimes, saves, credentials, generated maps and database files
  are excluded. No two-PC or internet-hosting success is claimed.

## ArenaDemo 0.7.0 - 2026-10-28 (source update; GUI verification pending)

- Keep only Play-Arena.bat. Repeated launches allocate independent player profiles;
  serialize compilation and avoid rebuilding files while another game runs.
- All games start offline. Entrance attendant hosts or joins using the same app;
  same-PC joins use 127.0.0.1, LAN joins use the host's displayed IPv4 address.
- Host service/database start only when requested in-game, in hidden helpers.
  Database stays loopback-only; idle managed game servers stop after ten minutes.
- Connect/disconnect in place with one local character and save. No title switch,
  cloud-world restoration or local progression upload. Preserve historical saves.
- Retain native authentication/PvP/peer validation and existing room restrictions.
- 53 Ruby tests / 380 assertions plus 13 PowerShell checks passed. Actual GUI
  launch, authenticated play and two-PC/network-firewall verification remain pending.

## ArenaDemo 0.6.0 - 2026-10-28 (source update; GUI verification pending)

- One normal Play-Arena launcher, with background local server and one game window.
- Explicit Offline/Online choice before token login; Connection pause menu saves
  and switches profiles through the title screen in the same process.
- Offline blocks automatic connections. Separate offline saves preserve legacy
  data; failed login reloads the correct offline slot. Online switches wait for
  save acknowledgment; visits must close first.
- 48 tests / 324 assertions passed. Real launcher/UI switching remains untested
  because private game-data access still stalls in this execution environment.

## ArenaDemo 0.5.0 - 2026-10-28 (source update; GUI verification pending)

- Added the arena customization pause entry and replaced the object-manager NPC
  with a medic. All edits enforce room and session restrictions.
- Added an entrance attendant, account-ID invitations, one-guest temporary rooms,
  frozen host layouts/difficulty, private presence and room-only visitor access.
- Lock before opening; unlock after confirmed close. Handle declined/expired
  invitations, disconnects, replaced connections and deferred guest returns.
- Preserve personal saves and existing PEMK battle consent/relay. Extend local
  player collision checks to the entrance room; simultaneous movement still has
  no server tile reservations.
- Added offline Founders' Path with normal Essentials grass encounters, capture
  supplies, a keeper story and a one-time completion reward.
- Root server launcher loads the isolated adapter; readiness rejects old servers.
- 41 tests / 291 assertions passed. Real socket tests use injected account
  identities, not production authentication. Actual private maps and GUI gameplay
  could not be checked because private game-data access stalled.

## v2.1 - 2026-10-28

- Fixed clipped text using rendered font heights in the pinned mkxp-z runtime.
- Added local arena player blocking, while allowing exit from shared spawn tiles.
- Fixed client win/loss perspective and singles speed ties; flush RNG before
  replacement menus and end messages to avoid stalled battle replay.
- Reuse healthy local servers; show readiness failure stages and TCP entries/PIDs.
- User-verified: multiplayer launch, text, battle synchronization/completion and
  player collisions. ArenaDemo plugin version: 0.4.2.
- Release regressions: 22 tests / 106 assertions passed; full upstream suite not
  rerun. Private runtime assets, saves and credentials remain excluded.
- Simultaneous moves can still overlap without server tile reservations. No
  general replay guarantee across all abilities/items or new online arena storage.


## v2 — 2026-10-27

### Arena demo

- Replaced the village test layout with a generated 25x19 enclosed training yard using the local Essentials tileset.
- Added a trainer who offers an Essentials battle when spoken to and a manager near the entrance.
- Expanded offline customization to six object slots, three arrangements, clear/light/full presets, trainer difficulty, and team healing.
- Preserved the player's position during management edits; overlapping placement is rejected.
- Fixed Escape selecting Leave or another unintended action. Leaving now requires the explicit Leave choice.
- Retained intro skip, pause-menu entry, existing saves, and configurable sample teams.

### Local multiplayer

- Added Windows server and two-client launchers using Essentials v21.1 and the existing PEMK server/protocol.
- Fixed the native bcrypt dependency build and account-form connections expiring while the player types.
- Added a real PEMK readiness check before opening clients and private server diagnostics.
- Added facing-player/same-tile interaction and a Players in arena list, using PEMK's battle request, accept/decline, consent, and team-exchange flow.
- Kept primary and guest accounts separate. Online clients use one fixed obstacle layout; offline customization remains saved.

### Runtime stability

- Diagnosed the closing-window bug as native divide by zero in the bundled runtime's Input.update.
- Switched root launchers to an official mkxp-z Windows build pinned to commit `37a04d14413454551a7b6aadbb4e93e67168accb`, with archive/executable checksum validation.
- Preserved the original executable, private assets, accounts, and saves. Removed unsuccessful timing workarounds and heavy temporary tracing.
- Corrected diagnostic console redirection that caused a separate bad-file-descriptor error.

### Verification and limits

- User-confirmed: arena/customization behavior, GUI account creation, and no window exit on the physical click test with the replacement runtime.
- Final regressions: **16 customization/interaction tests / 90 assertions**, plus **1 real-backend arena protocol test / 18 assertions**, all passed.
- Validated primary/guest runtime selection, installer checksums, PowerShell/Ruby syntax, and Git whitespace checks.
- A complete GUI PvP battle and movement after the runtime change remain unverified. The full upstream suite was not rerun.
- Online arena editing, friend-owned arena visits, shared layout storage, public hosting, chat, and trading are outside this snapshot.
- Private runtime binaries, copyrighted game assets, generated maps, databases, session tokens, credentials, saves, and crash logs remain excluded from Git.

For startup/reconstruction instructions, exact upstream commits, runtime download provenance, and the complete setup history, see [README.md](README.md) and [SETUP_STATUS.md](SETUP_STATUS.md). This is a personal, non-commercial fan project, not official Pokémon software.
