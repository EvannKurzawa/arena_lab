# Mobilier : corrections visuelles 0.25.1

Les identifiants des objets sont conservés : pas de nouvel achat ni de nouvelle
dotation. Les noms du Sac sont rafraîchis même lorsqu'ils proviennent de données
compilées plus anciennes : Tapis rouge, Pics, Plante en pot, Jolies fleurs,
Bouquet de fleurs. Les mentions HGSS/Hoenn/Sinnoh sont retirées des noms.

| Objets | Correction |
|---|---|
| Boule de neige | Recadrage sur la boule seule, alpha autour du contour ; aucun escalier/support |
| Tapis rouge | Suppression de la bordure opaque extérieure, contour rouge conservé |
| Arbre feuillu | Arbre entier, dessin 64 × 64, collision 2 × 1 cases |
| Sapin | Dessin 64 × 96, collision 2 × 1 cases |
| Machine de laboratoire | Dessin 64 × 76, collision 2 × 1 cases |
| Set de barils | Dessin 64 × 76, collision 2 × 1 cases |
| Baril seul | Dessin 16 × 28, collision 1 case |
| Poubelle | Dessin limité à 20 × 24, collision 1 case |
| Lampe | Dessin 18 × 36, collision 1 case |
| Plantes / fleurs | Limites respectives 24 × 32 et 20 × 30, proportions conservées |
| Chandelier | Nouveau pixel art lisible, limité à 24 × 40, alpha réel |
| Estrade / planche | Une seule représentation : sommet et paroi du relief natif |

Les sprites peuvent dépasser vers le haut sans bloquer la case sous leur cime.
Les quatre meubles larges réservent deux cases côte à côte au même niveau,
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
Les 36 PNG finaux sont dans `game-mod/SharedAssets/Graphics/ArenaFurniture/`.
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

## Chandelier : génération et consigne exacte

Outil : **imagegen intégré**, édition de l'ancien chandelier sur fond transparent.
Le résultat choisi est installé dans
[`chandelier.png`](../game-mod/SharedAssets/Graphics/ArenaFurniture/chandelier.png),
après réduction au gabarit natif par échantillonnage au plus proche voisin.
La source grand format reste dans le cache privé des sources pour la reconstruction.

```text
Edit target: the attached tiny furniture sprite. Replace the poorly legible drawing with one clean three-candle floor candelabra for a Pokemon Gen 3/4 top-down RPG interior. Single object, red-brown brass central stem, three arms, cream candles and small amber flames, compact stable base. Precisely pixel-art drawn on a logical 24 by 32 pixel grid, presented as an exact integer nearest-neighbor enlargement on the output canvas. Crisp square pixels, dark outlines, 8-12 flat colors, light from top left, slight top-down perspective matching handheld RPG furniture, no smooth curves, no antialiasing, no blur, no glow, no text, no border, no extra objects. Fill most of the canvas while leaving a small transparent margin. True transparent alpha background, no checkerboard drawn into image. Preserve the reference's general three-branch candelabra identity, improve proportions and pixel clarity.
```
