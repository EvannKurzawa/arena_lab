# Mobilier : corrections visuelles 0.25.6

L'estrade utilise désormais le sprite RSE entier, marches comprises, agrandi
uniformément à 128 × 64. Emprise : 4 cases de large, 3 vers le haut depuis
le coin bas gauche choisi. Les deux escaliers latéraux sont accessibles;
la façade centrale est bloquante. Les anciennes poses sont retirées et rendues
au Sac; leur sol enregistré est restauré. Les vestiges isolés de l'ancien
modèle sans meuble associé sont nettoyés à la migration.
La Tesla utilise une décharge pleine, irrégulière, à reflets blancs et bleus,
avec scintillement des filaments et sans rotation.

Révision du 3 novembre : cime complète de l'arbre individuel (recadrage
96 × 112, canevas transparent 96 × 128). L'estrade utilise maintenant quatre
cases dessinées dans le relief : deux pour la plateforme, deux pour les marches.
Son événement reste invisible afin que le joueur soit dessiné au-dessus du sol.
Le sol bas reste accessible depuis les marches, en solo et en visite.
L'étincelle Tesla utilise des éclairs bleus et blancs qui scintillent sur place,
avec des espaces transparents entre les arcs, sans noyau plein ni rotation.

La révision 0.25.4 retire Pics et Porte Cassable du catalogue, du Sac et des
graphismes; les anciennes sauvegardes perdent leurs poses et leur stock.
L'arbre feuillu utilise la silhouette individuelle du tileset. L'étincelle
Tesla est un éclat électrique plus organique en pixel art. L'estrade reprend
`Estrade_RSE.png` sur deux niveaux : sol bas, escalier intégré et plateforme.
Les anciennes poses sont migrées sans perdre le sol sous-jacent. Les PNG finaux sont générés par
`tools/build-extra-furniture-art.rb` et installés par Arena Update/Play-Arena.

La révision 0.25.2 précédente retirait déjà les pixels rouges, abaissait le
tapis de 6 pixels et rétablissait le dessin du meuble sur le sommet. Les détails
ci-dessous gardent les tailles, noms et comportements précédents.

Révision 0.25.2 : les pics perdent leurs pixels rouges, le tapis est décalé de
6 pixels vers le bas sans rogner l'image, et l'arbre feuillu utilise la pose
intacte d'un arbre individuel de `Characters/Object tree 1.png`.
Le dessin original de l'estrade et de la planche est de nouveau visible,
ajusté sur toute la case du sommet ; le relief dessine la paroi. La Tesla utilise neuf poses
d'arcs électriques bleus et blancs, inspirées des barrières de Major Bob HGSS.
Les descriptions du masquage des sprites ci-dessous concernent la 0.25.1.

Les identifiants des objets sont conservés : pas de nouvel achat ni de nouvelle
dotation. Les noms du Sac sont rafraîchis même lorsqu'ils proviennent de données
compilées plus anciennes : Tapis rouge, Plante en pot, Jolies fleurs,
Bouquet de fleurs. Les mentions HGSS/Hoenn/Sinnoh sont retirées des noms.

| Objets | Correction |
|---|---|
| Boule de neige | Recadrage sur la boule seule, alpha autour du contour ; aucun escalier/support |
| Tapis rouge | Suppression de la bordure opaque extérieure, contour rouge conservé |
| Arbre feuillu | Arbre individuel du tileset, dessin 96 × 96, collision 2 × 1 cases |
| Sapin | Dessin 64 × 96, collision 2 × 1 cases |
| Machine de laboratoire | Dessin 64 × 76, collision 2 × 1 cases |
| Set de barils | Dessin 64 × 76, collision 2 × 1 cases |
| Baril seul | Dessin 16 × 28, collision 1 case |
| Poubelle | Dessin limité à 20 × 24, collision 1 case |
| Lampe | Dessin 18 × 36, collision 1 case |
| Plantes / fleurs | Limites respectives 24 × 32 et 20 × 30, proportions conservées |
| Chandelier | Nouveau pixel art lisible, limité à 24 × 40, alpha réel |
| Estrade / planche | Estrade à deux niveaux; planche et relief natifs |

