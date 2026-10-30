# Catalogue des sols et plateformes — 0.17.4

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

## Les 16 sols généraux proposés

Sol de base, herbe, sable, glace glissante, roche, neige, sol volcanique, lave,
eau, pavés, terre battue, planches, boue, terre et racines,
dalles de ruines et dalles de cristal. La boue n'a plus de motifs blancs ajoutés.

**L'eau et la lave sont bloquées**, comme le vide. Elles ne peuvent pas recevoir
de meubles, de Dresseurs ou de plateformes ; elles ne peuvent pas remplacer
l'appui ou l'arrivée d'un escalier encore utilisé. Les remplacer par un autre
sol les rend de nouveau praticables. Comme le vide, les peindre retire le relief
de la case. Leur forme est conservée par la sauvegarde et les visites.

L'eau possède son propre identifiant `water`, distinct de la lave et du vide,
pour une future implémentation de Surf. Actuellement aucun état Surf ne permet
de la traverser. La neige, la boue et les autres matériaux décoratifs n'ajoutent
pas de glisse ni de ralentissement ; la glace glissante conserve son effet.

## Les 6 sols décoratifs conservés

Ces sols sont des mosaïques praticables, sans effet sur les combats.

| Type | Motif |
| --- | --- |
| Tatami | Tressage horizontal/vertical, sans diagonales claires |
| Améthyste | Texture violette, sans motif de premier plan |
| Quartz rose | Texture rosée, sans motif de premier plan |
| Ardoise mauve | Texture sombre, sans motif de premier plan |
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
Planches reprend le grain des éléments de pont du tileset Outside installé,
en longues lames continues, sans joints décalés façon briques. La plateforme
Bois utilise le même dessus, avec des supports assombris sous le plateau.
Les plateformes gardent les arrondis, la paroi sud bloquée et les escaliers
des versions précédentes. Les nouvelles matières fonctionnent aussi dans la
vue globale de l'éditeur.

`tools/test-native-relief.py` exporte dans le dossier privé ignoré `tools/runtime/` :

- `native-relief-probe.png` : plateformes, quatre par ligne, dans l'ordre du
  tableau ci-dessus.
- `native-relief-probe-floors.png` : 22 échantillons proposés, huit par ligne.
- `native-relief-probe-floors.txt` : noms et ordre des échantillons.
- `native-relief-probe-player.png` : capture du vrai moteur avec le joueur.

Fermez le jeu et relancez **Play-Arena.bat**. Les sauvegardes existantes gardent
leurs clés de matériaux ; aucune conversion manuelle n'est nécessaire.
Les visites demandent les deux clients et le serveur au **protocole 8**.
