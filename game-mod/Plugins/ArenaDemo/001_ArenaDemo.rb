# Arena Lab: a small Essentials v21.1 plugin prototype.
# Install this folder in the complete game's Plugins/ directory.
# Team species/levels use normal Essentials data and TrainerBattle.

module ArenaDemo
  MAP_ID = 100
  MAX_OBJECTS = 6
  OBJECTS = ["Boulder", "Rock", "Tree", "Boulder 2", "Rock 2", "Tree 2"].freeze
  OBJECT_EVENTS = Hash[OBJECTS.each_with_index.map { |name, i| [name, i + 3] }].freeze
  LAYOUTS = {
    "Sidelines" => [[5, 6], [5, 9], [5, 12], [19, 6], [19, 9], [19, 12]],
    "Slalom" => [[8, 6], [16, 8], [8, 10], [16, 12], [8, 14], [16, 14]],
    "Training ring" => [[9, 7], [12, 7], [15, 7], [9, 11], [12, 11], [15, 11]]
  }.freeze
  TRAINER_NAME = "Arena Trainee"
  TRAINER_TYPE = :YOUNGSTER
  TRAINER_TEAM = [[:RATTATA, 8], [:EKANS, 9]].freeze
  QUICK_START_TEAM = [[:PIKACHU, 10]].freeze

  module_function

  def multiplayer?
    return defined?(PEMK::Auth) && PEMK::Auth.logged_in?
  end

  def objects
    return [] if !$PokemonGlobal
    if !$PokemonGlobal.arena_demo_objects.is_a?(Array)
      $PokemonGlobal.arena_demo_objects = OBJECTS.dup
    end
    return $PokemonGlobal.arena_demo_objects
  end

  def map_start
    path = File.join("Data", "ArenaDemoStart.txt")
    values = File.file?(path) ? File.read(path).split(",").map(&:to_i) : []
    return values if values.length == 3
    return [10, 10, 2]
  end

  def enter
    return open if $game_map.map_id == MAP_ID
    $PokemonGlobal.arena_demo_return = [$game_map.map_id, $game_player.x,
                                        $game_player.y, $game_player.direction]
    transfer_to(MAP_ID, *map_start)
    refresh_objects
    open
  end

  # Used by the optional New Game intro shortcut. Keep this small team local to
  # the save so the sample trainer can be challenged immediately.
  def quick_start
    if $player && $player.party
      $player.party.clear
      QUICK_START_TEAM.each do |species, level|
        $player.party << Pokemon.new(species, level, $player)
      end
    end
    $PokemonGlobal.arena_demo_return = [3, 25, 6, 2] if $PokemonGlobal
    transfer_to(MAP_ID, *map_start)
  end

  def leave
    point = $PokemonGlobal.arena_demo_return
    unless point && point.length == 4 && point[0] != MAP_ID
      pbMessage("No return point is saved for this arena visit.")
      return
    end
    transfer_to(point[0], point[1], point[2], point[3])
  end

  def transfer_to(map_id, x, y, direction)
    pbFadeOutIn do
      $game_temp.player_new_map_id = map_id
      $game_temp.player_new_x = x
      $game_temp.player_new_y = y
      $game_temp.player_new_direction = direction
      pbCancelVehicles
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    end
  end

  def refresh_objects
    return if !$game_map || $game_map.map_id != MAP_ID
    # A shared map needs identical obstacles on both clients. Keep personal
    # offline layouts saved, but use one fixed layout for authenticated sessions.
    selected = multiplayer? ? OBJECTS : objects
    OBJECT_EVENTS.each do |name, event_id|
      event = $game_map.events[event_id]
      next if !event
      visible = selected.include?(name)
      positions = multiplayer? ? LAYOUTS["Sidelines"] :
                    (LAYOUTS[$PokemonGlobal.arena_demo_layout] || LAYOUTS["Sidelines"])
      x, y = positions[event_id - 3]
      event.moveto(x, y)
      event.transparent = !visible
      event.through = !visible
    end
  end

  def open
    choices = ["Manage arena objects", "Challenge the sample trainer", "Players in arena"]
    choices << "Leave the arena" if $game_map.map_id == MAP_ID
    choices << "Close"
    choice = pbMessage("Arena Demo", choices, -1)
    case choice
    when 0 then manage_objects
    when 1 then challenge_trainer
    when 2 then players_menu
    when 3 then leave if $game_map.map_id == MAP_ID
    end
  end

  def manage_objects
    if multiplayer?
      choice = pbMessage("This shared arena uses a fixed layout. Personal customization is available offline.",
                         ["Heal my team", "Back"], -1)
      heal_team if choice == 0
      return
    end
    loop do
      placed = objects
      summary = placed.empty? ? "No objects selected." : "Selected: #{placed.join(', ')}"
      choices = ["Add an object", "Remove an object", "Obstacle arrangement",
                 "Apply a layout preset", "Trainer difficulty", "Heal my team", "Back"]
      choice = pbMessage("Arena layout (#{placed.length}/#{MAX_OBJECTS})\n#{summary}",
                         choices, -1)
      case choice
      when 0 then add_object
      when 1 then remove_object
      when 2 then choose_layout
      when 3 then choose_preset
      when 4 then choose_difficulty
      when 5
        heal_team
      else
        break
      end
    end
  end

  def heal_team
    $player.party.each { |pkmn| pkmn.heal }
    pbMessage("Your team is ready to train again.")
  end

  def choose_layout
    names = LAYOUTS.keys
    choice = pbMessage("Choose an obstacle arrangement.", names + ["Cancel"], -1)
    return if choice < 0 || choice >= names.length
    return unless placement_clear?(objects, names[choice])
    $PokemonGlobal.arena_demo_layout = names[choice]
    refresh_objects
  end

  def choose_preset
    names = ["Clear floor", "Light training", "Full obstacle course", "Cancel"]
    choice = pbMessage("Choose a layout preset.", names, -1)
    return if choice < 0 || choice >= 3
    selected = [[], OBJECTS.first(3), OBJECTS.dup][choice]
    return unless placement_clear?(selected)
    $PokemonGlobal.arena_demo_objects = selected
    refresh_objects
  end

  # Reject an overlapping edit rather than unexpectedly moving the player.
  def placement_clear?(selected, layout = nil)
    if multiplayer?
      pbMessage("The shared arena's obstacle layout is fixed. Customize your personal arena offline.")
      return false
    end
    return true if $game_map.map_id != MAP_ID
    positions = LAYOUTS[layout || $PokemonGlobal.arena_demo_layout] || LAYOUTS["Sidelines"]
    blocked = selected.any? do |name|
      index = OBJECTS.index(name)
      index && positions[index] == [$game_player.x, $game_player.y]
    end
    if blocked
      pbMessage("An obstacle would be placed where you are standing. Step aside and try again.")
    end
    return !blocked
  end

  def choose_difficulty
    names = ["Beginner (levels 5-6)", "Standard (levels 8-9)", "Advanced (levels 12-13)", "Cancel"]
    choice = pbMessage("Choose the arena trainer's team level.", names, -1)
    return if choice < 0 || choice >= 3
    $PokemonGlobal.arena_demo_difficulty = choice
  end

  def add_object
    placed = objects
    if placed.length >= MAX_OBJECTS
      pbMessage("The demo supports up to #{MAX_OBJECTS} objects.")
      return
    end
    available = OBJECTS - placed
    return if available.empty?
    choice = pbMessage("Choose an arena object to add.", available + ["Cancel"], -1)
    return if choice < 0 || choice >= available.length
    return unless placement_clear?(placed + [available[choice]])
    placed << available[choice]
    refresh_objects
    pbMessage("#{available[choice]} added to your arena layout.")
  end

  def remove_object
    return unless placement_clear?([])
    placed = objects
    if placed.empty?
      pbMessage("There are no objects to remove.")
      return
    end
    choice = pbMessage("Choose an object to remove.", placed + ["Cancel"], -1)
    return if choice < 0 || choice >= placed.length
    removed = placed.delete_at(choice)
    refresh_objects
    pbMessage("#{removed} removed from your arena layout.")
  end

  def challenge_trainer
    if !$player || $player.able_pokemon_count == 0
      pbMessage("You need a Pokémon able to battle first.")
      return
    end
    return unless pbConfirmMessage("I'm the arena trainee. Ready for a practice battle?")
    foe = NPCTrainer.new(TRAINER_NAME, TRAINER_TYPE)
    offset = [-3, 0, 4][$PokemonGlobal.arena_demo_difficulty || 1] || 0
    foe.party = TRAINER_TEAM.map { |species, level| Pokemon.new(species, level + offset, foe) }
    TrainerBattle.start(foe)
  end
end

EventHandlers.add(:on_frame_update, :arena_demo_session_layout, proc {
  if $game_map && $game_map.map_id == ArenaDemo::MAP_ID
    session = [$game_map.object_id, !!ArenaDemo.multiplayer?]
    if ArenaDemo.instance_variable_get(:@layout_session) != session
      ArenaDemo.refresh_objects
      ArenaDemo.instance_variable_set(:@layout_session, session)
    end
  end
})

class PokemonGlobalMetadata
  attr_accessor :arena_demo_objects
  attr_accessor :arena_demo_return
  attr_accessor :arena_demo_layout
  attr_accessor :arena_demo_difficulty
end

MenuHandlers.add(:pause_menu, :arena_demo, {
  "name"      => _INTL("Arena Demo"),
  "order"     => 90,
  "condition" => proc { next $player && $game_map },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    ArenaDemo.enter
    menu.pbRefresh
  }
})

class Game_Map
  alias arena_demo_setup setup

  def setup(map_id)
    arena_demo_setup(map_id)
    ArenaDemo.refresh_objects if map_id == ArenaDemo::MAP_ID
  end
end
