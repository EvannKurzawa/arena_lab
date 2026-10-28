# frozen_string_literal: true
require_relative 'arena_customization_test'
class PokemonEncounters
  attr_reader :step_chances, :encounter_tables
  def setup(_map_id)
    @step_chances = {}
    @encounter_tables = {}
  end
end
def pbReceiveItem(item, count)
  $trail_gifts << [item, count]
  $trail_can_receive
end
require_relative '../Plugins/ArenaDemo/006_FoundersPath'

class FoundersPathTest < Minitest::Test
  def setup
    ArenaCustomizationTest.new('fixture').setup
    $trail_gifts = []
    $trail_can_receive = true
    $arena_accept = false
    $player.define_singleton_method(:owned?) { |_species| $trail_caught }
    $trail_caught = false
  end
  def test_encounters_use_the_existing_offline_land_table_shape
    encounters = PokemonEncounters.new
    encounters.setup(103)
    assert_equal 21, encounters.step_chances[:Land]
    assert_equal ArenaDemo::ROUTE_ENCOUNTERS, encounters.encounter_tables[:Land]
    encounters.encounter_tables[:Land][0][0] = 1
    assert_equal 50, ArenaDemo::ROUTE_ENCOUNTERS.first.first
    encounters.setup(101)
    assert_empty encounters.encounter_tables
    PEMK::Auth.logged_in = true
    encounters.setup(103)
    assert_empty encounters.encounter_tables
  end
  def test_supplies_and_completion_reward_are_each_granted_once
    ArenaDemo.town_guide
    ArenaDemo.town_guide
    assert_equal [[:POKEBALL, 10]], $trail_gifts
    refute $PokemonGlobal.arena_trail_complete
    $trail_caught = true
    ArenaDemo.town_guide
    ArenaDemo.town_guide
    assert_equal [[:POKEBALL, 10], [:GREATBALL, 3]], $trail_gifts
    assert $PokemonGlobal.arena_trail_complete
  end
  def test_full_bag_does_not_consume_the_supply_grant
    $trail_can_receive = false
    ArenaDemo.town_guide
    refute $PokemonGlobal.arena_trail_supplies
    $trail_can_receive = true
    ArenaDemo.town_guide
    assert $PokemonGlobal.arena_trail_supplies
  end
  def test_route_entry_is_offline_and_requires_confirmation
    PEMK::Auth.logged_in = true
    ArenaDemo.trail_scout
    assert_empty $arena_transfers
    PEMK::Auth.logged_in = false
    ArenaDemo.trail_scout
    assert_empty $arena_transfers
    $arena_accept = true
    ArenaDemo.trail_scout
    assert_equal [103, 12, 16, 8], $arena_transfers.last
  end
end
