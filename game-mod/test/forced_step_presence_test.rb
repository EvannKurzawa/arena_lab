require 'minitest/autorun'
module ArenaDemo
  MAP_ID = 100
end
module EventHandlers
  @callbacks = {}
  def self.add(event, key, handler); (@callbacks[event] ||= {})[key] = handler; end
  def self.trigger(event, *args); (@callbacks[event] || {}).each_value { |handler| handler.call(*args) }; end
end
module PEMK
  class << self
    attr_accessor :client, :self_id, :frames
    def send_message(frame); frames << frame; true; end
  end
end
require_relative '../../upstream/pokemon-essentials-mmo-kit/Plugins/PEMK/003_Game/003_Presence'
require_relative '../Plugins/ArenaDemo/040_ArenaStepPresence'

class ForcedStepPresenceTest < Minitest::Test
  def setup
    $game_map = Struct.new(:map_id).new(100)
    $game_player = Struct.new(:map_id, :x, :y, :direction, :move_speed, :character_name).new(100, 49, 53, 6, 4, 'trainer_POKEMONTRAINER_Red')
    $PokemonGlobal = Struct.new(:diving, :surfing, :bicycle).new(false, false, false)
    $player = Struct.new(:outfit, :name).new(0, 'Alice')
    PEMK.client = Struct.new(:connected?).new(true)
    PEMK.self_id, PEMK.frames = 1, []
    PEMK::Presence.instance_variable_set(:@last_key, nil)
  end

  def test_forced_ice_steps_emit_an_adjacent_path_without_ordinary_step_callbacks
    (49..54).each do |x|
      $game_player.x = x
      EventHandlers.trigger(:on_step_taken, $game_player)
    end
    assert_equal (49..54).to_a, PEMK.frames.map { |message| message[:x] }
    assert PEMK.frames.all? { |message| message[:type] == :pos && message[:map] == 100 && message[:mode] == :run }
  end

  def test_ordinary_step_notification_and_heartbeat_duplicates_are_not_added
    EventHandlers.trigger(:on_step_taken, $game_player)
    PEMK::Presence.emit(:pos)
    EventHandlers.trigger(:on_step_taken, $game_player)
    assert_equal 1, PEMK.frames.length
  end

  def test_offline_npcs_and_other_maps_do_not_send_arena_step_frames
    PEMK.client[0] = false
    EventHandlers.trigger(:on_step_taken, $game_player)
    PEMK.client[0] = true
    EventHandlers.trigger(:on_step_taken, Object.new)
    $game_map.map_id = 102
    EventHandlers.trigger(:on_step_taken, $game_player)
    assert_empty PEMK.frames
  end
end
