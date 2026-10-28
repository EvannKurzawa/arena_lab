# Arena Lab: a small Essentials v21.1 plugin prototype.
# Install this folder in the complete game's Plugins/ directory.
# Team species/levels use normal Essentials data and TrainerBattle.

module ArenaDemo
  MAP_ID = 100
  TOWN_MAP_ID = 101
  ENTRANCE_MAP_ID = 102
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

  # Fallbacks also keep this plugin usable without the optional PEMK extension.
  def customization_locked?
    multiplayer?
  end

  def customization_allowed?
    return true if $game_map && $game_map.map_id == MAP_ID && !customization_locked?
    pbMessage("Customize from the arena menu while it is closed to visitors.")
    false
  end

  def effective_layout
    return { :objects => OBJECTS, :layout => "Sidelines", :difficulty => 1 } if multiplayer?
    { :objects => objects, :layout => $PokemonGlobal.arena_demo_layout || "Sidelines",
      :difficulty => $PokemonGlobal.arena_demo_difficulty || 1 }
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
    if [TOWN_MAP_ID, ENTRANCE_MAP_ID].include?($game_map.map_id)
      pbMessage("Walk through the arena building's entrance to reach the training room.")
      return
    end
    enter_town
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
    enter_town
    pbMessage("Welcome to Arena Town! The building just north of you is your arena. Inside, the attendant handles visits and the PC opens Pokemon storage.")
  end

  def enter_town
    if defined?(Visits) && Visits.locked?
      if Visits.guest?
        Visits.close_arena if pbConfirmMessage("Leave this visit and return to your own entrance room?")
      else
        pbMessage("Close your arena with the attendant before returning to town.")
      end
      return
    end
    point = File.read(File.join("Data", "ArenaDemoTownStart.txt")).split(",").map(&:to_i)
    if $PokemonGlobal.respond_to?(:pokecenterMapId=)
      $PokemonGlobal.pokecenterMapId = ENTRANCE_MAP_ID
      $PokemonGlobal.pokecenterX, $PokemonGlobal.pokecenterY = 7, 10
      $PokemonGlobal.pokecenterDirection = 8
    end
    transfer_to(TOWN_MAP_ID, *point)
  end

  def enter_entrance
    transfer_to(ENTRANCE_MAP_ID, 7, 10, 8)
  end

  def enter_training_room
    transfer_to(MAP_ID, *map_start)
  end

  def exit_training_room
    # Shared multiplayer continues to use its existing return behavior.
    transfer_to(ENTRANCE_MAP_ID, 7, 3, 2)
  end

  def storage_pc
    pbPokeCenterPC
  end

  def transfer_to(map_id, x, y, direction)
    return if defined?(Visits) && !Visits.allow_travel?(map_id)
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
    # A visit uses the host's frozen snapshot; personal saves stay untouched.
    settings = effective_layout
    selected = settings[:objects]
    OBJECT_EVENTS.each do |name, event_id|
      event = $game_map.events[event_id]
      next if !event
      visible = selected.include?(name)
      positions = LAYOUTS[settings[:layout]] || LAYOUTS["Sidelines"]
      x, y = positions[event_id - 3]
      event.moveto(x, y)
      event.transparent = !visible
      event.through = !visible
    end
  end

  def open
    actions = []
    actions << ["Challenge the sample trainer", proc { challenge_trainer }]
    actions << ["Players in arena", proc { players_menu }]
    actions << ["Return to entrance room", proc { exit_training_room }] if $game_map.map_id == MAP_ID
    choice = pbMessage("Arena", actions.map(&:first) + ["Close"], -1)
    actions[choice][1].call if choice && choice >= 0 && choice < actions.length
  end

  def manage_objects
    if customization_locked?
      choice = pbMessage("Customization is locked while the arena is open to visitors or an online request is pending.",
                         ["Heal my team", "Back"], -1)
      heal_team if choice == 0
      return
    end
    return unless customization_allowed?
    loop do
      break unless customization_allowed?
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
    return unless customization_allowed?
    names = LAYOUTS.keys
    choice = pbMessage("Choose an obstacle arrangement.", names + ["Cancel"], -1)
    return if choice < 0 || choice >= names.length
    return unless placement_clear?(objects, names[choice])
    $PokemonGlobal.arena_demo_layout = names[choice]
    refresh_objects
  end

  def choose_preset
    return unless customization_allowed?
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
    return false unless customization_allowed?
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
    return unless customization_allowed?
    names = ["Beginner (levels 5-6)", "Standard (levels 8-9)", "Advanced (levels 12-13)", "Cancel"]
    choice = pbMessage("Choose the arena trainer's team level.", names, -1)
    return if choice < 0 || choice >= 3
    return unless customization_allowed?
    $PokemonGlobal.arena_demo_difficulty = choice
  end

  def add_object
    return unless customization_allowed?
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
    return unless placement_clear?([])
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
    offset = [-3, 0, 4][effective_layout[:difficulty]] || 0
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
  attr_accessor :arena_demo_layout
  attr_accessor :arena_demo_difficulty
end

MenuHandlers.remove(:pause_menu, :arena_demo)

class Game_Map
  alias arena_demo_setup setup

  def setup(map_id)
    arena_demo_setup(map_id)
    ArenaDemo.refresh_objects if map_id == ArenaDemo::MAP_ID
  end
end
