# Expedition generation, version 2

The wilderness remains an offline Essentials v21.1/RGSS feature. Every village
departure rolls a fresh saved expedition; the biome percentage table is unchanged.
The first layout's ellipse stamps, fixed cross-shaped roads and rectangle-drawn
textures have been replaced.

## Method and research

The generator is an independent Ruby implementation of a layered pipeline:

1. Seeded value noise uses quintic interpolation and three independently seeded
   octaves. Two lower-frequency fields warp the sampling coordinates. Separate
   elevation, moisture and route-cost fields give coherent ridges and vegetation.
2. Biome-specific elevation/moisture quantiles control coverage. Lakes occupy low
   ground; volcanic fields reserve a low molten basin and higher rock; mountains
   reserve higher ground. Majority smoothing and connected-component pruning
   remove small noisy fragments. This is a stylized 2D landscape, not a physical
   erosion or hydrological simulation.
3. A minimum spanning tree connects sector exits, camp and a local clearing.
   Offset waypoints break up long axial runs. A* uses terrain and elevation-change
   costs to route paths around hazards. Necessary water/lava crossings become
   traversable bridges. Reachability is verified with scenery blockers included.
4. Encounter grass and low vegetation form different patches. Clustered, spaced
   scenery stays off the route network. Inaccessible encounter patches are removed.
5. Native Essentials graphics are composed with the engine's existing 8-neighbor
   autotile lookup and quarter-tile patterns. Diagonals select inner shore/path
   corners. Native cliff edges surround separate plateau interiors. Full conifers,
   ice rocks and crystal props replace unsuitable cuttable-tree/boulder graphics
   in the wilderness. Snow/dry/ash grasses and molten water use palette grading.

Primary references consulted:

- [Amit Patel, Making maps with noise functions](https://www.redblobgames.com/maps/terrain-from-noise/)
  explains multi-frequency fields and elevation/moisture classification. This
  informed the field hierarchy, rather than independent per-tile randomness.
- [Ian Parberry, Designer Worlds, JCGT 3(1), 2014](https://jcgt.org/published/0003/01/04/)
  discusses value-noise terrain and controlling elevation statistics. This project
  does not use its USGS data pipeline or claim to reproduce its full method.
- [Amit Patel, Introduction to A*](https://www.redblobgames.com/pathfinding/a-star/introduction.html)
  explains weighted graph traversal and the distinction between graph navigation
  and how a route is represented in a game.
- [Maxim Gumin, WaveFunctionCollapse](https://github.com/mxgmn/WaveFunctionCollapse)
  was evaluated as an alternative. Local pattern constraints alone do not provide
  this project's global route guarantees. WFC and its sample assets were not
  copied, downloaded or added as dependencies.

The researched procedural approach was chosen instead of a web map pack. Native
Essentials art keeps tile dimensions, perspective and palettes consistent with
the installed game. No online maps or new third-party art have been imported.
The original installation's asset terms and credits still apply; local artwork
and rendered previews remain in ignored runtime/dist folders.

## Saves and species

New plans store `version = 2` and the actual resolved terrain/scenery. Existing
saved outings retain their geography; return home and leave again for version 2
layouts. The native renderer can also display older plans. Loading never silently
replaces the world beneath the player. Generation shows progress in the game.

Wild encounter pools now include only base species from generations **1-5**.
In 0.12.0 each zone selects up to five distinct species, weighted without
replacement, during generation. Those tables are saved; later respawns cannot
expand them. See [outing limits, deadlines and controls](EXPEDITION_RULES.md).
Generation 6, 7 and 8 entries are explicitly rejected even if their types match
the habitat. Existing custom trainer rosters, the starter and local gifts already
use generations 1-5. Engine species definitions are retained for save/plugin
compatibility; this update does not delete previously owned Pokemon from saves.

## Verification

`game-mod/test/expedition_world_test.rb` checks rarity intervals, reproducibility,
navigation with props, hazard behavior, save continuity and species exclusions.
`expedition_terrain_test.rb` exercises the actual upstream autotile tables,
source bounds, diagonal corner choices, scrolling coordinates, native scenery
lifecycle and cache disposal. The generation/build tests use synthetic fixtures.

For visual QA, `game-mod/tools/expedition_preview.rb PRIVATE_GAME OUTPUT_DIR SEED`
renders all 15 biome configurations with the production generator and renderer,
using the player's own installed art and a small RGSS drawing adapter. It writes
full-sector overviews, viewport crops and a JSON summary. It never changes game
maps or saves. Previews are static renders, not proof of a launched game or a
successful capture. Keep the output private and excluded from Git.

Remaining visual limits include finite sectors with fade transitions, shared
woodland artwork for forest/bamboo, and simple ruins/station motifs. Native
terrain still benefits from authored landmarks and further in-game feedback.
