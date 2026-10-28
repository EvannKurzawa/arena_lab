# Updates

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
