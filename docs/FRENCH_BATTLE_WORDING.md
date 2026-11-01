# Révision des textes de combat et noms de zones — 2026-11-01

Les corrections sont dans `090_FrenchBattleWording.rb`, chargé après les autres
plugins. Le pack français téléchargé reste intact. Les clés anglaises, les
identifiants de Dresseurs et de biomes, les surnoms et les sauvegardes restent
inchangés. Les phrases sont corrigées avant l'insertion des noms, plutôt que
par remplacement de mots dans une phrase déjà affichée.

Exemples corrigés :

| Contexte | Affichage |
|---|---|
| Choix d'une action | Que doit faire Dialga ? |
| Sélection dans l'équipe | Que faire de Zekrom ? |
| Bouton de remplacement | Envoyer |
| Rappel immédiat | Zekrom, on change ! Reviens ! |
| Arrivée d'un remplaçant | En avant, Zekrom ! |

Les autres variantes de rappel/envoi, le sommeil, le poison, la brûlure, le gel,
la confusion et une phrase de récupération de PV sont également revus. Les
actions immédiates sont au présent. Les annonces d'une action à venir conservent
leur sens : un changement adverse annoncé ou un effet dans trois tours n'est
pas converti artificiellement au présent.

« Fille Baston » est le nom officiel de Crush Girl dans Rouge Feu/Vert Feuille,
pas une erreur du pack. À la demande du joueur, l'affichage est harmonisé avec
« Combattante », autre appellation employée dans les jeux ; l'ID CRUSHGIRL ne
change pas. Ce choix ne renomme aucun Dresseur ou Pokémon du joueur.

Les 15 noms de biomes passent désormais par le traducteur dans Game_Map#name,
y compris quand le module d'expédition fournit directement un nom anglais.
Les anciens noms de l'arène/village et le nom de repli des secteurs sont aussi
traduits. Ces zones sont propres à Arena Lab : leurs noms français ne sont pas
présentés comme des lieux officiels de Pokémon.

Références consultées :

- [Corpus des textes français de Noir/Blanc](https://github.com/abcboy101/poke-corpus/blob/main/corpus/BlackWhite/fr_common.txt),
  pour vérifier le vocabulaire de commande, rappel et envoi. Référence brute
  conservée uniquement dans le runtime ignoré, jamais distribuée avec le plugin.
- [Combat Pokémon — interface](https://www.pokepedia.fr/Combat_Solo).
- [Combattante](https://www.pokepedia.fr/Combattante) et
  [Fille Baston](https://www.pokepedia.fr/Fille_Baston), pour distinguer les
  appellations selon les versions.

Les adaptations respectent les variables et l'interface d'Essentials ; elles
ne constituent pas une certification mot pour mot de tous les dialogues d'une
édition particulière. Aucun texte long ni corpus complet n'est ajouté au dépôt.

Vérification : `ruby --disable-gems game-mod/test/french_battle_wording_test.rb`
passe 94 contrôles. Elle utilise le véritable moteur de traduction Essentials
et ses méthodes de rappel/remplacement, teste les cinq branches de rappel et
les quatre branches d'envoi, les noms avec accents, les combats doubles/triples,
les variables, les noms des 15 biomes et les noms de repli des cartes.
Le test ne modifie aucun fichier runtime partagé. Aucun cache du jeu ni aucune
sonde native n'est installé pour ne pas interférer avec l'autre travail en cours.
