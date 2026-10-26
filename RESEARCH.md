# Repository review and initial recommendation

Research checked on 22 October 2026. This is a high-level repository/README/license review, not a complete code audit or legal opinion.

## Candidate comparison

### 1. Pokémon Showdown — best battle-rules engine candidate
- Repository: https://github.com/smogon/pokemon-showdown
- Provides a JavaScript battle simulator and Pokédex data; documentation says it simulates singles, doubles and triples across Generations 1–9.
- Architecture separates the game server, client and login server; server performs actual battle simulation.
- Server code is MIT-licensed. The licence for code does not grant rights to Pokémon trademarks, characters or art, and data/assets need their own review.
- Missing for this project: top-down arena editor, furniture placement, trainer recruitment, player progression and the custom visitor experience.
- Recommendation: evaluate as an isolated rules engine, not as the whole game to fork.

### 2. Project Pokeworld — closest to top-down browser multiplayer
- Repository: https://github.com/rohan-shettyy/project-pokeworld
- README describes Phaser + Socket.IO, browser-based multiplayer and a desired Black/White-style art direction with 16×16 tile/sprite frames.
- Repository is marked MIT.
- Limitations: small/old repository (31 commits observed during review); README refers to a Repl.it-hosted “stable” version and asks for server contributors. Its README does not establish a complete modern combat simulator, persistent accounts, or an arena-construction system.
- Recommendation: useful as a code-reading reference for Phaser/Socket.IO and tile sizing; not the core foundation without a deeper code audit.

### 3. Battle Lab — useful reference for battle presentation and modular design
- Repository: https://github.com/gosunoobie/pokemon-battle-simulator
- Vue 3, PixiJS, GSAP and Node.js; modular packages for battle simulation, reference data, sprites and visual effects. Server-authoritative battle runtime. README describes Generation 3 mechanics, private multiplayer rooms and 335 move-effect recipes.
- Important licence issue: no repository-wide licence is declared. Third-party software licenses and asset notices apply separately; do not assume the whole project can be copied or redistributed.
- Limitation: Generation 3 rules, not Generation 5; multiplayer currently focused on battles, not visiting custom arenas.
- Recommendation: inspect architecture and animation recipes for inspiration, but don't copy code until permissions/licensing are clarified.

### 4. Infinite Pokémon — useful architecture and Codex workflow example
- Repository: https://github.com/Shellishack/infinite-pokemon
- TypeScript/Phaser, save system, generated maps/interiors, battles and a multiplayer mode where friends share the host's world. MIT code licence shown on GitHub.
- README also says “Educational and non-commercial use only” and identifies third-party/reference assets. This makes it unsuitable as an unreviewed foundation for a public/commercial project, despite the repository's code licence. Asset and disclaimer terms must be checked individually.
- Recommendation: a strong learning reference for how a Codex-assisted Phaser project can be organized; do not assume the full game or assets are freely reusable.

## Art and sprites

- Smogon sprites repository: https://github.com/smogon/sprites
- Its README states code is MIT, but Pokémon sprites are owned by Nintendo / Game Freak / The Pokémon Company. It also says the licence for community-created Black/White-style sprites of later-generation Pokémon is still being determined and asks people to contact them before use.
- Therefore, don't treat the MIT code licence as permission to bundle the sprites. For a prototype, use original placeholder art; for a public build, seek permission or commission original creatures/art.

## Recommendation

Build a new browser game around Phaser (or a comparable 2D engine) and a server-authoritative multiplayer backend. Keep arena state, persistence, trainer rosters and battle rules behind separate interfaces. Evaluate Pokémon Showdown as the battle engine candidate; do not fork a complete fan game just to obtain its graphics. Use original placeholder art until asset rights are cleared.

## Proof-of-concept scope

This folder's `index.html` demonstrates arena editing, local saving, sharing a snapshot between tabs in the same browser/origin, and a mock turn-based battle screen. It intentionally does not include copyrighted Pokémon art or an official battle engine. The same-browser snapshot is not true internet multiplayer.
