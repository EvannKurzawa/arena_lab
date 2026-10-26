# ARENA LAB — Game Vision, Specifications & Development Roadmap

> **This document is the main product reference for Arena Lab.**
>
> Read it before starting a development task, and consult it again whenever a change could affect the game's architecture, core mechanics, scope, or long-term direction.
>
> Keep this document consistent with the actual state of the codebase. Update the implementation status and roadmap when meaningful progress is made. Never describe a planned or simulated feature as fully implemented.

---

## 1. Project Overview

**Arena Lab** is an original, browser-based, multiplayer arena management RPG inspired by the visual style, exploration, and turn-based combat of classic Nintendo DS-era monster-catching games, particularly Pokémon Black and White, HeartGold and SoulSilver, and Diamond and Pearl.

The central idea is to let players become arena leaders rather than simply travel through a predefined adventure.

Each player should be able to:

- Design, build, and customize their own arena.
- Recruit trainers and assemble their teams.
- Collect and manage a large roster of creatures.
- Create puzzles, obstacles, and challenges for visitors.
- Open their arena to other players.
- Visit friends' arenas and challenge their trainers.
- Progress through a persistent world in which other players' creations matter.

The intended experience combines three complementary activities:

1. **Creation:** Build an arena that expresses the player's identity.
2. **Management:** Recruit trainers, manage creatures, and improve the arena.
3. **Challenge:** Explore other arenas and overcome their trainers, puzzles, and leaders.

The long-term goal is a polished, persistent, online game with the charm of a classic handheld RPG and the freedom of a management and construction game.

## 2. Product Principles

Every significant development decision should respect these principles.

### 2.1 Build an actual game, not just a collection of interfaces

Menus, buttons, and visual mockups are not enough. Every feature should eventually have real game logic, meaningful state, and observable consequences.

For example:
- Placing furniture should change the saved arena layout.
- Recruiting a trainer should create a persistent trainer entity.
- Assigning a team should affect the battles that trainer can participate in.
- Defeating a trainer should produce a real result and update progression.
- Visiting another player's arena should load that player's saved arena, not a hardcoded example.

### 2.2 Prioritize a playable core loop

The first objective is not to implement every creature, every battle mechanic, or every multiplayer feature.

The priority is to create a small but complete experience in which a player can build an arena, configure a trainer, challenge that trainer, finish a battle, and preserve the resulting state.

### 2.3 Favor a distinctive arena-building experience

Arena creation is the central differentiator of the game.

The editor should gradually evolve beyond simple furniture placement into a proper construction and level-design system with grid-based editing, obstacles, trainer placement, visitor routes, and puzzle logic.

### 2.4 Preserve the classic handheld RPG atmosphere

The game should feel like a polished top-down, tile-based RPG inspired by Nintendo DS-era games.

Use this inspiration to guide:
- Tile-based movement and world composition.
- Readable maps and rooms.
- Compact, expressive character sprites.
- Charming environments and animated details.
- Clear battle screens and battle feedback.
- Consistent menus, typography, and visual hierarchy.

The objective is to create an original game with its own identity, not to reproduce a specific existing game's maps, branding, or assets wholesale.

### 2.5 Build for the browser first

The primary target is a desktop browser.

The architecture should nevertheless make it possible to adapt the game to mobile browsers and, potentially, a packaged mobile application later.

Do not sacrifice the initial desktop experience to implement mobile support prematurely.

### 2.6 Make progress incremental and verifiable

Prefer small, complete, testable improvements over large rewrites.

Each development task should leave the repository in a coherent state, with working functionality and updated documentation where appropriate.

---

## 3. Target Experience

### 3.1 The player fantasy

The player owns an arena and is responsible for turning it into an interesting challenge.

They can decorate it, choose its layout, recruit trainers, assign creatures and teams, design puzzles, and decide how visitors will progress through it.

Other players can discover the arena, enter it, solve its challenges, and fight its trainers.

Over time, the arena becomes a personal creation that reflects the player's strategy, creativity, and progression.

### 3.2 Typical gameplay loop

The intended long-term loop is:

1. Enter the player's arena management interface.
2. Earn or spend in-game currency.
3. Buy furniture, decorations, tiles, obstacles, and other construction elements.
4. Place and arrange objects on a grid.
5. Recruit or unlock trainers.
6. Assign each trainer a team of creatures.
7. Design routes, gates, puzzles, and challenges.
8. Test the arena locally.
9. Publish or update the arena.
10. Visit other players' arenas.
11. Fight their trainers and arena leader.
12. Earn rewards, experience, currency, or progression.
13. Return to improve the arena and its defenses.

