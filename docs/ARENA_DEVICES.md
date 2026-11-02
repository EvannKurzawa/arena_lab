# Objets interactifs d'arène (0.23.0)

Les six objets sont dans **Custom mode → Meubles** et reçoivent une réserve
initiale une seule fois par profil. La préparation installe les sprites décrits
dans [les sources graphiques et sonores](ARENA_DEVICE_ASSETS.md).

| Objet | Réserve initiale | Fonctionnement |
|---|---:|---|
| Tapis roulant | 8 | Choisir Bas/Gauche/Droite/Haut à la sélection. Transporte le joueur dans ce sens ; plusieurs tapis peuvent s'enchaîner. |
| Antenne magnétique | 4 | Choisir le côté attiré. Attire sur la demi-ligne correspondante, jusqu'à la case voisine de l'antenne. |
| Toile d'araignée | 8 | Multiplie par quatre la durée du pas entrant ou sortant de sa case. |
| Téléporteurs | 4 lots | Deux dalles liées, avec rotation et compression/réapparition du joueur. Fonctionnent dans les deux sens. |
| Bobine Tesla et bouton | 4 lots | Bobine toujours solide. Choisir le côté de sa case électrifiée ; marcher sur le bouton désactive seulement cette étincelle. Le bouton reste visuellement enfoncé. |
| Rune cécité | 4 | Déclenche le cercle de visibilité d'une grotte non éclairée, centré sur le joueur. |

Les tapis et antennes respectent les obstacles, le vide et les accès de relief.
Un objet solide interposé arrête l'attraction sur la dernière case libre.
Les cycles de tapis sont interrompus pour éviter un blocage permanent.
Le joueur glisse sans marcher sur les tapis et pendant l'attraction. Le
suiveur disparaît pendant toute la chaîne de tapis puis retrouve sa visibilité.
Les sols interactifs restent traversables ; ils n'exigent pas Entrée en jeu.

## Poser et retirer un lot

Le Pokémon suiveur est masqué pendant la traversée des toiles et revient à
l'arrivée sur la première case sans toile. Plusieurs toiles jointes ne le font
pas réapparaître entre deux cases. Le joueur tourne sur lui-même pendant
l'attraction magnétique, à la cadence des sables mouvants, puis regarde vers
l'antenne à l'arrêt. Le bouton utilise le MP3 électrique fourni ; la rune
utilise le fichier personnel installé localement et conserve sa durée de
cécité de 60 secondes.

Les toiles posées sur deux cases voisines se raccordent automatiquement sur
leur bord commun, à l'horizontale et à la verticale. Les raccords disparaissent
quand la toile voisine est retirée. Les diagonales seules ne sont pas reliées.

La bobine compacte possède quatre orientations : choisir son orientation et
le côté de sa boule électrique à la pose. Un arc animé relie son extrémité à
la boule voisine ; le bouton éteint la boule et cet arc. La bobine reste solide.

Sélectionner le lot, puis valider la première case avec Entrée. Déplacer le
curseur et valider une deuxième case libre. Pour Tesla, la première case est
la bobine et la seconde le bouton. Le lot est consommé seulement quand les
deux cases sont validées. X avant la deuxième case abandonne la pose sans
consommer d'objet. Chaque lot occupe deux des 80 emplacements de mobilier.

L'outil **Retirer un meuble** retire les deux éléments, quel que soit l'élément
choisi, et rend un seul lot au Sac. L'annulation complète du Custom mode
restaure aussi correctement les lots. Les éléments ne peuvent pas être posés
dans l'eau, le vide, sur une paroi, un escalier ou un occupant.

## Téléportation et visibilité

Une dalle d'arrivée ne renvoie pas immédiatement le joueur. Il faut la quitter
puis marcher dessus à nouveau. Le suiveur est transféré avec le joueur. Les
contrôles sont suspendus pendant l'animation.

La dalle verte/violette est extraite d'une capture HGSS ; le son provient du
pack HGSS référencé dans le document des assets. L'installation conserve ces
ressources dans le jeu privé et ne remplace pas `Anim/Teleport`.
Référence de fonctionnement : [Warp panels](https://bulbapedia.bulbagarden.net/wiki/Warp_panel).

La cécité dure **60 secondes** pour ce joueur. Sortir de la pièce principale
ou entrer en Custom mode la supprime aussi. Elle utilise le rayon natif sans Flash (64 pixels).
La sortie rétablit la vision et libère le masque graphique.

## Multijoueur

Protocole de visites **14** : mettre à jour les deux clients et redémarrer le
serveur. Le serveur accepte les déplacements sur les objets au sol et valide
une téléportation uniquement entre deux dalles liées. Les autres sauts de
position restent refusés.

Le bouton désactive la bobine pour les deux joueurs. Un joueur entrant plus
tard reçoit l'état courant. Les bobines se réactivent quand tous les joueurs
ont quitté la pièce principale. En solo, sortir de la pièce ou entrer en
Custom mode réinitialise les bobines. Les plans enregistrent seulement les
placements, pas ces états temporaires.

## Implémentation et vérification

- `000_ArenaDeviceRules.rb` : directions, paires et collisions partagées.
- `096_ArenaDeviceEditor.rb` : catalogue, stocks et pose/retrait atomiques.
- `097_ArenaDevices.rb` : déplacement natif, téléportation, ralentissement,
  interrupteurs et masque de cécité.
- `098_ArenaDeviceArt.rb` : dessins et aperçus natifs.
- `arena_visits.rb` : autorité serveur sur collisions, téléporteurs et bobines.

Les liens suivent l'ordre des éléments dans le plan : les deux dalles d'un
lot sont insérées/retirées ensemble ; les bobines et boutons sont appariés
dans leur ordre respectif. Le format existant des placements est conservé.

Vérification native :

```text
C:/msys64/mingw64/bin/python.exe tools/test-native-dark-lugia.py --devices
```

La sonde utilise un profil de test en mémoire et ne lit/écrit aucune sauvegarde
joueur. Les essais serveur emploient deux connexions TCP au vrai réacteur PEMK,
avec authentification injectée, sans comptes ni base de données privée.
La version 0.23.0 vérifie aussi le chemin complet des six aperçus et ouvre
réellement le sélecteur de meubles, pour couvrir l'erreur de constante corrigée.
