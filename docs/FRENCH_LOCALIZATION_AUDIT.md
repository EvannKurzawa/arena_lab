# French localization audit — 0.13.4

## References and wording

The user requested wording inspired by French HeartGold/SoulSilver and Black/
White. Consulted these online references on 2026-10-30:

- [Poké Corpus](https://abcboy101.github.io/poke-corpus/) and its
  [Black/White French corpus](https://github.com/abcboy101/poke-corpus/blob/main/corpus/BlackWhite/fr_common.txt).
- [HGSS corpus directory](https://github.com/abcboy101/poke-corpus/tree/main/corpus/HeartGoldSoulSilver).
- [HGSS dialog citations](https://www.pokepedia.fr/M%C3%A8re/Citations).
- [Black/White ability names](https://www.pokebip.com/pokedex/noir-blanc/talents).

The Black/White reference was read locally to check brief inventory/escape
formulations; it remains ignored under tools/runtime. No game text dump is
bundled. Arena Lab's revised sentences are adaptations for Essentials' variables
and UI, not a claim that each sentence is an exact official HGSS/BW quotation.

## Defects corrected

- The global _INTL wrapper replaced English words in lookup keys before native
  translation. This changed Bag to Sac and prevented existing French messages
  from matching. Native lookup now uses the original key.
- Source Ruby strings and the community extraction encode line breaks differently.
  Canonical aliases now match actual newline, escaped newline and whitespace
  variants, without modifying displayed control codes or player arguments.
- Inventory uses “Vous rangez … dans la poche … du Sac.”
- Successful escape uses the user's requested “Vous avez pris la fuite !”.
- AbilitySplashBar retains its graphic and animation, with one line containing
  only the translated ability name. Its renderer no longer draws a Pokémon name.
- Reviewed/corrected switching, critical-focus, fainting, ability attribution,
  editor descriptions, UI labels and malformed numeric format placeholders.
- Graphics/Audio/Data asset IDs bypass presentation translation entirely.

## Per-template audit

Run from the repository root using bundled Ruby:

    ruby --disable-gems game-mod/tools/audit_french_messages.rb

The tool scans every literal _INTL/_ISPRINTF call in the installed Essentials
Data/Scripts tree: **3,310 distinct templates**. It evaluates string escapes
exactly, loads plugins after the same tab normalization as PluginManager, and
records the effective French result and originating filenames for each phrase.
It checks untranslated English, English possessive syntax, formatting parameter
preservation and unchanged asset IDs. The 47 unchanged labels were explicitly
classified: shared French spellings, proper names, formatting and resources.

Full private report: `tools/runtime/french_messages_audit.json`; machine fixture:
`tools/runtime/french_messages_audit.dat`. Both stay ignored because they contain
upstream/community translation text. The audit is per-template automated
validation plus targeted editorial corrections; it is not a claim of a fresh
manual linguistic review of every line or every original story event.

## Native verification

`python tools/test-native-french.py` starts a separate hidden native engine,
without loading or writing a save. It verifies all 3,310 template outputs agree
with the report, executes real NPC/quest dialog methods and checks the actual
ability-bar drawing calls contain only the ability name. It also audits the
304 follower and 131 PEMK literal templates. The final UI sink is intercepted
for automated NPC testing. This verifies generated text, not visual playtesting
of every possible screen. The temporary probe is removed in finally.

Results: 0 audit failures; 23 native checks pass; follower/network coverage and
standalone title/translation regressions pass. The original graphical battle
buttons requested by the user remain in place. Original sample-map event text,
dynamically constructed templates and graphical labels baked into other assets
are outside this literal-script audit and are not certified by its counts.