The first playable prototype only needs a simplified version of this loop.

---

## 4. Core Feature Specifications

### 4.1 Arena construction and editing

**Priority: P0 — foundational feature**

The arena editor is one of the two most important systems in the game, alongside combat.

The editor should eventually support:

- A top-down tile grid.
- Multiple room sizes and layouts.
- Floor and wall tiles.
- Furniture and decorative objects.
- Object placement, movement, rotation where applicable, and removal.
- Collision and walkability rules.
- Trainer placement.
- Player spawn points.
- Doors and transitions between rooms.
- Obstacles and gates.
- Interactive objects.
- A configurable arena entrance and leader room.
- Undo and redo.
- Save and load.
- Preview or play mode.
- Validation of invalid layouts.
- Persistent layouts that survive refreshes and reconnects.

The user should be able to select an item from a catalog and place it onto the grid.

Objects should be represented as structured game data, not merely as arbitrary visual elements.

A placed object may have properties such as:

- Unique instance ID.
- Object type.
- Grid coordinates.
- Rotation or orientation.
- Collision behavior.
- Interaction behavior.
- Visual or animation state.
- Configuration parameters.

Use a clear separation between:
- The underlying arena data.
- The editor interface.
- The game-world renderer.
- The interaction and collision systems.

The editor and the actual playable arena should use the same underlying layout representation.

A layout that looks valid in the editor must not become impossible to navigate in play mode because the two systems interpret collisions differently.

### 4.2 Arena objects and construction economy

**Priority: P1**

The long-term game should feature a catalog of construction elements, including:

- Floors and walls.
- Furniture.
- Decorative items.
- Trainer platforms or designated battle spaces.
- Doors and gates.
- Switches.
- Pressure plates.
- Movable obstacles.
- Teleporters or other traversal devices, if appropriate.
- Arena-specific decorative themes.

Some items may be available immediately, while others are unlocked through progression.

A future economy may introduce:
- Purchase prices.
- Unlock requirements.
- Inventory.
- Placement limits.
- Arena expansion.
- Cosmetic customization.
- Rewards for defeating visitors' challenges.

Do not introduce an economy system before the basic editor and save system are reliable.

### 4.3 Trainers and teams

**Priority: P0 for a minimal trainer; P1 for a full recruitment system**

Trainers are characters placed throughout an arena who can challenge visitors.

A trainer should eventually have:

- A persistent unique ID.
- A name.
- A sprite or visual representation.
- A trainer archetype or role.
- A position in the arena.
- An optional dialogue.
- A battle team.
- A battle configuration.
- A challenge condition.
- A defeated or undefeated state where appropriate.
- Progression or recruitment data.

The management interface should eventually allow players to:
- Recruit or unlock trainers.
- Place trainers in their arena.
- Configure their teams.
- Select battle difficulty or strategy where appropriate.
- Define dialogue and challenge behavior.
- Test their battles.
- Save their configurations.

Trainers should not rely on hardcoded special cases for every individual instance. Use reusable data models and configurable behavior.

### 4.4 Creature collection and management

**Priority: P1 initially; long-term scale: 1,000+ species**

The long-term ambition is to support a roster of more than 1,000 creature species, including their forms and relevant variants where appropriate.

The player should eventually be able to:
- Acquire creatures.
- View a collection or roster.
- Inspect stats, types, abilities, and moves.
- Assign creatures to trainers.
- Build and edit teams.
- Compare creatures.
- Manage duplicates or alternate forms if the game design requires them.
- Unlock additional creatures through progression.

The architecture must separate creature data from the interface and battle logic.

A creature definition should be distinguishable from an individual owned creature.

For example:

**Species data**
- Species identifier.
- Display name.
- Types.
- Base stats.
- Available abilities.
- Learnable moves.
- Forms.
- Sprite or asset references.

**Owned creature instance**
- Unique instance ID.
- Species and form.
- Level.
- Current and maximum HP.
- Individual stats where supported.
- Ability.
- Nature or equivalent trait, if supported.
- Moveset.
- Experience and progression.
- Status conditions during a battle, where applicable.

Do not manually hardcode hundreds of species into UI components.

