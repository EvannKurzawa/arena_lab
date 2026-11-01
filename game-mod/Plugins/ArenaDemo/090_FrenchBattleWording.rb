# Late presentation-only corrections over the separately downloaded French pack.
# Keep original lookup keys, trainer IDs, map IDs and saved names unchanged.
module ArenaDemo::French
  <<~'TRANSLATIONS'.each_line do |line|
What will\n{1} do? ||| Que doit faire\n{1} ?
Do what with {1}? ||| Que faire de {1} ?
Switch In ||| Envoyer
Arena Demo ||| Arène
Arena Town ||| Village Arène
Good job, {1}! Come back! ||| Tu t'es bien battu, {1} ! Reviens !
OK, {1}! Come back! ||| C'est bien, {1} ! Reviens !
{1}, that's enough! Come back! ||| {1}, ça suffit ! Reviens !
{1}, come back! ||| {1}, reviens !
{1}, switch out! Come back! ||| {1}, on change ! Reviens !
{1} withdrew {2}! ||| {1} retire {2} !
You're in charge, {1}! ||| En avant, {1} !
Go for it, {1}! ||| Vas-y, {1} !
Just a little more! Hang in there, {1}! ||| Encore un effort, {1} ! Tiens bon !
Your opponent's weak! Get 'em, {1}! ||| L'adversaire faiblit ! Vas-y, {1} !
Go! {1}! ||| En avant, {1} !
Go! {1} and {2}! ||| En avant, {1} et {2} !
Go! {1}, {2} and {3}! ||| En avant, {1}, {2} et {3} !
{1} sent out {2}! ||| {1} envoie {2} !
{1} sent out {2} and {3}! ||| {1} envoie {2} et {3} !
{1} sent out {2}, {3} and {4}! ||| {1} envoie {2}, {3} et {4} !
{1} is about to send out {2}. Will you switch your Pokémon? ||| {1} va envoyer {2}. Voulez-vous changer de Pokémon ?
Use next Pokémon? ||| Voulez-vous envoyer un autre Pokémon ?
{1} fell asleep! ||| {1} s'endort !
{1} was poisoned! ||| {1} est empoisonné !
{1} was badly poisoned! ||| {1} est gravement empoisonné !
{1} was burned! ||| {1} est brûlé !
{1} was frozen solid! ||| {1} est gelé !
{1} became confused! ||| {1} devient confus !
{1} was paralyzed! It may be unable to move! ||| {1} est paralysé ! Il risque de ne plus pouvoir attaquer !
{1} restored a little HP using its {2}! ||| {1} récupère quelques PV grâce à {2} !
TRANSLATIONS
    original, translated = line.chomp.split(' ||| ', 2)
    raise 'Invalid French battle wording entry' unless translated
    TEXT[original.gsub('\\n', "\n")] = translated.gsub('\\n', "\n")
  end
  @script_alias_size = nil

  module TrainerClassWording
    def getFromHash(type, key)
      if type == MessageTypes::TRAINER_TYPE_NAMES &&
         ['Crush Girl', 'CrushGirl', 'Fille Baston'].include?(key)
        return 'Combattante'
      end
      super
    end
  end

  module WorldMapWording
    def name
      original = super
      sector = /\AExpedition Sector (\d+)\z/.match(original)
      return "Expédition — secteur #{sector[1]}" if sector
      ArenaDemo::French.text(original)
    end
  end
end
MessageTypes.singleton_class.prepend(ArenaDemo::French::TrainerClassWording)
Game_Map.prepend(ArenaDemo::French::WorldMapWording) if defined?(Game_Map)
