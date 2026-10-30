# Source templates and extracted message files encode line breaks differently.
# Canonicalize lookup keys only; never alter source control codes or user names.
module ArenaDemo::French
  def self.script_key(key)
    key.gsub(/\\[rnt]|\\[\r\n]|[\r\n\t]/, ' ').gsub(/\s+/, ' ').strip
  end

  def self.script_translation(key)
    if @script_alias_size != TEXT.length
      @core ||= File.open('Data/messages_french_core.dat', 'rb') { |file| Marshal.load(file) }
      @script_aliases = {}
      (@core[MessageTypes::SCRIPT_TEXTS] || {}).each { |original, translated| @script_aliases[script_key(original)] = translated }
      TEXT.each { |original, translated| @script_aliases[script_key(original)] = translated }
      @script_alias_size = TEXT.length
    end
    @script_aliases[script_key(key)]
  end

  <<~'TRANSLATIONS'.each_line do |line|
You got away safely! ||| Vous avez pris la fuite !
No! There's no running from a Trainer battle! ||| Impossible de fuir un combat de Dresseurs !
{1} fled from battle! ||| {1} prend la fuite !
{1} fainted... ||| {1} est K.O...
{1} recovered from fainting! ||| {1} n'est plus K.O. !
All Pokémon that hear the song will faint in three turns! ||| Tous les Pokémon qui entendent ce chant seront K.O. dans trois tours !
Both Pokémon will faint in three turns! ||| Les deux Pokémon seront K.O. dans trois tours !
Both Pokémon will faint in three turns because of {1}'s {2}! ||| À cause du talent {2} de {1}, les deux Pokémon seront K.O. dans trois tours !
{1}'s {2} is disabled! ||| {1} ne peut plus utiliser {2} !
{1}'s {2} was disabled! ||| {1} ne peut plus utiliser {2} !
{1}'s {2} was disabled by {3}'s {4}! ||| Le talent {4} de {3} empêche {1} d'utiliser {2} !
{1} is no longer disabled! ||| {1} peut à nouveau utiliser toutes ses capacités !
The Exp Share was turned off. ||| Le Multi Exp est désactivé.
Disabled Exp. All's effect. ||| Le Multi Exp est désactivé.
{1} is fainted, can't change status. ||| {1} est K.O. Impossible de modifier son statut.
Make fainted ||| Mettre K.O.
Choose whether you can switch Pokémon when an opponent's Pokémon faints. ||| Choisissez si vous pouvez changer de Pokémon quand le Pokémon ennemi est K.O.
Battlers... ||| Pokémon au combat...
An item used by the Trainer during battle. ||| Objet utilisé par ce Dresseur pendant le combat.
How this item can be used within a battle. ||| Utilisation de cet objet en combat.
BGM played before battles against trainers of this type. ||| Musique jouée avant les combats contre ce type de Dresseur.
BGM played in battles against trainers of this type. ||| Musique jouée pendant les combats contre ce type de Dresseur.
BGM played when player wins battles against trainers of this type. ||| Musique de victoire contre ce type de Dresseur.
You put the {1} in\nyour Bag's <icon=bagPocket{2}>\c[1]{3}\c[0] pocket. ||| Vous rangez {1}\ndans la poche <icon=bagPocket{2}>\c[1]{3}\c[0] du Sac.
But your Bag is full... ||| Mais votre Sac est plein...
The Bag is full. The Pokémon's item could not be removed. ||| Votre Sac est plein. Impossible de récupérer l'objet du Pokémon.
There's no more room in the Bag. ||| Il n'y a plus de place dans le Sac.
You have no room in your Bag. ||| Il n'y a plus de place dans votre Sac.
You have no room left in the Bag. ||| Il n'y a plus de place dans le Sac.
Pocket in the Bag where this item is stored. ||| Poche du Sac dans laquelle cet objet est rangé.
But it failed because of {1}'s {2}! ||| Mais le talent {2} de {1} empêche l'action !
PP: {1: 2d}/{2: 2d}<br>TYPE/{3:s} ||| PP : {1: 2d}/{2: 2d}<br>TYPE/{3:s}
x{1: 3d} ||| x{1: 3d}
x{1: 2d} ||| x{1: 2d}
{1} can't be switched out! ||| {1} ne peut pas être remplacé !
{1} is getting pumped! ||| {1} se concentre !
{1} got pumped from the {2}! ||| {1} se concentre grâce à {2} !
{1} used its {2} to get pumped! ||| Grâce à {2}, {1} se concentre !
{1} is switched out by the {2}! ||| {1} est rappelé grâce à {2} !
{1} is switched out with the {2}! ||| {1} est rappelé grâce à {2} !
Your opponent's weak! Get 'em, {1}! ||| L'adversaire faiblit ! Vas-y, {1} !
This can't be used on the fainted Pokémon. ||| Cela ne peut pas être utilisé sur un Pokémon K.O.
It cannot be fused with that fainted Pokémon. ||| Impossible de fusionner avec un Pokémon K.O.
The {1} can't be held. ||| Un Pokémon ne peut pas tenir {1}.
Battle Effects ||| Animations de combat
Battle Points: {1} ||| Points de Combat : {1}
Battle Points:\n<r>{1} ||| Points de Combat :\n<r>{1}
Battle Points:\n<ar>{1}</ar> ||| Points de Combat :\n<ar>{1}</ar>
Money:\n<ar>{1}</ar> ||| Argent :\n<ar>{1}</ar>
Coins:\n<ar>{1}</ar> ||| Jetons :\n<ar>{1}</ar>
Money:\n<r>{1} ||| Argent :\n<r>{1}
Money:\n{1} ||| Argent :\n{1}
ANNOUNCER: The Bug-Catching Contest is over! ||| ANNONCE : Le Concours de Capture d'insecte est terminé !
ANNOUNCER:  The Bug-Catching Contest is over! ||| ANNONCE : Le Concours de Capture d'insecte est terminé !
Use the Arrow keys to move the main character.\nYou can also use the Arrow keys to select entries and navigate menus. ||| Utilisez les flèches pour vous déplacer.\nElles permettent aussi de choisir les options dans les menus.
Use the Arrow keys to move the main character.\n\nYou can also use the Arrow keys to select entries and navigate menus. ||| Utilisez les flèches pour vous déplacer.\n\nElles permettent aussi de choisir les options dans les menus.
My Game by: ||| Un jeu créé par :
Also involved were: ||| Avec la participation de :
Special thanks to: ||| Remerciements :
Kanto Pokédex ||| Pokédex de Kanto
Johto Pokédex ||| Pokédex de Johto
Usage of deprecated method "{1}" or its alias. ||| Utilisation de la méthode obsolète « {1} » ou de son alias.
Registered {1} in the Pokégear! ||| Le numéro de {1} est enregistré dans le Pokématos !
Pokégear ||| Pokématos
Poké Center ||| Centre Pokémon
Croagunk ||| Cradopaud
Click! ||| Clic !
Dex No. ||| N° Pokédex
Sp. Atk ||| Atq. Spé.
Set the wild {1}'s level. ||| Définissez le niveau du {1} sauvage.
Name of the Pokémon Storage creator (the storage option is named "XXX's PC"). ||| Nom du créateur du système de stockage Pokémon, affiché sous la forme « PC de XXX ».
Player earns this much money times the highest level among the trainer's Pokémon. ||| Somme gagnée multipliée par le niveau du Pokémon le plus fort de ce Dresseur.
Cel Focus... ||| Point d'ancrage de la cellule...
Bug Catcher Ed ||| Édouard le Scout
Camper Barry ||| Bernard le Campeur
TRANSLATIONS
    original, translated = line.chomp.split(' ||| ', 2)
    raise 'Invalid French core review entry' unless translated
    TEXT[original] = translated
    TEXT[original.gsub('\\n', "\n")] = translated.gsub('\\n', "\n")
  end

  # Retain the stock artwork/animations; the bar displays only the ability name.
  module AbilityOnlyBar
    def refresh
      self.bitmap.clear
      return unless @battler
      x = (@side == 0) ? 10 : self.bitmap.width - 8
      align = (@side == 0) ? :left : :right
      pbDrawTextPositions(self.bitmap, [[@battler.abilityName, x, 23, align,
        self.class::TEXT_BASE_COLOR, self.class::TEXT_SHADOW_COLOR, :outline]])
    end
  end
end
Battle::Scene::AbilitySplashBar.prepend(ArenaDemo::French::AbilityOnlyBar) if defined?(Battle::Scene::AbilitySplashBar)
