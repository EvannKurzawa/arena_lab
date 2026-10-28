require 'minitest/autorun'

module ArenaDemo
  MAP_ID = 100
  def self.connected?; true; end
  def self.arena_peers; @peers ||= []; end
end
class Game_Player
  def passable?(*); true; end
end
module PEMK
  module BattleNet
    class << self
      attr_accessor :host, :packet
      def host?; @host; end
      def take_end; packet = @packet; @packet = nil; packet; end
    end
  end
  class HostBattle
    attr_reader :events
    def initialize; @events = []; end
    def maxBattlerIndex; 1; end
    def pbRandom(limit = 65_536); 0; end
    def pbCalculatePriority(*); [pbRandom(2), pbRandom(100)]; end
    def pokemmo_flush_rng; @events << :flush; end
    def pbEndOfBattle(*); @events << :end; end
    def pbSwitchInBetween(*); @events << :switch; end
  end
  class ClientBattle < HostBattle; end
end
require_relative '../Plugins/ArenaDemo/004_MultiplayerFixes'

class MultiplayerFixesTest < Minitest::Test
  def setup
    PEMK::BattleNet.host = false
    ArenaDemo.arena_peers.clear
    $game_map = Struct.new(:map_id).new(100)
  end

  def test_remote_tile_blocks_entry_but_shared_spawn_can_be_exited
    ArenaDemo.arena_peers << Struct.new(:x, :y).new(5, 5)
    player = Game_Player.new
    refute player.passable?(4, 5, 6)
    assert player.passable?(5, 5, 6)
    $game_map.map_id = 2
    assert player.passable?(4, 5, 6)
  end

  def test_result_is_mirrored_only_on_client
    { 1 => 2, 2 => 1, 5 => 5, 0 => 0 }.each do |sent, expected|
      PEMK::BattleNet.packet = { :decision => sent }
      assert_equal expected, PEMK::BattleNet.take_end[:decision]
    end
    PEMK::BattleNet.host = true
    PEMK::BattleNet.packet = { :decision => 1 }
    assert_equal 1, PEMK::BattleNet.take_end[:decision]
    assert_nil PEMK::BattleNet.take_end
  end

  def test_only_the_clients_single_battle_shuffle_draw_is_mirrored
    battle = PEMK::ClientBattle.new
    assert_equal [1, 0], battle.pbCalculatePriority(true)
    assert_equal 0, battle.pbRandom(2)
    assert_equal [0, 0], battle.pbCalculatePriority(false)
    PEMK::BattleNet.host = true
    assert_equal [0, 0], PEMK::HostBattle.new.pbCalculatePriority(true)
  end

  def test_final_rolls_flush_before_end_messages
    battle = PEMK::HostBattle.new
    battle.pbEndOfBattle
    assert_equal [:flush, :end], battle.events
  end

  def test_rolls_flush_before_replacement_wait
    battle = PEMK::HostBattle.new
    battle.pbSwitchInBetween(1)
    assert_equal [:flush, :switch], battle.events
  end
end
