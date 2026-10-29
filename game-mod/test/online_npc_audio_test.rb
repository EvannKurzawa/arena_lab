require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

# Exercise the production entry points with lightweight engine/asset fixtures.
module ArenaDemo
  MAP_ID = 100
  TRAINER_PROFILES = { HOST_TRAINER: { name: 'Host trainer', type: :YOUNGSTER, team: [[:PIKACHU, 20]] } }
  def self.trainer_placements; [{ 'item' => 'HOST_TRAINER' }]; end
  def self.placement_item(placement); placement['item'].to_sym; end
  def self.multiplayer?; true; end
end
source = File.read(File.expand_path('../Plugins/ArenaDemo/009_ArenaCustomMode.rb', __dir__))
ArenaDemo.module_eval("module_function\n" + source[/  def challenge_recruited_trainer\(slot\).*?(?=  def copy_tile_edits)/m])
source = File.read(File.expand_path('../Plugins/ArenaDemo/001_ArenaDemo.rb', __dir__))
ArenaDemo.module_eval("module_function\n" + source[/  def play_door_sound\n.*?^  end/m])
class NPCTrainer
  attr_accessor :party
  attr_reader :name
  def initialize(name, type); @name = name; end
end
Pokemon = Struct.new(:species, :level, :owner)
module TrainerBattle
  def self.start(foe); @foe = foe; end
  def self.foe; @foe; end
end
def pbConfirmMessage(*); true; end
def pbSEPlay(name); $played_sound = name; end
module RPG
  class AudioFile; end
end

class OnlineNpcAudioTest < Minitest::Test
  def test_connected_player_can_challenge_shared_trainer
    $game_map = Struct.new(:map_id).new(100)
    $game_temp = Struct.new(:in_battle).new(false)
    $player = Struct.new(:able_pokemon_count).new(1)
    ArenaDemo.challenge_recruited_trainer(0)
    assert_equal 'Host trainer', TrainerBattle.foe.name
    assert_equal [:PIKACHU, 20], TrainerBattle.foe.party.first.values_at(0, 1)
    assert_equal true, ArenaDemo.multiplayer?
  end

  def test_blank_template_gets_installed_music_and_door_uses_existing_sound
    Dir.mktmpdir('arena-audio-') do |directory|
      FileUtils.mkdir_p(File.join(directory, 'Audio/BGM'))
      FileUtils.mkdir_p(File.join(directory, 'Audio/SE'))
      File.binwrite(File.join(directory, 'Audio/BGM/Town.ogg'), '')
      File.binwrite(File.join(directory, 'Audio/SE/Door enter.wav'), '')
      scope = Module.new
      scope.const_set(:PROJECT, directory)
      builder = File.read(File.expand_path('../tools/build_arena_map.rb', __dir__))
      scope.module_eval(builder[/def enable_map_music\(map\).*?^end/m])
      map = Object.new
      Object.new.extend(scope).send(:enable_map_music, map)
      assert_equal true, map.instance_variable_get(:@autoplay_bgm)
      assert_equal 'Town', map.instance_variable_get(:@bgm).instance_variable_get(:@name)
      Dir.chdir(directory) { ArenaDemo.play_door_sound }
      assert_equal 'Door enter', $played_sound
    end
  end
end
