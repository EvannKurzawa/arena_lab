require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../Plugins/ArenaDemo/015_ExpeditionLayout'

module EventHandlers
  def self.add(*); end
end
module MenuHandlers
  def self.add(*); end
end
module ArenaDemo
  TOWN_MAP_ID = 101
  def self.multiplayer?; !!$online; end
  def self.prepare_village_return; $prepared_return = true; end
  def self.reset_saved_player_movement; $reset_movement = true; end
  def self.transfer_to(*destination)
    raise 'transfer failed' if $fail_transfer
    $transfers << destination
    $game_map.map_id = destination[0]
  end
end
class Table
  def initialize(*); @tiles = {}; end
  def []=(*args); value = args.pop; @tiles[args] = value; end
  def [](*args); @tiles[args] || 0; end
end
module RPG
  class Event
    attr_accessor :id, :name
    attr_reader :x, :y, :pages
    Page = Struct.new(:graphic, :through, :trigger, :direction_fix, :list)
    Graphic = Struct.new(:character_name)
    def initialize(x, y)
      @x, @y, @pages = x, y, [Page.new(Graphic.new)]
    end
  end
  EventCommand = Struct.new(:code, :indent, :parameters)
end
module GameData
  module Species
    class << self; attr_accessor :entries; end
    def self.each(&block); entries.each(&block); end
  end
  module TerrainTag
    def self.get(value); value; end
  end
end
def pbResolveBitmap(*); true; end
def load_data(*)
  { 'ground' => [401, 0, 0], 'path' => [403, 0, 0], 'grass' => [402, 0, 0] }
end
def pbConfirmMessage(*); $confirm; end
def pbMessage(*); end
require_relative '../Plugins/ArenaDemo/016_ExpeditionWorld'
module SaveData
  FILE_PATH = 'unused-expedition-test-save.rxdata'
end
require_relative '../Plugins/ArenaDemo/018_ExpeditionLimits'

