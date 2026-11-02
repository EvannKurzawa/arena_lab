# Gold — configuration et ressources personnelles

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
