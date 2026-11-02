require 'minitest/autorun'
load File.expand_path('../../upstream/pokemon-essentials/Data/Scripts/003_Game processing/003_Interpreter.rb', __dir__)
class Interpreter
  def end_follower_overrides; end
end
module ArenaDemo
  ENTRANCE_MAP_ID = 102
end
class DialogSaveSystem
  attr_reader :map_interpreter
  def initialize(interpreter); @map_interpreter = interpreter; end
end
module Game
  def self.save(*, **)
    raise IOError, 'fixture failure' if $save_failure
    $saved_dialog_system = Marshal.load(Marshal.dump($game_system))
    true
  end
  def self.load_map; :loaded; end
end
require_relative '../Plugins/ArenaDemo/010_EntranceDialogRecovery'

class EntranceDialogSaveTest < Minitest::Test
  Command = Struct.new(:code, :parameters)
  Event = Struct.new(:starting, :list) do
    def clear_starting; self.starting = false; end
  end
  def setup
    $game_map = Struct.new(:map_id, :events).new(102, { 4 => Event.new(true, [Command.new(355, ['ArenaDemo.multiplayer_attendant'])]) })
    @interpreter = Interpreter.new(0, true)
    @interpreter.setup([Command.new(355, ['ArenaDemo.multiplayer_attendant']), Command.new(0, [])], 4, 102)
    $game_system = DialogSaveSystem.new(@interpreter)
    $save_failure = false
  end
  def test_connection_save_excludes_dialogue_but_live_event_continues
    assert Game.save
    refute $saved_dialog_system.map_interpreter.running?
    assert_same @interpreter, $game_system.map_interpreter
    assert @interpreter.running?
    assert_equal 0, @interpreter.instance_variable_get(:@index)
  end
  def test_failed_save_restores_the_live_interpreter
    $save_failure = true
    assert_raises(IOError) { Game.save }
    assert_same @interpreter, $game_system.map_interpreter
    assert @interpreter.running?
  end
  def test_old_saved_dialogue_and_queued_start_are_cleared_before_map_update
    assert_equal :loaded, Game.load_map
    refute @interpreter.running?
    refute $game_map.events[4].starting
    # An explicit interaction can start this guide again normally.
    @interpreter.setup([Command.new(355, ['ArenaDemo.multiplayer_attendant'])], 4, 102)
    assert @interpreter.running?
  end
  def test_unrelated_event_with_same_id_is_preserved
    @interpreter.setup([Command.new(355, ['story_event'])], 4, 102)
    $game_map.events[4].list = [Command.new(355, ['story_event'])]
    Game.save
    assert $saved_dialog_system.map_interpreter.running?
    Game.load_map
    assert @interpreter.running?
    assert $game_map.events[4].starting
    @interpreter.setup([Command.new(355, ['ArenaDemo.multiplayer_attendant'])], 4, 101)
    Game.load_map
    assert @interpreter.running?
  end
end
