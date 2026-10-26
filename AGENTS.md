# AGENTS.md — Codex Instructions

## Project mission

Build a personal, non-commercial Pokémon arena-management fan game by extending an existing Pokémon RPG engine. Do not build the Pokémon battle engine or game data from scratch.

Read `README.md` before taking action.

## Priority order

### Priority 1: integrate upstream projects

The first task is to clone and integrate:

- Pokémon Essentials: https://github.com/Maruno17/pokemon-essentials
- Pokémon Essentials MMO Kit (PEMK): https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit

Do not begin the custom arena demo until you have made a serious attempt to get the base projects working together and recorded the outcome in `SETUP_STATUS.md`.

Required steps:
1. Inspect the workspace and available tools.
2. Clone both projects using their documented recommended locations.
3. Read the READMEs, setup docs, version requirements, and license files.
4. Determine PEMK's supported Essentials version. Do not assume the latest Essentials release is compatible; check the documented target (PEMK has been associated with v21.1).
5. Follow the documented integration procedure.
6. Configure local-only development settings and keep credentials/secrets out of source control.
7. Start the server and client if the environment supports it.
8. Test two local clients if supported.
9. Record exact versions/commits, commands, outcomes, errors, and manual steps in `SETUP_STATUS.md`.
10. Be honest about what was and was not actually executed.

If a required GUI application, RPG Maker XP, Ruby/RGSS runtime, or Windows-specific tool is unavailable, identify the limitation precisely. Do not claim the full game was launched if only files were inspected.

### Priority 2: implement the small demo

Only after the integration attempt and status report, build a minimal arena-management demo within the existing engine:

- Small custom arena map.
- Player movement and collisions.
- A few arena objects.
- At least one interactive trainer/NPC.
- A configurable sample trainer team.
- A battle using the existing Pokémon Essentials battle engine and data.
- One meaningful arena-management feature (for example, a simple menu or limited placement/removal system).
- A clear way to enter the demo from the game.

Keep the demo genuinely playable and modest in scope. If full runtime editing is too large, implement a limited first version and explain what remains.

If PEMK works, test that the demo does not break its supported multiplayer behavior. Do not assume that PEMK already synchronizes custom arenas, object placement, player-owned layouts, trainer teams, or challenges.

## Technical constraints

- Target a downloadable desktop RPG Maker XP/RGSS game.
- Follow the engine and extension's actual supported languages, tooling, and versions.
- Do not port the project to Phaser, Unity, Godot, or the browser.
- Do not create a new Pokémon battle engine or manually recreate the full Pokédex.
- Do not add unrelated frameworks or services.
- Follow upstream instructions instead of inventing an installation procedure.

## Upstream references

- Pokémon Essentials: https://github.com/Maruno17/pokemon-essentials
- PEMK: https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit
- Essentials documentation: https://essentialsdocs.fandom.com/wiki/Essentials_Docs_Wiki
- PSDK alternative (research only; do not add it to this project unless explicitly asked): https://github.com/PokemonWorkshop/psdk

Check actual current repository docs and license files. Public GitHub availability is not a blanket license to copy code or assets.

## Scope boundaries

Do not implement these in the first demo:
- Full arena builder with every furniture type.
- Visiting and challenging custom arenas hosted by friends.
- Persistent online arena storage.
- Matchmaking, ranking, trading, or moderation.
- Public production hosting.
- A new battle engine or complete reimplementation of Pokémon mechanics.

These may become later milestones.

## Assets and personal use

This is a personal, non-commercial project. The user wants to reuse existing Pokémon systems and visuals.

- Follow Essentials' own installation and asset instructions.
- Check the licenses and terms of the engine, PEMK, plugins, and third-party assets.
- Do not assume non-commercial use automatically grants permission to redistribute copyrighted assets.
- Do not commit ROM dumps, proprietary RPG Maker assets, local game files, private saves, or credentials.
- Keep personal local assets separate from distributable code.
- Do not describe the project as official Pokémon software.

## Code and repository hygiene

- Inspect before editing.
- Prefer plugins, scripts, and documented extension points over core-engine patches.
- Keep changes small, reversible, and documented.
- Do not overwrite user changes.
- Do not commit secrets, credentials, generated binaries, or unnecessary large files.
- Update README and `SETUP_STATUS.md` when setup or behavior changes.
- Run relevant tests/builds where possible, and report exact results.

## Required status file

Maintain `SETUP_STATUS.md` with:
- Repository URL and checked-out commit/version for each project.
- Compatibility evidence.
- Required tools and versions.
- Commands run.
- Server/client/two-client test results.
- Files changed.
- Errors and unresolved blockers.
- Exact manual steps required from the user.

Clearly distinguish inspection from execution and successful launch from successful multiplayer connection.

## Initial instruction

Start now with Priority 1: clone Pokémon Essentials and PEMK, inspect versions and instructions, and attempt to make them work together. Record the result in `SETUP_STATUS.md`. Do not start the custom demo until that integration attempt has been made. Then proceed to Priority 2 if feasible.
