require 'minitest/autorun'
class Game_Map
  REAL_RES_X = REAL_RES_Y = 128
end

# Load actual Essentials movement, rather than a replacement movement model.
load File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/004_Game classes/006_Game_Character.rb', __dir__)
module EventHandlers
  def self.add(type, key, handler); (@handlers ||= {})[[type, key]] = handler; end
  def self.get(type, key); @handlers[[type, key]]; end
end
require_relative '../Plugins/ArenaDemo/011_ArenaFollowingIntegration'
require_relative '../Plugins/ArenaDemo/014_VisibleWildPokemon'
require_relative '../../upstream/pokemon-essentials-mmo-kit/Plugins/PEMK/003_Game/002_RemotePlayer'

class Scene_Map
  attr_reader :requested_map
  def spriteset(map_id)
    @requested_map = map_id
    Object.new.tap { |object| def object.addUserAnimation(*); end }
  end
end
module Settings
  GRASS_ANIMATION_ID = 1
end

class RemoteFollowerTest < Minitest::Test
  def test_network_pose_retargets_from_drawn_position_without_snapping_or_restarting
    follower = ArenaRemotePokemon.allocate
    follower.instance_variable_set(:@map, Struct.new(:width, :height).new(100,100))
    follower.define_singleton_method(:calculate_bush_depth) { }
    follower.define_singleton_method(:triggerLeaveTile) { }
    { x: 0, y: 0, real_x: 0, real_y: 0, move_time: 0.125,
      delta_t: 0.03, anime_count: 0, walk_anime: true, step_anime: true }.each do |key,value|
      follower.instance_variable_set("@#{key}",value)
    end
    follower.glide_to(1,0)
    follower.update_move
    partial = follower.real_x
    assert_operator partial, :>, 0
    assert_operator partial, :<, 128
    timer = follower.instance_variable_get(:@move_timer)
    follower.glide_to(1,0)
    assert_equal timer, follower.instance_variable_get(:@move_timer)
    follower.glide_to(2,0)
    assert_equal partial, follower.real_x
    follower.update_move
    assert_operator follower.real_x, :>, partial
    assert_operator follower.real_x, :<, 128
    follower.instance_variable_set(:@delta_t,0.2)
    follower.update_move
    assert_equal 256, follower.real_x
    assert_nil follower.instance_variable_get(:@move_timer)
    follower.glide_to(3,0)
    follower.update_move
    follower.glide_to(4,0,true)
    assert_equal 512, follower.real_x
    assert_nil follower.instance_variable_get(:@move_timer)
    assert_nil follower.instance_variable_get(:@arena_glide_from)
  end
  def test_remote_player_movement_uses_visual_callbacks_on_current_essentials
    ArenaDemo::FollowingIntegration.install_network_hooks
    player = PEMK::RemotePlayer.allocate
    player.define_singleton_method(:can_move_in_direction?) { |_| false }
    [2,4,6,8].each do |direction|
      player.move_generic(direction)
      assert_equal false, player.check_event_trigger_touch(direction)
    end
    player.instance_variable_set(:@map, Struct.new(:map_id).new(100))
    assert_equal 100, player.map_id
  end
  def test_visible_wild_character_supports_actual_essentials_grass_step_callback
    source = File.read(File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/012_Overworld/001_Overworld.rb', __dir__))
    eval(source[/EventHandlers.add\(:on_step_taken, :grass_rustling,.*?^\)/m], TOPLEVEL_BINDING)
    character = ArenaVisibleWildCharacter.allocate
    { map: Struct.new(:map_id).new(101), x: 5, y: 6, width: 1, height: 1 }.each do |key, value|
      character.instance_variable_set("@#{key}", value)
    end
    $map_factory = Object.new
    def $map_factory.getTerrainTagFromCoords(*); Struct.new(:shows_grass_rustle).new(true); end
    $scene = Scene_Map.new
    EventHandlers.get(:on_step_taken, :grass_rustling).call(character)
    assert_equal 101, character.map_id
    assert_equal 101, $scene.requested_map
  end

  def test_blocked_movement_in_every_direction_has_no_event_trigger
    follower = ArenaRemotePokemon.allocate
    follower.define_singleton_method(:can_move_in_direction?) { |_| false }
    [2, 4, 6, 8].each do |direction|
      follower.move_generic(direction)
      assert_equal false, follower.check_event_trigger_touch(direction)
    end
  end

  def test_released_runtime_callback_names_are_visual_only
    follower = ArenaRemotePokemon.allocate
    assert_equal false, follower.pbCheckEventTriggerAfterTurning
    assert_equal false, follower.pbCheckEventTriggerTouch(2)
    assert_equal false, follower.pbCheckEventTriggerAfterMoving
  end
end
