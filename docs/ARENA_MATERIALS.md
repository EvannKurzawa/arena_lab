# Catalogue des sols et plateformes — 0.18.1

## Liquides surélevés, raccords et cascades (0.19.1)

Peindre Eau, Lave, Eau de marécage, Déchets toxiques ou Boue sur une plateforme
conserve sa hauteur et le matériau de ses murs. Une case dont le côté sud est
une paroi visible affiche une coulée animée de la même couleur ; les autres
cases conservent leur surface normale. Les liquides voisins se raccordent
sans bordures internes ; les coins touchant une paroi restent pleins.
La paroi reste bloquée, y compris avec Surf : aucun passage sous la plateforme
ni descente/remontée de cascade. Meubles et Dresseurs restent interdits dans
l'eau, la lave, le marécage et les déchets. La boue reste praticable.

Ajouter une case contre une plateforme reprend le style et le sol de base
de ses voisines, sans recopier leurs liquides peints. Le style majoritaire
des quatre voisins directs gagne ; égalité : haut, droite, bas, gauche.

Dans l'arène, Entrée depuis une rive accessible propose Surf sans badge ni
capacité dans l'équipe. Le véhicule et la sortie d'eau viennent d'Essentials.
La rive doit être à la même hauteur ; Surf ne permet pas de monter une falaise.
Les visites doivent utiliser des clients et un serveur au protocole 11.

Dans **Personnalisation**, utilisez **Changer le sol** pour peindre des cases,
au sol ou sur un plateau. La liste visuelle s'ouvre directement, sans familles.
**Style de plateforme entière** applique le sol et les murs au groupe de cases
surélevées reliées par un côté, escaliers compris. Les occupants restent en place.
Une retouche de sol ne change pas les murs. X quitte l'outil, puis permet de
valider et sauvegarder ou d'annuler les modifications.

Le sélecteur présente une vignette par ligne et un aperçu agrandi du choix
surligné. Pour les plateformes, le dessus et la paroi sont visibles ensemble.
Le panneau distingue les surfaces praticables, glissantes et infranchissables,
notamment l'eau réelle et la glace glissante. Parcourez avec les
flèches, confirmez avec Entrée et revenez avec X. Aucun changement n'est appliqué
à l'arène tant que vous parcourez les aperçus.

## Les 11 plateformes proposées

| Style | Dessus | Murs |
| --- | --- | --- |
| Herbe | Herbe | Terre et rebord végétal |
| Montagne | Roche | Roche grise |
| Neige | Neige | Roche enneigée bleutée |
| Volcanique | Sol volcanique | Roche rouge sombre |
| Désert | Sable | Grès ocre |
| Forêt | Terre et racines | Terre, racines et teintes végétales |
| Ruines anciennes | Dalles fissurées | Blocs de pierre patinée |
| Cristal | Roche bleutée, petits points cyan | Roche sombre, points cyan discrets |
| Industrielle | Métal et grilles | Panneaux verticaux sombres, poutres et rivets |
| Bois | Longues planches parallèles de pont | Poutres sombres et renforts diagonaux |
| Marécage | Boue | Terre humide et racines |

Arène de combat est retirée du sélecteur. Son ancien identifiant reste pris
en charge pour conserver les arènes sauvegardées.

## Les 21 sols généraux proposés

Sol de base, herbe, sable, glace glissante, roche, neige, sol volcanique, lave,
eau, pavés, terre battue, planches, boue, terre et racines,
dalles de ruines et dalles de cristal, déchets toxiques, eau de marécage,
acier bleuté, hexagones holographiques et sables mouvants. Avec les six sols
décoratifs ci-dessous, la liste propose **27 sols plus le vide**.
La boue n'a plus de motifs blancs ajoutés. La glace glissante n'a aucun contour
par case : son fond bleu se raccorde en grandes zones continues.

**La lave et les déchets toxiques sont toujours bloqués**, comme le vide.
**L'eau et l'eau de marécage sont bloquées à pied et traversables avec Surf**.
Ces liquides ne peuvent pas recevoir de meubles ou de Dresseurs. L'eau peinte
sur un dessus de plateforme conserve sa hauteur et ses murs, avec une cascade
sur une face sud exposée. Lave, marécage, déchets et boue peuvent aussi être
peints sur un plateau existant et former leur propre coulée.
Un liquide ne remplace pas un accès bas d'escalier encore utilisé. Leur forme
est conservée par la sauvegarde et les visites.

L'eau possède son propre identifiant `water` et le marécage `marsh_water`.
Depuis la rive, interagissez face à l'eau ou utilisez Surf depuis le menu Pokémon.
Dans l'arène, aucun badge ni capacité n'est exigé depuis la rive ; les
restrictions de compagnons suivent Essentials.
Le saut d'entrée, la nage, la sortie et le véhicule utilisent le Surf natif.
Le marécage liquide est marron avec de petites rides ; la Boue classique reste
un sol solide. Les déchets toxiques sont jaune fluorescent, avec des bulles.
La neige, la boue et les autres matériaux décoratifs n'ajoutent
pas de glisse ni de ralentissement ; la glace glissante conserve son effet.

