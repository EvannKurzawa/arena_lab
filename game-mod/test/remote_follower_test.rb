require 'minitest/autorun'

# Load actual Essentials movement, rather than a replacement movement model.
load File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/004_Game classes/006_Game_Character.rb', __dir__)
module EventHandlers
  def self.add(*); end
end
require_relative '../Plugins/ArenaDemo/011_ArenaFollowingIntegration'

class RemoteFollowerTest < Minitest::Test
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
