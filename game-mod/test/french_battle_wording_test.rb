# Read-only checks using the actual Essentials message lookup and interpolation.
# No plugin installation, shared mkxp cache, live game, save or pack is modified.
def assert_wording(condition, label)
  raise label unless condition
  $wording_checks += 1
end
$wording_checks = 0
def load_data(path); Marshal.load(File.binread(path)); end
def nil_or_empty?(value); value.nil? || value.empty?; end
class Game_Map
  def initialize(label); @label = label; end
  def name; @label; end
end
root = File.expand_path('../..', __dir__)
load File.join(root, 'upstream/pokemon-essentials/Data/Scripts/001_Technical/003_Intl_Messages.rb')
%w[021_French 023_FrenchFollowers 024_FrenchNetwork 025_FrenchEngineMessages 026_FrenchCoreReview 090_FrenchBattleWording 092_FrenchFieldWording].each do |name|
  path = File.join(root, "game-mod/Plugins/ArenaDemo/#{name}.rb")
  # Essentials normalizes literal tabs before loading plugins.
  eval(File.read(path, encoding: 'UTF-8').gsub("\t", '  '), TOPLEVEL_BINDING, path)
end
load File.join(root, 'game-mod/Plugins/ArenaDemo/015_ExpeditionLayout.rb')
Dir.chdir(File.join(root, 'tools/runtime/essentials-v21.1-base')) do
  MessageTypes.load_message_files('french')
  assert_wording(_INTL("This rock seems breakable with a hidden move.\nWould you like to use Rock Smash?") == "Ce bloc de pierre peut être brisé.\nVoulez-vous utiliser Éclate-Roc ?", 'HGSS Rock Smash prompt replaces hidden move and English move name')
  assert_wording(_INTL("This tree looks like it can be cut down!\nWould you like to cut it?") == "Cet arbre semble pouvoir être coupé.\nUtiliser Coupe ?", 'HGSS Cut confirmation')
  assert_wording(_INTL('Would you like to use Strength?') == 'Voulez-vous utiliser Force ?', 'HGSS Strength confirmation')
  assert_wording(_INTL('Strength made it possible to move boulders around!') == 'Force permet de déplacer le rocher.', 'Strength describes current effect in present tense')
  assert_wording(_INTL("What will\n{1} do?", 'Dialga') == "Que doit faire\nDialga ?", 'Battle command prompt')
  assert_wording(_INTL('Do what with {1}?', 'Zekrom') == 'Que faire de Zekrom ?', 'Party command prompt')
  assert_wording(_INTL('Switch In') == 'Envoyer', 'Send button')
  assert_wording(_INTL('{1}, switch out! Come back!', 'Zekrom') == 'Zekrom, on change ! Reviens !', 'Recall message')
  assert_wording(_INTL("You're in charge, {1}!", 'Zekrom') == 'En avant, Zekrom !', 'Replacement message')
  assert_wording(_INTL('{1} used {2}!', 'Dialga', 'Draco-Choc') == 'Dialga utilise Draco-Choc !', 'Present-tense move narration retained')
  assert_wording(_INTL('{1} withdrew {2}!', 'Alice', 'Zekrom') == 'Alice retire Zekrom !', 'Opponent recall present tense')
  assert_wording(pbGetMessageFromHash(MessageTypes::TRAINER_TYPE_NAMES, 'Crush Girl') == 'Combattante', 'Trainer class uses display name without changing ID')
  assert_wording(_INTL('Go! {1} and {2}!', 'Dialga', 'Zekrom') == 'En avant, Dialga et Zekrom !', 'Double battle placeholders')
  assert_wording(_INTL('Go! {1}, {2} and {3}!', 'Dialga', 'Zekrom', 'Mew') == 'En avant, Dialga, Zekrom et Mew !', 'Triple battle placeholders')
  assert_wording(_INTL("What will\n{1} do?", 'Éclair (ami)') == "Que doit faire\nÉclair (ami) ?", 'Nickname preserved')
  assert_wording(_INTL('Graphics/UI/Bag/icon_register') == 'Graphics/UI/Bag/icon_register', 'Resource IDs preserved')
  assert_wording(_INTL('All Pokémon that hear the song will faint in three turns!').include?('dans trois tours'), 'Legitimate future event retained')
  biomes = ArenaDemo::ExpeditionLayout::BIOMES
  assert_wording(Game_Map.new('Expedition Sector 12').name == 'Expédition — secteur 12', 'Uninitialized sector fallback name translated')
  assert_wording(Game_Map.new('Arena Demo').name == 'Arène', 'Legacy arena map name translated')
  assert_wording(Game_Map.new('Arena Town').name == 'Village Arène', 'Legacy village map name translated')
  biomes.each do |id, (english, *rest)|
    translated = Game_Map.new(english).name
    assert_wording(translated == ArenaDemo::French::TEXT.fetch(english), "French map-name accessor for #{id}")
    assert_wording(biomes.key?(id) && biomes[id][0] == english, "Biome IDs and source records preserved for #{id}")
  end
  # Exercise all recall/send-out branches from the real Essentials battle file.
  load File.join(root, 'upstream/pokemon-essentials/Data/Scripts/011_Battle/001_Battle/005_Battle_ActionSwitching.rb')
  battle = Battle.allocate
  battle.define_singleton_method(:pbDisplayBrief) { |message| @wording_message = message }
  battle.define_singleton_method(:wording_message) { @wording_message }
  battle.define_singleton_method(:pbGetOwnerName) { |_| 'Alice' }
  battler_type = Struct.new(:name, :hp, :totalhp, :turnCount, :index, :owned) do
    def pbOwnedByPlayer?; owned; end
  end
  [[10, 0], [40, 0], [100, 6], [100, 3], [100, 0]].each do |hp, turns|
    battle.pbMessageOnRecall(battler_type.new('Zekrom', hp, 100, turns, 0, true))
    actual = battle.wording_message
    assert_wording(actual.include?('Zekrom') && actual.downcase.include?('reviens'), 'Actual recall branch uses singular familiar address')
    assert_wording(!actual.match?(/éteignez|Revenez|commande/), 'No literal machine translation in actual recall branch')
  end
  battle.pbMessageOnRecall(battler_type.new('Dialga', 100, 100, 0, 1, false))
  assert_wording(battle.wording_message == 'Alice retire Dialga !', 'Actual enemy recall keeps name and present tense')
  opposing = Struct.new(:hp, :totalhp) { def fainted?; hp <= 0; end }.new(100, 100)
  actor = Struct.new(:opposing) { def pbDirectOpposing; opposing; end }.new(opposing)
  battle.instance_variable_set(:@battlers, [actor])
  battle.define_singleton_method(:pbParty) { |_| [Struct.new(:name, :ability).new('Zekrom', nil)] }
  battle.define_singleton_method(:pbOwnedByPlayer?) { |_| true }
  [100, 60, 30, 10].each do |hp|
    opposing.hp = hp
    battle.pbMessagesOnReplace(0, 0)
    assert_wording(battle.wording_message.include?('Zekrom') && !battle.wording_message.match?(/commande|Allez-y|Tenez|Attrapez/), 'Actual send-out branch addresses Pokemon naturally')
  end
  assert_wording(_INTL('{1} was poisoned!', 'Zekrom') == 'Zekrom est empoisonné !', 'Immediate status narration present tense')
  assert_wording(_INTL('{1} restored a little HP using its {2}!', 'Zekrom', 'Restes') == 'Zekrom récupère quelques PV grâce à Restes !', 'Healing uses PV and present tense')
  plugin = File.read(File.join(root, 'game-mod/Plugins/ArenaDemo/090_FrenchBattleWording.rb'), encoding: 'UTF-8')
  table = plugin.split("<<~'TRANSLATIONS'", 2).last.split(/^TRANSLATIONS$/, 2).first
  table.lines.grep(/ \|\|\| /).each do |row|
    english, french = row.strip.split(' ||| ', 2)
    assert_wording(english.scan(/\{\d+\}/).sort == french.scan(/\{\d+\}/).sort, "Placeholder preservation: #{english}")
  end
end
puts "#{$wording_checks} French battle/map wording checks passed; no shared runtime files changed."
