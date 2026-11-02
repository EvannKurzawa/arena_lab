# Gold et ressources partagées

**Procédure actuelle : fermer le jeu, utiliser Arena Update.exe, puis lancer
Play-Arena.bat. Aucune copie manuelle de Gold, Dark Lugia ou du son de la rune
n'est nécessaire.** Les anciens EXE récupèrent aussi ces fichiers avec l'archive
GitHub ; Play-Arena les installe à la préparation suivante. Le nouvel EXE installe
en plus les graphismes et sons partagés pendant la mise à jour.

Sur demande explicite de l'utilisateur, les deux sprites de Gold et sa musique
sont versionnés dans `game-mod/SharedAssets/`, ainsi que le son de la rune.
La planche de Dark Lugia est dans `game-mod/AssetSources/xd001.png` ; l'importeur
habituel génère les variantes sur chaque PC. Crédit de la planche : ShadowGate31.
Les conditions de redistribution de ces ressources restent non vérifiées.

Pour les futurs graphismes et sons, ajouter les fichiers dans
`game-mod/SharedAssets/Graphics/...` ou `game-mod/SharedAssets/Audio/...`, avec
le chemin attendu par Essentials, puis les commit/push avec leur code.
L'installation parcourt automatiquement ces dossiers, sans liste à maintenir.
Une source nécessitant une conversion doit avoir son importeur branché dans
Prepare, comme Dark Lugia. Ne pas y placer le runtime entier, les sauvegardes
ou les identifiants.

Les fichiers publiés remplacent les anciennes versions au même chemin. Les
versions remplacées sont sauvegardées dans `arena-asset-backups/` du jeu, ou
dans `update-backup-...` pendant le nouvel updater. Les ressources retirées du
dépôt ne sont pas supprimées automatiquement des installations.

## Ancienne procédure privée (v9.3, remplacée)

Les instructions ci-dessous décrivent l'ancien fonctionnement et ne sont plus
nécessaires pour les ressources maintenant partagées.

Le profil `ARENA_TRAINER_GOLD` est inclus dans 009_ArenaCustomMode.rb :
Léviator chromatique 82, Typhlosion 85, Togekiss 83 et Raikou 87.
Le type et les musiques sont définis dans
`game-mod/PBS/trainer_types_gold.txt` (Battle GOLD / Battle Champion).

Prepare lance `tools/install-custom-trainers.ps1`. Il installe le PBS séparé
uniquement si aucun type GOLD n'existe déjà ; une définition personnelle
existante est conservée. Les fichiers présents dans le jeu sont sauvegardés
une première fois dans le cache privé ci-dessous. Si le runtime est reconstruit,
les fichiers manquants sont recopiés depuis ce cache, sans écraser les fichiers
déjà présents.

Les binaires personnels ne sont pas publiés sur GitHub. Pour reproduire Gold
sur un autre PC, copier séparément ces fichiers dans
`tools/runtime/custom-trainer-assets/`, en conservant les sous-dossiers :

- `Graphics/Characters/trainer_GOLD.png`
- `Graphics/Trainers/GOLD.png`
- `Audio/BGM/Battle GOLD.ogg`

Puis relancer Play-Arena.bat. Les nouvelles ressources d'autres dresseurs
doivent rester locales selon leurs conditions d'utilisation. Pour remplacer
un asset du cache volontairement, sauvegarder l'ancien fichier et copier la
nouvelle version dans le cache et le runtime.

Le son personnel de la rune est distinct : copier séparément
`tools/runtime/device-src-rune-cecite.mp3` sur l'autre PC si souhaité. Le son
Myinstants du bouton est téléchargé et vérifié par l'installateur des objets.