Les sprites peuvent dépasser vers le haut sans bloquer la case sous leur cime.
Les six meubles larges réservent deux cases côte à côte au même niveau,
hors vide, eau, escaliers, parois et autres meubles. Cliquer sur l'une des deux
cases permet le retrait. Les validations serveur appliquent aussi ces règles.
Une ancienne implantation serrée est ajustée une seule fois : priorité à la
position existante, puis à la place valide la plus proche au même niveau,
sinon retour au Sac. Les meubles voisins ne sont pas déplacés.

Estrade et planche créaient correctement un relief de hauteur 1, mais affichaient
en plus leur ancienne image d'objet au-dessus. L'événement reste traversable et
son image est masquée : le moteur dessine une plateforme et sa paroi une seule
fois. Le catalogue utilise le même dessin que le relief. L'accès reste régi par
les plateformes et escaliers existants.

Fermer les jeux, Arena Update.exe sur les deux PC, puis Play-Arena.bat.
Les 34 PNG finaux sont dans `game-mod/SharedAssets/Graphics/ArenaFurniture/`.
Les anciennes images restent récupérables dans l'historique Git ; l'installateur
conserve aussi les versions locales remplacées dans `arena-asset-backups/`.
Les rectangles, dimensions visibles et SHA-256 figurent dans
`game-mod/AssetSources/furniture-sources.json`.

Validation : **266 contrôles natifs**, **78 tests / 2 607 assertions**.
La capture `tools/runtime/furniture-native-report-revised-map.png` a été
inspectée visuellement. Les tests natifs utilisent une copie jetable, sans
sauvegarde personnelle ; aucune nouvelle session manuelle entre deux PC n'est
revendiquée. Les tests TCP vérifient notamment le rejet d'un chevauchement sur
la deuxième case et l'annonce de la nouvelle capacité du serveur.

## Estrade RSE : sprite exact et escalier intégré

Source originale consultée : [Estrade RSE sur Poképédia](https://www.pokepedia.fr/Fichier%3AEstrade_RSE.png).
Le plateau source est conservé sans redessin. La forme de deux cases de large
est suivie d'un rang d'escalier intégré; le rang bas reste au sol. Le relief
stocke hauteur 1 sur le plateau et code 8 sur les deux cases de l'escalier,
qui monte vers le nord. Le placement réserve plateau et marches; le sol bas
reste praticable. Retirer l'estrade restaure les surfaces des quatre cases
modifiées. Les anciennes estrades sont migrées vers cette disposition, ou
retournent au Sac si aucune place sûre n'existe.

## Chandelier : génération et consigne exacte

Outil : **imagegen intégré**, édition de l'ancien chandelier sur fond transparent.
Le résultat choisi est installé dans
[`chandelier.png`](../game-mod/SharedAssets/Graphics/ArenaFurniture/chandelier.png),
après réduction au gabarit natif par échantillonnage au plus proche voisin.
La source grand format reste dans le cache privé des sources pour la reconstruction.

```text
Edit target: the attached tiny furniture sprite. Replace the poorly legible drawing with one clean three-candle floor candelabra for a Pokemon Gen 3/4 top-down RPG interior. Single object, red-brown brass central stem, three arms, cream candles and small amber flames, compact stable base. Precisely pixel-art drawn on a logical 24 by 32 pixel grid, presented as an exact integer nearest-neighbor enlargement on the output canvas. Crisp square pixels, dark outlines, 8-12 flat colors, light from top left, slight top-down perspective matching handheld RPG furniture, no smooth curves, no antialiasing, no blur, no glow, no text, no border, no extra objects. Fill most of the canvas while leaving a small transparent margin. True transparent alpha background, no checkerboard drawn into image. Preserve the reference's general three-branch candelabra identity, improve proportions and pixel clarity.
```
