require_relative 'furniture_catalog_test'
require_relative '../Plugins/ArenaDemo/000_ArenaFurnitureRules'
require_relative '../Plugins/ArenaDemo/000_ArenaDeviceRules'
require_relative '../Plugins/ArenaDemo/092_ExtraFurniture'

class ExtraFurnitureTest < FurnitureCatalogTest
  def test_extra_stock_is_idempotent_on_existing_profiles
    $PokemonGlobal.arena_custom_stock_added = true
    stock
    assert $PokemonGlobal.arena_extra_furniture_stock_added
    assert_equal 36, ArenaDemo::EXTRA_FURNITURE.length
    ArenaDemo::EXTRA_FURNITURE.each_key { |item| assert_equal 2, $bag.quantity(item) }
    item = ArenaDemo::EXTRA_FURNITURE.keys.first
    $bag.remove(item, 2)
    stock
    assert_equal 0, $bag.quantity(item)
  end

  def test_raised_furniture_round_trip_and_restores_underlying_ground
    stock
    placements = $PokemonGlobal.arena_demo_placements = []
    records = ArenaDemo.tile_edit_records
    records['44,44'] = { 'floor' => 'field', 'ground' => 'sand', 'height' => 0 }
    original = Marshal.load(Marshal.dump(records))
    item = :ARENA_FURNITURE_RSE_STAND
    ArenaDemo.stub(:refresh_custom_placements, nil) do
      ArenaDemo.stub(:apply_tile_surface, nil) do
        assert ArenaDemo.editor_apply_placement(placements, records, 'furniture', { item: item }, 44, 44)
        assert_equal 1, ArenaDemo.relief_code(records, 44, 44)
        assert_equal 1, $bag.quantity(item)
        payload = ArenaDemo.visit_snapshot_payload
        decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
        assert decoded
        assert_equal 1, decoded[:tile_edits]['44,44']['height']
        assert_equal item.to_s, decoded[:placements][0]['item']
        assert_equal placements, Marshal.load(Marshal.dump(placements))
        assert ArenaDemo.editor_apply_placement(placements, records, 'furniture', { action: :remove }, 44, 44)
        assert_equal original, records
        assert_empty placements
        assert_equal 2, $bag.quantity(item)
      end
    end
  end

  def test_failed_raised_placement_and_dependent_stair_removal_are_atomic
    stock
    placements = $PokemonGlobal.arena_demo_placements = []
    records = ArenaDemo.tile_edit_records
    item = :ARENA_FURNITURE_RSE_SOLID_BOARD
    ArenaDemo.stub(:refresh_custom_placements, nil) do
      ArenaDemo.stub(:apply_tile_surface, nil) do
        assert ArenaDemo.editor_apply_placement(placements, records, 'furniture', { item: item }, 44, 44)
        assert ArenaDemo.editor_apply_relief(records, placements, 43, 44, 6)
        before = Marshal.dump([placements, records, $bag])
        refute ArenaDemo.editor_apply_placement(placements, records, 'furniture', { action: :remove }, 44, 44)
        assert_equal before, Marshal.dump([placements, records, $bag])
        refute ArenaDemo.editor_apply_placement(placements, records, 'furniture', { item: item }, 44, 44)
        assert_equal before, Marshal.dump([placements, records, $bag])
      end
    end
  end

  def test_server_collision_agrees_with_native_floor_rules
    ArenaDemo::EXTRA_FURNITURE.each_key do |item|
      assert_equal !ArenaFurnitureRules.walkable?(item), ArenaDevices.blocked?(item, 0, []), item.to_s
    end
    assert ArenaDevices.blocked?('ARENA_FURNITURE_SNOWBALL', 0, [])
    assert ArenaDevices.blocked?('ARENA_FURNITURE_RSE_BREAKABLE_DOOR', 0, [])
  end

  def test_each_extra_asset_is_visible_and_available_to_the_catalogue
    ArenaDemo::EXTRA_FURNITURE.each do |item, (_name, stem)|
      assert_match(/\A[A-Z0-9_]{1,48}\z/, item.to_s)
      assert ArenaDemo.catalog_furniture?(item)
      assert File.file?(File.expand_path("../SharedAssets/Graphics/ArenaFurniture/#{stem}.png", __dir__))
      art = ArenaDemo.furniture_bitmap(item)
      assert_equal [32, 64], [art.width, art.height]
      assert (0...64).any? { |y| (0...32).any? { |x| art.get_pixel(x, y).alpha > 0 } }, stem
      assert_equal [96, 96], [ArenaDemo.furniture_catalog_preview(item: item).width, ArenaDemo.furniture_catalog_preview(item: item).height]
    end
  end
end
