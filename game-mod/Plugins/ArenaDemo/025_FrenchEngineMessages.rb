# Core messages absent from the community French pack (mostly editor/compiler
# validation). Keep constants, filenames and numeric format fields intact.
module ArenaDemo::French
  <<~'TRANSLATIONS'.each_line do |line|
Bad line syntax (expected syntax like XXX=YYY). ||| Syntaxe de ligne incorrecte. Format attendu : XXX=YYY.
Delete this trainer type? ||| Supprimer ce type de Dresseur ?
Delete this trainer battle? ||| Supprimer ce combat de Dresseur ?
Delete this item? ||| Supprimer cet objet ?
Delete this species? ||| Supprimer cette espèce ?
Set the number of steps remaining. ||| Définissez le nombre de pas restants.
Expected a section at the beginning of the file. ||| Une section est attendue au début du fichier.
Expected a section at the beginning of the file.\nThis error may also occur if the file was not saved in UTF-8. ||| Une section est attendue au début du fichier.\nCette erreur peut aussi survenir si le fichier n'est pas enregistré en UTF-8.
This error may also occur if the file was not saved in UTF-8. ||| Cette erreur peut aussi survenir si le fichier n'est pas enregistré en UTF-8.
Invalid quoted field (in: {1}). ||| Champ entre guillemets incorrect (dans : {1}).
Field '{1}' is not a Boolean value (true, false, 1, 0). ||| Le champ « {1} » n'est pas un booléen (true, false, 1, 0).
Field '{1}' is not an integer. ||| Le champ « {1} » n'est pas un nombre entier.
Field '{1}' is not a positive integer. ||| Le champ « {1} » n'est pas un entier positif.
Field '{1}' is not a number. ||| Le champ « {1} » n'est pas un nombre.
Field '{1}' is not a positive integer or 0. ||| Le champ « {1} » doit être un entier positif ou zéro.
Field '{1}' must be greater than 0. ||| Le champ « {1} » doit être supérieur à zéro.
Field '{1}' is not a hexadecimal number. ||| Le champ « {1} » n'est pas un nombre hexadécimal.
Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number. ||| Le champ « {1} » ne doit contenir que des lettres, des chiffres et des traits de soulignement, et ne peut pas commencer par un chiffre.
Undefined value {1} in {2}. ||| Valeur {1} non définie dans {2}.
Incorrect value {1} in {2}. ||| Valeur {1} incorrecte dans {2}.
Undefined value {1} (expected one of: {2}). ||| Valeur {1} non définie. Valeurs attendues : {2}.
Enumeration not defined. ||| Énumération non définie.
Field '{1}' must be 0 or greater. ||| Le champ « {1} » doit être supérieur ou égal à zéro.
Field '{1}' is not a floating point number. ||| Le champ « {1} » n'est pas un nombre décimal.
Undefined item constant name: {1}.\nMake sure the item is defined in PBS/items.txt. ||| Objet non défini : {1}.\nVérifiez sa définition dans PBS/items.txt.
Undefined species constant name: {1}.\nMake sure the species is defined in PBS/pokemon.txt. ||| Espèce non définie : {1}.\nVérifiez sa définition dans PBS/pokemon.txt.
Undefined move constant name: {1}.\nMake sure the move is defined in PBS/moves.txt. ||| Attaque non définie : {1}.\nVérifiez sa définition dans PBS/moves.txt.
Undefined nature constant name: {1}.\nMake sure the nature is defined in the scripts. ||| Nature non définie : {1}.\nVérifiez sa définition dans les scripts.
Undefined trainer type constant name: {1}.\nMake sure the trainer type is defined in PBS/trainer_types.txt. ||| Type de Dresseur non défini : {1}.\nVérifiez sa définition dans PBS/trainer_types.txt.
Section name '{1}' is used twice. ||| Le nom de section « {1} » est utilisé deux fois.
Warning: Map {1}, as mentioned in the map connection data, was not found. ||| Attention : la carte {1} indiquée dans les connexions de cartes est introuvable.
North side of first map must connect with south side of second map. ||| Le nord de la première carte doit rejoindre le sud de la seconde.
South side of first map must connect with north side of second map. ||| Le sud de la première carte doit rejoindre le nord de la seconde.
East side of first map must connect with west side of second map. ||| L'est de la première carte doit rejoindre l'ouest de la seconde.
West side of first map must connect with east side of second map. ||| L'ouest de la première carte doit rejoindre l'est de la seconde.
'{1}' is not a defined type (type {2}, Weaknesses). ||| « {1} » n'est pas un type défini (type {2}, faiblesses).
'{1}' is not a defined type (type {2}, Resistances). ||| « {1} » n'est pas un type défini (type {2}, résistances).
'{1}' is not a defined type (type {2}, Immunities). ||| « {1} » n'est pas un type défini (type {2}, immunités).
Move {1} is defined as a Status move with a non-zero base damage. ||| L'attaque {1} est définie comme une attaque de statut avec des dégâts de base non nuls.
Warning: Move {1} is defined as Physical or Special but has a base damage of 0. Changing it to a Status move. ||| Attention : l'attaque {1} est physique ou spéciale, mais ses dégâts de base sont nuls. Elle devient une attaque de statut.
Evolution method {1} requires a parameter, but none was given. ||| La méthode d'évolution {1} nécessite un paramètre, mais aucun n'est fourni.
Undefined species ID '{1}'. ||| Identifiant d'espèce « {1} » non défini.
Form {1} for species ID '{2}' is defined twice. ||| La forme {1} de l'espèce « {2} » est définie deux fois.
Dex list number {1} is defined at least twice. ||| La liste du Pokédex n° {1} est définie plusieurs fois.
Dex list number {1} has species {2} listed twice. ||| L'espèce {2} apparaît deux fois dans la liste du Pokédex n° {1}.
Expected a species entry line for encounter type {1} for map {2}. ||| Une ligne d'espèce est attendue pour les rencontres de type {1} sur la carte {2}.
Level number {1} is not valid (max. {2}). ||| Le niveau {1} n'est pas valide (maximum : {2}).
Minimum level is greater than maximum level. ||| Le niveau minimum est supérieur au niveau maximum.
Encounters for map '{1}' are defined twice. ||| Les rencontres de la carte « {1} » sont définies deux fois.
Expected a map number, got "{1}" instead. ||| Un numéro de carte est attendu, mais la valeur reçue est « {1} ».
Undefined encounter type "{1}" for map '{2}'. ||| Type de rencontre « {1} » non défini pour la carte « {2} ».
Pokémon hasn't been defined yet! ||| Ce Pokémon n'est pas encore défini !
Trainer with ID '{1}' has no Pokémon. ||| Le Dresseur « {1} » n'a aucun Pokémon.
Invalid Pokémon level {1} (must be 1-{2}). ||| Niveau de Pokémon incorrect : {1} (valeurs autorisées : 1 à {2}).
Invalid Pokémon nickname: {1} (must be 1-{2} characters). ||| Surnom de Pokémon incorrect : {1} (longueur autorisée : 1 à {2} caractères).
Invalid IV: {1} (must be 0-{2}). ||| IV incorrect : {1} (valeurs autorisées : 0 à {2}).
Invalid EV: {1} (must be 0-{2}). ||| EV incorrect : {1} (valeurs autorisées : 0 à {2}).
Invalid EV set (must sum to {1} or less). ||| Répartition des EV incorrecte. Le total ne doit pas dépasser {1}.
Bad happiness: {1} (must be 0-255). ||| Bonheur incorrect : {1} (valeurs autorisées : 0 à 255).
Value '{1}' isn't a defined Poké Ball. ||| La valeur « {1} » n'est pas une Poké Ball définie.
No trainer data file given in section {1}. ||| Aucun fichier de Dresseurs n'est indiqué dans la section {1}.
Global metadata ID '{1}' is used twice. ||| L'identifiant de métadonnées globales « {1} » est utilisé deux fois.
Player metadata ID '{1}' is used twice. ||| L'identifiant de métadonnées du joueur « {1} » est utilisé deux fois.
The entry 'Home' is required in metadata.txt section 0. ||| L'entrée « Home » est obligatoire dans la section 0 de metadata.txt.
Global metadata is not defined in metadata.txt but should be. ||| Les métadonnées globales doivent être définies dans metadata.txt.
Metadata for player character 1 is not defined in metadata.txt but should be. ||| Les métadonnées du personnage joueur 1 doivent être définies dans metadata.txt.
Version {1} of dungeon area {2} is defined twice. ||| La version {1} de la zone de donjon {2} est définie deux fois.
TRANSLATIONS
    original, translated = line.chomp.split(" ||| ", 2)
    next unless translated
    original = original.gsub('\\n', "\n")
    translated = translated.gsub('\\n', "\n")
    TEXT[original] = translated
    TEXT[Translation.stringToKey(original)] = translated
  end
end
