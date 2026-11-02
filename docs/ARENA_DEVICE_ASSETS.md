# Assets des objets interactifs — 0.23.0

## Correction du rendu — 2 novembre 2026

Le tapis est maintenant construit par un motif périodique natif : période de
16 pixels, quatre phases espacées de 4 pixels, cadre fixe et rotations des
quatre directions. Cette méthode remplace le décalage d'un recadrage non
raccordable de l'image générée, qui provoquait des sauts dans l'animation.

La rune est creuse et allégée. La toile n'a plus de contour noir ; sa réduction
conserve la couverture des fils avant conversion en pixels clairs opaques.
Les fichiers `antenna-R.png`, `antenna-L.png`, `antenna-U.png` et `antenna-D.png`
remplacent le sprite unique avec flèche. La vue gauche est le miroir exact de
la vue droite. Les vues nord/sud conservent un pied vertical et orientent la
parabole. Génération intégrée imagegen, prompts exacts :
[DEVICE_REVISION_PROMPTS.md](DEVICE_REVISION_PROMPTS.md).
Les PNG actifs restent dans `game-mod/Graphics/ArenaDevices/`.

Le bourdonnement utilise maintenant 330/660/990 Hz à volume 95 avant application
du réglage général des effets. L'ancienne fondamentale à 110 Hz pouvait être
masquée sur des petits haut-parleurs ; ce n'est pas une cause confirmée du
silence rapporté. Le test natif contrôle maintenant le WAV complet, sa résolution
par le moteur et l'appel réel à `Audio.bgs_play` à volume non nul.

Reconstruction facultative depuis les originaux privés :
`powershell -ExecutionPolicy Bypass -File tools/rebuild-device-revision.ps1 -SourceRoot <dossier-images-generees>`.
L'installation normale copie les PNG prêts à jouer et régénère le son ; elle
ne dépend pas du dossier des originaux.

## Révision du 2 novembre 2026

Les sprites actifs `conveyor-sheet.png`, `teleporter.png`, `rune.png`,
`antenna.png` et `web.png` sont désormais des adaptations générées avec l'outil
imagegen intégré à partir des références utilisateur. La toile est une
adaptation pixel art, pas une copie exacte de la photo de stock. La dalle
bleue remplace le recadrage HGSS. Les sources décrites plus bas pour l'ancien
tapis et l'ancienne rune sont historiques et ne décrivent plus les fichiers
actifs. Les boutons et la bobine restent inchangés.

`game-mod/tools/build_device_sprites.ps1` réduit les originaux transparents
en sprites natifs 32×64 ; le tapis est assemblé en quatre phases et quatre
directions (planche 128×256), bord fixe et intérieur défilant. Les PNG prêts
à jouer sont dans `game-mod/Graphics/ArenaDevices/` ; les originaux restent
dans le dossier privé des images générées.

Les sons `Arena Magnet` (BGS en boucle) et `Arena Coil Off` (SE décroissant)
sont synthétisés par `game-mod/tools/build_device_audio.rb` lors de Prepare.
Aucun échantillon externe : sinusoïdes modulées et bruit déterministe. Le
son HGSS de téléportation existant est conservé. L'ambiance BGS précédente
reprend après l'attraction, depuis son début.

Prompts utilisés avec l'outil intégré (fond transparent) :

- Tapis : Use reference image #1 (green conveyor) as EDIT TARGET. Create a single square conveyor floor tile with exactly this simple chevron design but charcoal black belt and yellow chevron bands pointing left. Remove surrounding ground and frame, keep thin grey mechanical border. Crisp 16-bit RPG pixel sprite, no blur. Transparent outside square. One tile only, no text. For game integration will reduce to 32x32 and animate chevrons in code.
- Téléporteur : Use reference image #2 as design reference: isolate/recreate ONLY the blue white square teleporter pad circled in red, without the red circle. Square blue cyan center, concentric dark-blue and white square frames, metallic dark border, slightly top-down Pokemon floor tile. One 32x32 logical pixel-art tile enlarged, transparent outside tile. No people, scene, text.
- Rune : Use reference image #3 as reference. Single purple magenta glowing circular blindness rune, two concentric circles with little arcane marks between, four main projecting radial ticks and central tiny magenta point. Dark plum translucent interior, bright pink-white outlines. Preserve design as closely as possible. One floor tile sprite, crisp pixel art suitable for 32x32 logical reduction. Transparent outside circular glyph. No text or scene.
- Antenne : Create a very SIMPLE restrained Pokemon RPG overworld magnetic antenna sprite, 32x48 logical pixels enlarged, crisp pixel art with small limited grey/red palette. Plain small square grey pedestal, short thin post and simple small grey dish with red central emitter pointed right. No bolts, wires, gauges, complex panels, large highlights or elaborate machinery. Fits understated existing Pokemon map props. Entire single sprite on transparent background. No text.
- Toile : Use attached reference image #4 as design reference. Create one white irregular dense spiderweb matching its angular radial pattern, with broken and uneven polygonal rings and jagged outer strands. Pixel art sprite for Pokemon floor tile. White strands with subtle dark outline for visibility on ground. Transparent background including the holes between strands. No grey rectangle, text, stock footer or watermark. Square centered single web, 32x32 logical pixels enlarged, crisp pixels.

