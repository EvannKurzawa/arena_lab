# Pokémon Arena Manager — Codex Project Brief

Correctif connexion : si le PNJ de l'entrée affichait
`uninitialized constant ArenaDemo::ConnectionMode::PEMK`, fermer le jeu,
lancer **Arena Update.exe**, puis **Play-Arena.bat**. La préparation ajoute
PEMK au cache compilé et le charge avant Arena Demo. Les sauvegardes sont conservées.

## v9.3 — Arena Demo 0.24.0

Ajoute Gold et de nouvelles équipes de dresseurs, dont le Léviator chromatique
de Gold. Objets interactifs revus : toiles jointes avec suiveur masqué, rune et
sons personnalisés, tapis animés, bobines dorées orientées reliées à leur
étincelle, rotation pendant l'attraction magnétique. Corrige aussi les alias
de sprites Dark Lugia. **58 contrôles natifs et 33 tests / 509 assertions réussis.**

Fermer les clients, lancer **Arena Update**, puis **Play-Arena.bat**. Protocole
inchangé (**14**). **Arena Update.exe récupère aussi les ressources de Gold,
Dark Lugia et le son de la rune**, installées automatiquement au lancement
suivant avec Play-Arena.bat, même avec l'ancien updater. Les futurs sons et
graphismes placés dans `game-mod/SharedAssets/` suivent le même circuit.
Voir [les ressources partagées](docs/GOLD_TRAINER.md).

Dernière révision locale : le suiveur se cache dans les toiles et revient sur
la première case sans toile. L'attraction magnétique fait tourner le joueur
comme les sables mouvants. Bobines dorées à socle métallique, plus petites,
en quatre orientations reliées à leur étincelle. Son du bouton remplacé par
le MP3 Myinstants fourni ; son de la rune installé depuis `rune_cecite.mp3`.
**55 contrôles natifs réussis.** Fermer les clients puis relancer
**Play-Arena.bat**. Le son personnel de la rune reste dans le runtime privé.

Toiles voisines raccordées automatiquement, horizontalement et verticalement.
Bobine Tesla compacte en quatre orientations, reliée à sa boule électrique par
un arc animé qui s'éteint avec le bouton. Choisir l'orientation à la pose.
**46 contrôles natifs réussis.** Relancer **Play-Arena.bat** pour charger cette
révision locale.

Révision visuelle locale : boule électrique bleue pleine animée sur neuf
images, rune simplifiée avec anneaux continus et toile plus contrastée.
Ces trois dessins utilisent directement la grille native 32×32, sans réduction
d'image. **38 contrôles natifs réussis.** Fermer le jeu puis relancer
**Play-Arena.bat** pour charger les scripts modifiés.

## v9.2.1 — Arena Demo 0.23.1

Corrige le blocage au démarrage après une réécriture des données d'animations
sans changement de contenu. Révise le tapis, la rune, la toile, les quatre
orientations de l'antenne et le son magnétique. Fermer les jeux, lancer
**Arena Update**, puis **Play-Arena.bat** sur chaque PC. Aucune réinstallation
complète requise ; protocole multijoueur inchangé (**14**).

Avant mise à jour, sauvegarder les scripts, PBS et sprites personnalisés.
Réintégrer les ajouts dans les fichiers à jour sans rétablir les anciens scripts
complets. Les scripts personnalisés vont dans `game-mod/Plugins/ArenaDemo/` ;
les copies du runtime sont remplacées lors de la préparation.

Diagnostic d'un blocage « Battle animation data changed » : voir
[le compte rendu](docs/BATTLE_ANIMATION_STARTUP_RECOVERY.md). Le lancement accepte
désormais les réécritures dont le contenu des animations est inchangé et migre
les anciennes installations automatiquement si leur référence peut être vérifiée.
Ne pas supprimer le marqueur pour forcer une réinstallation du pack.

## Nouveaux visuels et sons des objets (2 novembre 2026)

Correction du rendu : tapis à défilement périodique sans coupure, rune creuse,
toile claire sans contour noir et quatre antennes orientées sans flèche.
Bourdonnement renforcé dans les médiums ; fichier et appel au moteur audio
vérifiés. **35 contrôles natifs réussis.** Fermer toutes les fenêtres du jeu,
puis relancer **Play-Arena.bat** pour installer cette révision.

Tapis noir à chevrons jaunes animé, dalle de téléportation bleue, rune violette,
toile irrégulière et antenne simplifiée. Le Pokémon suiveur disparaît pendant
l'attraction magnétique et revient à l'arrêt, y compris devant un obstacle.
Un bourdonnement accompagne l'attraction ; le bouton Tesla produit un son de
coupure électrique. Relancer **Play-Arena.bat** pour installer les sprites et
générer les sons sur chaque PC. Vérification native : **32 contrôles réussis**,
sans lire ni écrire de sauvegarde joueur. Détails : [assets](docs/ARENA_DEVICE_ASSETS.md).

## Objets interactifs et Pokédex de 650 Pokémon (Arena Demo 0.23.0, local)

**Dark Lugia possède désormais sa propre entrée nationale 650** ; Lugia normal
reste au numéro 249. Les anciens exemplaires sont convertis dans l'équipe et
le PC, en conservant leurs données et leurs attaques personnalisées. Le
Pokédex contient exactement **650 espèces** : les **649 Pokémon des générations
1 à 5**, puis **Dark Lugia**. Les générations suivantes sont exclues de la liste
et des compteurs ; les évolutions vers ces espèces sont bloquées. Leurs données
techniques d'origine restent internes au moteur pour préserver sa compatibilité.

Six meubles interactifs sont disponibles en Custom mode : **tapis roulant**,
**antenne magnétique directionnelle**, **toile d'araignée (vitesse ÷4)**,
**téléporteurs liés**, **bobine Tesla avec bouton rouge**, **rune cécité**.
Les déplacements forcés s'arrêtent devant les obstacles et le vide. Les lots
se posent sur deux cases et se retirent ensemble. Les bobines partagent leur
état en multijoueur ; la cécité est individuelle et dure **60 secondes**.
Les tapis et antennes font glisser le joueur sans animation de marche ; le
suiveur est caché pendant les tapis et réapparaît à leur sortie. La bobine
reste solide : le bouton enfoncé désactive seulement son étincelle voisine,
dont le côté est choisi à la pose. Les sprites et le son sont revus.
Le catalogue de meubles corrige aussi l'erreur `DeviceCatalogArt::DeviceArt` :
ses six nouveaux aperçus et l'ouverture de la liste sont vérifiés dans le moteur.

Relancer **Play-Arena.bat** pour charger les changements locaux. Protocole de
visites **14** : les deux clients et le serveur doivent être mis à jour.
Le téléporteur reprend la dalle et le son HGSS, préparés dans le jeu local.
Sources et installation : [assets des objets](docs/ARENA_DEVICE_ASSETS.md).
Voir [le fonctionnement et les contrôles](docs/ARENA_DEVICES.md).
Ces changements ne sont pas encore commit/push.

## Dernière version du code : v9.1 (Arena Demo 0.21.4)

Cette version ajoute Dark Lugia et ses animations, les sprites de combat animés
des 649 premières espèces et de leurs formes prises en charge, les aperçus de
Dresseurs corrigés, et l'équipe personnelle de debug niveau 100. Force se
déclenche avec Entrée une première fois, puis les rochers se poussent en
avançant contre eux, avec un déplacement animé partagé en multijoueur.

### Dark Lugia Ténèbres/Vol et attaques obscures

Dark Lugia est désormais **Ténèbres/Vol** et apprend sa propre liste de capacités
par niveau : Étonnement, Groz'Yeux, Cyclone et Draco-Rush (1), Brume (9), Provoc
(18), Machination (27), Vibrobscur (36), Soin (45), Aéroblast (54), Ball'Ombre
(63), Dévorêve (81) et Mort-Ailes (90). **Trou Noir est exclu.**

Au niveau 100, le cadeau et les Dark Lugia déjà dans l'équipe reçoivent une fois
**Aéroblast / Vibrobscur / Machination / Mort-Ailes**. Un exemplaire stocké au PC
est mis à jour quand il rejoint l'équipe. Les modifications manuelles suivantes
sont conservées. Relancer `Play-Arena.bat` pour charger le changement, puis
sauvegarder normalement. Vérification native : 48 contrôles réussis sans lire
ni écrire de sauvegarde joueur.

## Équipe personnelle niveau 100 (local)

Au prochain chargement via **Play-Arena.bat**, l'équipe temporaire est remplacée
une seule fois par **Kyurem Blanc, Dark Lugia, Zekrom, Lugia, Giratina Originelle
et Mew**, tous niveau 100. Giratina tient l'Orbe Platiné ; Mew possède Coupe,
Surf, Éclate-Roc et Force. L'équipe précédente est conservée dans les métadonnées
de sauvegarde pour récupération. L'installation locale de Dark Lugia est requise ;
si elle manque, l'équipe actuelle est conservée.


## Dark Lugia (XD001), intégration locale (Arena Demo 0.21.4)

Dernier correctif local (import layout 7) : Dark Lugia reprend désormais les
GIF du Lugia normal recolorés avec sa palette violette, en conservant toutes
les poses et leur cadence. Les sprites de la planche restent utilisés pour
l'icône, le Pokédex et le suiveur. Les rectangles du dos et des huit poses de
map ont été corrigés pour conserver les extrémités des ailes. La préparation
installe les GIF de base avant de générer cette variante locale.

