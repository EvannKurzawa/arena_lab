require 'minitest/autorun'

module ArenaDemo
  MAP_ID = 100
  ENTRANCE_MAP_ID = 102
  def self.refresh_custom_placements; @placement_refreshes = (@placement_refreshes || 0) + 1; end
end
source = File.read(File.expand_path('../Plugins/ArenaDemo/009_ArenaCustomMode.rb', __dir__))
eval(source[/module ArenaDemo::CustomModeRefresh\n.*?^end/m], TOPLEVEL_BINDING)

class RefreshHarness
  attr_reader :base_calls
  def refresh_objects; @base_calls = (@base_calls || 0) + 1; end
  prepend ArenaDemo::CustomModeRefresh
end

class EntranceRefreshTest < Minitest::Test
  Event = Struct.new(:name, :transparent, :through)
  def test_connecting_preserves_pc_and_restores_hidden_entrance_boundaries
    pc = Event.new('Pokemon storage PC', false, false)
    attendant = Event.new('Multiplayer attendant', false, false)
    left = Event.new('Foyer boundary', true, true)
    right = Event.new('Foyer boundary', true, true)
    $game_map = Struct.new(:map_id, :events).new(102, { 3 => pc, 4 => attendant, 6 => left, 7 => right })
    harness = RefreshHarness.new
    3.times { harness.refresh_objects } # connect, ready, host-open refreshes
    assert_equal [false, false], [pc.transparent, attendant.transparent]
    assert_equal [false, false], [left.transparent, right.transparent]
    assert_equal [false, false], [left.through, right.through]
    assert_equal 3, harness.base_calls
  end

  def test_arena_still_hides_legacy_objects
    event = Event.new('Legacy arena object', false, false)
    $game_map = Struct.new(:map_id, :events).new(100, { 3 => event })
    RefreshHarness.new.refresh_objects
    assert_equal [true, true], [event.transparent, event.through]
  end
end
