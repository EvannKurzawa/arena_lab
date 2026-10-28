# Updates

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