Use a structured, versioned data layer that can load and validate a large roster efficiently.

**Important:** Do not implement all 1,000+ species before the core game is playable. Begin with a small, representative dataset and prove that the data architecture can scale.

### 4.5 Turn-based battle system

**Priority: P0 — foundational feature**

Combat must become a real, deterministic, testable game system.

The initial version should support:
- Two opposing teams.
- Turn order.
- Move selection.
- Accuracy and damage calculations.
- HP tracking.
- Knockouts.
- Switching where applicable.
- Victory and defeat conditions.
- Battle logs and clear action feedback.
- A proper end-of-battle result.
- Integration with arena trainers.

The long-term system may support:
- Types and type effectiveness.
- Abilities.
- Status conditions.
- Stat stages.
- Held items.
- Weather and terrain.
- Multi-creature teams.
- Switching and forced switches.
- Critical hits.
- Priority and speed.
- Battle formats and rule variants.
- Competitive or custom rulesets.

These mechanics must be implemented progressively, with automated tests for important rules.

Do not attempt to reproduce every detail of a complex existing battle engine from memory.

Investigate whether a suitable existing battle engine can be reused, adapted, or integrated.

Pokémon Showdown is an important candidate for investigation because of its extensive battle rules and data. Before choosing it, verify its current API, dependency requirements, supported battle formats, integration complexity, and applicable licenses.

Keep battle rules separate from rendering. The visual battle interface should display the state of the battle rather than independently calculating outcomes.

Battle actions and outcomes should be reproducible and validated by the authoritative game logic.

### 4.6 Arena puzzles and progression

**Priority: P2**

The arena should eventually support meaningful puzzles rather than only battles.

Possible puzzle mechanics include:
- Switches that open doors.
- Movable blocks.
- Pressure plates.
- Gates with conditions.
- Trainers who must be defeated to unlock a route.
- Teleporters.
- Ordered interactions.
- Keys and locked doors.
- Conditional paths.
- Multi-room challenges.
- Arena-specific mechanics.

Design a reusable interaction system rather than implementing each puzzle as a separate hardcoded scene.

The system should distinguish between:
- Static objects.
- Interactive objects.
- Conditions.
- Actions.
- Persistent progression state.

Puzzle complexity should increase gradually. Begin with one simple interaction that proves the architecture works.

### 4.7 Visiting other players' arenas

**Priority: P1 after the local game loop**

Players should eventually be able to:
- Find a friend or another player's arena.
- Load the arena's published layout.
- Explore it using the normal game controls.
- Interact with its objects.
- Challenge trainers.
- Fight the arena leader.
- Receive a result or reward.
- Return to their own arena.

The arena must be loaded from persistent game data, not from a collection of manually prepared demo layouts.

The visitor experience should be separated from the owner's editing experience.

Visitors must not be able to modify another player's arena unless an explicit permission system allows it.

### 4.8 Online multiplayer and persistence

**Priority: P1 after a complete local prototype**

Online functionality is a core long-term requirement, not an optional afterthought.

The eventual game should support:
- Player accounts or a suitable identity system.
- Persistent player profiles.
- Persistent arena layouts.
- Persistent trainer and team configurations.
- Published arena versions.
- Arena discovery or friend-based access.
- Multiplayer visits.
- Server-authoritative battle outcomes.
- Validation of actions that affect game state.
- Reconnection and error handling.
- Basic abuse prevention and data validation.

Do not treat local browser storage or communication between two tabs as real online multiplayer.

Local storage is useful for a prototype, but it is not a shared database.

Similarly, a local demonstration of hosting an arena does not prove that remote players can connect over the Internet.

Online multiplayer must eventually be tested with two independent clients connecting to a real server.

Avoid introducing a complex backend before the core gameplay loop is understood. However, keep data models and service boundaries compatible with a future authoritative backend.

---

## 5. Technical Direction

The following is the proposed technical direction, not a claim that these systems are already implemented.

Verify the actual repository before making architecture decisions.

### 5.1 Frontend and rendering

**Preferred candidate: Phaser with TypeScript**

Phaser is a candidate for the main game rendering and interaction layer because it is designed for 2D browser games.

Potential responsibilities:
- Tile-based maps.
- Sprite rendering and animation.
- Character movement.
- Camera management.
- Collision detection.
- Input handling.
- Scene management.
- In-game interactions.
- Rendering the arena editor and playable arena.

TypeScript is preferred for maintainability as the game grows.

