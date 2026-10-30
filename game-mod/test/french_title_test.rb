# Standalone regression checks using Essentials' actual translation loader.
def assert(value, label)
  raise label unless value
  puts "PASS: #{label}"
end
def load_data(path); Marshal.load(File.binread(path)); end
def nil_or_empty?(value); value.nil? || value.empty?; end
load File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/001_Technical/003_Intl_Messages.rb', __dir__)
def pbMessage(message, commands = nil, *args); $last_french_dialog = [message, commands, args]; end
def pbDrawTextPositions(bitmap, rows); rows; end
def pbDrawShadowText(*args); args; end
def pbMessageDisplay(window, message, *args); message; end
def pbShowCommands(window, commands, *args); commands; end
module GameData
  class Ability
    def initialize(name); @real_name = name; end
    def name; @real_name; end
    def description; ''; end
  end
end
%w[021_French 023_FrenchFollowers 024_FrenchNetwork 025_FrenchEngineMessages 026_FrenchCoreReview].each do |name|
  path = File.expand_path("../Plugins/ArenaDemo/#{name}.rb", __dir__)
  code = File.binread(path).force_encoding(Encoding::UTF_8).gsub("\t", '  ')
  eval(code, TOPLEVEL_BINDING, path)
end
source = File.expand_path('../../tools/runtime/essentials-v21.1-base', __dir__)
Dir.chdir(source) do
  MessageTypes.load_message_files('french')
  assert(pbGetMessageFromHash(1, 'Bulbasaur') == 'Bulbizarre', 'French species names')
  assert(pbGetMessageFromHash(1, 'Charmander') == 'Salamèche', 'UTF-8 accents')
  assert(pbGetMessageFromHash(5, 'Tackle') == 'Charge', 'French move names')
  assert(_INTL('New Game') != 'New Game', 'native load menu translated')
  assert(GameData::Ability.new('Teravolt').name == 'Téra-Voltage', 'actual ability accessor localized')
  assert(GameData::Ability.new('Pressure').name == 'Pression', 'Pressure ability localized')
  assert(_INTL('{1} used {2}!', 'Zekrom', 'Charge') == 'Zekrom utilise Charge !', 'move narration uses present tense')
  assert(_INTL("{1}'s", 'Zekrom') == 'Talent de Zekrom', 'ability splash has French possessive wording')
  assert(_INTL('You got away safely!') == 'Vous avez pris la fuite !', 'escape wording')
  item_key = "You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket."
  stored = _INTL(item_key, 'Poké Balls', 3, 'Poké Balls')
  assert(stored.start_with?('Vous rangez Poké Balls') && !stored.include?("Sac's"), 'real inventory key keeps native lookup and French grammar')
  assert(_INTL('Graphics/UI/Bag/icon_register') == 'Graphics/UI/Bag/icon_register', 'asset IDs never translated')
  enemy = _INTL('The opposing {1}', 'Galopa')
  wild = _INTL('The wild {1}', 'Galopa')
  assert(_INTL('{1} fainted!', enemy) == 'Le Galopa ennemi est K.O. !', 'enemy grammar')
  assert(_INTL('{1} fainted!', wild) == 'Le Galopa sauvage est K.O. !', 'wild grammar')
  assert(File.binread('Audio/BGM/Arena Title.mp3').bytesize > 100_000, 'MP3 installed')
  assert(File.binread('Graphics/Titles/arena_title.png', 8) == "\x89PNG\r\n\x1a\n".b, 'title PNG installed')
end
f = ArenaDemo::French
assert(pbMessage('Arena', ['Add an object', 'Cancel'])[0..1] == ['Arène', ['Ajouter un objet', 'Annuler']], 'dialog and choice translation')
assert(f.text("Status: Offline\nYour arena is closed to visitors.") == "État : Hors ligne\nVotre arène est fermée aux visiteurs.", 'dynamic status and detail')
assert(f.text('Outing: 12:34') == 'Expédition : 12:34', 'timer preserves numbers')
assert(f.text("3/3 free outings available (24 hours).\nLeave on a new 20-minute expedition? Returning home ends this outing.").include?('3/3 expéditions gratuites'), 'nested departure allowance')
assert(_INTL('{1} wants to battle! Accept?', 'Alice') == 'Alice souhaite vous affronter ! Accepter ?', 'multiplayer placeholders')
assert(Kernel.pbMessageDisplay(nil, 'Welcome to your arena. What would you like to do?') == 'Bienvenue dans votre arène. Que souhaitez-vous faire ?', 'guide text through Kernel message display')
assert(Kernel.pbShowCommands(nil, ['Host online', 'Find an arena to visit', 'Back']) == ['Héberger en ligne', 'Trouver une arène à visiter', 'Retour'], 'entrance choices through Kernel')
assert(_INTL('{1} started spinning around in circles.', 'Zekrom') == 'Zekrom se met à tourner en rond.', 'follower spinning dialogue')
assert(MessageTypes.getFromHash(MessageTypes::SCRIPT_TEXTS, '{1} is singing and humming.') == '{1} chante et fredonne.', 'native follower lookup without display hooks')
reception_source = File.read(File.expand_path('../Plugins/ArenaDemo/009_ArenaCustomMode.rb', __dir__))
eval(reception_source[/module ArenaDemo::CustomModeReception\n.*?^end/m], TOPLEVEL_BINDING)
def ArenaDemo.ensure_custom_inventory; end
guide = Object.new.extend(ArenaDemo::CustomModeReception)
def guide.multiplayer?; false; end
guide.arena_reception
assert($last_french_dialog[0] == 'Bienvenue dans votre arène. Que souhaitez-vous faire ?', 'actual arena guide method speaks French')
assert($last_french_dialog[1] == ['Personnalisation', 'Recruter un Dresseur', 'Soigner mon équipe', 'Retour'], 'actual arena guide choices are French')
puts 'French title integration checks passed.'

