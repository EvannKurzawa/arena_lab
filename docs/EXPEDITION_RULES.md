# Outing rules and controls (0.12.2)

## Keyboard

Hold either Shift/Maj key while moving to run. No running-shoes unlock is needed.
Release Shift to walk. Essentials still selects the movement animation/speed and
enforces walk-only terrain, bumps, jumping, vehicles and scripted movement.
The old Default Movement option is removed because hold-to-run replaces that
setting's behavior.

Space opens pause in the overworld. If a step is in progress, movement stops at
the next tile before the menu opens. Space does not also interact with an NPC or
wild Pokemon. Enter/Z remain interaction keys. Native confirm/cancel behavior
continues in dialogues, battles and menu screens.

The plugin uses the existing mkxp-z raw keyboard functions, rather than changing
the engine binary or overwriting the player's F1 bindings. The existing U-key
overview shortcut already uses the same input extension. The native API and raw
Space/Shift scancodes were checked against the
[mkxp-z input source](https://raw.githubusercontent.com/mkxp-z/mkxp-z/dev/src/input/input.cpp)
and [Ruby bindings](https://raw.githubusercontent.com/mkxp-z/mkxp-z/dev/binding/input-binding.cpp).
Fetching the exact pinned source commit via web cache failed; the installed
runtime pin remains unchanged. Actual physical keyboard testing is still needed.

## Three free outings

Each local save profile has three free departures in any rolling 86,400-second
period. Each slot replenishes 24 hours after its own departure, rather than all
slots resetting at midnight. The village guide and confirmation prompt show the
remaining allowance. Returning early, losing a battle or closing the game does
not refund an outing. Declining the prompt, failed generation, failed record
writes and failed transfers do not consume a completed departure.

The persistent file is `SaveData::FILE_PATH + '.expeditions.dat'`, beside that
profile's save. It stores departure timestamps, absolute deadlines, completed
session IDs and an initially zero bonus balance. Loading an old save cannot undo
spent slots or resume an outing already ended. A malformed record blocks new
departures with an explanation rather than silently granting fresh allowance.
Different primary/guest profiles have independent allowances.

`OutingLedger#credit(count)` is an extension point for later extra outings.
Free slots are consumed before bonus outings. No payment flow, currency charge,
prices, checkout, network service or purchase button is implemented.

## Twenty-minute deadline

An outing gets an absolute real-clock deadline 1,200 seconds after its successful
generation, just before entering the wilderness. Menus, time out of focus and
time with the game closed do not pause that deadline. The HUD and Expedition
menu show remaining time. A save/reload retains the original deadline.

When time expires, new steps, sector crossings and visible wild encounters stop.
Ordinary menus receive cancel input so they close through their own cleanup
paths. Input in a battle is never cancelled this way. Return waits for a current
step, battle, capture/reward/evolution sequence, NPC interpreter or dialogue to
finish, then transfers to the village before displaying the end notice. This
avoids transferring under a battle scene or an open bag/party screen. A battle
loss may already return through Essentials' healing flow; that also ends the
outing. Caught Pokemon and items remain in the current game as usual.

Old saved plans without an outing ID get one recorded migration outing, spending
a free/bonus slot if available and receiving twenty minutes on the first load.
Its migration ID depends on the original seed, so repeatedly loading that same
old save does not restart its timer. With no allowance remaining, that old outing
expires and returns safely. Existing terrain and Pokemon are not deleted.

## Five species per zone

After terrain generation, each of the 16 zones draws up to five distinct species
from its biome's weighted generation 1-5 pool, without replacement. A private RNG
derived from the outing seed and zone index makes the selection independent of
battle RNG. The chosen weighted tables are stored inside the expedition save.

Subsequent spawns use only that zone's table. Leaving/re-entering a zone, species
despawning, catching everything visible, or loading the save does not expand or
reroll its table. Multiple individuals of the same species may coexist, so the
existing six-visible-individual cap is separate from the five-species limit.
If an installation has fewer than five eligible species, it uses those available.
An old plan without a table gets the same deterministic selection when migrated.
The village's existing three-species grass patch remains unchanged.
