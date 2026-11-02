# Contrôle des animations au lancement — 2026-11-02

## Correction durable implémentée

Après mise à jour du code, relancer `Play-Arena.bat`. Le marqueur comprend
désormais trois empreintes : source du pack, fichier installé, contenu des
animations. Un lancement ordinaire conserve le contrôle rapide du fichier.
Si ses octets changent, Ruby compare son contenu : classes, tableaux, valeurs,
variables d'instance et octets des chaînes. Les détails de sérialisation comme
les liens entre objets ou les métadonnées d'encodage ne déclenchent plus de faux
blocage. Si le contenu est identique, seul le marqueur est actualisé, par
remplacement atomique. Animations, correspondances d'attaques et sprites restent
intacts. Une vraie modification ou un fichier invalide reste bloqué et préservé.

Une ancienne installation à deux empreintes est migrée directement si le fichier
est encore identique. S'il a déjà été réécrit, l'installateur utilise le pack
ZIP dont l'empreinte est vérifiée et la sauvegarde
`Data/ArenaLab-BattleAnimations-before-Gen9.rxdata` pour reconstruire la référence
en mémoire. Il exige d'abord que cette reconstruction corresponde exactement
à l'ancienne empreinte, puis compare le contenu avec le fichier actuel. Il ne
réinstalle pas le pack et ne l'ajoute pas une deuxième fois. Si la sauvegarde
manque ou ne permet pas de vérifier la référence, une intervention reste requise.
Le ZIP est téléchargé seulement si nécessaire et autorisé par la préparation.

Il faut récupérer les changements de `tools/install-battle-animations.ps1` et
`game-mod/tools/install_battle_animation_data.rb` ensemble. Le marqueur manuel
ci-dessous n'est plus nécessaire pour une installation migrable automatiquement.

## Diagnostic initial

Le contrôle dans `tools/install-battle-animations.ps1` compare les octets de
`Data/PkmnAnimations.rxdata` à l'empreinte enregistrée lors de l'installation.
Le compilateur Essentials peut réécrire ce fichier pendant la compilation PBS
(`Compiler.compile_animations`), même sans modification des animations.

Les fichiers transmis dans `other_computer_bug` contiennent 1 843 animations.
Leur contenu a été comparé récursivement avec la référence locale : classes,
éléments de tableaux, variables d'instance et valeurs, avec comparaison des
chaînes par octets. Les deux contenus sont identiques. Leurs empreintes SHA256
binaires diffèrent :

- Référence, conforme au marqueur original :
  `1f430420899324554d541929b9407fe3a5a972b9fbb5f54edf966619b3597b0e`.
- Copie transmise :
  `b266b87315c066f4b7669d9d1b7416cb4d64224ba80f645cb5dfa4e0b84c991b`.

`tools/inspect-battle-animation-report.rb` permet de reproduire cette comparaison
sur les fichiers locaux via les empreintes de leur contenu normalisé. Ce script
est destiné aux fichiers locaux de confiance ; il charge le format Ruby Marshal.

Un marqueur corrigé et les étapes de récupération ont été préparés localement
dans `other_computer_bug/repaired/`, exclus de la publication. Ils concernent
exclusivement la copie examinée.
Les originaux transmis, le runtime local et les dresseurs sont conservés intacts.
Le contrôle du lanceur reste en place avec comparaison de contenu. Ne pas supprimer le marqueur :
l'installateur pourrait ajouter une deuxième fois le pack.

Le script de dresseurs transmis passe `ruby -c`, avec deux clés dupliquées :
`ARENA_TRAINER_POKEMONBREEDER_1` (5011/5015) et
`ARENA_TRAINER_PSYCHIC_F_1` (5615/5619). La dernière définition remplace la
première. Le PBS modifié et les sprites ne figurent pas dans les fichiers reçus.
Leur validité et le lancement sur l'autre ordinateur restent à vérifier.
