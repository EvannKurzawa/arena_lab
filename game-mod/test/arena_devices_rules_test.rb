require 'minitest/autorun'
require_relative '../Plugins/ArenaDemo/000_ArenaDeviceRules'

class ArenaDevicesRulesTest < Minitest::Test
  def device(item, x, y); [0, item, x, y]; end
  def test_ray_uses_only_configured_half_line_and_stops_beside_antenna
    objects = [device('ARENA_MAGNET_R', 50, 50)]
    assert_equal 4, ArenaDevices.attraction(objects, 60, 50)
    assert_nil ArenaDevices.attraction(objects, 40, 50)
    assert_nil ArenaDevices.attraction(objects, 50, 60)
    assert_nil ArenaDevices.attraction(objects, 51, 50)
    assert_nil ArenaDevices.attraction(objects, 60, 51)
    assert_equal 2, ArenaDevices.attraction([device('ARENA_MAGNET_U', 50, 50)], 50, 40)
  end
  def test_multiple_pairs_survive_removal_without_cross_linking
    objects = [[1, 'TRAINER', 0, 0], device(ArenaDevices::TELEPORT, 1, 1),
      device(ArenaDevices::COIL, 3, 3), device(ArenaDevices::BUTTON, 4, 4),
      device(ArenaDevices::TELEPORT, 2, 2), device(ArenaDevices::TELEPORT, 8, 8), device(ArenaDevices::TELEPORT, 9, 9)]
    assert ArenaDevices.valid_pairs?(objects)
    assert_equal [2, 2], ArenaDevices.teleport_target(objects, 1, 1)
    assert_equal [9, 9], ArenaDevices.teleport_target(objects, 8, 8)
    assert_equal 2, ArenaDevices.partner(objects, 1)
    objects.reject! { |p| p[1] == ArenaDevices::TELEPORT && [1, 2].include?(p[2]) }
    assert_equal [9, 9], ArenaDevices.teleport_target(objects, 8, 8)
    refute ArenaDevices.valid_pairs?(objects.reject { |p| p[1] == ArenaDevices::BUTTON })
  end
  def test_coil_state_accepts_only_unique_real_coil_slots
    objects = [device(ArenaDevices::WEB, 1, 1), device(ArenaDevices::COIL, 2, 2), device(ArenaDevices::BUTTON, 3, 3)]
    assert ArenaDevices.valid_disabled?([1], objects)
    refute ArenaDevices.valid_disabled?([2], objects)
    refute ArenaDevices.valid_disabled?([-1], objects)
    refute ArenaDevices.valid_disabled?([1, 1], objects)
    assert ArenaDevices.blocked?(ArenaDevices::COIL, 1, [])
    assert ArenaDevices.blocked?(ArenaDevices::COIL, 1, [1])
    ArenaDevices::FLOOR.each { |item| refute ArenaDevices.blocked?(item, 0, []) }
    assert ArenaDevices.blocked?('ARENA_MAGNET_D', 0, [])
    refute ArenaDevices.valid_pairs?([nil])
    refute ArenaDevices.valid_pairs?([[0, ArenaDevices::TELEPORT]])
  end
  def test_directional_spark_is_separate_and_only_spark_switches_off
    ArenaDevices::DIRECTIONS.each do |key, (_d, dx, dy)|
      objects = [device("ARENA_TESLA_#{key}", 50, 50), device(ArenaDevices::BUTTON, 40, 40)]
      assert ArenaDevices.valid_pairs?(objects)
      assert_equal({0 => [50 + dx, 50 + dy]}, ArenaDevices.sparks(objects))
      assert_empty ArenaDevices.sparks(objects, [0])
      assert ArenaDevices.blocked?(objects[0][1], 0, [0])
    end
  end
end
