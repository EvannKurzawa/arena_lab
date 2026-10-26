# AGENTS.md — Arena Lab Development Instructions

These instructions apply to the entire repository.

## 1. Read the project reference first

- Before starting a task, read `README.md` to understand Arena Lab's vision, priorities, roadmap, and acceptance criteria.
- Read `RESEARCH.md` when relevant to technical choices or existing research.
- Inspect the actual source code before describing implementation status or proposing changes.
- The codebase is the source of truth for what currently works. `README.md` is the source of truth for intended product direction.

## 2. Understand before changing

Before editing:
1. Check `git status` and preserve the user's existing changes.
2. Inspect relevant files, entry points, dependencies, and callers.
3. Identify the requested outcome and its acceptance criteria.
4. For multi-file, architectural, or risky changes, present a concise plan before implementing.
5. Prefer the smallest coherent change that achieves the requested outcome.

Do not rewrite the whole application to implement a small feature. Do not introduce a new framework, backend, database, battle engine, or networking layer without first explaining the need, trade-offs, and migration strategy.

## 3. Protect existing work

- Do not delete files or remove working functionality without a clear reason and explicit user approval where appropriate.
- Do not overwrite unrelated user changes.
- Do not perform destructive Git operations, rewrite history, force-push, or reset user work without explicit approval.
- Avoid unrelated refactoring.
- Do not commit, push, publish, or deploy unless the user asks you to do so.
- Never expose, copy into the repository, or commit credentials, access tokens, private keys, or secrets.

## 4. Product priorities

Follow the sequence in `README.md`. The near-term priority is a small, complete, playable local gameplay loop, not a large unfinished feature set.

Prioritize, in order:
1. Audit and stabilize the existing prototype.
2. Build a reliable grid-based arena editor and save/load flow.
3. Add playable character movement and collision.
4. Add a configurable trainer and a complete minimal turn-based battle.
5. Connect arena, trainer, team, and battle data cleanly.
6. Add reusable puzzles and progression.
7. Design and implement real online persistence and multiplayer only after the core loop is reliable.
8. Expand the creature roster and content once the underlying systems are proven.

Do not try to implement the entire roadmap in one task. Keep the intended top-down, tile-based, Nintendo DS-era RPG atmosphere while developing an original game identity.

## 5. Architecture and code quality

- Separate game rules and domain data from UI, rendering, and input handling as the codebase grows.
- Prefer reusable, data-driven definitions over hardcoded special cases.
- Keep arena data independent of its visual renderer; editor and play mode should use consistent underlying data and collision rules.
- Keep battle calculations separate from battle presentation.
- Use clear names, focused functions, and existing project conventions.
- Add dependencies only when justified; explain significant dependency and architecture choices.
- Validate external or user-provided data where appropriate.
- Design persisted data with versioning and future migration in mind when introducing schemas.
- Do not claim that local storage or communication between browser tabs is real online multiplayer.
- Do not trust client-submitted battle results or permissions in any future multiplayer implementation.

## 6. Intellectual property and licenses

- Do not assume that publicly accessible Pokémon sprites, names, datasets, or artwork are free to redistribute.
- Check licenses for third-party code, packages, datasets, and assets before adopting them.
- Code licenses do not automatically cover associated artwork or franchise intellectual property.
- Document the source and license of dependencies and assets when adding them.
- Prefer original or properly licensed production assets, and flag unresolved licensing risks before public release.
- Before integrating an existing battle engine such as Pokémon Showdown, verify its current license, dependencies, API, compatibility, and data/asset licensing separately.

## 7. Testing and verification

For each meaningful change:
- Run the relevant automated tests, build, lint, or other checks available in the repository.
- If no suitable tests exist, perform reasonable manual verification and recommend focused tests where useful.
- Check browser console errors for frontend behavior when feasible.
- Test important edge cases and persistence behavior where relevant.
- Report exactly which checks were run and their results.
- If a check could not be run, say so. Never claim tests passed unless they were actually executed.

A feature is not complete merely because a button, screen, or mockup exists. Distinguish clearly between implemented behavior, prototype behavior, simulated behavior, and unimplemented behavior.

## 8. Documentation and implementation status

- Update `README.md` when meaningful changes affect the product direction, actual feature status, setup, architecture, or roadmap.
- Update `RESEARCH.md` when a technical investigation or source review materially changes its findings.
- Keep documentation consistent with the implementation.
- Never mark a feature as tested without testing it.
- Document important limitations, unresolved decisions, and follow-up work.

## 9. Expected workflow for each task

1. Read `README.md` and these instructions.
2. Inspect Git status and the relevant code.
3. Summarize the current behavior and relevant constraints.
4. State a concise implementation plan when the task is not trivial.
5. Implement the smallest complete change within the requested scope.
6. Run relevant checks and inspect the resulting diff.
7. Update documentation when necessary.
8. Summarize:
   - what changed;
   - which files changed;
   - what was tested and the results;
   - known limitations or remaining work.

Do not silently change the game's long-term direction. If a request conflicts with the documented vision or would introduce significant technical debt, explain the conflict and recommend a practical alternative. Ask a question only when an important decision cannot reasonably be inferred from the repository and requirements.

## 10. First task when entering an unfamiliar codebase

If the user has not specified a concrete implementation task, do not immediately build major features. First audit the repository and report:
- its structure and entry points;
- how to run it locally;
- the architecture and dependencies actually present;
- what works and what is mocked, incomplete, or missing;
- bugs and technical risks;
- whether incremental extension is sensible;
- recommended architecture changes, with trade-offs;
- the next three to five small tasks and their acceptance criteria.

Do not rewrite the application during this audit.