Les fichiers partagés sont dans `game-mod/Graphics/ArenaDevices/`.
`Play-Arena.bat` appelle `tools/install-arena-device-assets.ps1` pendant la
préparation. Le téléporteur et le son HGSS restent dans le runtime privé ignoré
par Git : ces ressources Pokémon ne sont pas présentées comme redistribuables.
L'installateur contrôle leur SHA-256 et conserve les ressources natives.

| Fichier | Source / conditions |
|---|---|
| `conveyor-sheet.png` | [Conveyor belt spriteset, Gary Shaw](https://opengameart.org/content/conveyor-belt-spriteset), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Copie de la planche ; les quatre premières phases des directions droites sont utilisées. Licence limitée à cet asset. |
| `rune.png` | [Magic Rune Circle](https://freegamesprites.com/en/assets/library-magic-rune-circle), indiqué CC0 par la source. Réduction à 32 px et ajout de transparence de cadrage. |
| `coil.png`, `antenna.png`, `button-up.png`, `button-down.png` | Créations avec l'outil intégré imagegen ; mise au format technique 32×64, transparence conservée. Images utilisateur utilisées comme inspiration de forme uniquement ; aucun extrait des photos de stock. |
| Dalle HGSS, locale | [Capture de l'arène de Safrania HGSS](https://www.pokekalos.fr/jeux/nds/hgss/articles-arene-de-safrania-3850.html), dalle verte/magenta recadrée à l'exécution. Droits Pokémon/Nintendo et ayants droit. |
| Son HGSS, local | [HGSSMusicPack](https://github.com/JappaWakka/P3DToolsAndContentPacks/tree/d5f82265d24f20dba94fb83cf1fb4a7344114d49/ContentPacks/HGSSMusicPack), `Sounds/Teleport.wav`. Crédits du pack : jianmingyong, JappaWakka, Arnie_Jr, SViper, David Adam. Origine annoncée HGSS ; pas de comparaison avec une extraction personnelle du jeu. |

La toile et l'étincelle sont dessinées par le code Bitmap : fils blancs avec
contour noir et éclair animé bleu/jaune, respectivement.

## Prompts finaux — outil imagegen intégré

### Bobine

Use case: stylized-concept. Asset type: a single overworld pixel-art sprite for an RPG Maker monster-catching RPG, north-up camera tilted down like Pokemon HGSS. Draw ONE Tesla coil only, complete silhouette, upright tall thin brass post with three distinct horizontal oval brass capacitor plates, small rounded octagonal metallic cap, heavy silver-grey hexagonal mechanical pedestal with bolts and a little cyan glass gauge. Follow a classic Tesla coil tower design: three dark-outlined gold plates at different heights, copper/brass vertical axis, silver pedestal on floor. No electricity, no cables outside sprite, no surrounding scene. The pedestal occupies one floor tile; tower rises about two tile heights. Authentic hand-drawn 16-bit JRPG pixel-art aesthetic, dark one-pixel outline, precise stepped pixels, restrained gold/grey palette, highlights from upper left, no gradients or blur. Native logical resolution 32x64 pixels, shown enlarged using nearest-neighbor pixels, centered on a transparent canvas with a small transparent margin, base aligned at bottom. No characters, text, grid, labels, shadows outside the base, watermark, or multiple objects.

### Antenne

Use case: stylized-concept. Asset type: a single overworld pixel-art prop sprite for an RPG Maker monster-catching RPG in Pokemon HGSS-like perspective. Draw ONE compact magnetic antenna device: an attractive blue-grey industrial pedestal with little brass bolts, short solid mast, a silver parabolic dish aimed toward screen-right and slightly upward, a red copper U-shaped magnetic emitter inside the dish and a tiny red indicator lamp on its base. Complete single silhouette, pedestal fits one floor tile, total height roughly 1.5 tiles. Authentic polished 16-bit JRPG pixel art, precise dark stepped outline, shaded metal, small cyan details, highlight upper left. Native logical resolution 32x56 pixels, shown enlarged with nearest-neighbor pixels. Center one single object on genuinely transparent background, base aligned at bottom, no scenery, text, grid, multiple variants, glow outside object, or watermark.

### Bouton relevé

Use case: stylized-concept. Asset type: one floor switch sprite for a Pokemon HGSS-like top-down RPG Maker game. Draw ONE large round red push button in its RELEASED raised state, viewed from above with the slight north-up RPG downward perspective. Bright red elliptical cap sitting high above a silver-grey circular metal mounting ring, dark crimson vertical side wall visible at bottom, silver beveled rim with two tiny screws, white-red highlight along upper left edge, crisp black exterior outline. A physical floor object, not a UI icon. Native logical 32x32 pixel sprite, shown enlarged using nearest neighbor, complete object centered with transparent empty margins, 16-bit RPG pixel art with clean stepped pixels and a restrained palette. Genuinely transparent background. One button only. No square tile, text, grid, logo, watermark, scenery, or ground shadow.

### Bouton enfoncé — édition du bouton relevé

Edit the supplied pixel-art floor push-button into its PRESSED DOWN state. Preserve exactly the same transparent canvas, viewpoint, lighting, black outline, metal mounting ring shape, width and position, both screws, and red palette. Lower the red cap into its silver mounting ring: the crimson vertical side wall becomes only a very thin strip, the cap is visibly much flatter and lower. Keep the base sitting at exactly the same bottom position and the red cap centered in the same silver ring. One object only, no new text or scenery, no glow. Authentic crisp RPG pixel-art, do not introduce blur. Preserve transparency.
