# Suiveurs locaux et multijoueurs

Version Arena Demo 0.24.2, 2026-11-02.

Le suiveur disparaît pendant le sable mouvant et les deux phases de la
téléportation. Une espèce vide est alors relayée au visiteur, qui retire le
sprite distant. À l'arrivée, le suiveur actif est remis sur une case voisine
accessible, sans superposition au joueur ; le drapeau natif de masquage après
transfert est levé. Un suiveur déjà désactivé n'est pas réactivé par les effets.
Les masquages des toiles, tapis, aimants et pièges se cumulent.

Le suiveur distant possède une animation au repos comme le suiveur local.
L'animation tourne dans le moteur de chaque client et n'exige pas l'envoi
de chaque image par le réseau. Les mises à jour de position ne recréent pas
son personnage ou son sprite.

Le client annonce la case et la direction du suiveur réellement présent.
Le serveur accepte uniquement des coordonnées entières dans la carte, proches
du joueur (3 cases maximum), et une direction cardinale. Il ne reçoit aucun
chemin de fichier graphique. Les anciens messages sans position explicite
utilisent la dernière case parcourue par le joueur ; tourner sur place ne
déplace plus le Pokémon autour de lui.

Les deux affichages conservent la trajectoire du suiveur, avec une marge de
8 pixels par défaut, jusqu'à 16 pixels pour les grandes espèces configurées.
Dark Lugia utilise la règle de Lugia. La marge s'adapte progressivement sur
environ 90 ms et ne change pas lorsqu'on lit plusieurs fois les coordonnées
du sprite pendant une image. La projection sur un cercle fixe de la version
0.24.1 est supprimée : elle amplifiait les petits changements de direction
près du joueur et pouvait donner l'impression d'un sprite bloqué dans un coin.
Les virages et demi-tours suivent désormais la trajectoire naturelle du moteur,
avec un écartement temporairement variable. Les nouvelles positions distantes
prolongent le glissement depuis la position affichée, sans saut au point
d'arrivée précédent. Les collisions restent celles du moteur ; les personnages
distants sont uniquement visuels.

Fermer les jeux et mettre à jour les deux PC avec Arena Update, puis relancer
Play-Arena.bat, puis choisir d'héberger. Le contrôle du service vérifie aussi
sa capacité à relayer les positions des suiveurs ; un ancien service géré est
relancé par le lanceur après ses contrôles habituels.
Le protocole reste 14 : ces champs sont facultatifs, mais les deux clients et
l'hôte à jour donnent le rendu complet.

Validation 0.24.2 : 71 contrôles dans le moteur natif sur un personnage en
mémoire, sans lecture ni écriture de sauvegarde joueur ; 35 tests Ruby / 181
assertions sur les dialogues, suiveurs, connexion, entrée et cache des plugins.
Le test natif affiche un suiveur local et un suiveur distant, injecte les messages
de déplacement dans le vrai registre PEMK, et vérifie repos, quatre directions,
marche, virages et demi-tours (écart maximal 43 pixels et déplacement relatif
maximal de 9 pixels par image dans le parcours testé avec Mew). Les tests TCP
de la version précédente ont vérifié le relais et les données invalides avec
authentification injectée ; le protocole et son relais restent inchangés ici.
Cela ne constitue pas un essai de deux clients graphiques sur deux PC.
