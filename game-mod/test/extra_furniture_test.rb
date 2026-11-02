require_relative 'furniture_catalog_test'
require_relative '../Plugins/ArenaDemo/000_ArenaFurnitureRules'
require_relative '../Plugins/ArenaDemo/000_ArenaDeviceRules'
require_relative '../Plugins/ArenaDemo/000_FieldStateRules'
require_relative '../Plugins/ArenaDemo/092_ExtraFurniture'
require_relative '../Plugins/ArenaDemo/028_ArenaMaterialsArt'
require_relative '../Plugins/ArenaDemo/031_ArenaLiquidAnimation'

class ExtraFurnitureTest < FurnitureCatalogTest
  def test_extra_stock_is_idempotent_on_existing_profiles
    $PokemonGlobal.arena_custom_stock_added = true
    stock
    assert $PokemonGlobal.arena_extra_furniture_stock_added
    assert_equal 34, ArenaDemo::EXTRA_FURNITURE.length
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
        assert_equal 1, ArenaDemo.relief_code(records, 44, 42)
        assert_equal 8, ArenaDemo.relief_code(records, 44, 43)
        assert_equal 0, ArenaDemo.relief_code(records, 44, 44)
        grid = ArenaDemo.relief_grid(records)
        [44,45].each do |column|
          assert ArenaRelief.step?(grid,column,44,column,43)
          assert ArenaRelief.step?(grid,column,43,column,42)
          assert ArenaRelief.step?(grid,column,42,column,43)
          assert ArenaRelief.step?(grid,column,43,column,44)
        end
        art = ArenaDemo.furniture_bitmap(item)
        [[44,42,0,0],[45,42,32,0],[44,43,0,32],[45,43,32,32]].each do |tx,ty,sx,sy|
          tile = ArenaDemo.relief_bitmap(records,tx,ty)
          assert_equal [32,32], [tile.width,tile.height]
          assert_equal art.get_pixel(sx+16,sy+16).bytes, tile.get_pixel(16,16).bytes
        end
        assert_equal 1, $bag.quantity(item)
        payload = ArenaDemo.visit_snapshot_payload
        decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
        assert decoded
        assert_equal 1, decoded[:tile_edits]['44,42']['height']
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
  end

  def test_each_extra_asset_is_visible_and_available_to_the_catalogue
    ArenaDemo::EXTRA_FURNITURE.each do |item, (_name, stem)|
      assert_match(/\A[A-Z0-9_]{1,48}\z/, item.to_s)
      assert ArenaDemo.catalog_furniture?(item)
      assert File.file?(File.expand_path("../SharedAssets/Graphics/ArenaFurniture/#{stem}.png", __dir__))
      art = ArenaDemo.furniture_bitmap(item)
      expected_width = item.to_s == 'ARENA_FURNITURE_TREE_LEAFY' ? 96 : ArenaFurnitureRules.width(item) * 32
      assert_equal expected_width, art.width
      assert_includes [64,96,128], art.height
      assert (0...art.height).any? { |y| (0...art.width).any? { |x| art.get_pixel(x, y).alpha > 0 } }, stem
      assert_equal [96, 96], [ArenaDemo.furniture_catalog_preview(item: item).width, ArenaDemo.furniture_catalog_preview(item: item).height]
    end
  end

  def test_wide_furniture_reserves_both_cells_and_rejects_partial_placement
    stock
    placements = $PokemonGlobal.arena_demo_placements = []
    records = ArenaDemo.tile_edit_records
    item = :ARENA_FURNITURE_DPPT_LABMACHINE
    ArenaDemo.stub(:refresh_custom_placements, nil) do
      ArenaDemo.editor_apply_placement(placements,records,'furniture',{item:item},44,44)
      assert_equal 1, placements.length
      assert_same placements[0], ArenaDemo.editor_occupied(placements,45,44)
      before = Marshal.dump([placements,records,$bag])
      refute ArenaDemo.editor_apply_placement(placements,records,'furniture',{item: :ARENA_FURNITURE_TREE_PINE},45,44)
      assert_equal before, Marshal.dump([placements,records,$bag])
      refute ArenaDemo.editor_apply_placement(placements,records,'furniture',{item:item},99,44)
      assert_equal before, Marshal.dump([placements,records,$bag])
      ArenaDemo.editor_apply_placement(placements,records,'furniture',{action: :remove},45,44)
      assert_empty placements
      assert_equal 2, $bag.quantity(item)
    end
  end

  def test_footprints_cannot_overlap_or_straddle_height_and_void
    surface, relief = '1' * 10000, '0' * 10000
    wide = [0,'ARENA_FURNITURE_DPPT_LABMACHINE',44,44]
    assert ArenaFurnitureRules.valid_footprints?([wide],surface,relief)
    refute ArenaFurnitureRules.valid_footprints?([wide,[0,'ARENA_FURNITURE_SNOWBALL',45,44]],surface,relief)
    relief.setbyte(44*100+45,49)
    refute ArenaFurnitureRules.valid_footprints?([wide],surface,relief)
    relief.setbyte(44*100+45,48)
    surface.setbyte(44*100+45,48)
    refute ArenaFurnitureRules.valid_footprints?([wide],surface,relief)
  end

  def test_existing_crowded_layout_moves_only_enlarged_furniture_without_losing_stock
    stock
    wide = {'kind'=>'furniture','item'=>'ARENA_FURNITURE_TREE_LEAFY','x'=>44,'y'=>44}
    snow = {'kind'=>'furniture','item'=>'ARENA_FURNITURE_SNOWBALL','x'=>45,'y'=>44}
    $PokemonGlobal.arena_demo_placements = [wide,snow]
    before_bag = Marshal.dump($bag)
    placements = ArenaDemo.custom_placements
    assert_equal 2, placements.length
    assert_equal [45,44], snow.values_at('x','y')
    refute ArenaFurnitureRules.cells(wide['item'],wide['x'],wide['y']).include?([45,44])
    assert_equal 1, (wide['x']-44).abs+(wide['y']-44).abs
    assert_equal before_bag, Marshal.dump($bag)
    previous = Marshal.dump(placements)
    ArenaDemo.custom_placements
    assert_equal previous, Marshal.dump(placements)
  end

  def test_tesla_sparks_and_strength_respect_the_second_cell
    wide = [0,'ARENA_FURNITURE_DPPT_LABMACHINE',44,44]
    surface,relief = '1'*10000,'0'*10000
    placements = [wide,[0,'ARENA_FURNITURE_BOULDER',45,45]]
    assert_nil ArenaFieldState.proposal(placements,{},1,:STRENGTH,8,surface,relief)
    coil = [0,'ARENA_TESLA_L',46,44]
    refute ArenaDevices.valid_sparks?([wide,coil],surface,relief)
  end
end