However, do not migrate the current prototype to Phaser simply because it is the preferred candidate. First evaluate the existing code, explain the benefits and costs, and establish a migration plan.

### 5.2 Game architecture

Prefer clear separation between the following responsibilities:

1. **Presentation layer:** menus, HUD, editor UI, sprites, animations.
2. **Game domain:** arena rules, trainer entities, creature entities, progression.
3. **Simulation layer:** movement, collisions, interactions, battles.
4. **Data layer:** species data, object definitions, saved layouts.
5. **Persistence layer:** local prototype saves and, later, server-backed saves.
6. **Networking layer:** remote arena access, synchronization, and authoritative multiplayer.
7. **Development and test tools:** validation, automated tests, diagnostics.

Avoid placing all game logic inside a single HTML file or a collection of tightly coupled UI components as the project expands.

### 5.3 Multiplayer technology

**Candidate: Colyseus**

Colyseus is a candidate for authoritative multiplayer sessions and synchronized game state.

Other solutions may be appropriate depending on the actual requirements.

Before implementation, compare:
- Hosting and operational complexity.
- Persistent storage requirements.
- Authentication.
- Connection and reconnection behavior.
- Deployment costs.
- Compatibility with the chosen frontend.
- Scalability.
- Security and server-side validation.

Do not add a multiplayer framework until the intended network model is defined.

### 5.4 Battle engine

**Candidate: Pokémon Showdown battle simulation**

Investigate whether its battle simulation can provide a suitable foundation for battle rules.

Treat this as a technical investigation, not a predetermined dependency.

Verify:
- License compatibility.
- Data and asset licensing separately from code.
- Supported formats and generations.
- Runtime and dependency compatibility.
- Integration boundaries.
- Required adaptations.
- Maintenance and upgrade implications.

Do not copy an engine into the project without documenting its source, license, dependencies, and modifications.

### 5.5 Persistence

The first prototype may use browser-local storage for convenience.

The long-term design should support a backend database and validated save data.

Arena saves should include enough version information to support future schema migrations.

For example, an arena save may contain:
- Schema version.
- Arena identifier.
- Owner identifier.
- Map dimensions.
- Tiles and objects.
- Trainer placements.
- Puzzle configuration.
- Spawn point.
- Publication metadata.

Avoid storing essential game rules only in rendered HTML or transient interface state.

### 5.6 Deployment

The initial game should run locally in a browser with a straightforward development workflow.

Later deployment should support:
- A hosted frontend.
- A backend service when needed.
- Persistent storage.
- Environment-specific configuration.
- Error reporting.
- Basic automated testing before release.

Never commit credentials, access tokens, private keys, or production secrets to GitHub.

---

## 6. Art Direction and User Experience

### 6.1 Visual identity

The visual direction is inspired by the readability and charm of Nintendo DS-era top-down RPGs, especially the more expressive presentation of Pokémon Black and White.

The intended style includes:
- Pixel-art characters and environments.
- Tile-based maps.
- Clear object silhouettes.
- Compact, readable menus.
- Restrained but expressive animations.
- Cohesive environmental palettes.
- Strong visual feedback for interactions.
- Battle screens that clearly communicate actions and outcomes.

Use original artwork or assets that the project is authorized to use.

Do not assume that publicly available sprites, open-source code, or a freely accessible API grant permission to redistribute copyrighted game artwork or proprietary datasets.

### 6.2 Interface priorities

The UI should prioritize usability over decorative complexity.

The arena editor should make it easy to:
- Select construction categories.
- Browse available objects.
- Place and remove objects.
- Understand grid coordinates.
- Identify invalid placements.
- Save and test the layout.
- Switch between editing and playing.

The management UI should make trainer configuration, team assignment, and arena progression understandable without requiring the player to navigate deeply nested menus.

### 6.3 Accessibility and usability

Where practical, support:
- Clear text contrast.
- Consistent controls.
- Keyboard navigation for desktop interactions.
- Readable feedback messages.
- Responsive layout for different desktop window sizes.
- Reasonable handling of browser resizing.
- Error messages that explain what went wrong.

Do not make important game actions depend exclusively on subtle color differences.

---

## 7. Intellectual Property and Licensing

The project is inspired by an existing franchise, but its long-term distribution strategy must be considered early.

Pokémon names, characters, designs, sprites, artwork, trademarks, and related assets may be protected by intellectual property rights.

