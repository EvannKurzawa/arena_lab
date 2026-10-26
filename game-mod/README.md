# Arena Demo

The Essentials v21.1 plugin lives in `Plugins/ArenaDemo/`. It adds an **Arena Demo** pause-menu entry that transfers the player to a small dedicated map, then offers arena management and a sample trainer challenge. The generated New Game intro also offers **Skip intro and start Arena Demo** or **Play the full intro**. Quick start creates a level 10 Pikachu so the sample battle can be played immediately.

## Demo features

- A playable test map copied from Essentials' Lappet Town map (map 2), with a new map ID, its own trainer, a manager, and three object events.
- Normal Essentials walking, walls, event collisions, and map transitions.
- A saved three-slot roster for a boulder, rock, and tree. These fixed map slots can be added or removed from the arena; hidden objects stop blocking movement.
- An interactive Youngster trainer with a configurable Rattata/Ekans sample team. The battle uses Essentials' existing battle engine and Pokémon data.
- A return-to-previous-map option in the manager menu.

The map binary is generated locally from the complete project's existing Lappet Town map; the generator reads the Player's House exit transfer to choose a valid town spawn. It updates `Data/MapInfos.rxdata`, writes `Data/ArenaDemoStart.txt`, patches the new-game intro, and writes `Data/Map100.rxdata`:

```powershell
ruby game-mod/tools/build_arena_map.rb "C:\path\to\your\Essentials-v21.1-project"
```

Install `Plugins/ArenaDemo/` into the project's `Plugins/` directory and run the map generator once. It generates Map100 and patches Map001's first intro event with the skip/full-intro choice (safe to run again; it won't add duplicate choices). A local assembled test project is stored under ignored `tools/runtime/essentials-v21.1-base/` when available. It contains the Essentials v21.1 package, the PEMK plugin, the Arena Demo plugin, and a loopback-only `mmo_config.txt`. Its `PlayMMO-debug.bat` starts the bundled mkxp-z game client in debug mode.

## Controls and startup

Click the actual gameplay window so it has keyboard focus; the separate **Pokémon Essentials Output Window** is only a log. Use the arrow keys to move, Z/Enter/Space to interact or confirm, and X/Esc to cancel/back. Essentials opens its pause menu with the mapped **Action** key (A in RGSS, commonly Shift), so Esc is not the menu key. On a fresh New Game, choose **Skip intro and start Arena Demo** to bypass the long story intro. Existing saves do not replay that startup choice; use the pause menu's Arena Demo entry to enter the demo.

## Limits

- The player can toggle objects in their fixed slots; free placement and map editing are not implemented.
- The current PEMK server does not synchronize object selection or arena ownership. Authentication currently crashes in the local Windows bcrypt native extension, so online login is unverified. Choose offline mode to test the local arena while that is unresolved.
- The user confirmed the game window opens and loads both plugins, but reported a long intro with no skip and no response to Esc/other keys after it. The generator now adds a skip/full-intro startup choice. The arena transfer and battle are not yet confirmed in-game. RPG Maker XP is not installed; the map generator avoids requiring its editor for this first map.
- Keep the downloaded Essentials assets and resulting client package private. They remain under ignored local runtime files and are not part of this repository's distributable source.
