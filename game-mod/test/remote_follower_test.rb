require 'minitest/autorun'

# Load actual Essentials movement, rather than a replacement movement model.
load File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/004_Game classes/006_Game_Character.rb', __dir__)
module EventHandlers
  def self.add(type, key, handler); (@handlers ||= {})[[type, key]] = handler; end
  def self.get(type, key); @handlers[[type, key]]; end
end
require_relative '../Plugins/ArenaDemo/011_ArenaFollowingIntegration'
require_relative '../Plugins/ArenaDemo/014_VisibleWildPokemon'

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
