# Arena Lab — proof of concept

A no-dependency browser prototype exploring three separate systems for a future arena-management game:

1. **Top-down arena editor** — 10×7 grid, place/remove furniture, obstacles, puzzle tiles and a trainer; choose a floor theme; save to browser storage.
2. **Visit snapshot** — one browser tab can host/publish an arena snapshot and another tab on the same browser/origin can visit it. Uses `BroadcastChannel` and `localStorage`.
3. **Battle UI loop** — mock turn-based battle with a small original pixel creature illustration, HP bars and action buttons.

## Run on Windows

1. Extract the ZIP to a folder.
2. Open PowerShell in that folder.
3. Run:

   ```powershell
   py -m http.server 8000
   ```

4. Open `http://localhost:8000` in two browser tabs.
5. In tab 1, edit the arena and click **Start hosting**.
6. In tab 2, click **Visit hosted arena** then **Refresh snapshot**.

The prototype is deliberately dependency-free. It is not yet a true network multiplayer game: two tabs on the same browser/origin can share a snapshot, but two different computers cannot connect. Real online multiplayer requires a server-authoritative room service, identity/session handling, persistent storage, validation, and deployment.

## Important limitations

- The battle logic is illustrative only. Damage, types, turn order, stats, status and abilities are not official Pokémon mechanics.
- Creature artwork is original placeholder art, not a Pokémon sprite. Replace it only after the chosen art's rights and terms are checked.
- This does not bundle Pokémon Showdown, Pokémon assets, ROM data, or any third-party source code.
- It is an architecture experiment, not a production-ready game.

## Suggested next engineering step

Create a TypeScript/Vite application with separate packages/modules for `arena`, `battle-adapter`, `trainer-roster`, `persistence`, and `multiplayer`. Evaluate Pokémon Showdown's simulator as a separately version-pinned dependency behind a small adapter. Keep game state and arena persistence independent of battle engine internals.