Open-source code licenses do not automatically grant rights to associated game assets or franchise material.

Therefore:

- Prefer original creatures, characters, names, maps, and artwork if the goal is an independently distributable game.
- Track the provenance and license of every third-party dependency.
- Verify whether external datasets can legally be used and redistributed.
- Do not assume that non-commercial or fan-project status automatically resolves all legal issues.
- Keep code, game data, and visual assets clearly separated.
- Document any unresolved licensing questions before public release.

During early prototyping, temporary placeholders may be used to test mechanics, but they should not be confused with a cleared production asset library.

Before any public release, assess the licensing and intellectual property implications of the complete product.

---

## 8. Development Roadmap

The roadmap is ordered by dependencies. Do not skip foundational milestones simply because later features are more exciting.

### Phase 0 — Repository audit and prototype stabilization

**Priority: Immediate**

Objectives:
- Inspect all existing files.
- Understand the current prototype.
- Identify what actually works.
- Identify mocked, simulated, or incomplete behavior.
- Establish how the project runs locally.
- Check current Git status and repository structure.
- Document the current architecture.
- Identify the smallest useful next milestone.

Acceptance criteria:
- The prototype can be opened or run using documented instructions.
- The actual features and limitations are known.
- The README accurately describes the implementation.
- There is a clear, prioritized development plan.

### Phase 1 — A functional local arena editor

**Priority: P0**

Objectives:
- Implement a reliable grid.
- Display a small catalog of objects.
- Place and remove objects.
- Enforce basic placement and collision rules.
- Save and reload an arena.
- Provide an editor/play-mode distinction.
- Make the arena data independent of the renderer.

Acceptance criteria:
- A player can create a layout from scratch.
- Objects remain in their saved positions after a refresh.
- Invalid placements are handled consistently.
- The same arena data can be rendered in editor and play mode.
- The editor works without manually editing source code.

### Phase 2 — A playable arena

**Priority: P0**

Objectives:
- Implement a controllable player character.
- Support movement on the arena map.
- Implement collision detection.
- Add interaction with at least one trainer.
- Add a basic transition into a battle.
- Return the player to the arena after the battle.

Acceptance criteria:
- The player can navigate a constructed arena.
- Walls and obstacles prevent invalid movement.
- A trainer can be approached and challenged.
- The battle starts and ends correctly.
- The player can resume exploration after the battle.

### Phase 3 — A minimal but real battle system

**Priority: P0**

Objectives:
- Define structured creature and move data.
- Implement a minimal team system.
- Implement turn order and move selection.
- Calculate damage and update HP.
- Handle knockouts and victory conditions.
- Provide a battle log.
- Test the rules independently of the UI.

Acceptance criteria:
- Battles can be completed from beginning to end.
- Different actions can produce different outcomes.
- Battle results are based on game rules, not presentation code.
- Important calculations have automated tests.
- A completed battle cannot accidentally remain active.

Use a limited test dataset at this stage.

### Phase 4 — Trainers and team management

**Priority: P1**

Objectives:
- Define persistent trainer entities.
- Assign teams to trainers.
- Edit trainer configurations through the UI.
- Save and reload configurations.
- Support multiple trainers in one arena.
- Track defeated trainers where appropriate.

Acceptance criteria:
- Different trainers can have different teams.
- Changes persist after reload.
- Battles use the configured team.
- Trainer behavior is data-driven.

### Phase 5 — Arena puzzles and progression

**Priority: P1/P2**

Objectives:
- Add interactive objects.
- Implement conditions and actions.
- Add switches, gates, and simple puzzles.
- Connect puzzles to arena progression.
- Provide a way to test puzzle configurations.

Acceptance criteria:
- At least one puzzle is fully playable.
- Its state changes through actual interactions.
- Invalid puzzle configurations can be detected where practical.
- Puzzle logic is reusable.

### Phase 6 — Online arena publishing

**Priority: P1**

Objectives:
- Define player and arena identities.
- Design the persistence model.
- Publish arena snapshots.
- Load an arena by identifier.
- Protect owner-only editing operations.
- Add an initial backend.

Acceptance criteria:
- A saved arena can be retrieved by a separate client.
- Published data survives server restarts, subject to the selected persistence design.
- Visitors cannot modify another player's saved arena through ordinary client actions.
- Invalid or malformed arena data is rejected safely.

### Phase 7 — Real multiplayer visits and challenges

