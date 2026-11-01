require 'minitest/autorun'
module EventHandlers
  def self.add(*); end
end
class PokemonGlobalMetadata; end
class Pokemon
  attr_reader :species, :level, :moves
  def initialize(species, level, _owner); @species, @level, @moves = species, level, [:TACKLE]; end
  def learn_move(move); @moves << move; end
  def heal; @healed = true; end
end
module Game
  def self.save; $save_calls += 1; $save_ok; end
end
class Scene_Map; end
module System
  def self.uptime; 0; end
end
def pbMapInterpreterRunning?; false; end
require_relative '../Plugins/ArenaDemo/038_DebugParty'

class DebugPartyTest < Minitest::Test
  def setup
    $player = Struct.new(:party).new([Object.new, Object.new])
    $PokemonGlobal = PokemonGlobalMetadata.new
    $save_ok, $save_calls = true, 0
    ArenaDemo::DebugParty.instance_variable_set(:@retry_at, nil)
  end
  def test_replaces_party_once_and_preserves_previous_team
    old = $player.party.dup
    assert ArenaDemo::DebugParty.apply
    assert_equal 1, $player.party.length
    assert_equal [:MEW, 100, [:CUT, :SURF, :ROCKSMASH, :STRENGTH]],
      $player.party.first.then { |p| [p.species, p.level, p.moves] }
    assert_equal old, $PokemonGlobal.arena_debug_party_backup
    refute ArenaDemo::DebugParty.apply
    assert_equal 1, $save_calls
  end
  def test_save_failure_rolls_back_entire_migration
    old = $player.party
    $save_ok = false
    refute ArenaDemo::DebugParty.apply
    assert_same old, $player.party
    assert_nil $PokemonGlobal.arena_debug_party_version
    assert_nil $PokemonGlobal.arena_debug_party_backup
  end
  def test_each_profile_gets_its_own_migration
    assert ArenaDemo::DebugParty.apply
    $PokemonGlobal = PokemonGlobalMetadata.new
    $player = Struct.new(:party).new([])
    assert ArenaDemo::DebugParty.apply
    assert_equal 1, $player.party.length
    assert_equal 2, $save_calls
  end
  def test_automatic_migration_waits_for_a_safe_frame_then_saves
    $scene = Scene_Map.new
    $game_temp = Struct.new(:in_battle, :in_menu, :message_window_showing, :player_transferring).new(true, false, false, false)
    ArenaDemo::DebugParty.update
    assert_equal 0, $save_calls
    assert_equal 2, $player.party.length
    $game_temp.in_battle = false
    ArenaDemo::DebugParty.update
    assert_equal 1, $save_calls
    assert_equal :MEW, $player.party.first.species
    assert_equal 1, $player.party.length
  end
end
