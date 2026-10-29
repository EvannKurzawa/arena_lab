require 'minitest/autorun'
module EventHandlers
  def self.add(*); end
end
class Scene_Map; end
class ArenaRemotePokemon
  attr_accessor :x, :y, :move_speed
  def initialize(*); end
  def moveto(x, y); @x, @y = x, y; end
  def moving?; false; end
  def update; end
  def move_generic(direction)
    dx, dy = ArenaDemo::VisibleWild::DIRECTIONS[direction]
    @x += dx; @y += dy
  end
end
class PokemonIconSprite
  def initialize(*); end
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end
end
class PokemonEncounters
  def encounter_triggered?(*); :original; end
end
module ArenaDemo
  TOWN_MAP_ID = 101
  VILLAGE_ENCOUNTERS = [[50, :RATTATA, 3, 5], [30, :CATERPIE, 3, 4], [20, :SPEAROW, 4, 6]]
  def self.multiplayer?; !!$online; end
  module Visits
    def self.now; $clock; end
  end
  module FollowingIntegration
    def self.descriptor(*); {}; end
    def self.charset_for(*); ''; end
  end
end
module WildBattle
  def self.start(pokemon); $battled = pokemon; end
end
def pbGenerateWildPokemon(species, level); Struct.new(:species, :level).new(species, level); end
require_relative '../Plugins/ArenaDemo/014_VisibleWildPokemon'

class VisibleWildTest < Minitest::Test
  Player = Struct.new(:x, :y, :direction) do
    def moving?; false; end
  end
  class Map
    def map_id; 101; end
    def width; 8; end
    def height; 6; end
    def terrain_tag(x, y); Struct.new(:land_wild_encounters).new(x < 7); end
    def passableStrict?(*); true; end
    def events; {}; end
  end
  def setup
    $online = false; $clock = 0; $battled = nil
    $scene = Scene_Map.new
    $game_map = Map.new
    $game_temp = Struct.new(:in_battle, :in_menu).new(false, false)
    $game_player = Player.new(7, 5, 4)
    $player = Struct.new(:able_pokemon_count).new(1)
    @wild = ArenaDemo::VisibleWild
    set = Struct.new(:map).new($game_map)
    def set.addUserSprite(*); end
    @wild.context(set, Object.new)
  end
  def teardown; @wild.clear; $online = false; end

  def test_density_scales_and_is_capped
    assert_equal [0, 1, 1, 2, 4], [0, 1, 24, 42, 500].map { |count| @wild.target_count(count) }
  end

  def test_spawns_and_random_movement_stay_on_grass_without_overlaps
    20.times do
      @wild.update
      $clock += 2
      positions = @wild.entries.map { |entry| [entry[:character].x, entry[:character].y] }
      assert positions.all? { |x, y| x.between?(0, 6) && y.between?(0, 5) }
      assert_equal positions.uniq, positions
    end
    assert_equal 2, @wild.entries.length
  end

  def test_contact_starts_essentials_battle_with_the_visible_pokemon_and_cooldown
    @wild.update
    entry = @wild.entries.first
    $game_player.x, $game_player.y = entry[:character].x, entry[:character].y
    @wild.update
    assert_same entry[:pokemon], $battled
    assert_empty @wild.entries
    @wild.update
    assert_empty @wild.entries
  end

  def test_online_clears_transient_spawns_and_other_encounters_are_unchanged
    @wild.update
    sprite = @wild.entries.first[:sprite]
    assert_equal false, PokemonEncounters.new.encounter_triggered?(:Land)
    $online = true
    @wild.update
    assert_empty @wild.entries
    assert sprite.disposed?
    assert_equal :original, PokemonEncounters.new.encounter_triggered?(:Land)
  end

  def test_pause_menu_blocks_contact_battles
    @wild.update
    entry = @wild.entries.first
    $game_player.x, $game_player.y = entry[:character].x, entry[:character].y
    $game_temp.in_menu = true
    @wild.update
    assert_nil $battled
  end

  def test_confirm_facing_a_spawn_requests_the_same_battle
    @wild.update
    entry = @wild.entries.first
    $game_player.x = entry[:character].x + 1
    $game_player.y = entry[:character].y
    $game_player.direction = 4
    @wild.interact
    @wild.update
    assert_same entry[:pokemon], $battled
  end

  def test_expired_spawns_despawn_without_an_immediate_replacement
    @wild.update
    sprite = @wild.entries.first[:sprite]
    $clock = 61
    @wild.update
    assert sprite.disposed?
    assert_empty @wild.entries
  end

  def test_weighted_rolls_keep_species_and_levels_in_the_existing_table
    30.times do
      species, level = @wild.roll_encounter
      row = ArenaDemo::VILLAGE_ENCOUNTERS.find { |entry| entry[1] == species }
      assert row
      assert level.between?(row[2], row[3])
    end
  end
end
