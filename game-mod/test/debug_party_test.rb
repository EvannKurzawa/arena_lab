require 'minitest/autorun'
module EventHandlers
  def self.add(*); end
end
class PokemonGlobalMetadata; end
class Pokemon
  attr_reader :species, :level, :moves
  attr_accessor :form, :item, :name
  def initialize(species, level, _owner = nil); @species, @level, @moves, @form = species, level, [:TACKLE], 0; end
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
module ArenaDemo::DarkLugia
  def self.register; true; end
  def self.make(level)
    pokemon = Pokemon.new(:LUGIA, level)
    pokemon.form = 1
    pokemon.name = 'Dark Lugia'
    pokemon
  end
end

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
    assert_equal [:KYUREM, :LUGIA, :ZEKROM, :LUGIA, :GIRATINA, :MEW], $player.party.map(&:species)
    assert_equal [1, 1, 0, 0, 1, 0], $player.party.map(&:form)
    assert_equal [100] * 6, $player.party.map(&:level)
    assert_equal :GRISEOUSORB, $player.party[4].item
    assert_equal [:MEW, 100, [:CUT, :SURF, :ROCKSMASH, :STRENGTH]],
      $player.party.last.then { |p| [p.species, p.level, p.moves] }
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
    assert_equal 6, $player.party.length
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
    assert_equal :KYUREM, $player.party.first.species
    assert_equal 6, $player.party.length
  end

  def test_upgrade_preserves_both_original_and_immediately_previous_party
    original = [Object.new]
    previous = $player.party
    $PokemonGlobal.arena_debug_party_version = 1
    $PokemonGlobal.arena_debug_party_backup = original
    assert ArenaDemo::DebugParty.apply
    assert_same original, $PokemonGlobal.arena_debug_party_backup
    assert_equal previous, $PokemonGlobal.arena_debug_party_backups[2]
  end

  def test_missing_dark_lugia_leaves_party_and_save_untouched
    previous = $player.party
    ArenaDemo::DarkLugia.stub(:register, false) do
      assert_raises(RuntimeError) { ArenaDemo::DebugParty.apply }
    end
    assert_same previous, $player.party
    assert_equal 0, $save_calls
    assert_nil $PokemonGlobal.arena_debug_party_version
  end
end
