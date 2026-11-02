require 'minitest/autorun'
module System
  def self.uptime; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
end
class Game_Map
  REAL_RES_X = REAL_RES_Y = 128
end
class Game_Character
  attr_accessor :x, :y, :direction, :move_speed, :character_name
  def initialize(*); @x = @y = 0; end
  def moveto(x, y); @x, @y = x, y; end
  def moving?; false; end
  def move_speed=(value); @move_speed = value; @move_time = 2.0 / (2**value); end
  def update; end
  def screen_x; x * 32; end
  def screen_y; y * 32; end
  def screen_z; y; end
  def real_x; x * 128; end
  def real_y; y * 128; end
  def move_right(*); @x += 1; end
  def move_left(*); @x -= 1; end
  def move_up(*); @y -= 1; end
  def move_down(*); @y += 1; end
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
  FOLLOWER_DISTANCE_EXCEPTIONS = { LUGIA: 24, KYUREM: 32 }.freeze
  def self.can_check?; true; end
  def self.active?; false; end
  def self.get_pokemon; nil; end
  def self.get; nil; end
  def self.start_following(*); raise 'Must not recreate a hidden follower during a battle'; end
end
require_relative '../Plugins/ArenaDemo/011_ArenaFollowingIntegration'

class FollowingOwnershipTest < Minitest::Test
  Leader = Struct.new(:player_id, :x, :y, :direction, :move_speed) do
    def real_x; x * 128; end
    def real_y; y * 128; end
  end
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

  def test_turning_in_place_does_not_orbit_the_remote_follower
    leader = Leader.new(2, 10, 10, 2, 4)
    follower = ArenaRemotePokemon.new(leader, 'sprite')
    [4,8,6,2].each do |direction|
      leader.direction = direction
      follower.follow_remote(leader)
      assert_equal [10,9], [follower.x,follower.y]
    end
    assert_equal true, follower.instance_variable_get(:@step_anime)
  end

  def test_position_updates_reuse_character_and_relay_its_own_facing
    leader = Leader.new(2, 10, 10, 2, 4)
    PEMK::Remotes.players[2] = leader
    @integration.stub(:charset_for, 'sprite') do
      @integration.sync_remote(2, leader, { follower_species: 'LUGIA', follower_x: 9, follower_y: 10, follower_dir: 6 })
      first = @integration.followers[2]
      assert_equal [9,10,6], [first.x,first.y,first.direction]
      leader.x = 11
      @integration.sync_remote(2, leader, { follower_species: 'LUGIA', follower_x: 10, follower_y: 10, follower_dir: 6 })
      assert_same first, @integration.followers[2]
      assert_equal [10,10], [first.x,first.y]
    end
  end

  def test_spacing_uses_relative_position_and_caps_large_species_margin
    leader = Leader.new(2, 10,10,2,4)
    follower = Game_Character.new
    follower.moveto(9,10)
    assert_equal [-8,0], @integration.visual_spacing(follower,leader,:MEW)
    assert_equal [-16,0], @integration.visual_spacing(follower,leader,:LUGIA)
    assert_equal [-16,0], @integration.visual_spacing(follower,leader,:DARKLUGIA)
    assert_equal [-16,0], @integration.visual_spacing(follower,leader,:KYUREM)
    leader.direction = 6
    follower.direction = 4
    assert_equal [-16,0], @integration.visual_spacing(follower,leader,:LUGIA)
    follower.moveto(10,9)
    assert_equal [0,-16], @integration.visual_spacing(follower,leader,:LUGIA)
    follower.moveto(7,10)
    assert_equal [-16,0], @integration.visual_spacing(follower,leader,:LUGIA)
    follower.moveto(10,10)
    assert_equal [-16,0], @integration.visual_spacing(follower,leader,:LUGIA)
  end

  def test_visual_margin_eases_across_turns_without_projecting_native_positions
    leader = Leader.new(2,10,10,6,4)
    follower = Game_Character.new
    follower.moveto(9,10)
    @integration.update_visual_spacing(follower,leader,:MEW,0.0)
    assert_equal [-8,0], @integration.visual_spacing(follower,leader,:MEW)
    follower.moveto(10,9)
    @integration.update_visual_spacing(follower,leader,:MEW,1.0/60)
    margin = @integration.visual_spacing(follower,leader,:MEW)
    assert_operator margin[0], :<, 0
    assert_operator margin[1], :>, -8
    assert_equal [10,9], [follower.x,follower.y]
    10.times { assert_equal margin, @integration.visual_spacing(follower,leader,:MEW) }
    @integration.update_visual_spacing(follower,leader,:MEW,1.0/60)
    assert_equal margin, @integration.visual_spacing(follower,leader,:MEW)
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

  def test_missing_local_follower_can_start_even_before_it_is_active
    $game_map.define_singleton_method(:events) { { 900 => Object.new } }
    pokemon = Object.new
    def pokemon.egg?; false; end
    called = nil
    FollowingPkmn.stub(:get_pokemon, pokemon) do
      FollowingPkmn.stub(:start_following, ->(*args) { called = args }) do
        @integration.ensure_local_follower
      end
    end
    assert_equal [900,false], called
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
