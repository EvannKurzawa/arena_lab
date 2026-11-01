require_relative 'arena_relief_test'
require_relative '../tools/furniture_preview'

class FurnitureCatalogTest < Minitest::Test
  class Bag
    attr_accessor :blocked
    def initialize; @items = Hash.new(0); end
    def has?(item); @items[item] > 0; end
    def quantity(item); @items[item]; end
    def add(item, count = 1)
      return false if blocked
      @items[item] += count
      true
    end
    def remove(item, count = 1)
      return false if @items[item] < count
      @items[item] -= count
      true
    end
  end
  def setup
    ArenaDemo::Visits.instance_variables.each { |key| ArenaDemo::Visits.remove_instance_variable(key) }
    ArenaDemo::Visits.reset
    $PokemonGlobal = PokemonGlobalMetadata.new
    $PokemonGlobal.arena_demo_void_recovery_version = 1
    $bag = Bag.new
    $game_player = Struct.new(:x, :y).new(49, 53)
    $game_map = Game_Map.new
    @game = File.expand_path('../../tools/runtime/essentials-v21.1-base', __dir__)
    game = @game
    Object.send(:define_method, :pbResolveBitmap) do |path|
      candidate = File.join(game, path + '.png')
      File.file?(candidate) ? candidate : nil
    end
  end
  def stock
    ArenaDemo.stub(:ensure_bag_pockets, nil) { ArenaDemo.ensure_custom_inventory }
  end
  def test_catalogue_extends_without_replacing_existing_obstacles
    assert_equal 20, ArenaDemo::BASIC_FURNITURE.length
    %i[ARENA_FURNITURE_BOULDER ARENA_FURNITURE_ROCK ARENA_FURNITURE_TREE].each { |item| assert ArenaDemo::FURNITURE_STOCK.key?(item) }
    ArenaDemo::BASIC_FURNITURE.each_key { |item| assert_match(/\A[A-Z0-9_]{1,48}\z/, item.to_s) }
  end
  def test_fresh_and_old_saves_receive_two_copies_only_once
    [false, true].each do |old_save|
      $PokemonGlobal = PokemonGlobalMetadata.new
      $PokemonGlobal.arena_custom_stock_added = old_save
      $bag = Bag.new
      stock
      assert $PokemonGlobal.arena_basic_furniture_stock_added
      ArenaDemo::BASIC_FURNITURE.each_key { |item| assert_equal 2, $bag.quantity(item) }
      stock
      ArenaDemo::BASIC_FURNITURE.each_key { |item| assert_equal 2, $bag.quantity(item) }
      item = ArenaDemo::BASIC_FURNITURE.keys.first
      $bag.remove(item, 2)
      stock
      assert_equal 0, $bag.quantity(item), 'A used grant must not refill on reopening'
    end
  end
  def test_partial_grant_and_placed_copies_are_not_duplicated
    $PokemonGlobal.arena_custom_stock_added = true
    item = ArenaDemo::BASIC_FURNITURE.keys.first
    $bag.add(item, 1)
    $PokemonGlobal.arena_demo_placements = [{ 'kind' => 'furniture', 'item' => item, 'x' => 40, 'y' => 40 }]
    $bag.blocked = true
    stock
    refute $PokemonGlobal.arena_basic_furniture_stock_added
    $bag.blocked = false
    stock
    assert $PokemonGlobal.arena_basic_furniture_stock_added
    assert_equal 1, $bag.quantity(item)
  end
  def test_twenty_objects_place_and_round_trip_through_visit_snapshot
    stock
    placements = $PokemonGlobal.arena_demo_placements = []
    ArenaDemo.stub(:ensure_bag_pockets, nil) do
      ArenaDemo.stub(:refresh_custom_placements, nil) do
        ArenaDemo::BASIC_FURNITURE.each_key.with_index do |item, i|
          ArenaDemo.editor_apply_placement(placements, ArenaDemo.tile_edit_records, 'furniture', { item: item }, 40 + i % 5, 44 + i / 5)
        end
      end
      assert_equal 20, placements.length
      payload = ArenaDemo.visit_snapshot_payload
      restored = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
      assert_equal placements, restored[:placements]
      assert_equal placements, Marshal.load(Marshal.dump(placements))
    end
  end
  def test_all_art_is_visible_single_cell_and_cached
    ArenaDemo::BASIC_FURNITURE.each_key do |item|
      art = ArenaDemo.furniture_bitmap(item)
      assert_equal [32, 64], [art.width, art.height]
      assert (0...64).any? { |y| (0...32).any? { |x| art.get_pixel(x, y).alpha > 0 } }, item.to_s
      assert_same art, ArenaDemo.furniture_bitmap(item)
      preview = ArenaDemo.furniture_catalog_preview(item: item)
      assert_equal [96, 96], [preview.width, preview.height]
      assert_same preview, ArenaDemo.furniture_catalog_preview(item: item)
    end
    removal = { action: :remove }
    assert_same ArenaDemo.furniture_catalog_preview(removal), ArenaDemo.furniture_catalog_preview(removal)
  end
  def test_visual_selector_retains_item_quantity_and_remove_action
    item = ArenaDemo::BASIC_FURNITURE.keys.first
    entries = [{ item: item, name: 'Chaise bleue', qty: 2 }, { action: :remove, name: 'Remove furniture', qty: '' }]
    received = nil
    ArenaDemo.stub(:choose_material_catalog, proc { |options, _title| received = options; options.first }) do
      chosen = ArenaDemo.choose_catalog(entries, 'Choose furniture you own')
      assert_equal item, chosen[:item]
      assert_equal 2, chosen[:qty]
    end
    assert received.all? { |row| row[:furniture_catalog] }
    assert_equal :remove, received.last[:action]
    refute entries.first.key?(:furniture_catalog), 'Browsing must not mutate the caller entries'
  end
end
