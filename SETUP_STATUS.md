# Setup and implementation status

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