**Priority: P1**

Objectives:
- Connect two independent browser clients.
- Allow players to discover or join another player's arena.
- Load the published layout.
- Support interactions and battles.
- Synchronize the relevant state.
- Validate consequential actions on the server.
- Handle disconnects and reconnects.

Acceptance criteria:
- Two clients on separate browser sessions or devices can connect to the actual server.
- One can visit an arena published by the other.
- Arena data is not dependent on local browser storage shared between tabs.
- Battle outcomes are validated by authoritative game logic.
- Network failures produce understandable behavior.

### Phase 8 — Content, collection, and progression

**Priority: P1/P2**

Objectives:
- Expand the creature roster.
- Add more trainer archetypes.
- Add construction categories.
- Add arena themes and cosmetics.
- Introduce currency and unlocks.
- Add player progression and rewards.

Acceptance criteria:
- New content can be added through data rather than major code rewrites.
- Content validation catches missing or malformed definitions.
- The UI can browse a substantially larger roster.
- Progression is persistent and testable.

### Phase 9 — Polish and release preparation

Objectives:
- Improve animations, sound, and feedback.
- Optimize performance.
- Improve mobile browser usability.
- Add loading and error states.
- Test security and persistence.
- Document deployment.
- Resolve asset and dependency licensing.
- Add backup and migration procedures.

Acceptance criteria:
- The game has a consistent presentation.
- Core flows work reliably.
- Major errors can be diagnosed.
- A new developer can set up the project using the documentation.
- Release blockers and licensing risks are documented.

---

## 9. Scope Management

The long-term vision is intentionally ambitious. The implementation order must remain disciplined.

### Build first

1. Reliable arena editor.
2. Persistent local arena saves.
3. Character movement and collisions.
4. One functioning trainer.
5. One complete battle.
6. Trainer team configuration.

### Build next

1. Reusable puzzles.
2. A larger construction catalog.
3. Better management interfaces.
4. Online persistence.
5. Remote arena visits.
6. Multiplayer validation.

### Build later

1. More than 1,000 creature species.
2. Advanced battle mechanics.
3. Extensive cosmetic customization.
4. Large progression systems.
5. Mobile-specific optimizations.
6. Advanced social and discovery systems.

Do not implement large content catalogs before the underlying systems have been validated.

Do not build an elaborate backend before the core local gameplay loop works.

Do not claim that a feature is complete just because a button or screen exists.

---

## 10. Engineering Standards

All development work should follow these standards.

### 10.1 Understand before modifying

Before changing a subsystem:
- Inspect the relevant files.
- Understand the existing behavior.
- Identify dependencies and callers.
- Explain significant architectural consequences.
- Preserve existing working behavior unless the task explicitly changes it.

Avoid speculative rewrites.

### 10.2 Keep changes focused

Each task should have a clear objective.

Prefer modifying a small number of relevant files rather than restructuring the entire project.

Do not introduce a framework, dependency, database, or networking layer without explaining why it is needed.

### 10.3 Separate data from presentation

Game rules and entities should not be defined exclusively inside UI components.

Use reusable models and services where appropriate.

Avoid duplicating the same rule in multiple places.

### 10.4 Test meaningful behavior

For each meaningful change:
- Run relevant tests.
- Check the browser console where applicable.
- Verify the expected behavior manually when needed.
- Test important edge cases.
- Report what was tested and what remains unverified.

If tests cannot be run, say so explicitly.

Never claim a test passed if it was not executed.

### 10.5 Protect existing progress

- Do not delete project files without a clear reason.
- Do not overwrite working features unnecessarily.
- Do not replace the entire application to implement a small feature.
- Do not remove functionality silently.
- Do not rewrite Git history or perform destructive Git operations without explicit approval.
- Avoid unrelated refactoring during feature work.

### 10.6 Maintain documentation

When a change affects the architecture, setup instructions, feature status, data schema, or roadmap, update the relevant documentation.

Keep the README concise enough to navigate even if it contains extensive specifications.

Record major architectural decisions in separate documents when useful.

### 10.7 Keep dependencies and secrets under control

- Explain why a new dependency is necessary.
- Prefer maintained and appropriately licensed dependencies.
- Avoid unnecessary packages.
- Never commit credentials or secrets.
- Validate data received from external clients.
- Do not trust client-submitted battle results or permissions in a future multiplayer implementation.

---

## 11. Definition of Done