Son suiveur conserve le battement d'ailes ralenti. Les animations de combat
gardent une échelle ×2 avec un cadre assez grand pour les ailes et les dos.

L'image locale `xd001.png` est découpée par `game-mod/tools/install_dark_lugia.rb`
en sprites de combat avant/arrière, icônes et suiveur. Le menu pause propose
**Dark Lugia** : ouvrir sa fiche dans le Pokédex ou recevoir un exemplaire
niveau 100. Il s'agit de la forme 1 de Lugia (#249) : stats et talents viennent
des données natives de Lugia, avec le type et l'apprentissage propres décrits
plus haut. Cela n'ajoute pas les mécaniques
de Pokémon Obscur ni la purification de Pokémon XD.

La préparation locale (`tools/local-multiplayer.ps1 -Action Prepare`) importe
les sprites dans le jeu privé. Chaque PC doit avoir une copie identique de
`xd001.png` à la racine du projet lors de cette préparation ; l'image d'origine
et les sprites découpés restent locaux et sont ignorés par Git. L'auteur crédité
sur la planche est ShadowGate31 ; les conditions de redistribution n'ont pas été
vérifiées. Aucune image n'est incluse dans le dépôt. Le test natif a passé 23
vérifications sans lire ni écrire de sauvegarde joueur.

## Dresseurs complets et Pokémon animés en combat (local)

Les aperçus de **Motard** et **Loubard** affichent désormais une pose entière,
redimensionnée pour la ligne de sélection, dans les menus de recrutement et de pose.
Le plugin `094_AnimatedBattlers.rb` anime les 649 premiers Pokémon en combat
avec les sprites Noir/Blanc, de face/de dos et chromatiques. Les différences
femelles disponibles et **82 formes alternatives de l’époque Noir 2/Blanc 2**
sont prises en charge : Kyurem Noir/Blanc (y compris leurs états lumineux en
combat), Giratina Originelle, Motisma, Deoxys, Zarbi, Arceus et autres formes
détaillées dans la documentation. Les formes postérieures, Pichu Troizépi
(sans animation dans ce pack), Pokémon Obscurs et motifs de Spinda conservent
leur rendu natif.

