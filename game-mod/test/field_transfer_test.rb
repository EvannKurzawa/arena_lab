require 'minitest/autorun'
module ArenaDemo
  MAP_ID = 100
end
module EventHandlers
  def self.add(*); end
end
module Game; end
module PEMK
  module Presence
    def self.emit_now(type); $presence << [type, $game_map.map_id]; end
  end
end
class Scene_Map
  def transfer_player(target); $game_map.map_id = target; :transferred; end
end
require_relative '../Plugins/ArenaDemo/036_FieldObstacles'

class FieldTransferTest < Minitest::Test
  def setup
    $game_map = Struct.new(:map_id).new(100)
    $PokemonMap = nil
    $presence = []
    @field = ArenaDemo::FieldObstacles
    @field.clear
    @field.instance_variable_set(:@states, {0 => nil})
  end
  def test_fast_shared_roundtrip_emits_both_maps_and_keeps_overlay_until_server_reset
    @field.stub(:network?, true) do
      scene = Scene_Map.new
      assert_equal :transferred, scene.transfer_player(102)
      scene.transfer_player(100)
      assert_equal [[:pos, 102], [:pos, 100]], $presence
      assert_equal({0 => nil}, @field.instance_variable_get(:@states))
    end
  end
  def test_solo_departure_resets_but_failed_or_unrelated_transfers_do_not
    @field.stub(:network?, false) do
      scene = Scene_Map.new
      scene.transfer_player(100)
      assert_equal({0 => nil}, @field.instance_variable_get(:@states))
      scene.transfer_player(102)
      assert_empty @field.instance_variable_get(:@states)
      assert_empty $presence
    end
  end

  def test_native_access_blocks_follower_displacement_and_restores_flags_on_error
    $game_temp = Struct.new(:no_follower_field_move).new(false)
    assert_raises(RuntimeError) do
      @field.with_native_access do
        assert @field.using?
        assert $game_temp.no_follower_field_move
        @field.with_native_access { assert $game_temp.no_follower_field_move }
        assert $game_temp.no_follower_field_move
        raise 'interrupted animation'
      end
    end
    refute @field.using?
    refute $game_temp.no_follower_field_move
    $game_temp.no_follower_field_move = true
    @field.with_native_access { assert $game_temp.no_follower_field_move }
    assert $game_temp.no_follower_field_move
  ensure
    $game_temp = nil
  end
end
