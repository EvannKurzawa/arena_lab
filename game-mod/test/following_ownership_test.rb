require 'minitest/autorun'
class Game_Character
  attr_accessor :x, :y, :direction, :move_speed, :character_name
  def initialize(*); @x = @y = 0; end
  def moveto(x, y); @x, @y = x, y; end
  def moving?; false; end
  def update; end
  def screen_x; x * 32; end
  def screen_y; y * 32; end
  def screen_z; y; end
end
class Sprite_Character
  attr_accessor :x, :y, :z
  attr_reader :character
  def initialize(viewport, character); @character = character; end
  def update; @character = $wrong_character if $wrong_character; end
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end
end
class Scene_Map; end
module EventHandlers
  def self.add(*); end
end
module PEMK
  def self.self_id; 1; end
  module Remotes
    def self.players; @players ||= {}; end
  end
end
module FollowingPkmn
  def self.get; nil; end
  def self.start_following(*); raise 'Must not recreate a hidden follower during a battle'; end
end
require_relative '../Plugins/ArenaDemo/011_ArenaFollowingIntegration'

class FollowingOwnershipTest < Minitest::Test
  Leader = Struct.new(:player_id, :x, :y, :direction, :move_speed)
  def setup
    $scene = Scene_Map.new
    $game_map = Struct.new(:map_id).new(100)
    @integration = ArenaDemo::FollowingIntegration
    $game_temp = Struct.new(:in_battle).new(false)
    @integration.clear_remote
    PEMK::Remotes.players.clear
    @set = Object.new
    def @set.map; $game_map; end
    def @set.addUserSprite(sprite); end
    @integration.sprite_context(@set, Object.new)
  end
  def teardown; $wrong_character = nil; @integration.clear_remote; end

  def test_self_echo_cannot_create_a_second_local_follower
    @integration.sync_remote(1, Leader.new(1, 5, 5, 2, 4), { follower_species: 'PIKACHU' })
    assert_empty @integration.followers
  end

  def test_connected_neighbor_spriteset_cannot_steal_the_follower_context
    other = Struct.new(:map).new(Object.new)
    @integration.sprite_context(other, Object.new)
    assert_same @set, @integration.instance_variable_get(:@spriteset)
  end

  def test_battle_temporarily_hidden_local_follower_is_not_created_twice
    $game_temp.in_battle = true
    $game_map.define_singleton_method(:events) { { 900 => Object.new } }
    @integration.stub(:local_pokemon, Object.new) { @integration.ensure_local_follower }
    assert_empty @integration.followers
  end

  def test_battle_rebuild_keeps_both_remote_followers_bound_to_their_owners
    a, b = Leader.new(2, 10, 10, 2, 4), Leader.new(3, 20, 20, 2, 4)
    PEMK::Remotes.players.merge!(2 => a, 3 => b)
    @integration.stub(:charset_for, 'sprite') do
      @integration.sync_remote(2, a, { follower_species: 'PIKACHU' })
      @integration.sync_remote(3, b, { follower_species: 'EEVEE' })
      old = @integration.sprites.values.dup
      @integration.rebuild_after_battle
      assert old.all?(&:disposed?)
      a.x = 30
      b.x = 40
      @integration.update_remote_followers
      assert_equal 30, @integration.followers[2].x
      assert_equal 40, @integration.followers[3].x
      $wrong_character = a
      @integration.sprites[3].update
      assert_equal @integration.followers[3], @integration.sprites[3].character
      assert_equal 40 * 32, @integration.sprites[3].x
      assert_equal [2, 3], @integration.followers.values.map(&:owner_id)
      @integration.followers[3].follow_remote(a, true)
      assert_equal 40, @integration.followers[3].x
    end
  end
end