La préparation lancée par **Play-Arena.bat** installe automatiquement les
sprites manquants depuis [PokéAPI Sprites](https://github.com/PokeAPI/sprites),
avec une source figée et des empreintes SHA-256. Le premier lancement demande
une connexion Internet et peut prendre quelques minutes ; les suivants utilisent
les fichiers locaux. Images propriétaires conservées dans le runtime ignoré,
sans ajout au dépôt ni modification des originaux. Protocole réseau inchangé.
Voir [la documentation](docs/ANIMATED_BATTLERS.md).

## Force : activation et poussées animées (Arena Demo 0.21.3, local)

Appuyez sur **Entrée** face au rocher pour activer Force. Ensuite, avancez
contre les rochers pour continuer à les pousser sans réappuyer sur Entrée.
Chaque poussée fait glisser le rocher jusqu'à la case suivante, avec le son
correspondant, en solo et sur les deux clients multijoueurs. En ligne, le
déplacement commence après validation du serveur ; une demande en attente
ne se répète pas tant que la direction reste maintenue.

Corrections installées localement, non encore publiées : fermez le jeu puis
relancez **Play-Arena.bat** sur ce PC. Après publication, mettez les deux clients
à jour ; le protocole reste **12**.

## Version précédente : v9.0.2 (Arena Demo 0.21.2)

Cette mise à jour ajoute les nouveaux profils de Dresseuses Pique-Nique et les
noms révisés des Peintres, ainsi que les deux correctifs ci-dessous.

Les CS conservent désormais la position et la direction du joueur pendant
l'animation du Pokémon suiveur : le serveur peut valider Coupe, Éclate-Roc
et Force face à l'objet. Les effets de coupe et de bris sont conservés.
Chaque case parcourue pendant une glissade est annoncée au serveur : le vide
bloque sur la dernière case de glace, sans retour au début de la glissade.
Le joueur peut ensuite repartir dans une autre direction.

Fermez les jeux, mettez les deux clients à jour avec **Arena Update**, puis
relancez **Play-Arena.bat** ; le protocole serveur reste **12**.

## Version précédente : v9.0.1

v9.0.1 ajoute des Dresseurs au catalogue de v9, décrit ci-dessous.

Version interne : **Arena Demo 0.21.1** ; visites multijoueurs au **protocole 12**.
Cette version regroupe les correctifs Surf/suiveur, les arrivées praticables en
expédition, les PNJ au repos, le pack d'animations de combat, les objets CS
temporaires partagés, les dialogues et effets CS, les corrections de français
et les 20 nouveaux meubles avec leur sélecteur visuel.

Pour tester les CS, chaque profil reçoit une seule fois **un Mew niveau 100**
avec **Coupe, Surf, Éclate-Roc et Force**, en remplacement de l'équipe actuelle
conservée en secours dans la sauvegarde.

Fermez les jeux, lancez **Arena Update sur les deux PC**, puis **Play-Arena.bat**.
Redémarrez le serveur pour le protocole 12. L'updater récupère le code de `main` ;
aucun nouvel exécutable de mise à jour n'est nécessaire. Le premier téléchargement
du pack d'animations demande Internet ; ses ressources restent privées au runtime.
Les détails et résultats de vérification figurent dans les sections suivantes
et dans [SETUP_STATUS.md](SETUP_STATUS.md).

## Dialogues CS et effets sur les objets (Arena Demo 0.21.1)

Le rocher de Force demande **Entrée**, face au rocher, pour activer Force.
Depuis 0.21.3, les poussées suivantes se font en avançant contre le rocher.
Les textes de Coupe, Éclate-Roc et Force reprennent les dialogues français de
HeartGold/SoulSilver, avec une typographie adaptée à l'interface.
Coupe affiche une entaille et l'arbuste se sépare ; Éclate-Roc disperse le
caillou en fragments. Ces effets utilisent les graphismes déjà installés et
les sons du moteur. L'autre joueur présent voit aussi la destruction validée
par le serveur ; entrer après coup ne rejoue pas l'animation.
Les règles de réinitialisation des objets restent celles décrites ci-dessous.
Fermez le jeu puis relancez **Play-Arena.bat** pour charger ces corrections.
Ces changements font partie de v9 et sont récupérés par Arena Update depuis `main`.

## Nouveau mobilier et sélection visuelle (2026-11-01)

La personnalisation propose **20 nouveaux meubles**, soit **23 types** avec
les trois obstacles existants : sièges, petites tables, bibliothèque, plantes,
statues, console et quatre poupées Pokémon. Chaque profil reçoit deux exemplaires
de chaque nouveauté une seule fois, y compris les sauvegardes existantes.

Dans **Personnalisation → Meubles**, les vignettes et l'aperçu agrandi utilisent
un gabarit commun avec les proportions conservées. Le panneau affiche uniquement
**En réserve** et **Occupe 1 case**, sans troisième ligne tronquée.
Voir [le catalogue et son utilisation](docs/ARENA_FURNITURE.md).

Validation : **26 tests / 1 200 assertions**, **1 test réseau / 16 assertions**
et **101 contrôles moteur** dans une copie temporaire séparée. Les ajouts font
partie de v9 : mettez les deux PC à jour puis relancez **Play-Arena.bat**.

## Objets CS temporaires partagés et Mew de debug (Arena Demo 0.21.0)

Coupe et Éclate-Roc font disparaître temporairement l'objet, sans ajout au Sac.
Force déplace temporairement le rocher. Le plan sauvegardé reste inchangé.
En solo, sortir de l'arène puis revenir, ou ouvrir le mode Custom, réinitialise
tous ces changements. L'annulation du mode Custom garde cette réinitialisation.

En multijoueur, les changements restent partagés tant qu'au moins un joueur
occupe la pièce principale. Le joueur qui entre depuis le hub retrouve les
objets disparus et les rochers déplacés. Le serveur réinitialise la pièce quand
le dernier joueur sort ; un aller-retour d'un seul joueur ne suffit pas.

Au premier lancement de chaque profil avec cette version, l'équipe est remplacée
pour le debug par **un seul Mew niveau 100**, avec **Coupe, Surf, Éclate-Roc et
Force**. L'équipe précédente reste conservée en secours dans la sauvegarde.
Cette migration est unique par profil, sans remplacement répété après capture.

Fermez les jeux et relancez **Play-Arena.bat** après mise à jour des deux PC.
Redémarrez le serveur : les visites passent au **protocole 12** dans v9.
Voir les [règles et vérifications](docs/ANIMATIONS_AND_FIELD_MOVES.md).

## Pack d'animations complet et objets CS (Arena Demo 0.20.0)

Le pack compatible Essentials 21.1 apporte des animations dédiées pour
**738 des 740 attaques**, au lieu de 211. Les animations de charge/impact et
les versions adverses sont conservées. Le lancement télécharge et prépare
les ressources privées vérifiées si elles manquent ; une connexion Internet
est nécessaire la première fois. Aucun nouveau moteur de combat n'est ajouté.

Le moteur utilise désormais **OpenGL** pour contourner la voie D3D11 ayant
signalé `0x887A0006`. Les animations ont été testées avec ce réglage ; le
blocage graphique d'origine n'a pas été reproduit.

Les trois objets plaçables répondent aux CS : **Coupe**, **Éclate-Roc** et
**Force**. Les CS sont fournies dans le Sac au premier essai ; un Pokémon de
l'équipe doit connaître la capacité. Les badges du scénario ne sont pas requis
dans l'arène. La version 0.21.0 remplace le retrait permanent initial par l'état
temporaire et partagé décrit ci-dessus.

Fermez le jeu puis relancez **Play-Arena.bat**. Voir les
[détails, crédits et limites](docs/ANIMATIONS_AND_FIELD_MOVES.md).

## Surf dans les coins, animations et PNJ (Arena Demo 0.19.4)

Le suiveur reste masqué pendant Surf même lorsque son déplacement lui fait
franchir une rive dans un coin. Il revient sur terre si le suivi est activé.
Les PNJ statiques du village, de l'entrée et de l'arène, ainsi que les Dresseurs
placés, utilisent leur pose de repos et peuvent toujours se tourner pour parler.

La bibliothèque d'animations d'Essentials installée est partielle. **Coup de
Boue** et **Éclair Croix** n'ont pas d'animation dédiée : ils utilisent maintenant
respectivement l'effet de poussière de Jet de Sable et l'effet électrique de
Tonnerre, au lieu des effets génériques précédents. Une animation dédiée reste
prioritaire si un pack compatible est installé plus tard. Les règles de combat
et l'option d'activation des animations restent celles d'Essentials.

Fermez le jeu puis relancez **Play-Arena.bat**. Les corrections prennent aussi
en charge les modèles de cartes existants ; protocole multijoueur inchangé (**11**).

## Correctifs Surf et expéditions (Arena Demo 0.19.3)

Le Pokémon suiveur est masqué pendant Surf, y compris les Pokémon Eau ou
volants, puis réapparaît à la sortie si le suivi est activé. Les passages entre
secteurs choisissent une arrivée praticable reliée aux chemins, même dans une
ancienne expédition. Charger une sauvegarde sur un obstacle ou un îlot isolé
replace le joueur sur le terrain accessible le plus proche. Les transferts des
expéditions réinitialisent aussi les mouvements en cours.
Fermez le jeu et relancez **Play-Arena.bat** pour installer les corrections.
Le protocole de visite reste **11**.

## Version précédente : v8.4

Version interne : **Arena Demo 0.19.2** ; visites multijoueurs au **protocole 11**.
Cette version regroupe les corrections depuis v8.3 :

- Écran titre réparé sur les installations mises à jour ; préparation automatique
  des données françaises manquantes avec vérification du téléchargement.
- Surf accessible depuis la rive dans l'arène sans badge ni capacité requise.
- Liquides sur plateformes avec hauteur et murs conservés, raccords sans
  bordures internes et sans encoche au contact des parois sud.
- Coulées animées pour eau, lave, marécage, déchets toxiques et boue.
- Extensions héritant du style voisin, y compris sur un mur ou à travers sa case.
- Retours à l'entrée stabilisés ; maintien d'Entrée pour accélérer le texte ×4.

Vérifications déjà effectuées : **43 tests / 1 211 assertions**, **411 contrôles
dans le moteur**, plus tests de téléchargement/préparation du français et du
titre. Les visites réseau sont vérifiées par sockets ; aucune nouvelle visite
manuelle entre deux fenêtres n'est revendiquée. Les Dresseurs ajoutés sont conservés.

Fermez les jeux et lancez **ArenaLab-Update.exe v6.2.8 sur les deux PC** : il
récupère le code actuel de GitHub `main`, dont v8.4. Relancez **Play-Arena.bat**
et redémarrez le serveur pour le protocole 11. Le numéro de l'updater est distinct
de celui du jeu ; aucun nouvel EXE n'est nécessaire.

## Extensions depuis un mur et dialogues (Arena Demo 0.19.2)

Une plateforme ajoutée sur une paroi, ou contre cette paroi à une case du
plateau, reprend le style du plateau qui porte le mur. Si la case remplace
directement un mur, le style de son plateau d'origine est prioritaire.

Pendant un dialogue, maintenir **Entrée** affiche les lettres quatre fois
plus vite. Relâcher rétablit la vitesse choisie ; les pauses et la validation
des choix restent manuelles. Mettez à jour puis relancez **Play-Arena.bat**.
Le protocole multijoueur reste **11**.

## Raccords, coulées et extensions (Arena Demo 0.19.1)

Les liquides voisins sur une plateforme se raccordent sans bordure de pierre
entre leurs cases. Les coins d'un plateau qui touchent une paroi sud ne créent
plus d'encoche arrondie. Les coulées animées fonctionnent pour **l'eau, la lave,
le marécage, les déchets toxiques et la boue**, avec leur couleur propre.
Les liquides dangereux restent bloqués ; la boue reste praticable.

Une case de plateforme ajoutée contre une plateforme reprend son style et
son sol de base. Une case voisine peinte en liquide ne propage pas ce liquide
sur l'extension. En cas de styles différents autour de la nouvelle case, le
style le plus représenté est choisi (égalité : haut, droite, bas, gauche).

Fermez les jeux, lancez l'updater sur les deux PC puis Play-Arena.bat et
redémarrez le serveur. Les visites utilisent désormais le **protocole 11**.

## Correctifs arène (Arena Demo 0.19.0)

L'image de l'écran titre est maintenant incluse dans les mises à jour ; le
lanceur la récupère aussi si un ancien updater l'avait omise. Surf se propose
depuis la rive dans l'arène sans badge ni Pokémon connaissant Surf, avec le
véhicule et la sortie d'eau natifs d'Essentials. Hors de l'arène, les conditions
habituelles restent applicables.

Peindre de l'eau sur le dessus d'une plateforme conserve sa hauteur et ses
murs. Une case d'eau au bord sud crée une cascade animée sur la paroi ; une
case intérieure reste de l'eau normale. La cascade bloque le passage.
Les transferts entre village, entrée et arène réinitialisent l'interpolation
et les mouvements forcés pour éviter la traversée visuelle du vide.

Fermez les jeux puis lancez l'updater et **Play-Arena.bat** sur les deux PC.
Redémarrez le serveur : les visites passent au **protocole 10** pour accepter
l'eau surélevée et vérifier ses collisions.

## Historique : v8.3

Cette version ajoute les sols interactifs et animés, ainsi que le catalogue
de Dresseurs enrichi dans `009_ArenaCustomMode.rb`, avec leurs noms, sprites
et équipes configurées. Le catalogue propose **27 sols plus le vide** et
**11 styles de plateformes**. Version interne : **Arena Demo 0.18.1**.

L'eau et le marécage utilisent Surf ; lave et déchets toxiques restent bloqués.
Les sables mouvants piègent le joueur puis le ramènent à l'entrée. Les quatre
liquides sont animés ; Basalte nocturne et glace ont été retouchés.

Vérification de livraison : **27 tests / 1 087 assertions**, sans échec,
et syntaxe Ruby du catalogue de Dresseurs valide. Les retouches de sols ont
également passé **376 vérifications moteur** avant les derniers ajouts de
Dresseurs ; chaque nouvelle équipe n'a pas été jouée manuellement.

Fermez le jeu, mettez à jour puis relancez **Play-Arena.bat**.
Les visites utilisent le **protocole 9** : mettez les deux clients et le serveur
à jour ensemble. Aucune nouvelle visite manuelle à deux fenêtres n'est revendiquée.

## Retouches des sols (Arena Demo 0.18.1)

Eau, lave, marécage et déchets toxiques sont animés avec les frames natives
d'Essentials, à des rythmes différents, même lorsque le joueur reste immobile.
Basalte nocturne remplace les Dalles hantées : pierre bleu-noir, joints décalés
raccordables, sans yeux ni grande fissure. Les sables mouvants reprennent le
sable normal assombri de 4 %, sans spirale, et jouent un son grave à
l'enfoncement. La fissure centrale de la glace est supprimée.
Fermez le jeu et relancez **Play-Arena.bat** pour installer ces retouches.

## Nouveaux sols interactifs (Arena Demo 0.18.0)

**Changer le sol** propose désormais 27 sols plus le vide, avec aperçu :
déchets toxiques jaune fluorescent (toujours infranchissables), eau de marécage
marron (Surf requis), acier bleuté, hexagones holographiques et sables mouvants.
Ardoise mauve devient **Dalles hantées**, une pierre sombre fissurée avec de
petites lueurs spectrales. La glace garde sa glisse, avec un fond continu sans
contour par case.

Les sables mouvants font tourner le joueur et le font disparaître progressivement,
puis le ramènent à l'entrée de l'arène. Ils ne peuvent pas recevoir d'occupants,
de plateformes ou d'escaliers. L'eau et le marécage utilisent le **Surf natif
d'Essentials**, depuis la rive ou le menu Pokémon, avec ses conditions normales
de capacité/badges. Ils restent bloqués à pied. Les visites passent au **protocole
9** : le serveur vérifie Surf et le retour depuis les sables mouvants.
Fermez et relancez **Play-Arena.bat** sur les deux clients et redémarrez le serveur.

## Historique : v8.2

Cette version regroupe l'éditeur de plateformes à deux hauteurs, les escaliers
dans les quatre directions, les bordures et murs arrondis, le placement sur
les plateaux et leur synchronisation lors des visites multijoueurs (protocole 8).
Le catalogue final propose **22 sols plus le vide et 11 styles de plateformes**,
avec vignettes et aperçu agrandi. Les dernières retouches incluent les planches
de pont, les murs Bois/Industrielle et les points cyan du Cristal.
Version interne du plugin : **Arena Demo 0.17.4**.

Vérifications : 14 tests éditeur / 820 assertions, 10 tests serveur / 168
assertions et 315 vérifications dans le moteur local. Les tests serveur
utilisent des clients socket ; aucune nouvelle visite manuelle à deux fenêtres
n'est revendiquée. Fermez le jeu et relancez **Play-Arena.bat** ; les deux clients
et le serveur doivent être à jour pour les visites.

## Plateformes et sols (Arena Demo 0.18.0)

Le sol **Planches** et la plateforme **Bois** utilisent de longues lames
parallèles inspirées des ponts d'Essentials, avec des supports sombres et
contreventés. **Métal et grilles** est retiré de la liste des sols.
**Sol de base** et **Plaques métalliques** remplacent les anciens libellés.

Le tatami conserve son tressage sans diagonales claires. Les anciens noms de
types ont été remplacés par **Améthyste, Quartz rose, Dalles hantées, Obsidienne
et Plaques métalliques**. Le sol et les murs Cristal utilisent une roche bleutée
sombre avec de petits points cyan lumineux. Les murs Industrielle et Bois ont
une face verticale plus sombre, avec panneaux/rivets ou poutres/montants.

Les listes de sols affichent une **vignette sur chaque ligne** et un **aperçu
agrandi à droite** quand la sélection change. Les styles de plateformes montrent
le sol et les murs ensemble. Le panneau précise si le sol est praticable,
glissant ou infranchissable. Flèches pour parcourir, Entrée pour choisir,
X pour revenir ; parcourir les aperçus ne modifie pas l'arène.

Le sélecteur ouvre directement une **liste unique de 27 sols, plus le vide**,
avec ses vignettes et son aperçu agrandi. Les sous-familles ont été retirées.
Parquet, mousse, dalles de combat et les sols monotype Normal, Feu, Eau, Glace,
Électrik, Plante, Sol, Vol, Insecte, Roche, Dragon et Fée n'y sont plus proposés.
L'eau accessible avec Surf et la glace glissante sont conservées.

Le catalogue propose **11 styles de plateformes**. Les thèmes
proposés sont disponibles : Herbe, Montagne, Neige, Volcanique, Désert, Forêt,
Ruines anciennes, Cristal, Industrielle, Bois et Marécage. La plateforme
Arène de combat a été retirée du sélecteur.
Pavés, terre battue, planches, boue et racines complètent les sols
précédents. **Changer le sol** ouvre immédiatement le visualiseur.

Les sols **Tatami, Boue, Améthyste, Obsidienne et Quartz rose**
conservent leurs textures sans les motifs retirés. Plaques métalliques reste
disponible. Ces sols décoratifs ne changent pas les combats.
Voir [le catalogue complet et son utilisation](docs/ARENA_MATERIALS.md).

Les escaliers sont proposés vers **le haut, la droite, le bas et la gauche**.
Le dessus a de petits coins extérieurs arrondis, avec des rebords fins.
La paroi basse occupe une case bloquée juste en dessous : le joueur s'arrête
sur le plateau, avant la face rocheuse. Les anciennes découpes miniatures des
coins ont été supprimées. Les raccords suivent le contour de la plateforme.
Les arrondis se poursuivent aussi sur les extrémités des murs. Le sol inférieur
reste visible dans les coins transparents, y compris sur une plateforme enneigée.

**Changer le sol** fonctionne maintenant aussi sur les plateformes : sol
de base, herbe, sable, roche, glace, neige et tous les nouveaux matériaux. La retouche ne change pas le
matériau de leurs murs. La neige est un sol normal ; la glace conserve la glisse.
L'**eau et le marécage nécessitent Surf ; la lave et les déchets restent
infranchissables** : aucun meuble, Dresseur ou escalier ne peut y être posé.
Un liquide ne peut pas remplacer un accès d'escalier
encore utilisé. Le **sol volcanique** est praticable.
L'eau et le marécage gardent des identités distinctes. Les identifiants des sols retirés sont conservés pour lire
les anciennes sauvegardes ; leurs cases existantes ne sont pas effacées.

Pour transformer une grande plateforme d'un coup, choisissez **Personnalisation
→ Style de plateforme entière**, puis l'un des **11 styles** et
cliquez une case de son dessus ou un escalier. Toutes les cases surélevées
reliées par un côté, escaliers compris, reçoivent le sol et les murs du style.
Les plateformes séparées et les contacts seulement en diagonale sont épargnés.
Vous pouvez ensuite retoucher quelques sols avec Changer le sol. Validez et
sauvegardez normalement ; Annuler restaure aussi les changements de style.

Dans l'arène hors ligne, ouvrez **Personnalisation**, puis **Entrée → Plateformes
et escaliers**. Ajoutez des plateformes sur les cases de sol existantes. Les
bordures de pierre se raccordent automatiquement. Un escalier occupe une case
haute : sa flèche pointe vers une plateforme et son côté opposé vers le sol bas.
Quatre orientations sont disponibles ; des escaliers parallèles côte à côte
forment un escalier plus large. Les autres bordures bloquent le passage.

Les outils Meubles et Dresseurs fonctionnent sur les plateformes. Les escaliers
restent libres. Retirez les occupants avant de modifier leur hauteur, puis les
escaliers avant leurs appuis. **X → Valider et sauvegarder** conserve les
modifications ; l'annulation restaure l'arène précédente. **U** conserve les
trois vues de l'éditeur, avec le relief indiqué dans la vue globale.

Une seule map et deux hauteurs : aucun étage superposé ni passage sous une
plateforme. Les textures proviennent des ressources locales d'Essentials ; les
types de terrain et les matériaux des murs sont enregistrés séparément.
Les visites transmettent le relief et le serveur vérifie les passages.
Fermez les jeux et relancez **Play-Arena.bat** pour installer la version locale.
Pour jouer ensemble, mettez à jour **les deux clients et le serveur** : le
protocole de visite passe à **9** pour ces nouveaux sols et leurs déplacements.

Vérification : tests de l'éditeur et du réseau PEMK avec deux connexions TCP,
plus chargement dans le vrai moteur mkxp-z, collisions, rendu/zoom, placement,
sauvegarde et rechargement d'une partie jetable. Une visite manuelle entre deux
fenêtres de jeu avec ce nouveau relief reste à faire. Résultats et commandes
dans [SETUP_STATUS.md](SETUP_STATUS.md).

## v8.1: French interface and custom title (Arena Demo 0.13.4)

Close all game windows, update the source with **ArenaLab-Update.exe**, then
launch **Play-Arena.bat**. The launcher installs the plugin and prepares the
locally supplied translation and title assets. Existing saves are supported.

The custom title opens directly, without the stock splash screens, and displays
**APPUYEZ SUR ENTRÉE OU ESPACE** centered in its panel. Confirm opens the usual
Continue/New Game menu; automatic continuation is disabled. The local title
music is the requested HeartGold/SoulSilver theme. The original graphical battle
buttons are retained.

French is selected automatically for Pokémon names, moves, items, abilities,
menus and battle messages. Arena Lab supplies French village/arena guides,
customization, expeditions, follower interactions and multiplayer dialogs.
Inventory wording and successful escape were corrected; the ability popup
shows only the translated ability name. Saved layout keys, species IDs,
multiplayer protocol values and player nicknames keep their existing format.

This release fixes two localization defects: Essentials converts tabs to spaces
before evaluating plugins, which emptied the previous tab-separated catalogs;
and translating fragments of English lookup keys prevented native French
matches. Catalog separators, Windows paths and line-break matching are fixed.
Graphics/Audio/Data resource identifiers bypass presentation translation.

### Local assets on each computer

`title_screen.png` is included in the repository. Other players receive it
through ArenaLab-Update.exe, and Play-Arena.bat installs it automatically as
`Graphics/Titles/arena_title.png` in their local game.

These third-party files still need to be supplied separately:

- `tools/runtime/arena-title.mp3` (title music).
- French data is downloaded, verified and compiled automatically by Update,
  Setup or the launcher when missing (installer v6.2.8). An existing local
  source pack or compiled `Data/messages_french_core.dat` is also supported.

The launcher copies the tracked title image, copies local music when present,
and compiles the French pack.
The first French-data preparation requires Internet access if no local pack
is available. Title music still needs to be supplied separately.
`title_screen_design.pptx` remains a local design document.

### Verification and limits

The audit checks all **3,310 literal Essentials script templates**, 304 follower
templates and 131 PEMK templates. The native engine passes **23 checks**,
including actual NPC quest branches, inventory/flee wording and ability-only
text drawing. No save was loaded or written by the native probe. This is text
generation/format verification, not a manual playthrough of every screen or
certification of original upstream sample-map event dialogs.

Run `ruby --disable-gems game-mod/tools/audit_french_messages.rb` with the bundled
Ruby to regenerate the private per-phrase report. On Windows,
`python tools/test-native-french.py` runs the disposable native boot check and
removes its temporary plugin. Reports stay under ignored `tools/runtime/`.
See [the audit, references and coverage limits](docs/FRENCH_LOCALIZATION_AUDIT.md)
and [SETUP_STATUS.md](SETUP_STATUS.md) for executed checks and setup history.

## v8: procedural outings and running (Arena Demo plugin 0.12.2)

Hold **Shift (Maj) + a direction** to run. **Space** opens the pause menu; when
moving, it waits for the current step to finish. **Enter/Z** interact. Space still
confirms inside menus/dialogs. Running uses Essentials' movement/animations and
respects walk-only terrain, scripted movement and battle/menu locks.

Each local profile gets **three free departures in a rolling 24 hours**. A used
slot returns exactly 24 hours after that departure. Cancelled or failed starts
do not spend a slot; returning early still uses the outing. The guide and departure
prompt show availability. There is no purchase UI; an extra-outing balance is
reserved for a later feature.

Each outing lasts **20 real minutes**, including menus and time with the game
closed. A screen timer shows the remaining time. Expiry returns the player
automatically; menus cancel cleanly, while an ongoing wild/NPC battle and its
capture/reward/evolution/dialogue sequence finish before returning. Used slots
and deadlines are recorded beside the profile save, so loading an earlier save
does not reset them. See [outing rules](docs/EXPEDITION_RULES.md).

Offline expeditions now leave through the **south village gate**. Each confirmed
departure creates a new 4x4 wilderness of 64x64-tile sectors (256x256 tiles in
total). Follow the clear paths between sectors. Talk to the return guide near
the starting camp, or choose **Expedition -> Return to village** in the pause
menu. Pokemon, items and normal progression stay with the player. Saving outside
retains that expedition's geography; crossing sectors or loading does not reroll
it. The next departure from the village replaces it.

The starting sector is always grassland. Each of the other 15 sectors rolls
independently with these fixed chances; duplicates are allowed and special areas
are not guaranteed on every outing:

| Area | Chance per random sector |
| --- | ---: |
| Grassland | 52% |
| Dense forest | 12% |
| Desert | 5% |
| Volcanic fields | 4% |
| Snow peaks | 4% |
| Lake district | 4% |
| Swamp | 3% |
| Rocky canyon | 3% |
| Flower meadow | 3% |
| Crystal caverns | 2% |
| Ancient ruins | 2% |
| Storm plains | 2% |
| Coast and islands | 2% |
| Bamboo grove | 1% |
| Abandoned power station | 1% |

Visible wilderness Pokemon use only installed **generation 1-5** base species,
weighted by habitat types and strength, with the primary habitat type favored.
Legendaries, Mythicals, Ultra Beasts and ocean-only/rare habitats are excluded
from ordinary roaming encounters. Levels range from 3-7 near camp up to 23-27
in the farthest sector. Each zone selects **at most five distinct species** during
generation; the saved selection stays fixed through revisits and reloads. Individual
Pokemon can respawn, but no additional species join that zone during the outing.
Approach or interact to battle and catch through
Essentials. Up to six nearby Pokemon are active; village encounters keep their
existing four-Pokemon cap. Walking graphics use installed follower sprites with
the existing icon fallback. Populations are transient; terrain and zone species are saved.

Generation 0.11.0 replaces ellipse stamps and rectangular pixel textures with
multi-scale terrain noise, elevation/moisture fields, connected route planning
and native Essentials artwork. Paths, vegetation and shores use real autotile
transitions; full trees, snowy rocks and crystals use the installed art. Long
paths take offset waypoints and avoid ridges/water. Necessary crossings have
walkable bridges. Generation shows progress while building the 16 sectors.
See [the method and research](docs/EXPEDITION_GENERATION.md).

Return to the village and leave again to get the new layout; existing saved
outings keep their geography. Generation 6-8 Pokemon no longer enter wild pools.
Previously owned Pokemon and engine data are preserved. Caverns/ruins/power
stations remain themed sectors without separate interiors. Water/lava/cliffs
block walking except at bridges; Surf travel is not implemented. Snow, storm
and swamp sectors use Essentials weather.
Expeditions remain offline; multiplayer visit protocol and shared rooms are
unchanged. The village itself still needs its planned visual redesign.

For v8, close game windows, run **ArenaLab-Update.exe on both computers** to fetch
GitHub `main`, then launch **Play-Arena.bat** to install the plugin and generate
templates 110-125. An existing save is supported. Automated and native-art
preview checks are recorded in SETUP_STATUS.md; a real GUI expedition, capture
and save/reload playtest is still required. The reported 0.12.0 startup error and
0.12.1 scene-update recursion are fixed in 0.12.2, but that version has not yet
been confirmed in the game window.

## Previous user-confirmed snapshot: v7 (Arena Demo plugin 0.9.32)

On 2026-10-29, after the latest outdoor fixes, the user confirmed that everything
worked in v7. This is the latest user-confirmed working snapshot. The recent test
cycle covered LAN hosting/visits, PvP and follower sprites, online trainer
interactions, music/sounds, entrance objects, save recovery and visible village
wild Pokemon. Codex did not operate the two clients or verify every feature.

Offline grass encounters are visible and roam within the grass. Walk into a
Pokemon or face it and press Confirm to battle and catch it. Density is one per
24 usable grass tiles, capped at four, with an eight-second replacement delay.
Walking sprites use separately installed follower assets; otherwise Essentials
Pokemon icons are used. Spawns are local and unsaved.

To update, close all game windows, run the existing **ArenaLab-Update.exe on both
computers**, then launch `Play-Arena.bat`. The updater fetches GitHub `main`.
v7 labels this source snapshot; it is not a newly published installer package.

See `SETUP_STATUS.md` for integration, automated checks and scope limits.
Older sections below describe the project's development history.

The generated Arena Village is currently an **ugly functional placeholder**:
it has a central stadium, houses, residents and an offline grass patch, but its
layout and look need to be redesigned manually in RPG Maker XP. The stadium and
house sprites are temporary matching-generation art. House events no longer
transfer to Lappet Town. The arena return point is directly in front of the
stadium; the playable route is village (101) → entrance (102) → arena (100).
The obsolete generated Founders' Path map (103) is removed from the registry.
Close all game windows and run `Play-Arena.bat` to regenerate the current
placeholder maps and copy the sprites.

**Next visual step:** rebuild the village cleanly in RPG Maker XP and refine the
procedural wilderness's terrain and landmarks after the first expedition playtest.

For this local save, the next primary offline launch grants Zekrom and Dialga
at level 100 directly to the party and saves automatically. Close all game
windows, then run `Play-Arena.bat` once. The one-time grant marker is local-only
and excluded from Git.

The generated Arena Village has an interactable sign marking the arena building.
The arena's south exit is now a visible door that returns to the entrance room.
Opening an online visit now shares the saved ground and placed furniture/trainers
with the visitor; both games must be updated to the same visit protocol.
When installed, Following Pokemon EX makes the lead able Pokémon follow using
walking sprites and multiplayer shares the matching appearance. That third-party
plugin archive is optional and is not bundled. If the archive is absent, Arena
Lab skips follower visuals and continues launching; multiplayer remains
available. Both players need the compatible add-on to see each other's
following Pokémon. To enable followers, place the Essentials 21.1 archive named
`Following Pokemon EX.rar` at the project root before running `Play-Arena.bat`.
The Windows Setup EXE also offers to select a separately downloaded archive
during installation. The archive is not included in the public installer.
The Windows Setup EXE also offers to select a separately downloaded archive
during installation. The archive is not included in the public installer.
The launcher installs it and merges animations without replacing Essentials'
animation table. See `SETUP_STATUS.md` for details.

The user has confirmed multiplayer communication between two physical computers
on the same network: the second computer installed the client from GitHub and
joined a host on the first computer. This is the first two-machine check; it
does **not** mean the clean installer can host by itself. The one-app setup that
can host or join from any newly installed computer is a later step. See
[TWO_COMPUTER_SETUP.md](TWO_COMPUTER_SETUP.md) for the tested setup.

The automatic LAN discovery, host-approved **Request to visit** flow and
connection status are included in the v7 user-confirmed working snapshot.

The offline custom arena is generated as a 100x100 tile map with a centered
25x25 walkable floor; the rest is void unless opened in custom mode. Custom mode
can convert tiles between field and void, paint concrete/plain, grass, sand,
rock, or ice, and place
furniture and recruited trainers. Press **U** to cycle normal, zoomed-out, and
global overview views. Ice uses Essentials' terrain-tag movement and slides
until the player reaches a non-ice tile. Tile and object edits save in the
player's game. The first map-editor playtest confirmed ice sliding but exposed
zoom, overview, dialog, layout and ground-menu issues. Plugin 0.9.2 addresses
those reports. The second playtest still exposed a mismatch between the centered
field, collision and saved edits. Plugin 0.9.4 reapplies the arena after loading
older saves and stores its base floor separately. Plugin 0.9.5 added void-save
recovery and 0.9.6 made all 10,000 tiles walkable by default, but the map still
rendered black. Plugin 0.9.7 rejects blank tile IDs and validates the serialized
floor. Preparation reports tile ID 401 and a present tileset, so that did not
explain the screen. Plugin 0.9.8 writes live RGSS map and renderer details to
`Data/ArenaFloorDiagnostic.txt` on the next arena load. The user confirmed that
fresh transfers work but saves already on Map 100 load black. Plugin 0.9.9
rebuilds Map 100 on save load, preserving player position and saved edits.
Plugin 0.9.10 restores the intended centered 25x25 starting floor with void
around it.
Plugin 0.9.11 makes `Play-Arena.bat` resume an existing save automatically;
fresh profiles still show the New Game menu.
Plugin 0.9.12 adds a clearly visible selected-tile frame to the full-map editor
overview.
Plugin 0.9.13 makes draft ice visible immediately, keeps editor dialogs at the
current zoom, and reorganizes editing into ground, trainer, and furniture modes.
Choose a type once, then press Enter on each tile to paint/place it; choose a
removal tool to remove matching placed items. The user has confirmed the editor
workflow and rendering work in-game.
Plugin 0.9.14 moves overview graphics below Essentials' message windows and
fixes catalog navigation, which had moved the cursor twice per keypress. The
user has confirmed the editor, text layering, and furniture/trainer selection
all work in-game.

## Windows installers

Installer/updater release: **v6.2.8**, for game source **v8.3**.
[Download ArenaLab-Update.exe](https://github.com/EvannKurzawa/arena_lab/releases/download/v6.2.8/ArenaLab-Update.exe)
for an existing installation; it fetches the current GitHub `main`.

Update and Setup automatically prepare missing French Essentials data. The
v21.1 core translation pack 1.2 by YusukyDelta is downloaded from its
[author's resource](https://eeveeexpo.com/resources/1860/), SHA256-verified and
compiled locally. Existing compiled French data is kept. The launcher also
repairs missing data after an older updater has fetched current source.
Internet access is required on the first download; no translation pack is
bundled in GitHub or in the EXEs.

If the updater reports a generic Windows error immediately after selecting the
folder, use a rebuilt updater containing the process-check fix. The updater now
checks running games without WMI/CIM, reports the failing step and writes a
diagnostic to `%TEMP%/ArenaLab-Update-error-*.log`. Running games still block
updates; an unreadable game process asks you to close its window and retry.
For a folder-dialog issue, the source script also accepts `-InstallDirectory`.
See SETUP_STATUS.md for local build versus published-package status.

The Windows build has two self-extracting EXE packages available from the
[latest GitHub release](https://github.com/EvannKurzawa/arena_lab/releases/latest).
`ArenaLab-Setup.exe`
sets up a clean client, and `ArenaLab-Update.exe` replaces Arena Lab source files
from GitHub `main` in an existing install. Build them with
`powershell -NoProfile -ExecutionPolicy Bypass -File tools/package-deliverables.ps1`;
the self-extracting EXEs are written to ignored `dist/` and are intended to be
attached to a GitHub release, not committed to source history. After pushing the
source changes, publish both with
`powershell -NoProfile -ExecutionPolicy Bypass -File tools/publish-installers.ps1`.

Setup downloads pinned Arena Lab/PEMK source plus Ruby and mkxp-z, and asks the
player to select their own complete Essentials v21.1 game folder. The Essentials
README does not provide a public download, and PEMK says game builds containing
Nintendo-derived assets are for private tests, so these assets are never bundled
in the installer. The first installer prepares the offline/join client; it does
not provision PostgreSQL and the native server dependencies required for a new
computer to host. Existing installations keep their assets, runtime, saves,
credentials and local server data during source updates. See `SETUP_STATUS.md`
for the package checks and limitations.

The user completed one full arena visit successfully using two game windows on
the same computer, and has since confirmed communication between a GitHub-
installed client on a second physical computer and the prepared host on the same
network. A clean install that can also host remains future work.

**`Play-Arena.bat` is the only root BAT file.** Every launch opens another player
window with its own local profile, initially offline. The first uses the primary
profile, the second the guest profile; profiles are reused when windows close.
Up to eight local players are supported. No separate server window is needed.

At the arena entrance, talk to the attendant:
- **Host online:** starts/reuses the internal PEMK service, connects this player
  and opens their arena.
- **Find an arena to visit:** discovers hosts on the local network automatically.
  Choose **Request to visit**; the host accepts at their attendant. No account ID
  or host address needs to be exchanged or typed.
- The attendant shows **Offline**, **Hosting**, **Connected**, or **Visiting**.
  Choose **Disconnect** there to return offline; an active visit closes first.

Two windows on one PC: open **the same Play-Arena.bat twice**, Host online in the
first, Find an arena to visit in the second, choose **Request to visit**, then
accept at the first window's attendant.
Two PCs on the same network: use the same launcher on each and the same flow.
Windows Firewall must permit the host's Ruby service on the private network,
UDP 9997 for discovery and TCP 9998 for the game connection. The database stays loopback-only.
Internet/NAT setup across different networks is not automated by this update.

Connecting/disconnecting happens **in place with the same character, Pokemon,
arena and local save**. No title/profile switch or cloud-world replacement.
Accounts identify players; progression stays local. Existing `_offline` saves
continue to be used. Historical server saves are preserved but not loaded or
overwritten. Visitors still access only the entrance room and arena.

Only the first launch prepares shared files; later launches wait for compilation
and skip rebuilding. Merely launching starts neither a server nor a database;
hosting is requested in-game. Internal PowerShell/Ruby helpers are not additional
player launchers. Managed servers stop after ten minutes without logged-in users.

Host online automatically replaces an older idle background server after checking
that it belongs to this exact project and has no connected players. It refuses
to stop an unrelated process or an active host, so no manual hidden-server cleanup
is needed for a verified idle project service.

Validation: **56 Ruby tests / 398 assertions and 24 PowerShell checks passed**.
Includes real wildcard-bound reactor sockets with loopback clients, local save
protection and multi-instance leases. Same-PC full visit and two-PC multiplayer
communication are user-reported; Codex did not operate those game windows.
Internet/NAT connectivity remains untested. See SETUP_STATUS.md for details.

If an older Offline/Online chooser was still visible, close all game windows
and relaunch this BAT. Preparation now explicitly synchronizes ArenaDemo's
compiled plugin-cache entry, preserving the other plugins and a backup of the
old cache. The preparation log records version 0.7.0 and its source checksum.

## Previous launcher design (0.6.0 history; superseded)

Close existing game windows, then use **`Play-Arena.bat`**. It prepares the game,
opens one player window and starts/reuses the local development server in the
background. A running game is detected before rebuilding. Backend startup failure
leaves offline play available. The other BAT files are developer tools, including
the two-window multiplayer test; they are no longer the normal entry point.

The game asks **Offline / Online** before any stored-token login. Offline keeps
the network disconnected, even if the local server is running. In the pause menu,
choose **Connection -> Go online / Go offline** to save and switch at the title
screen inside the same application. Close an active arena visit before switching.
Online switches wait for the current server save acknowledgment when connected.
The menu also shows connection/hosting/visiting status.

This version uses separate offline and online profiles. Online loads the server
account; offline uses `Game_offline.rxdata` (or `Game_guest_offline.rxdata` for
the test guest). On first mode selection, any legacy local save is copied to the
offline slot without overwriting either an existing offline slot or the original.
Offline catches are not automatically merged into an online account. Failed or
cancelled online login explicitly falls back to the offline slot.

48 automated tests / 324 assertions passed, including profile/save-switch tests.
The new launcher and actual in-game switching still need a GUI playtest: this
execution environment cannot read the private game data reliably. This remains
the development desktop runtime, not a newly packaged standalone executable.
See SETUP_STATUS.md for results and exact manual checks.

## Arena visits and first catching route (plugin 0.5.0 history)

This section records the original 0.5.0 implementation. Arena customization is
now accessed through the offline Arena Guide's **Custom mode** choice, not from
the pause menu. The entrance attendant handles multiplayer visits.

Offline: run `Play-Arena.bat`, choose offline, New Game and the intro skip.
Talk to the village keeper for 10 Poke Balls, then catch Rattata, Caterpie or
Spearow in the grass patch at the edge of Arena Village and return for the story
reward. Wild encounters and rewards are offline-only. The entrance PC uses
normal Essentials storage. Talk to the Arena Guide offline to edit furniture
and trainers before hosting.

For a local visit, stop the old server console with Ctrl+C and restart
`Launch-Multiplayer-Server.bat`, then `Launch-Multiplayer-Clients.bat` with two
different accounts. Both players now enter their own town and walk to their
entrance-room attendant. The attendant shows each account ID. The host chooses
**Open arena to visitors**, then **Invite a friend** and enters the guest's ID.
The guest talks to their attendant and accepts within 60 seconds. The guest
arrives in the host's entrance room and can access that room and arena only.
Both clients use the host's frozen object selection, arrangement and trainer
difficulty. Each player keeps their own party and PC storage.

Customization locks before the open request is sent and stays locked while open,
invited, visiting or awaiting a close reply. Leaving guests return to their own
entrance room. Hosts remain open until they explicitly close the arena; closing
or disconnecting the host ends the visit. Offline layouts remain saved locally.
Readiness now detects an old server that lacks the visit extension.

This is still loopback development for two accounts on this PC. Online arena
storage, public hosting, remote internet setup and arbitrary furniture placement
are outside this update. Village grass encounters and story rewards are offline.
The generated foyer still uses temporary rock boundaries.

Validation: 41 tests / 291 assertions passed, including real loopback protocol
tests through PEMK's reactor and synthetic map generation. Protocol test account
identities were injected; production login, private-map installation/rendering,
actual captures and two-window battles were not retested. Private game-data
access still stalls here. Details and manual playtest steps are in SETUP_STATUS.md.

## Initial world step (historical, superseded by 0.5.0)

Offline quick start now enters Arena Village directly in front of the central
stadium. Interact with its entrance to reach the arena foyer. Its PC opens Essentials' normal
Pokemon storage; interact with the north door to enter the training arena.
Walk through the arena's south opening to return, then through the entrance
room's south opening to reach town. Custom mode and trainer recruitment are
available from the Arena Guide; there is no Arena Demo pause-menu shortcut.

Close the game and run `Launch-ArenaDemo.bat` to install the source changes and
generate maps 100-102. Keep a backup of private saves before testing. New Game
with the intro skip is recommended because existing saves can retain old maps.
The village map is freshly composed from local terrain tiles, without Lappet
Town's building layout or transfer events. The stadium and village houses use
matching generated sprites. The arena's south door returns through the foyer to
the stadium frontage; house interactions remain local. The generated map 103
catching route has been retired and its grass patch now sits inside the village.
The first able Pokémon follows with its species, form, gender, shiny and shadow
appearance. Configure a second computer with the same plugin archive before
joining; Following Pokemon EX is optional and follower visuals are disabled on
machines that do not have its separately distributed archive.

Authenticated quick start still enters the tested shared arena directly.
Invitations, visitor restrictions and custom-layout synchronization are pending.
This update passed 24 automated tests / 130 assertions, including map generation
against synthetic fixtures. Real private-map generation and GUI playtesting
could not be completed here; see SETUP_STATUS.md.

## Current snapshot: v2.1

If the multiplayer launcher times out despite a server “listening” message, press
Esc in the server console to clear any selected text and retry the clients. The
readiness check now reports the failed network stage and visible port-9998 process
IDs. Keep that output if it still fails; a listening log alone is not a health check.

2026-10-28: the user verified that local multiplayer launch, text rendering and
battles now work, including the previously reported battle synchronization issue.
`v2.1` includes local peer collision checks, mirrored win/loss and singles speed
ties, earlier battle RNG delivery, rendered font heights, and clearer readiness
diagnostics. Player collision is also user-verified;
simultaneous movement can overlap because tiles are not reserved server-side.
Use the root multiplayer launchers. The server launcher reuses a responding PEMK
instance instead of binding twice. See CHANGELOG.md and SETUP_STATUS.md for checks
and the earlier investigation history.

`v2` contains the enclosed arena, expanded offline customization, local PEMK setup, player battle-request interactions, and the native-runtime click-crash fix. See [CHANGELOG.md](CHANGELOG.md) for the update summary and [SETUP_STATUS.md](SETUP_STATUS.md) for exact versions, commands, results, and limitations.

The arena and customization, GUI account creation, click-crash fix, multiplayer launch, text rendering and battles have been user-confirmed. This repository contains source and setup tools; ignored private game assets, runtime binaries, accounts, saves, and credentials are not part of this snapshot. Use the root BAT launchers with the existing local setup; a clean clone requires the private prerequisites described in the setup report.

## 1. Vision

Build a **personal, non-commercial Pokémon fan game** based on an existing Pokémon RPG engine rather than creating the battle engine, Pokémon data, and core RPG systems from scratch.

The intended game is an **arena-management game** with a visual and gameplay feel inspired by Pokémon games:

- Build and decorate a battle arena with furniture, obstacles, walls, and puzzle-like layouts.
- Recruit and configure trainers and their Pokémon teams.
- Let visitors challenge trainers and, eventually, other players.
- Support private multiplayer with friends.
- Preserve as much of the existing Pokémon Essentials battle engine, Pokémon/move data, and game systems as practical.
- Start with a small, playable vertical slice, then expand.

This is not intended to be a conventional story-and-badges adventure. The arena-management loop is the core custom feature.

## Running the local demo

The manager now preserves your position when changing objects or presets. If an edit would place an obstacle on your tile, it asks you to step aside. The user confirmed the new arena and trainer/customization work in-game; this teleport correction has automated regression coverage.

## Local multiplayer (first version)

Runtime fix (0.4.1): use the root BAT launchers. They now select the official mkxp-z Windows build pinned to `37a04d1`, which the user confirmed no longer exits on clicking the game. The original bundled `Game.exe` is retained, but its direct `PlayMMO-*.bat` launchers still use the old crashing runtime. Existing accounts and saves are retained. The replacement runtime and license stay under ignored `tools/runtime/mkxp-official-test/`; its configuration points to the existing private game assets. To restore a missing runtime, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/install-client-runtime.ps1 -Download`.

Version 0.4.0: face another player in the arena and press **Z/Enter/Space**, then choose **Challenge to battle**. The other player receives PEMK's accept/decline prompt; close their pause menu if it is open. Players on the same tile can also interact. **Arena Demo → Players in arena** (or **Battle Player**) lists players by name and account ID. Escape closes these menus without sending a request or leaving the arena; leaving requires choosing **Leave the arena**. Restart both game clients after installing this update. GUI login is now user-confirmed; full PvP battle completion is still awaiting a playtest.

Account-form timeout fix (0.3.1): PEMK expires unauthenticated sockets after 30 seconds. The ArenaDemo extension now reconnects after you finish typing, immediately before submitting login/registration. Restart the game to load it. The client launcher waits for a real PEMK ping reply before opening the games, and both launchers print their project folder to catch use of an older copy. Server output/crash diagnostics are saved privately in `tools/runtime/pemk-server.log`.

1. Close existing game windows.
2. Run `Launch-Multiplayer-Server.bat` and leave it running.
3. Run `Launch-Multiplayer-Clients.bat`. It installs the plugin, rebuilds the arena, and opens the normal and guest clients using PEMK's separate instance settings.
4. Create **two different accounts**, one in each window. For new accounts, choose the intro skip to enter the arena. Existing accounts use the Arena Demo pause-menu entry.
5. Walk around the same arena. PEMK provides player presence and its **Battle Player** pause-menu challenge flow. Actual two-window rendering and PvP battle completion still need an in-game check.

Authenticated players use a fixed Sidelines layout with all six objects so their obstacles agree. Personal offline layouts remain saved; online arena editing, friend-owned arena visits, and shared layout persistence are not implemented. The server binds only to `127.0.0.1:9998`; PostgreSQL uses `127.0.0.1:55432`. This version is for two clients on this PC.

The native Windows bcrypt crash was fixed by rebuilding bcrypt/bigdecimal with the matching MSYS2 UCRT compiler. Backend account/login and presence tests now pass, including two authenticated protocol clients entering, moving on, and leaving arena map 100. This is distinct from a two-window GUI playtest. Current details and exact results are in `SETUP_STATUS.md`; older dated setup notes below are historical.

Diagnostics (PowerShell, from this folder):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/local-multiplayer.ps1 -Action Test
```

`Test` uses the isolated `pemk_test` database; upstream tests clear its account records. Play accounts stay in `pemk`. If native gems need rebuilding, first install the matching compiler with `C:\msys64\usr\bin\pacman.exe -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc`, then run the script with `-Action RepairGems`. WSL remains unavailable in this environment; these launchers use the existing project-local Windows runtimes and upstream PEMK server without modifying its authentication code.

## Offline demo launcher

The updated demo generates a compact 25x19 enclosed training yard. Speak to the Youngster at the north end to battle. The manager near the south entrance offers six object slots, three arrangements, clear/light/full presets, trainer difficulty, and team healing. Close the game before rebuilding; use a fresh New Game and the intro skip to avoid loading the old village map stored in an existing save. The earlier village demo's object toggles and menu battle were confirmed working by the user.

Double-click [Launch-ArenaDemo.bat](Launch-ArenaDemo.bat). It copies the current plugin into the private game, rebuilds the arena map from the local Essentials data, then launches the client. Start a fresh game and choose **Skip intro and start Arena Demo** to bypass the Essentials story intro. Choose **Play the full intro** to keep the original opening. In gameplay, click the game window to give it keyboard focus (the separate Essentials Output Window is only a log). Arrow keys move, Z/Enter/Space interact or confirm, X/Esc cancel or go back, and Essentials' mapped Action key (A in RGSS, commonly Shift) opens the pause menu. Custom mode and trainer recruitment are accessed through the Arena Guide.

## 2. Chosen starting point

Evaluate and integrate these projects first:

1. **Pokémon Essentials** — https://github.com/Maruno17/pokemon-essentials
   - The base RPG framework and Pokémon-specific systems.
   - Essentials is built around RPG Maker XP and Ruby/RGSS, not Phaser or a browser stack.
   - Use the version required by the multiplayer project, not the latest version by assumption.

2. **Pokémon Essentials MMO Kit (PEMK)** — https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit
   - Candidate multiplayer client/server foundation for Essentials.
   - The project has been associated with Pokémon Essentials v21.1. Verify the current README, branches, dependencies, and compatibility before proceeding.
   - Do not assume that the repositories work together merely because both are public.

Official and project documentation:
- Essentials: https://essentialsdocs.fandom.com/wiki/Essentials_Docs_Wiki
- PEMK repository: https://github.com/SamDreamsMaker/pokemon-essentials-mmo-kit

### Compatibility rule

**The first task is to clone the projects and get them working together.** Do not start building the arena game before a basic Essentials + PEMK setup is running.

If the expected versions are incompatible:
- Identify the exact version/commit mismatch and error.
- Check the project's documented supported version and installation steps.
- Prefer using the supported Essentials version or a documented compatible branch.
- Do not blindly upgrade/downgrade dependencies or rewrite the networking layer.
- If integration cannot be completed in the current environment, leave a reproducible setup and a concise blocker report, including the commands run and exact errors.

## 3. Target platform and technical constraints

- **Initial target:** a downloadable desktop game, not a browser game.
- Use the engine's intended tooling: RPG Maker XP/RGSS and Ruby as required by the projects.
- Do not port the project to Phaser, Unity, Godot, or the browser.
- Do not create a new battle engine. Reuse Essentials' existing battle systems and data.
- Do not add unrelated web stacks or dependencies.
- Respect the existing architecture and conventions of both repositories.

Codex must first inspect the current repository and local environment. Determine whether RPG Maker XP and the required runtime/editor are available. If a proprietary editor or Windows-specific tool is required and unavailable, do not pretend a full game launch was tested. Complete the parts that can be verified and document what must be done manually.

## 4. Milestone 1 — clone and integrate the projects

This is the **first and highest-priority task**.

1. Inspect the current working directory and available tools.
2. Clone the official Essentials repository and PEMK repository into clearly named directories or use the layout their setup instructions recommend.
3. Read each repository's README, installation instructions, version requirements, license, and known issues.
4. Establish the exact supported Essentials version/commit for PEMK.
5. Follow the documented setup to integrate PEMK with that Essentials version.
6. Configure the server and client using local development settings.
7. Keep secrets, passwords, private keys, and local-only configuration out of version control. Provide an example configuration file if needed.
8. Run the smallest documented single-player test, then the smallest possible local multiplayer test (two clients if supported).
9. Record every command and manual step needed to reproduce the working setup.
10. Write a short `SETUP_STATUS.md` containing:
    - Repository URLs and checked-out versions/commits.
    - Required software and versions.
    - Files changed and why.
    - Commands used.
    - Tests attempted and their actual results.
    - Remaining manual steps or blockers.

Do not claim success unless the relevant test was actually run. Clearly distinguish “code/configuration reviewed”, “server started”, “client started”, and “two clients successfully connected”.

### Repository layout

Use the layout recommended by the projects if they specify one. Otherwise, keep the work organized, for example:

```text
project-root/
  README.md
  AGENTS.md
  SETUP_STATUS.md
  upstream/
    pokemon-essentials/
    pokemon-essentials-mmo-kit/
  game-mod/
    # Our custom plugin/scripts/assets, if the engine architecture supports this
  config/
    # Example configuration only; no secrets
```

Avoid copying entire upstream repositories into nested directories if their own setup instructions require a different structure. Do not modify upstream files unnecessarily; isolate custom changes in a plugin, patch, or clearly documented mod directory wherever feasible.

## 5. Milestone 2 — a small playable demo

Only after the base game and multiplayer integration have been tested, build a minimal demo that proves the intended direction.

### Demo scope

- A small, custom arena map.
- A player character that can move around and collide with walls/objects.
- A small set of placeable or pre-placed arena objects.
- At least one trainer/NPC that can be interacted with.
- A trainer with a configurable sample team using the existing Essentials Pokémon data and battle system.
- A battle that starts and finishes using the existing battle engine.
- A simple arena-management interaction, such as changing the layout or placing/removing a limited set of objects. If runtime editing is too large for the first demo, implement a small in-game management menu or a clearly documented first approximation.
- A clear entry point from the existing game into the demo map.
- If PEMK integration is working, verify that two local clients can connect and that the supported multiplayer behavior remains functional in the demo. Do not assume this means remote arena visiting is already implemented.

### Not required in the first demo

- A complete arena editor.
- Persistent player-owned arenas shared across sessions.
- Visiting and challenging other players' custom arenas.
- Full online progression, matchmaking, ranking, trading, or moderation.
- A complete Pokédex overhaul or new battle mechanics.
- Public hosting or production deployment.

Keep the demo small but genuinely playable. Avoid creating fake UI controls or unimplemented buttons.

## 6. Later milestones (not part of the first task)

Potential future work, only after the initial setup and demo succeed:

1. A grid-based arena editor with placement validation.
2. Saving and loading player-owned arena layouts.
3. Trainer recruitment and team configuration.
4. A private arena browser/list and challenge flow.
5. Server-side persistence and validation of arena data.
6. Inviting friends to a private server.
7. More sophisticated puzzles, obstacles, and arena rules.

Multiplayer architecture must be checked before designing arena synchronization. Do not assume PEMK automatically synchronizes arbitrary custom maps, furniture placement, trainer teams, or battles in player-owned arenas.

## 7. Pokémon assets and non-commercial use

This is intended for **personal, non-commercial use**. The developer wants to make use of the existing Pokémon engine, data, and graphics rather than recreating everything.

- Preserve assets that are already legitimately part of the chosen local Essentials installation and follow that project's installation and licensing instructions.
- Verify the license and terms for each repository, extension, plugin, and third-party asset.
- Do not assume that personal ownership of a Pokémon game automatically authorizes extracting or redistributing its assets.
- Do not bundle or publish copyrighted Pokémon assets, ROM contents, or third-party materials unless the applicable permissions allow it.
- Do not upload private game files or proprietary RPG Maker assets to public repositories.
- Keep any local-only assets and secrets out of public commits.
- Never describe this as an official Pokémon product.

The goal is to make the local personal project work, not to distribute a prepackaged game containing unlicensed assets.

## 8. Coding and change-management rules

- Read the upstream docs before modifying code.
- Keep upstream changes minimal and explain each change.
- Prefer documented plugin/script extension points over patching core engine files.
- Make backups or use version control before substantial modifications.
- Do not commit generated binaries, local save files, credentials, or large copyrighted assets.
- Keep setup instructions accurate and reproducible.
- Report failed tests honestly.
- If a requirement cannot be met, implement the closest safe, testable slice and state the limitation.

## 9. Definition of done for the first task

The first task is complete when:

- Both repositories have been cloned or a specific access/tooling blocker is documented.
- The required versions and compatibility relationship have been verified from project documentation or repository metadata.
- Integration follows documented instructions.
- A local server/client startup has been tested where the environment supports it.
- A two-client local multiplayer test has been attempted if supported by the available tools.
- `SETUP_STATUS.md` records exact versions, commands, results, and remaining steps.

## 10. Definition of done for the first demo

The demo is complete when:

- The custom arena can be entered and explored.
- Movement and collision work.
- The player can interact with a trainer.
- A trainer battle uses the existing Essentials battle system.
- At least one meaningful arena-management interaction works.
- The game can still start using the documented setup.
- If multiplayer integration works, its effect on the demo is tested and documented.
- The README and `SETUP_STATUS.md` reflect reality.

## Initial instruction to Codex

**Task 1 — do this first:** clone Pokémon Essentials and PEMK, inspect their documentation and versions, and get them working together. Do not start building the custom arena demo until this integration has been attempted and its status is recorded in `SETUP_STATUS.md`.

**Task 2 — only after Task 1:** implement the small playable arena-management demo described above, reusing Essentials' Pokémon data and battle system. Keep the scope small, run all tests that are possible in the environment, and document manual editor/runtime steps that cannot be automated.

## Current workspace status (2026-10-26)

Both upstream repositories are checked out under `upstream/`; the checked versions agree at Essentials v21.1. WSL Debian was inaccessible, so I set up a local Windows Ruby 3.3.12 + PostgreSQL 17.11 environment instead. The PEMK server starts on loopback port 9998. A private v21.1 game package is assembled under the ignored `tools/runtime/essentials-v21.1-base/` folder with PEMK and ArenaDemo installed. Two raw TCP sockets connected, but those were not authenticated game clients. Two non-auth PEMK tests pass; the authentication test crashes inside Windows bcrypt, and the full test suite did not complete. See [SETUP_STATUS.md](SETUP_STATUS.md) for exact commits, commands, test output, and blockers.

The client package includes Essentials maps/assets and the mkxp-z runtime in the ignored local test copy, so it can be launched without installing RPG Maker XP. The Ruby map generator derives Map100 from Essentials' walkable Lappet Town map (map 2), reads the Player's House exit transfer to choose the town spawn, and adds reusable furniture/trainer event slots. The offline Arena Guide opens the tile editor, whose validated placements persist in the local save; the user has confirmed the latest custom editor workflow in-game. Online visits retain their existing fixed layout snapshot. See [game-mod/README.md](game-mod/README.md) and [SETUP_STATUS.md](SETUP_STATUS.md).

## Révision des traductions de combat et des zones (2026-11-01)

Les textes de commande, de rappel et d'envoi sont revus : « Que doit faire
Dialga ? », « Envoyer » et des rappels adressés au Pokémon au singulier.
Crush Girl s'affiche « Combattante » ; les 15 biomes et les noms de repli des
secteurs s'affichent en français sans changer les identifiants sauvegardés.
Voir [la révision, ses références et sa validation](docs/FRENCH_BATTLE_WORDING.md).
Le plugin isolé `090_FrenchBattleWording.rb` préserve le pack téléchargé et
les changements de gameplay en cours. Fermez le jeu et relancez Play-Arena.bat
pour préparer le nouveau plugin. Vérification séparée : 94 contrôles réussis.

## Catalogue de mobilier de base (2026-11-01)

**20 nouveaux objets** complètent les trois obstacles existants : sièges,
petites tables, bibliothèque, plantes, statues, console et quatre poupées Pokémon.
Dans **Personnalisation → Meubles**, le sélecteur propose des vignettes,
un aperçu agrandi et la quantité disponible, comme pour les sols.
Deux exemplaires par nouveauté sont fournis une seule fois, même sur une
sauvegarde existante. Les obstacles CS gardent leur fonctionnement.
Voir [le catalogue, son utilisation et sa validation](docs/ARENA_FURNITURE.md).
L'ajout est isolé dans `091_ArenaFurnitureCatalog.rb` ; les fichiers de gameplay
actuellement modifiés par l'autre agent sont préservés. Fermez le jeu puis
relancez Play-Arena.bat. Mettez les deux clients à jour pour les visites.

### Lisibilité du sélecteur de meubles (2026-11-01)

Les vignettes et aperçus des meubles utilisent un gabarit commun, calculé sur
les pixels visibles, avec les proportions conservées. Le panneau garde seulement
« En réserve » et « Occupe 1 case » ; la troisième ligne est supprimée.