# Exercise the real title plugin against the Essentials scene's public API.
class EventScene
  def dispose; @disposed = true; end
end
load File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/016_UI/001_Non-interactive UI/001_UI_SplashesAndTitleScreen.rb', __dir__)
class TitlePicture
  attr_accessor :name
  def method_missing(*); end
  def running?; false; end
end
class TitleCallbacks
  def clear; end
  def set(*); end
end
module Graphics
  def self.width; 512; end
  def self.height; 384; end
end
module Input
  DOWN = 1
  BACK = 2
  CTRL = 3
  def self.press?(*); false; end
end
class Bitmap
  attr_reader :font, :width, :height, :labels, :draw_calls
  def initialize(width, height); @width, @height = width, height; @font = Struct.new(:size).new; @labels = []; @draw_calls = []; end
  def fill_rect(*); end
  def draw_text(*args); @labels << args[4]; @draw_calls << args; end
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end
  def text_offset_y; 6; end
end
class Color
  def initialize(*); end
end
def pbSetSystemFont(*); end
def pbBGMPlay(track); $title_track = track; end
def pbBGMStop(*); end
class IntroEventScene
  def onUpdate; @callbacks ||= TitleCallbacks.new; end
  def onCTrigger; @callbacks ||= TitleCallbacks.new; end
  def addBitmap(*); TitlePicture.new; end
  def pictureWait; end
end
load File.expand_path('../Plugins/ArenaDemo/020_FrenchTitle.rb', __dir__)
Dir.chdir(source) do
  scene = IntroEventScene.allocate
  scene.instance_variable_set(:@pic, TitlePicture.new)
  scene.instance_variable_set(:@pic2, TitlePicture.new)
  scene.open_title_screen(scene)
  assert($title_track == 'Arena Title', 'custom title plays requested MP3')
  assert(scene.instance_variable_get(:@pic).name == 'Graphics/Titles/arena_title', 'custom title selects user image')
  assert(scene.instance_variable_get(:@arena_prompt_bitmap).labels.include?('APPUYEZ SUR ENTRÉE OU ESPACE'), 'French start prompt drawn')
  prompt = scene.instance_variable_get(:@arena_prompt_bitmap)
  assert(prompt.draw_calls[0][1] == prompt.text_offset_y && prompt.draw_calls[0][3] == 44, 'prompt compensates native baseline offset inside full panel height')
  scene.open_splash(scene)
  assert(scene.instance_variable_get(:@pic).name == 'Graphics/Titles/arena_title', 'stock splash entry opens artwork directly')
  scene.title_screen_update(scene, nil)
  scene.fade_out_title_screen(scene)
  assert(scene.instance_variable_get(:@arena_prompt_bitmap).disposed?, 'title prompt disposed after fade')
  $DEBUG = true
  assert(pbCallTitle.is_a?(Scene_Intro), 'real title entry overrides debug bypass')
  assert(Kernel.pbCallTitle.is_a?(Scene_Intro), 'Kernel title entry also shows artwork')
  $DEBUG = false
end

class Battle
  class Scene
    class CommandMenu
      BUTTON_HEIGHT = 46
      def initialize(*)
        @buttons = Array.new(4) { Struct.new(:bitmap).new }
        @buttonBitmap = Bitmap.new(260, 460)
      end
      def refresh; end
      def dispose; @buttonBitmap.dispose; end
    end
  end
end
load File.expand_path('../Plugins/ArenaDemo/022_FrenchBattleMenu.rb', __dir__)
menu = Battle::Scene::CommandMenu.new
buttons = menu.instance_variable_get(:@buttons)
assert(buttons.all? { |button| button.bitmap.nil? }, 'original battle button code retained without redraw')
