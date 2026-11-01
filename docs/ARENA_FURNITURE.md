# Mobilier de base pour la personnalisation — 2026-11-01

Le catalogue ajoute **20 objets** aux trois obstacles existants, soit 23 types.
Ils s'inspirent des familles de décorations des bases secrètes des jeux
classiques : sièges, bureaux, plantes, ornements et poupées.

| Nouveaux objets | |
|---|---|
| Chaise bleue | Chaise rouge |
| Tabouret vert | Fauteuil confortable |
| Petit canapé bleu | Petit bureau bleu |
| Petite table ronde | Petite bibliothèque |
| Plante feuillue | Fougère en pot |
| Palmier en pot | Arbuste taillé |
| Corbeille | Console de jeu |
| Statue de pierre | Statue de jade |
| Poupée Pikachu | Poupée Bulbizarre |
| Poupée Salamèche | Poupée Carapuce |

Dans l'arène hors ligne : **Personnalisation → Meubles**. La liste montre une
vignette par ligne, un aperçu agrandi à droite et la quantité dans le Sac.
Les sprites sont recadrés sur leur partie visible et ajustés à un même gabarit,
en conservant leurs proportions. Le panneau d'information est limité à deux
lignes : quantité en réserve et occupation d'une case.
Flèches pour parcourir, Entrée pour choisir, X pour revenir. Choisir un objet
prépare son placement ; parcourir ou annuler ne modifie pas l'arène.
Le retrait utilise le même sélecteur. Validez et sauvegardez normalement
en quittant la personnalisation pour conserver les placements.

Deux exemplaires de chaque nouveauté sont fournis une seule fois par profil,
y compris pour une sauvegarde existante. Les exemplaires déjà placés sont
comptés lors d'une attribution partielle. Le catalogue ne se remplit pas à
chaque réouverture. Les trois obstacles d'origine et leurs interactions CS
restent inchangés.

Chaque objet occupe et bloque une case, sur le sol ou sur une plateforme.
Les plantes et statues peuvent dépasser visuellement vers le haut, comme les
sprites habituels. Les petits meubles sont adaptés à cette empreinte ; il
n'y a pas de grands meubles multi-cases ni d'action pour s'asseoir ou jouer à
la console. Eau, escaliers, parois, vide et cases occupées conservent leurs
restrictions. La capacité globale du mobilier reste celle de l'éditeur.

Les images sont composées en mémoire depuis `Interior general.png` et les
icônes Pokémon de l'installation locale d'Essentials. Les poupées emploient
une icône sur un petit socle. Aucun asset n'est téléchargé ou ajouté au dépôt.
L'aperçu et les objets placés utilisent le même rendu.

Les visites gardent leur format réseau actuel. Les deux clients doivent avoir
le nouveau catalogue pour interpréter les nouveaux identifiants. Le serveur
existant accepte et transmet ces identifiants : aucune modification du serveur
ou du protocole n'est nécessaire pour ce catalogue.

Implémentation isolée : `091_ArenaFurnitureCatalog.rb` complète le catalogue et
les points d'extension existants. `009_ArenaCustomMode.rb`, les interactions CS,
les profils de Dresseurs et le fichier de version partagé ne sont pas modifiés
par cet ajout. Fermez le jeu puis relancez **Play-Arena.bat** pour le préparer.

Références consultées :

- [Décoration — Poképédia](https://www.pokepedia.fr/D%C3%A9coration).
- [Décorations des bases secrètes classiques](https://www.pokemon-france.com/jeux/gen3/rs/cabane/index.php).
- [Manuel Pokémon Platine — Nintendo](https://csassets.nintendo.com/noaext/image/private/t_KA_PDF/DS_Pokemon_Platinum?_a=DATAg1AAZAA0),
  pour le principe d'entreposage et de placement dans une base.

Vérification : 26 tests / 1 200 assertions dans `furniture_catalog_test.rb`
(dont les tests de relief existants), 1 test serveur / 16 assertions avec de
vraies connexions TCP, et **101 vérifications dans mkxp-z**. Le test graphique
utilise une copie temporaire séparée : rendu des 20 sprites, empreinte d'une
case, changements de graphisme, placement sur plateforme, sauvegarde/chargement,
visite encodée, confirmation/annulation du vrai sélecteur et libération des
fenêtres. Captures du menu plante et poupée inspectées visuellement.
Le cache partagé et les sauvegardes personnelles ne sont pas utilisés.

Outils de QA privés :

```text
ruby game-mod/tools/furniture_preview.rb PRIVATE_GAME OUTPUT.png
python tools/test-native-furniture.py
```

Les PNG de vérification restent dans le runtime ignoré ; ils ne sont pas
distribués avec le code. Aucune nouvelle visite manuelle entre deux PC n'est
revendiquée.
