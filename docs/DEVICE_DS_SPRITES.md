# Bobine et antenne : variante DS

Créées le 2026-11-02 avec la compétence imagegen et l’outil intégré image_gen.

Les quatre orientations de chaque objet sont générées en une planche, puis
converties en PNG transparents 32 × 64 par `tools/build-ds-device-sprites.ps1`.
Le moteur conserve les arcs animés de la bobine ; le fichier
`Graphics/ArenaDevices/device-art-style.txt` sélectionne leurs points d’attache.

- Planches sources : `game-mod/AssetSources/device-coil-ds.png` et
  `game-mod/AssetSources/device-antenna-ds.png`.
- Nouveaux sprites conservés : `game-mod/AssetSources/DeviceArt-DS/`.
- Anciens sprites conservés sans modification : `game-mod/AssetSources/DeviceArt-previous/`.
- Sprites utilisés : `game-mod/Graphics/ArenaDevices/`.

Pour remettre les anciens dessins :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/select-device-art.ps1 -Style previous
```

Pour revenir à la variante DS : même commande avec `-Style DS`.
Fermer le jeu puis lancer Play-Arena.bat pour installer le choix local.
Pour transmettre ce choix à l’autre PC, commit/push des fichiers actifs modifiés,
puis Arena Update sur l’autre PC. Les sauvegardes et placements sont inchangés.

## Prompts exacts

### Bobine

Use case: stylized-concept. Asset type: single transparent spritesheet of a Tesla coil arena puzzle prop for a Pokémon HeartGold/SoulSilver style 2D top-down RPG. Draw four equal views side by side in ONE ROW, facing RIGHT, LEFT, UP, DOWN respectively, exactly same scale and feet baseline. Compact cute mechanical scenery, authentic Nintendo DS era hand-pixelled game prop, clear dark navy 1px outlines, limited palette and simple 2-3 shade clusters, upper-left light. Short golden copper coil with three stacked broad round windings, chunky silver-grey square foot, dark blue insulator, small blue-white terminal sticking toward its facing direction. Height about 36 logical pixels, width 26 logical pixels in each 32x64 logical pixel cell. Body occupies y=25..59 within each 32x64 cell, centered x=16; terminal must be at (26,26),(8,26),(16,25),(16,29) for views RIGHT LEFT UP DOWN. A readable game tileset prop matching Pokémon gym furniture, not photoreal, no realistic tiny details, no soft glow, no gradients, no cast shadow outside object, no lightning bolts (engine adds animated arcs). Transparent background, clean alpha, no labels, no text, no floor, no extra objects. The total logical spritesheet size is 128x64 with four 32x64 cells. Render as crisp nearest-neighbor upscaled pixels with the exact four-cell spacing and plenty of clear transparent padding above the small objects. Save project-bound source to C:/arena-lab/game-mod/AssetSources/device-coil-ds.png.

### Antenne

Use case: stylized-concept. Asset type: single transparent spritesheet of a magnetic emitter antenna arena puzzle prop for a Pokémon HeartGold/SoulSilver style 2D top-down RPG. Draw four equal views side by side in ONE ROW facing RIGHT, LEFT, UP, DOWN respectively, exactly same scale and feet baseline. Authentic Nintendo DS era hand-pixelled gym puzzle scenery, chunky compact cheerful machine, dark navy 1px outlines, limited palette and simple 2-3 shade clusters, upper-left light. Small square silver-grey pedestal with deep blue trim, short gold/copper neck supporting a visibly directional horseshoe electromagnet, two small red and blue magnet poles pointing toward the facing direction, and a tiny cyan status light. Clear silhouette, readable front/back/side orientations in a top-down RPG 3/4 overhead perspective. No arrows. Object logical height 32 pixels, logical width 26 pixels, centered at x=16 with bottom y=59 in each 32x64 logical cell. Visual matches Pokémon DS gym furniture, not realistic engineering, no thin wires, no smooth illustration, no glow, no gradients, no floor or cast shadow outside object, no labels or text or Pokemon characters. Transparent background, clean alpha. Total logical spritesheet size 128x64, four equal 32x64 cells. Render as crisp nearest-neighbor upscaled pixels with exact four-cell spacing and clear transparent padding above compact objects. Save project-bound source to C:/arena-lab/game-mod/AssetSources/device-antenna-ds.png.