Les **sables mouvants** sont un piège accessible à pied. Le sable est seulement
4 % plus sombre. En entrant dessus, le joueur tourne, s'enfonce et disparaît
en 1,25 seconde, puis revient à l'entrée de l'arène. Les contrôles et l'affichage
sont restaurés, même après une glissade. Aucun dégât ni perte d'argent.
Les sables mouvants restent au niveau bas, sans occupant ni escalier ; ils ne
peuvent pas remplacer une case réservée ou l'appui d'un escalier. Les visites
transmettent leur emplacement ; le serveur autorise ce retour uniquement
depuis un piège du plan partagé.

Les deux nouveaux sols futuristes sont **Acier bleuté** (plaques biseautées,
joints sombres et petits témoins cyan) et **Hexagones holographiques** (alvéoles
continues, fond bleu nuit et traits cyan). Ils sont praticables et peuvent
aussi recouvrir les dessus de plateformes.

## Les 6 sols décoratifs conservés

Ces sols sont des mosaïques praticables, sans effet sur les combats.

| Type | Motif |
| --- | --- |
| Tatami | Tressage horizontal/vertical, sans diagonales claires |
| Améthyste | Texture violette, sans motif de premier plan |
| Quartz rose | Texture rosée, sans motif de premier plan |
| Dalles hantées | Pierre bleu nuit fissurée, petites lueurs spectrales |
| Obsidienne | Texture obsidienne, sans motif de premier plan |
| Plaques métalliques | Plaques métalliques et rivets |

Métal et grilles, parquet, mousse, dalles de combat et les anciens sols monotype Normal, Feu,
Eau, Électrik, Plante, Glace, Sol, Vol, Insecte, Roche, Dragon et Fée sont retirés
du sélecteur. L'eau réelle, la glace glissante et le sol Roche général restent.
Les anciennes cases sont conservées : les identifiants retirés restent lisibles
et les styles de plateformes existants gardent leurs ressources.

## Vérification et ressources locales

Les textures combinent les ressources installées d'Essentials, des palettes et
de petits motifs de mosaïque dessinés en mémoire. Aucun atlas source n'est
écrasé et aucune nouvelle image tierce n'est distribuée.
Références visuelles consultées : [Modular Space Kit de Kenney](https://kenney.nl/assets/modular-space-kit),
[Cosmic Explorer de Kokoro Reflections](https://kokororeflections-shop.fourthwall.com/products/kr-cosmic-explorer-spaceship-tileset-for-rpgs)
et [panneaux ISS de la NASA](https://science.nasa.gov/3d-resources/iss-panels/).
Ces références servent à la géométrie des panneaux et à leur contraste ; leurs
images ne sont pas intégrées au jeu.
Planches reprend le grain des éléments de pont du tileset Outside installé,
en longues lames continues, sans joints décalés façon briques. La plateforme
Bois utilise le même dessus, avec des supports assombris sous le plateau.
Les plateformes gardent les arrondis, la paroi sud bloquée et les escaliers
des versions précédentes. Les nouvelles matières fonctionnent aussi dans la
vue globale de l'éditeur.

`tools/test-native-relief.py` exporte dans le dossier privé ignoré `tools/runtime/` :

- `native-relief-probe.png` : plateformes, quatre par ligne, dans l'ordre du
  tableau ci-dessus.
- `native-relief-probe-floors.png` : 27 échantillons proposés, huit par ligne.
- `native-relief-probe-floors.txt` : noms et ordre des échantillons.
- `native-relief-probe-player.png` : capture du vrai moteur avec le joueur.

Fermez le jeu et relancez **Play-Arena.bat**. Les sauvegardes existantes gardent
leurs clés de matériaux ; aucune conversion manuelle n'est nécessaire.
Les visites demandent les deux clients et le serveur au **protocole 11**.

## Retouches 0.18.1

Les anciennes Dalles hantées deviennent **Basalte nocturne**, avec des joints
de pierre bleu-noir décalés qui se raccordent, sans yeux ni grande fissure.
Référence de direction artistique :
[Dark Dungeon Stone Tileset](https://sohaib9211.itch.io/dark-dungeon-stone-tileset),
qui présente des sols modulaires raccordables. Aucun asset externe importé.

Les quatre liquides (eau, lave, eau de marécage, déchets toxiques) utilisent
les frames de l'eau native, recolorées selon le sol et animées à des rythmes
différents. Les règles de collision et de Surf sont conservées.
Sables mouvants : texture exacte du sable, luminosité multipliée par 0,96,
sans spirale ; son natif `Player fall` à volume 80 et hauteur 70 lors du piège.
Glace : fissure centrale retirée, reflets courts et glisse conservés.
