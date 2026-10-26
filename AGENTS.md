# AGENTS.md — Instructions for Codex

## Mission

Build **Arena Lab**, an original browser-based arena-management game inspired by the visual language of Nintendo DS-era monster RPGs. The current milestone is a playable single-player prototype. Read `README.md` for the product vision, feature scope, architecture, and definition of done.

## Mandatory workflow

1. Inspect the repository, existing files, `package.json`, and Git status before editing.
2. Read `README.md` before starting implementation.
3. If the repository is empty, scaffold the project using Vite + TypeScript + Phaser 3.
4. Implement the actual game; do not only return a plan or a list of suggestions.
5. Keep changes focused and avoid unnecessary dependencies.
6. Run `npm install` if needed, then run tests and `npm run build`.
7. Fix errors caused by your changes. If a command cannot be run, state exactly why.
8. Update `README.md` to reflect what was actually implemented, including controls, commands, and known limitations.
9. Summarize changed files, features, commands run, test/build results, and remaining work.

## Stack decisions

- Use TypeScript and Vite.
- Use Phaser 3 for the 2D game world.
- Use plain TypeScript and HTML/CSS overlays for UI unless a framework is clearly justified.
- Use browser `localStorage` for the first prototype's save data.
- Use Vitest for pure logic tests when practical.
- Do **not** implement multiplayer in this milestone.
- Do **not** add React, Vue, a database, login/authentication, Colyseus, Socket.IO, or cloud deployment yet.
- Do not introduce an elaborate architecture for hypothetical future needs.

## Required first playable prototype

Aim to deliver all of the following in this milestone:

- A crisp top-down pixel-art arena with a DS-era RPG aesthetic.
- Keyboard movement for the player and collisions with walls/furniture.
- A clear grid-based room.
- An editor mode to place and remove a small set of furniture items.
- Save/load arena layout using `localStorage`.
- At least one interactive trainer NPC with dialogue.
- A trainer-management panel with editable demo team data.
- A simple turn-based battle demo launched from the trainer, with a battle result.
- A coherent game-style interface, not a generic dashboard.
- A README with actual controls and working commands.

If completing every item at once risks leaving the project broken, prioritize a reliable playable arena first, then implement the remaining features in small steps. Do not leave non-functional controls disguised as finished features.

## Art direction

- Use original placeholder art with a Nintendo DS-era pixel-art feel.
- Prefer 16×16 logical tiles (or another documented consistent tile size) and nearest-neighbor scaling.
- In Phaser, enable pixel-art rendering (`pixelArt: true` or equivalent settings).
- Keep sprites, tiles, UI, and colors stylistically consistent.
- Do not use blurry scaling or unrelated generic dashboard design.
- Do not fetch, scrape, or bundle official Pokémon sprites, game ROM contents, copyrighted music, logos, or other proprietary assets without authorization.
- Use original placeholder creature names and designs. Never imply placeholders are official Pokémon.
- If third-party assets are used, confirm their license and document the source and attribution.

## Code quality

- Separate pure game rules and data from Phaser scenes and UI.
- Use typed interfaces for arena objects, trainers, furniture, and battle state.
- Keep arena layouts serializable and include a save schema version.
- Give placed objects stable IDs.
- Validate placement and prevent invalid overlaps.
- Handle corrupt or outdated `localStorage` data gracefully; fall back to a safe default layout.
- Avoid giant files. Keep names and modules clear, but do not over-engineer.
- Do not use `any` unless necessary and explained.
- Add tests for placement validation, save/load, and battle calculations where practical.
- Ensure the app has useful error handling and no obvious console errors.

## Scope boundaries

Do not implement yet:
- Online or local multiplayer.
- User accounts or cloud saves.
- The full Pokédex or all official battle mechanics.
- Trading, breeding, story campaigns, badges, or a large world.
- Payments, analytics, or telemetry.

Keep the code structured so multiplayer and a larger data catalogue can be added later, but do not let future features delay the first playable version.

## Done means

- `npm run dev` starts the game.
- `npm run build` succeeds.
- `npm test` succeeds if configured.
- Player movement, collision, furniture placement/removal, save/load, trainer interaction, team editing, and the demo battle work.
- The README accurately describes the implementation and controls.
- The final response reports what was built and any known gaps honestly.
