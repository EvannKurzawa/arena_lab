# A connection save can be taken inside the attendant's event command. Keep
# that transient interpreter out of the snapshot, and repair older snapshots
# before Game.load updates the map. Other events resume normally.
module ArenaDemo::EntranceDialogRecovery
  module_function

  def attendant_interpreter?(interpreter)
    return false unless interpreter
    return false unless interpreter.instance_variable_get(:@map_id) == ArenaDemo::ENTRANCE_MAP_ID &&
                        interpreter.instance_variable_get(:@event_id) == 4
    attendant_commands?(interpreter.instance_variable_get(:@list))
  end

  def attendant_commands?(list)
    list && list.any? do |command|
      [355, 655].include?(command.code) &&
        command.parameters.any? { |value| value.is_a?(String) && value.strip == 'ArenaDemo.multiplayer_attendant' }
    end
  end
end

module ArenaDemo::EntranceDialogSave
  def save(*args, **kwargs, &block)
    system = $game_system
    interpreter = system.map_interpreter if system
    if ArenaDemo::EntranceDialogRecovery.attendant_interpreter?(interpreter)
      replaced = true
      system.instance_variable_set(:@map_interpreter, Interpreter.new(0, true))
    end
    super
  ensure
    system.instance_variable_set(:@map_interpreter, interpreter) if replaced
  end

  def load_map(*args, **kwargs, &block)
    result = super
    interpreter = $game_system.map_interpreter if $game_system
    if ArenaDemo::EntranceDialogRecovery.attendant_interpreter?(interpreter)
      interpreter.setup(nil, 0, ArenaDemo::ENTRANCE_MAP_ID)
    end
    if $game_map && $game_map.map_id == ArenaDemo::ENTRANCE_MAP_ID
      event = $game_map.events[4]
      event.clear_starting if event && ArenaDemo::EntranceDialogRecovery.attendant_commands?(event.list)
    end
    result
  end
end
Game.singleton_class.prepend(ArenaDemo::EntranceDialogSave)
