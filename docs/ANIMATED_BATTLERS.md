# Pokémon animés en combat

`094_AnimatedBattlers.rb` utilise le lecteur GIF déjà fourni par Essentials
v21.1/mkxp-z, uniquement pour les sprites des combattants. Aucun remplacement
du moteur de combat ni installation de Deluxe Battle Kit n'est nécessaire.

Couverture : les 649 premières espèces, de face et de dos, normales et
chromatiques, plus 384 variantes femelles disponibles. S'y ajoutent 82 formes
alternatives des générations 1 à 5, dont Giratina Originelle, les formes
de Motisma, Deoxys, Zarbi, Arceus et les saisons de Vivaldaim/Haydaim.
Kyurem Blanc/Noir ainsi que leurs formes de combat lumineuses sont tous pris
en charge : Essentials passe aux formes 3/4 à l'entrée en combat.

Les formes postérieures à Noir 2/Blanc 2, le type inconnu 9 d'Arceus et
Pichu Troizépi (aucun GIF animé correspondant dans cette source) gardent les
images natives. Les Pokémon Obscurs, œufs et motifs de Spinda gardent également
leur rendu natif. Les originaux ne sont jamais écrasés. Le canevas et la ligne
de base d'origine restent utilisés pour les métriques et effets de combat.
Les GIF gardent désormais leur échelle de pixels ×2 : le canevas transparent
s'agrandit pour accueillir les ailes et les grandes poses, au lieu de réduire
le Pokémon à la taille du cadre d'origine. Cela corrige notamment les vues de
dos de Lugia, Zekrom et Kyurem, ainsi que Giratina Originelle.

Dark Lugia utilise les GIF du Lugia normal recolorés en violet : 60 images de
face et 120 de dos, mêmes poses et mêmes durées. Seules les palettes changent.
La planche XD001 reste utilisée pour les icônes, le Pokédex et le suiveur.
Les découpes conservent les ailes complètes dans les huit poses sur la map.

Les icônes de Dark Lugia gardent une échelle constante ×2 ; son suiveur
conserve chaque pose deux frames, pour un battement d'ailes plus lent.

## Installation

Fermer puis relancer **Play-Arena.bat** prépare automatiquement les images.
La première préparation nécessite Internet et télécharge 3 316 GIF avec huit
requêtes simultanées au maximum. Les préparations suivantes réutilisent le pack.
Une interruption permet de reprendre les fichiers restants au prochain lancement.

Installation ou réparation manuelle, depuis la racine du projet :

```powershell
powershell -ExecutionPolicy Bypass -File tools/install-animated-battlers.ps1 -GameRoot tools/runtime/essentials-v21.1-base -Repair
```

`-SourceRoot` permet une installation hors ligne depuis un dossier contenant
exactement le sous-dossier `animated` de la source ci-dessous. Chaque fichier
est vérifié avant installation, y compris en mode hors ligne. Les téléchargements
se font vers le runtime du jeu ; aucune image n'est incluse dans Git.

## Sources et conditions

- [PokéAPI Sprites](https://github.com/PokeAPI/sprites), commit
  `1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64`.
- Dossier `sprites/pokemon/versions/generation-v/black-white/animated`.
- [README source](https://github.com/PokeAPI/sprites/blob/1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64/README.md)
  et [conditions](https://github.com/PokeAPI/sprites/blob/1dd55c0436d2a5b6e324c0b780e1b1b416fbfb64/LICENCE.txt)
  consultés. Le dépôt annonce CC0 mais attribue explicitement les images à
  The Pokémon Company. Ce statut ne constitue pas une autorisation de
  redistribuer les images propriétaires. Elles restent locales pour ce projet
  personnel ; seuls l'installateur, les chemins et les empreintes sont versionnés.
- `tools/animated-battlers-manifest.json` contient les 649 identifiants
  Essentials, les correspondances de 84 numéros de formes vers les noms de
  fichiers du pack, et les SHA-256 des 3 316 destinations.

## Correctif des aperçus de Dresseurs

`093_ArenaTrainerCatalogFrames.rb` corrige le découpage des feuilles 4 × 4 :
Motard/Loubard ont des poses de 48 × 48, les Dresseurs ordinaires de 32 × 48.
La pose complète est ajustée dans un cadre de 44 × 48. Ce correctif concerne
la fenêtre commune aux menus de recrutement et de pose, sans modifier les
profils ajoutés dans `009_ArenaCustomMode.rb`.

## Validation

```powershell
C:/msys64/mingw64/bin/python.exe tools/test-native-battlers.py
```

Le test utilise une copie jetable du jeu et du moteur : le cache partagé et
les sauvegardes restent intacts. Il lit le pack de test dans
`tools/runtime/battler-assets` (installer avec ce dossier comme `-GameRoot`).
Le contrôle natif couvre les rectangles des trois Dresseurs, le mouvement réel
des pixels, les formes de face/dos/chromatiques et la transition de Kyurem
vers sa forme lumineuse. Installation hors ligne, détection
du pack déjà installé et récupération HTTP d'un fichier manquant vérifiées.
Un combat complet et une session à deux clients n'ont pas été exécutés pour
ce changement ; le protocole réseau reste inchangé.