class ExpeditionWorldTest < Minitest::Test
  Layout = ArenaDemo::ExpeditionLayout
  World = ArenaDemo::Expeditions
  DataMap = Struct.new(:width, :height, :data, :events)
  class Map
    attr_accessor :map_id
    def initialize(id); @map_id = id; end
    def setup(id)
      @map_id = id
      @map = DataMap.new
      ArenaDemo::Expeditions.prepare(id, @map, nil)
    end
    def passable?(*); true; end
    def passableStrict?(*); true; end
    def terrain_tag(*); :original; end
    prepend ArenaDemo::ExpeditionCollision
  end
  Player = Struct.new(:x, :y, :direction) do
    def moveto(x, y); self.x, self.y = x, y; end
    def center(*); end
  end
  Species = Struct.new(:id, :form, :generation, :types, :habitat, :base_stat_total, :flags) do
    def has_flag?(flag); flags.include?(flag); end
  end
  def setup
    @ledger_directory = Dir.mktmpdir('arena-outing-world-', File.expand_path('../..', __dir__))
    SaveData.send(:remove_const, :FILE_PATH)
    SaveData.const_set(:FILE_PATH, File.join(@ledger_directory, 'Game.rxdata'))
    $PokemonGlobal = PokemonGlobalMetadata.new
    self.class.const_set(:BASE_PLAN, Layout.build(42)) unless self.class.const_defined?(:BASE_PLAN)
    $PokemonGlobal.arena_expedition = Marshal.load(Marshal.dump(self.class::BASE_PLAN))
    $online = false
    $confirm = true
    $fail_transfer = false
    $transfers = []
    $game_map = Map.new(101)
    $player = Struct.new(:able_pokemon_count).new(1)
    $game_player = Player.new(32, 56, 8)
    World.instance_variable_set(:@pools, nil)
    GameData::Species.entries = []
  end
  def teardown; FileUtils.remove_entry(@ledger_directory); end

  def test_fixed_rarities_cover_exactly_one_hundred_outcomes
    assert_equal 100, Layout::BIOMES.values.sum { |data| data[1] }
    counts = (0...100).map { |n| Layout.biome_at_roll(n) }.tally
    assert_equal Layout::BIOMES.transform_values { |data| data[1] }, counts
    assert_raises(ArgumentError) { Layout.biome_at_roll(-1) }
    assert_raises(ArgumentError) { Layout.biome_at_roll(100) }
  end

  def test_seeded_world_roundtrips_in_save_and_seeds_change_layout
    first = Layout.build(123)
    assert_equal first, Layout.build(123)
    assert_equal first, Marshal.load(Marshal.dump(first))
    refute_equal first['regions'], Layout.build(456)['regions']
    assert_equal 'grassland', first['regions'][Layout::HOME]['biome']
    assert_equal 16, first['regions'].length
  end

  def test_all_exits_and_encounter_tiles_are_reachable_across_many_worlds
    8.times do |seed|
      Layout.build(seed)['regions'].each_with_index do |region, i|
        cells = region['cells']
        occupied = region['decorations'].to_h { |x, y, _| [y * 64 + x, true] }
        seen = Layout.reachable_cells(cells, occupied)
        assert cells.count('g') > 0, "No encounter grass: #{seed}/#{i}"
        assert cells.bytes.each_with_index.all? { |code, pos| code != 103 || seen[pos] }, "Unreachable grass: #{seed}/#{i}"
        [2, 4, 6, 8].each do |direction|
          neighbor = Layout.neighbor(i, direction)
          x = direction == 4 ? 0 : (direction == 6 ? 63 : 32)
          y = direction == 8 ? 0 : (direction == 2 ? 63 : 32)
          if neighbor
            assert seen[y * 64 + x], "Disconnected exit: #{seed}/#{i}/#{direction}"
            assert_equal i, Layout.neighbor(neighbor, 10 - direction)
          else
            assert_equal 'o'.ord, cells.getbyte(y * 64 + x)
          end
        end
        assert region['decorations'].all? { |x, y, _| cells.getbyte(y * 64 + x) == 'b'.ord }
      end
    end
  end

  def test_departure_is_the_only_action_that_replaces_the_world
    original = World.state
    $confirm = false
    World.depart
    assert_same original, World.state
    $confirm = true
    $online = true
    World.depart
    assert_same original, World.state
    $online = false
    World.depart
    refute_same original, World.state
    refute_equal original['seed'], World.state['seed']
    assert_equal [123, 32, 56, 8], $transfers.last
    expedition = World.state
    $game_player.x, $game_player.y = 32, 0
    World.portal(8)
    assert_equal [119, 32, 62, 8], $transfers.last
    assert_same expedition, World.state
    World.return_home
    assert_equal [101, 16, 20, 8], $transfers.last
    refute World.active?
    World.depart
    refute_same expedition, World.state
  end

  def test_biome_features_survive_smoothing_and_roads
    Layout::BIOMES.each_key do |biome|
      region = Layout.build_region(biome, Layout::RNG.new(42), 5)
      assert_equal 2, region['style']
      assert region['cells'].bytes.all? { |byte| 'abgpvowl'.bytes.include?(byte) }
      assert region['cells'].count('g') > 0, "Missing encounter grass in #{biome}"
      assert region['cells'].count('w') > 100 if ['lake', 'coast', 'swamp'].include?(biome)
      assert region['cells'].count('l') > 100 if biome == 'volcano'
      assert region['decorations'].length > 60 if ['forest', 'bamboo'].include?(biome)
    end
  end

  def test_failed_transfer_rolls_back_new_expedition
    original = World.state
    $fail_transfer = true
    assert_raises(RuntimeError) { World.depart }
    assert_same original, World.state
    assert_equal 3, ArenaDemo::Outings.ledger.free_remaining(Time.now.to_f)
  end

  def test_map_setup_preserves_shared_template_and_creates_runtime_events
    original = DataMap.new(1, 1, :original, {})
    World.prepare(123, original, nil)
    assert_equal [64, 64], [original.width, original.height]
    assert_equal [403, 0, 0], 3.times.map { |z| original.data[32, 32, z] }
    assert_equal 'Village return guide', original.events[20].name
    assert original.events[900].pages.first.through
    portals = original.events.values.select { |event| event.name == 'Wilderness crossing' }
    assert_equal 9, portals.length # Home is on the south edge; west/east/north.
    assert portals.all? { |event| event.pages.first.trigger == 1 && event.pages.first.through }
    assert portals.all? { |event| event.pages.first.list.first.code == 355 }
    assert World.state['regions'][13].keys.none? { |key| key == 'map' }
  end

  def test_hazards_block_movement_and_surface_tags_match_the_layout
    $game_map.setup(123)
    data = World.data_for($game_map)
    blocked = data['cells'].bytes.index { |code| Layout.blocked?(code) }
    x, y = blocked % 64, blocked / 64
    refute $game_map.passable?(x + 1, y, 4)
    refute $game_map.passableStrict?(x, y, 2)
    assert $game_map.passableStrict?(32, 32, 2)
    grass = data['cells'].bytes.index(103)
    assert_equal :Grass, $game_map.terrain_tag(grass % 64, grass / 64)
    assert_equal :None, $game_map.terrain_tag(32, 32)
  end

  def test_loading_outside_retains_seed_layout_and_position
    $game_map.setup(123)
    $game_player.x, $game_player.y = 32, 56
    before = Marshal.dump(World.state)
    World.recover_loaded_map
    assert_equal before, Marshal.dump(World.state)
    assert_equal [32, 56, 8], $game_player.to_a
    assert $reset_movement
  end

  def test_crossings_land_in_connected_interior_for_every_lane_and_biome
    ['snow', 'volcano', 'canyon', 'crystal'].each do |biome|
      data = Layout.build_region(biome, Layout::RNG.new(42), 5)
      World.state['regions'][5] = data
      occupied = data['decorations'].to_h { |x, y, _| [y * 64 + x, true] }
      reachable = Layout.reachable_cells(data['cells'], occupied)
      [2, 4, 6, 8].each do |direction|
        source = Layout.neighbor(5, 10 - direction)
        (-1..1).each do |lane|
          $game_map.map_id = Layout::FIRST_MAP + source
          $game_player.x = [4, 6].include?(direction) ? (direction == 4 ? 0 : 63) : 32 + lane
          $game_player.y = [2, 8].include?(direction) ? (direction == 8 ? 0 : 63) : 32 + lane
          World.portal(direction)
          map, x, y, facing = $transfers.last
          assert_equal [115, direction], [map, facing]
          assert x.between?(1, 62) && y.between?(1, 62)
          assert reachable[y * 64 + x], "Unsafe #{biome}/#{direction}/#{lane}"
          refute occupied[y * 64 + x]
          assert_equal [x, y], World.landing_position(data, x, y)
        end
      end
    end
  end

  def test_load_recovers_blocked_and_isolated_saved_positions_without_changing_layout
    data = World.region(123)
    data['cells'] = 'o' * (64 * 64)
    (30..34).each { |y| (30..34).each { |x| data['cells'].setbyte(y * 64 + x, 112) } }
    data['cells'].setbyte(10 * 64 + 10, 98) # dry but isolated
    data['decorations'] = [[32, 31, 'Object boulder']]
    World.assign_region_species(World.state, 13)
    before = Marshal.dump(World.state)
    [[1, 32], [10, 10], [32, 31]].each do |x, y|
      $game_player.x, $game_player.y = x, y
      $game_map.map_id = 123
      World.recover_loaded_map
      assert $game_player.x.between?(30, 34) && $game_player.y.between?(30, 34)
      refute_equal [32, 31], [$game_player.x, $game_player.y]
      assert_equal before, Marshal.dump(World.state)
    end
  end

  def test_species_pool_filters_generation_forms_habitat_and_special_species
    GameData::Species.entries = [
      Species.new(:CHARMANDER, 0, 1, [:FIRE], :Mountain, 309, []),
      Species.new(:ROGGENROLA, 0, 5, [:ROCK], :Cave, 280, []),
      Species.new(:ROLYCOLY, 0, 8, [:ROCK], :Cave, 240, []),
      Species.new(:FIRE_GEN6, 0, 6, [:FIRE], :Mountain, 300, []),
      Species.new(:FIRE_GEN7, 0, 7, [:FIRE], :Mountain, 300, []),
      Species.new(:FIRE_GEN8, 0, 8, [:FIRE], :Mountain, 300, []),
      Species.new(:PIKACHU, 0, 1, [:ELECTRIC], :Forest, 320, []),
      Species.new(:FUTURE_FIRE, 0, 9, [:FIRE], :Mountain, 300, []),
      Species.new(:FORM_FIRE, 1, 8, [:FIRE], :Mountain, 300, []),
      Species.new(:LEGEND, 0, 2, [:FIRE], :Rare, 600, ['Legendary']),
      Species.new(:SEA_FIRE, 0, 8, [:FIRE], :Sea, 300, [])
    ]
    pool = World.encounter_pool('volcano')
    assert_equal [[48, :CHARMANDER], [12, :ROGGENROLA]], pool
    $PokemonGlobal.arena_expedition['regions'][13]['biome'] = 'volcano'
    $game_map.setup(123)
    30.times do
      species, level = World.encounter($game_map)
      assert_includes [:CHARMANDER, :ROGGENROLA], species
      assert level.between?(3, 7)
    end
  end
end
