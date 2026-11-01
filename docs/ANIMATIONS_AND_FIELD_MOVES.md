# Animations, rendu et objets CS

## Dialogues et effets CS — 0.21.1

Force exige Entrée face au rocher, y compris pour chaque poussée. Approcher
le rocher ne suffit plus à lancer le dialogue.

Les messages courts sont vérifiés dans le [script français de HeartGold et
SoulSilver, fichier texte 211](https://github.com/abcboy101/poke-corpus/blob/main/corpus/HeartGoldSoulSilver/fr_msg.txt).
La typographie et les retours à la ligne sont adaptés à Essentials. La phrase
de Force est au présent. Le corpus complet reste dans le runtime privé ignoré.

`039_FieldMoveEffects.rb` anime les graphismes déjà présents : entaille blanche
et séparation de l'arbuste pour Coupe ; six fragments tournants pour Éclate-Roc.
Les sons natifs sont conservés. Ce sont des effets réalisés pour Arena Lab,
inspirés du comportement des jeux ; aucun nouvel asset officiel n'est copié.
En multijoueur, la destruction s'anime sur réception de l'état validé du serveur.
Une entrée tardive dans la pièce affiche directement l'objet disparu.

## Bibliothèque d'animations

Le jeu de base possédait 311 animations et 211 correspondances directes pour
740 attaques : beaucoup utilisaient un effet générique. Le **Gen 9 Move Animation
Project**, compatible Essentials 20.1/21.1, est installé dans le jeu privé.
Il n'ajoute ni espèces, ni capacités, ni nouveau moteur de combat.

- Source et instructions : https://eeveeexpo.com/resources/1480/
- Auteurs : KRLW890, Nut0066 ; projet Gen 8 de StCooler, ressources de l'équipe
  Reborn, effets sonores de BellBlitzKing et contributeurs cités sur la page.
- Archive téléchargée : 53 537 466 octets ; SHA256
  `931691C2E0B4B7817AA891AAA6653FEBDD7C7D0870DC657DAD331F16752AF24B`.
- 1 532 enregistrements ajoutés en conservant les identifiants précédents et
  les séquences contiguës de charge/impact. Les emplacements vides nommés ne
  masquent pas les animations natives.
- Couverture vérifiée : **738/740 animations dédiées**. Force Nature et Force
  Cachée délèguent leur animation à l'attaque adaptée à leur effet/terrain.
  Les deux remplacements provisoires de 0.19.4 ne remplacent plus leurs vraies
  animations Coup de Boue et Éclair Croix lorsque le pack est installé.

Le lancement prépare le pack si nécessaire via `install-battle-animations.ps1`.
Le téléchargement est vérifié ; un pack installé et intact est réutilisé.
Le processus conserve `Data/ArenaLab-BattleAnimations-before-Gen9.rxdata`,
`Data/move2anim.dat.before-Gen9` et les anciennes images modifiées sous
`Data/ArenaLab-BattlePackAssetBackup/`. `Data/Animations.rxdata`, utilisé pour
les animations sur la carte et le suiveur, reste distinct.
Une modification ultérieure des données installées est préservée : le script
refuse de la remplacer automatiquement. Les ressources tierces et sauvegardes
restent dans `tools/runtime/`, ignoré par Git. Aucun droit général de
redistribution de ces ressources n'est revendiqué.

`037_AnimationTimingSafety.rb` initialise les valeurs de transition de fond
et de premier plan lorsqu'une séquence commence sans état précédent. Cette
compatibilité applique le correctif de transition indiqué par l'auteur sans
modifier les scripts du moteur.

## Erreur graphique D3D11

`0x887A0006` est `DXGI_ERROR_DEVICE_HUNG` :
https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-error

L'installateur configure désormais **renderer = 2 (OpenGL)** et désactive le
blitting. Cette option est documentée dans la configuration du moteur exact :
https://github.com/mkxp-z/mkxp-z/blob/37a04d14413454551a7b6aadbb4e93e67168accb/mkxp.json

Cela évite la voie de présentation Direct3D 11 signalée. Aucun pilote, registre
Windows ou délai TDR n'est modifié. Des lectures d'animations natives ont été
exécutées avec ce réglage ; le blocage matériel d'origine n'a pas été reproduit
et sa disparition durable sur un autre PC reste à confirmer.

## Objets placés dans l'arène

Interagissez face à **Pousse à couper**, **Rocher à briser** ou **Rocher à pousser**.
Les trois CS sont ajoutées une fois au Sac lors de la première interaction.
Enseignez la CS correspondante à un Pokémon compatible de l'équipe.
Les badges du scénario de démonstration ne sont pas requis dans cette arène.

- **Coupe** coupe la pousse ; **Éclate-Roc** brise le petit rocher.
  L'objet devient temporairement invisible et traversable, sans retour au Sac
  et sans modification du placement enregistré.
- **Force** s'active, puis permet de pousser le gros rocher d'une case à la fois,
  en appuyant sur Entrée face à lui. Les collisions, autres occupants,
  le vide, les liquides dangereux, escaliers et rebords bloquent la poussée.
- L'annulation ou l'absence de capacité apprise ne modifie pas la disposition.
  La position du rocher poussé est temporaire elle aussi. Le plan d'origine et
  l'inventaire restent identiques, y compris après une sauvegarde.

En solo, sortir de la pièce principale puis revenir restaure tous les objets.
Entrer en mode Custom restaure également tous les objets **avant** de créer le
brouillon de l'éditeur, même si l'édition est ensuite annulée. Charger une partie
commence une nouvelle session temporaire de la pièce.

En multijoueur, le serveur maintient cet état tant qu'au moins un des deux
joueurs reste dans la pièce principale. Sortir puis revenir seul ne suffit pas.
Quand le dernier joueur sort ou se déconnecte, tous les objets sont réinitialisés.
Un joueur dans le hub reçoit aussi les modifications et les retrouve en entrant.
Les arrivées tardives reçoivent le même état. Le serveur vérifie les demandes,
les collisions et les révisions pour qu'une double poussée simultanée ne déplace
pas le rocher deux fois. Les changements de pièce sont annoncés immédiatement,
même lors d'un aller-retour rapide. Les visites utilisent le **protocole 12** :
mettre les deux clients et le serveur à jour ensemble.

Les arbres du décor du village et les reliefs naturels ne sont pas assimilés
aux objets plaçables de l'éditeur.

## Équipe de debug de la version 0.21.0

Au premier lancement de chaque profil avec cette version, une migration remplace
l'équipe par **un seul Mew niveau 100**, soigné, avec exactement **Coupe, Surf,
Éclate-Roc et Force**. Elle couvre les profils existants et les nouvelles parties,
sans dépendre du nom de joueur ni d'un marqueur présent uniquement sur le PC hôte.

Le remplacement est sauvegardé à la première frame de carte sûre ; un échec de
sauvegarde restaure l'équipe et les marqueurs précédents. L'ancienne équipe est
conservée dans `PokemonGlobalMetadata#arena_debug_party_backup`, avec le marqueur
`arena_debug_party_version = 1`. Elle n'est pas envoyée au PC de stockage.
La migration ne s'applique qu'une fois par profil et ne remet pas à zéro l'équipe
à chaque déplacement ou après chaque capture. Le rafraîchissement du suiveur
affiche le nouveau Pokémon. Les sondes de test désactivent l'auto-sauvegarde de
cette migration et la vérifient uniquement en mémoire.
