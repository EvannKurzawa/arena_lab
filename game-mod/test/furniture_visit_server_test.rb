# Furniture uses the existing visit format with shared floor collision rules.
require_relative 'arena_visit_harness'
module ArenaDemo
  FURNITURE_STOCK = {}.freeze
end
require_relative '../Plugins/ArenaDemo/091_ArenaFurnitureCatalog'
require_relative '../Plugins/ArenaDemo/092_ExtraFurniture'

class FurnitureVisitServerTest < Minitest::Test
  include ArenaVisitTestSupport
  def test_all_extra_decorations_relay_with_raised_floor
    host, guest = connect, connect
    surface = '0' * 10000
    (37..61).each { |y| (37..61).each { |x| surface.setbyte(y * 100 + x, 49) } }
    relief = '0' * 10000
    placements = ArenaDemo::EXTRA_FURNITURE.keys.each_with_index.map do |item, i|
      x, y = 39 + i % 8 * 3, 39 + i / 8 * 4
      relief.setbyte(y * 100 + x, 49) if ArenaFurnitureRules.raised?(item)
      [0, item.to_s, x, y]
    end
    send_frame(host, type: :arena_open, objects: [], layout: 0, difficulty: 1,
      surface: surface, relief: relief, styles: '0' * 10000, placements: placements)
    room = until_type(host, :arena_state)
    assert_equal placements, room[:placements]
    joined = join(host, guest, room)
    assert_equal placements, joined[:placements]
    assert_equal relief, joined[:relief]
  end
  def test_all_twenty_new_objects_relay_through_real_server
    host, guest = connect, connect
    surface = '0' * 10000
    (37..61).each { |y| (37..61).each { |x| surface.setbyte(y * 100 + x, 49) } }
    placements = ArenaDemo::BASIC_FURNITURE.keys.each_with_index.map do |item, i|
      [0, item.to_s, 40 + i % 5, 44 + i / 5]
    end
    send_frame(host, type: :arena_open, objects: [], layout: 0, difficulty: 1,
      surface: surface, relief: '0' * 10000, styles: '0' * 10000, placements: placements)
    room = until_type(host, :arena_state)
    assert_equal placements, room[:placements]
    joined = join(host, guest, room)
    assert_equal placements, joined[:placements]
    assert_equal 20, joined[:placements].length
  end
end
