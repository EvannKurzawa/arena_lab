require_relative 'extra_furniture_test'
require_relative '../Plugins/ArenaDemo/096_ArenaDeviceEditor'
require_relative '../Plugins/ArenaDemo/094_DebugFurniture'

class DebugShowroomTest < ExtraFurnitureTest
  def legacy_showroom
    $PokemonGlobal.arena_wide_furniture_layout_version = 5
    ArenaDemo.custom_placements
    records = ArenaDemo.tile_edit_records
    placements = $PokemonGlobal.arena_demo_placements
    fixtures = placements.reject { |p| p['item'] == ArenaDevices::TELEPORT }
    fixtures.each do |p|
      (p['arena_under_surfaces'] || []).each do |entry|
        records[ArenaDemo.tile_edit_key(entry['x'],entry['y'])] = entry['surface'].dup
      end
    end
    buttons = 0
    fixtures.each_with_index do |p,i|
      x,y = if p['item'] == ArenaDevices::BUTTON
              point = [132+buttons*8,124]
              buttons += 1
              point
            else
              [124+(i%8)*8,132+(i/8)*6]
            end
      p['x'],p['y'] = x,y
      ArenaDemo.debug_raise_furniture(p,records)
    end
    $PokemonGlobal.instance_variable_set(:@arena_debug_furniture_version,1)
    placements
  end

  def test_showroom_compacts_existing_save_and_restores_old_relief
    ArenaDemo.stub(:ensure_bag_pockets,nil) do
      placements = legacy_showroom
      inventory = Marshal.dump($bag)
      ArenaDemo.custom_placements
      fixtures = placements.reject { |p| p['item'] == ArenaDevices::TELEPORT }
      assert_equal ArenaDemo.debug_furniture_layout.map { |item,x,y| [item.to_s,x,y] }, fixtures.map { |p| p.values_at('item','x','y') }
      assert_equal inventory, Marshal.dump($bag)
      payload = ArenaDemo.visit_snapshot_payload
      assert ArenaDemo.decode_visit_snapshot(payload[:surface],payload[:placements],payload[:relief],payload[:styles])
      assert_equal payload, ArenaDemo.visit_snapshot_payload
      assert_operator fixtures.map { |p| p['x'] }.max, :<, 150
      assert_operator fixtures.map { |p| p['y'] }.max, :<, 155
    end
  end

  def test_showroom_compaction_preserves_manual_changes
    ArenaDemo.stub(:ensure_bag_pockets,nil) do
      placements = legacy_showroom
      # Put a personal obstacle in the compact destination before migration.
      placed = {'kind'=>'furniture','item'=>'ARENA_FURNITURE_ROCK','x'=>124,'y'=>129}
      placements << placed
      before = Marshal.dump(placements)
      ArenaDemo.custom_placements
      assert_equal before, Marshal.dump(placements)
      assert_equal [124,129], placed.values_at('x','y')
    end
  end

  def test_showroom_complete_round_trip_and_idempotent
    ArenaDemo.stub(:ensure_bag_pockets,nil) do
      payload = ArenaDemo.visit_snapshot_payload
      assert_equal 40000, payload[:surface].bytesize
      assert_equal [200,200], [ArenaDemo::MAP_WIDTH,ArenaDemo::MAP_HEIGHT]
      ArenaDemo::FURNITURE_STOCK.each_key do |item|
        assert payload[:placements].any? { |p| p[1] == item.to_s }, item.to_s
      end
      assert ArenaDevices.valid_pairs?(payload[:placements])
      assert ArenaDevices.valid_sparks?(payload[:placements],payload[:surface],payload[:relief],ArenaDemo.relief_reserved)
      assert ArenaFurnitureRules.valid_footprints?(payload[:placements],payload[:surface],payload[:relief],ArenaDemo.relief_reserved)
      assert_equal [124,124], ArenaDevices.teleport_target(payload[:placements],49,49)
      assert_equal [49,49], ArenaDevices.teleport_target(payload[:placements],124,124)
      assert ArenaDemo.decode_visit_snapshot(payload[:surface],payload[:placements],payload[:relief],payload[:styles])
      assert_equal payload, ArenaDemo.visit_snapshot_payload
      assert_operator payload[:placements].length, :<=, ArenaDemo::MAX_ARENA_FURNITURE
    end
  end

  def test_showroom_preserves_existing_centre_furniture_and_saves
    $PokemonGlobal.arena_wide_furniture_layout_version = 5
    placed = {'kind'=>'furniture','item'=>'ARENA_FURNITURE_ROCK','x'=>49,'y'=>49}
    $PokemonGlobal.arena_demo_placements = [placed]
    ArenaDemo.stub(:ensure_bag_pockets,nil) do
      payload = ArenaDemo.visit_snapshot_payload
      assert_equal placed, ArenaDemo.custom_placements.first
      portals = payload[:placements].select { |p| p[1] == ArenaDevices::TELEPORT }
      refute_equal [49,49], portals.first[2,2]
      assert_equal [124,124], ArenaDevices.teleport_target(payload[:placements],*portals.first[2,2])
      $PokemonGlobal = Marshal.load(Marshal.dump($PokemonGlobal))
      assert_equal payload, ArenaDemo.visit_snapshot_payload
    end
  end
end