A feature is considered complete only when all applicable criteria are satisfied:

- Its intended behavior is implemented.
- It is integrated into the existing game.
- Relevant state is stored and restored correctly.
- Errors and invalid inputs are handled reasonably.
- Relevant tests have been executed.
- No known critical regression has been introduced.
- User-facing behavior is understandable.
- Documentation reflects the actual implementation.
- Any remaining limitations are explicitly documented.

A visual mockup, hardcoded demonstration, local-only simulation, or nonfunctional button must be labeled as a prototype rather than a completed feature.

---

## 12. Current Implementation Status

**This section must be updated as development progresses.**

Do not infer implementation status from the roadmap. Verify the repository.

Initial known repository contents:
- `index.html`
- `README.md`
- `RESEARCH.md`

The initial prototype has been described as a lightweight HTML application with an arena editor, local persistence, a mock battle interface, and a local demonstration of arena hosting or visiting between browser tabs.

These descriptions are preliminary. Inspect the actual implementation before treating them as verified facts.

The following capabilities must be audited individually:

| Capability | Status |
|---|---|
| Local application startup | To verify |
| Grid-based arena editor | To verify |
| Object placement and removal | To verify |
| Arena save and load | To verify |
| Character movement | To verify |
| Collision detection | To verify |
| Trainer configuration | To verify |
| Creature and team data | To verify |
| Complete battle logic | To verify |
| Battle result persistence | To verify |
| Puzzle system | To verify |
| Real remote multiplayer | Not established |
| Backend persistence | Not established |
| Support for 1,000+ species | Not established |
| Mobile support | Not established |
| Production deployment | Not established |

Replace these entries with evidence-based statuses as the codebase is audited and developed.

Suggested status labels:
- **Not started**
- **Prototype**
- **Implemented**
- **Tested**
- **Blocked**
- **Needs redesign**

A feature should not be marked as tested unless the relevant behavior has actually been tested.

---

## 13. Instructions for Codex

Whenever starting work on this repository:

1. Read this README.
2. Read `AGENTS.md` if present.
3. Inspect the current repository and Git status.
4. Read the relevant source files before modifying them.
5. Determine which requirements apply to the task.
6. Distinguish verified functionality from assumptions.
7. Propose a concise plan for changes that affect multiple files or architecture.
8. Implement only the requested scope.
9. Run relevant tests and checks.
10. Summarize changed files, implemented behavior, test results, and known limitations.
11. Update documentation when the actual project state changes.

If a request conflicts with the architecture or priorities described here, explain the conflict and recommend the smallest sensible alternative.

Do not silently replace the project's long-term direction with a different game concept or technology stack.

Do not attempt to implement the entire roadmap in one task.

If important information is missing, inspect the codebase first. Ask a clarifying question only when a decision genuinely cannot be made from the existing requirements and code.

The current implementation may differ from this document. The code is the source of truth for what already works; this README is the source of truth for the intended product direction.

---

## 14. Immediate Next Task

The next development task is to audit and stabilize the existing prototype.

Before implementing major features, produce a report covering:

1. Repository structure and entry points.
2. How to run the application locally.
3. Existing architecture and dependencies.
4. Features that are fully implemented.
5. Features that are simulated, incomplete, or missing.
6. Bugs and technical risks.
7. Whether the current code can be extended incrementally.
8. Recommended target architecture and the reasons for it.
9. A prioritized plan for the next three to five small development tasks.
10. Tests and acceptance criteria for the first task.

Do not rewrite the application during this audit.

Do not introduce Phaser, a backend, a battle engine, or a multiplayer framework before explaining the migration or integration strategy.

The immediate objective is to establish a trustworthy baseline and then build the first complete gameplay loop.

---

## 15. Long-Term Success Criteria

Arena Lab will be moving toward its intended vision when a player can:

- Open the game in a browser.
- Design a unique arena using a flexible editor.
- Save and reopen the arena.
- Recruit and configure trainers.
- Assign creatures and teams.
- Create functional puzzles.
- Explore the arena in play mode.
- Complete real turn-based battles.
- Publish the arena to a server.
- Let another player visit it remotely.
- Challenge trainers and complete the arena.
- Progress and improve their own arena.
- Access a large, data-driven creature roster without requiring major architectural changes.

**The guiding principle: build a small, genuinely playable game first, then scale its content, complexity, and multiplayer capabilities without compromising the foundations.**
