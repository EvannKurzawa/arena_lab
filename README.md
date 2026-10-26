# Arena Lab — Pokémon-Inspired Arena Management Game

## 1. Project vision

Arena Lab is an original, browser-based, 2D creature-battling and arena-management game inspired by the presentation and feel of Nintendo DS-era monster RPGs, especially Pokémon Diamond/Pearl/Platinum, HeartGold/SoulSilver, and Black/White.

The player is not following a traditional Pokémon story with gyms and badges. The core fantasy is to **build and operate a custom battle arena**:

- Design a top-down arena.
- Place furniture, decorations, obstacles, and interactive objects on a grid.
- Create routes and simple puzzles for visiting challengers.
- Recruit trainers and assign teams to them.
- Configure the creatures and battle rules used by those trainers.
- Eventually let friends visit each other's arenas and challenge them online.

The immediate goal is **a small, polished, playable single-player prototype**. Do not attempt to build every planned feature in the first pass.

## 2. First milestone: what Codex should build

When asked to implement the first version, create a working browser game with:

1. A top-down pixel-art room/arena with a Nintendo DS-era RPG feel.
2. A player character that moves around the arena using keyboard controls.
3. Collision with walls and furniture.
4. A visible grid-based arena layout.
5. A small editor mode to select and place/remove a few furniture pieces.
6. A way to save and reload the arena layout using browser `localStorage`.
7. At least one interactable trainer/NPC with a short dialogue.
8. A simple “trainer management” panel that can select the NPC and configure a small placeholder team.
9. A simple battle demo that can be launched from the trainer, using a turn-based interface and a few original placeholder creatures/moves. This is only a UI/logic prototype, not a complete official battle simulator.
10. A clear, usable UI that visually belongs to the game rather than a generic admin dashboard.
11. A README section with exact install/run/test commands and a summary of implemented controls.

The prototype should be fun to move around in even before the management and battle features are complete.

## 3. Recommended technology stack

Use a simple, maintainable TypeScript web stack:

- **Vite + TypeScript** for project tooling and development server.
- **Phaser 3** for the 2D game world, tile/grid movement, camera, collisions, sprites, and interactions.
- **HTML/CSS** for overlays, menus, inventory/editor panels, and trainer-management UI when that is more practical than drawing everything in Phaser.
- **Vitest** for unit tests of pure game logic (placement validation, save/load, and battle calculations).
- **ESLint** and **Prettier** if they can be set up without distracting from the prototype.
- Browser `localStorage` for the first version's save system.
- **No backend and no multiplayer in milestone 1.**

Do not add React, Vue, a database, authentication, Colyseus, Socket.IO, or deployment infrastructure unless there is a clear need. Keep the architecture ready for a future authoritative multiplayer server, but do not implement it yet.

### Asset strategy

The target is the **visual language** of DS-era Pokémon games: crisp pixel art, compact tiles, top-down rooms, readable character sprites, limited palettes, and a battle screen with a lower information panel.

For the first prototype:
- Prefer simple original placeholder sprites/tiles created from code or original SVG/PNG assets.
- Use a consistent tile size, preferably 16×16 logical pixels, scaled with nearest-neighbor rendering.
- Use `pixelArt: true` and pixel-art-friendly scaling in Phaser.
- Avoid blur, smoothing, gradients that clash with the pixel art, and generic modern dashboard styling.
- If an original asset pack with a compatible license is available, document its source and license.
- Do **not** download, scrape, bundle, or redistribute copyrighted Pokémon sprites, official game assets, music, fonts, or ROM content without authorization.
- Do not present placeholder creatures as official Pokémon. Use original placeholder names and silhouettes for now.
- Design asset interfaces so authorized or original sprites can be added later without rewriting game logic.

## 4. Architecture guidelines

Keep gameplay logic separate from rendering and UI. Suggested structure (adapt if the existing repository already has a sound structure):

```text
src/
  main.ts
  game/
    config.ts
    scenes/
      BootScene.ts
      ArenaScene.ts
      BattleScene.ts
    entities/
      Player.ts
      Trainer.ts
    systems/
      movement.ts
      collision.ts
      placement.ts
      saveLoad.ts
      battle/
        types.ts
        battleEngine.ts
        demoData.ts
  ui/
    appShell.ts
    editorPanel.ts
    trainerPanel.ts
    dialoguePanel.ts
  data/
    furniture.ts
    trainers.ts
  styles/
    main.css
  tests/
```

Keep the actual folder layout simple and consistent. Avoid building an elaborate framework before there is a playable game.

### Arena model

Represent the arena as structured data, not as a screenshot. It should include:
- map width/height and tile size;
- wall/floor tile identifiers;
- furniture/object instances with stable IDs, type IDs, grid coordinates, rotation if supported, and collision/interactable flags;
- trainer/NPC instances with stable IDs and grid positions;
- a schema version for save migration.

Validate placement: objects must remain inside the room, must not overlap blocking objects, and must not occupy the player's or an NPC's tile if that would make the layout invalid.

### Battle prototype

Implement a small, deterministic, testable battle loop with original demo data. Keep battle rules behind a clear interface so a more complete engine can be integrated later.

Do not claim that the first prototype reproduces official Pokémon battle mechanics. Do not fabricate a complete Pokédex or move database. The goal of milestone 1 is to prove that the battle UI and engine integration points work.

### Future multiplayer

Multiplayer is explicitly out of scope for milestone 1. Do not install or implement a multiplayer framework now. However:
- keep arena state serializable;
- give objects stable IDs;
- keep core battle logic independent of Phaser rendering;
- avoid relying on client-only state for rules that would later need server validation.

## 5. Product principles

- The arena-management loop comes first, not a long adventure campaign.
- Prefer an interactive working feature over placeholder buttons that do nothing.
- Make the UI understandable without requiring a tutorial.
- Keep the art crisp and consistent.
- Build in small increments and test after each major change.
- Do not silently remove working functionality to add new features.
- If the repository already contains code, inspect it before changing architecture.
- If a requirement is ambiguous, make a sensible small-prototype decision and document it rather than blocking on many questions.

## 6. Definition of done for milestone 1

The first milestone is done when:

- `npm install` completes.
- `npm run dev` starts the game locally.
- `npm run build` succeeds without TypeScript errors.
- `npm test` succeeds if tests are configured.
- The player can move around the arena and collide with walls/objects.
- The user can enter editor mode, place/remove furniture, and save/reload the layout.
- The trainer dialogue opens.
- The trainer panel can edit the demo team.
- A battle can be started and completed with a simple win/loss result.
- The interface is styled as a coherent DS-era pixel-art game.
- README instructions and known limitations are accurate.

## 7. Legal and naming note

This is an original fan-inspired project, not an official Pokémon product. Pokémon names, characters, sprites, art, sounds, logos, and game assets may be protected by intellectual-property rights. Do not bundle official assets or ROM data unless the user has the necessary authorization. Keep the initial prototype on original placeholder creatures and art, and document any third-party asset licenses.

## 8. First command to Codex

Open the repository folder in Codex and ask it to:

> Read `AGENTS.md` and this README completely. Inspect the current repository before making changes. Then implement Milestone 1 as a working, polished, playable Phaser 3 + TypeScript browser prototype. Follow the stack and asset rules in the README. Do not implement multiplayer yet. Do not use copyrighted Pokémon sprites or ROM assets; create simple original pixel-art placeholders. Run the available tests and production build, fix errors, and update the README with the actual controls and commands. Do not stop after writing a plan: implement the prototype.
