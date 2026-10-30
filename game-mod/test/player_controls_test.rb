require 'minitest/autorun'

module Input
  USE = 13
  BACK = 12
  ACTION = 11
  SHIFT = 21
  SPECIAL = 16
  F9 = 29
  class << self; attr_accessor :keys; end
  def self.triggerex?(key); (keys || []).include?(key); end
  def self.pressex?(key); triggerex?(key); end
  def self.trigger?(button)
    return [:SPACE, :RETURN, :Z].any? { |key| triggerex?(key) } if button == USE
    return triggerex?(:LSHIFT) || triggerex?(:RSHIFT) if [ACTION, SHIFT].include?(button)
    false
  end
  def self.press?(button); trigger?(button); end
end
module MenuHandlers
  def self.remove(*args); (@removed ||= []) << args; end
  def self.removed; @removed; end
end
module EventHandlers
  def self.trigger(key, *); $interaction_count += 1 if key == :on_player_interact; end
end
module ArenaDemo
  module Outings
    def self.expired?; !!$expired; end
  end
end
def pbMapInterpreterRunning?; !!$interpreter_running; end
def pbMapInterpreter; $interpreter; end
def pbTerrainTag; $terrain; end

class Game_Player
  attr_accessor :moving, :jumping
  attr_reader :commands
  def initialize; @commands = 0; @move_speed = 3; end
  def moving?; !!moving; end
  def jumping?; !!jumping; end
  def update_command_new; @commands += 1; end
  def update; update_command_new; self.moving = false; end
  def straighten; end
  def check_event_trigger_here(*); false; end
  def check_event_trigger_there(*); false; end
end
class Scene_Map
  attr_accessor :fail_update
  attr_reader :menus, :dialog_confirmation
  def initialize; @menus = 0; end
  def updateMaps; raise 'test update failure' if fail_update; end
  def updateSpritesets; end
  def call_menu
    @menus += 1
    $game_temp.menu_calling = false
    $game_temp.in_menu = true
    @dialog_confirmation = Input.trigger?(Input::USE)
    $game_temp.in_menu = false
  end
end
# Execute Essentials' real map polling order, including Use before Action.
source = File.read(File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/003_Game processing/002_Scene_Map.rb', __dir__))
Scene_Map.class_eval(source[/  def update\n.*?(?=  def main)/m])
require_relative '../Plugins/ArenaDemo/019_PlayerControls'

# Following Pokemon EX loads after Arena Demo and wraps Scene_Map#update using
# alias_method. A prepended update hook gets trapped in a recursive alias loop.
class Scene_Map
  alias __followingpkmn__update update
  def update(*args); __followingpkmn__update(*args); end
end

class PlayerControlsTest < Minitest::Test
  Temp = Struct.new(:in_menu, :in_battle, :message_window_showing, :in_mini_update,
    :player_transferring, :transition_processing, :title_screen_calling,
    :interact_calling, :menu_calling, :menu_beep, :ready_menu_calling, :debug_calling)
  Global = Struct.new(:forced) do
    def forced_movement?; !!forced; end
  end
  SystemState = Struct.new(:menu_disabled) do
    def update; end
  end
  def setup
    Input.keys = []
    $game_temp = Temp.new
    $game_system = SystemState.new(false)
    $PokemonGlobal = Global.new(false)
    $game_screen = Object.new
    def $game_screen.update; end
    $interpreter = Object.new
    def $interpreter.update; end
    $game_player = Game_Player.new
    $scene = Scene_Map.new
    $terrain = Struct.new(:must_walk).new(false)
    $interaction_count = 0
    $expired = false
    $interpreter_running = false
    ArenaDemo::Controls.cancel_menu
  end

  def test_following_pokemon_update_alias_does_not_recurse
    Input.keys = [:SPACE]
    $scene.update
    assert_equal 1, $scene.menus
  end

  def test_both_shift_keys_run_without_opening_pause_or_requiring_shoes
    [:LSHIFT, :RSHIFT].each do |key|
      Input.keys = [key]
      assert $game_player.can_run?
      $scene.update
      assert_equal 0, $scene.menus
    end
    Input.keys = []
    refute $game_player.can_run?
    assert_includes MenuHandlers.removed, [:options_menu, :movement_style]
  end

  def test_space_opens_menu_instead_of_confirming_an_overworld_interaction
    Input.keys = [:SPACE]
    $scene.update
    assert_equal 1, $scene.menus
    assert_equal 0, $interaction_count
    refute ArenaDemo::Controls.menu_pending?
    assert $scene.dialog_confirmation, 'Space still confirms inside an actual menu/dialog'
  end

  def test_space_queues_menu_until_the_current_step_finishes
    $game_player.moving = true
    Input.keys = [:SPACE, :LSHIFT]
    $scene.update
    assert_equal 1, $scene.menus
    assert_equal 0, $game_player.commands, 'No new step starts while the menu is queued'
  end

  def test_enter_and_z_remain_interaction_keys
    [:RETURN, :Z].each do |key|
      Input.keys = [key]
      $scene.update
    end
    assert_equal 2, $interaction_count
    assert_equal 0, $scene.menus
  end

  def test_dialog_battle_and_forced_movement_do_not_open_pause
    Input.keys = [:SPACE]
    $game_temp.message_window_showing = true
    $scene.update
    assert_equal 0, $scene.menus
    ArenaDemo::Controls.with_map_input { assert Input.trigger?(Input::USE) }
    $game_temp.message_window_showing = false
    $PokemonGlobal.forced = true
    $scene.update
    assert_equal 0, $scene.menus
    $PokemonGlobal.forced = false
    $game_system.menu_disabled = true
    $scene.update
    assert_equal 0, $scene.menus
  end

  def test_running_respects_walk_only_terrain_menus_battles_and_scripted_motion
    Input.keys = [:LSHIFT]
    $terrain.must_walk = true
    refute $game_player.can_run?
    $terrain.must_walk = false
    $game_temp.in_menu = true
    refute $game_player.can_run?
    $game_temp.in_menu = false
    $game_temp.in_battle = true
    refute $game_player.can_run?
    $game_temp.in_battle = false
    $game_player.jumping = true
    refute $game_player.can_run?
    $game_player.jumping = false
    $game_player.instance_variable_set(:@move_route_forcing, true)
    $game_player.instance_variable_set(:@move_speed, 4)
    assert $game_player.can_run?
  end

  def test_expired_outing_prevents_new_movement_or_interaction
    $expired = true
    Input.keys = [:RETURN]
    $scene.update
    assert_equal 0, $interaction_count
    assert_equal 0, $game_player.commands
    $interpreter_running = true
    $game_player.update_command_new
    assert_equal 1, $game_player.commands, 'An active NPC script must finish its forced movement before returning'
  end

  def test_input_scope_is_restored_after_a_map_exception
    Input.keys = [:SPACE]
    $scene.fail_update = true
    assert_raises(RuntimeError) { $scene.update }
    refute ArenaDemo::Controls.map_poll?
    assert Input.trigger?(Input::USE)
  end

  def test_expired_menus_close_normally_without_cancelling_battle_commands
    $expired = true
    $game_temp.in_menu = true
    assert Input.trigger?(Input::BACK)
    refute Input.trigger?(Input::USE)
    $game_temp.in_battle = true
    refute Input.trigger?(Input::BACK)
    $game_temp.in_battle = false
    $interpreter_running = true
    refute Input.trigger?(Input::BACK), 'NPC battle follow-up and dialogue finish normally'
  end
end
