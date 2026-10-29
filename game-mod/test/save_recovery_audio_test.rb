require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

module ArenaDemo
  MAP_ID = 100
  INITIAL_FIELD_X = INITIAL_FIELD_Y = 37
  INITIAL_FIELD_SIZE = 25
  MAP_WIDTH = MAP_HEIGHT = 100
  def self.map_start; [49, 53, 8]; end
  def self.tile_is_void?(x, y); [x, y] != [70, 70]; end
end
source = File.read(File.expand_path('../Plugins/ArenaDemo/009_ArenaCustomMode.rb', __dir__))
ArenaDemo.module_eval("module_function\n" + source[/  def reset_saved_player_movement\n.*?^  end/m])
ArenaDemo.module_eval("module_function\n" + source[/  def recover_player_from_void\(map\).*?^  end/m])
module RPG
  AudioFile = Struct.new(:name, :volume, :pitch)
end
class Game_Map
  attr_reader :map_id, :played
  def initialize(data); @map_id = 102; @map = data; end
  def autoplay; @played = [@map.instance_variable_get(:@autoplay_bgm), @map.instance_variable_get(:@bgm)]; end
end
require_relative '../Plugins/ArenaDemo/013_ArenaAudio'

class SaveRecoveryAudioTest < Minitest::Test
  def test_saved_forced_movement_is_cleared_before_repositioning
    $PokemonGlobal = Struct.new(:ice_sliding, :descending_waterfall, :ascending_waterfall).new(true, true, true)
    $game_player = Object.new
    $game_player.instance_variable_set(:@move_route_forcing, true)
    $game_player.instance_variable_set(:@through, true)
    $game_player.instance_variable_set(:@move_route, :repeat_left)
    ArenaDemo.reset_saved_player_movement
    assert_equal [false, false, false], $PokemonGlobal.to_a
    assert_equal false, $game_player.instance_variable_get(:@move_route_forcing)
    assert_equal false, $game_player.instance_variable_get(:@through)
    assert_nil $game_player.instance_variable_get(:@move_route)
  end

  def test_void_recovery_finds_custom_floor_outside_initial_field
    $game_player = Struct.new(:x, :y).new(12, 16)
    def $game_player.moveto(x, y); self.x, self.y = x, y; end
    map = Struct.new(:map_id).new(100)
    def map.passableStrict?(*); true; end
    ArenaDemo.recover_player_from_void(map)
    assert_equal [70, 70], [$game_player.x, $game_player.y]
  end

  def test_loaded_entrance_replaces_silent_midi_with_decoded_music
    Dir.mktmpdir('arena-playback-') do |directory|
      Dir.chdir(directory) do
        FileUtils.mkdir_p('Audio/BGM')
        FileUtils.mkdir_p('Data')
        File.write('Audio/BGM/Town.mid', '')
        File.write('Audio/BGM/Route.ogg', '')
        data = Object.new
        data.instance_variable_set(:@bgm, RPG::AudioFile.new('Town', 0, 100))
        data.instance_variable_set(:@autoplay_bgm, false)
        $PokemonSystem = Struct.new(:bgmvolume).new(60)
        map = Game_Map.new(data)
        map.autoplay
        assert_equal true, map.played[0]
        assert_equal 'Route', map.played[1].name
        assert_equal 80, map.played[1].volume
        assert_equal 60, $PokemonSystem.bgmvolume
        assert_includes File.read('Data/ArenaAudioDiagnostic.txt'), 'track="Route"'
      end
    end
  end
end
