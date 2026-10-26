# Arena Lab: a small Essentials v21.1 plugin prototype.
# Install this folder in the complete game's Plugins/ directory.
# Team species/levels use normal Essentials data and TrainerBattle.

module ArenaDemo
  MAP_ID = 100
  MAX_OBJECTS = 3
  OBJECTS = ["Boulder", "Rock", "Tree"].freeze
  OBJECT_EVENTS = { "Boulder" => 3, "Rock" => 4, "Tree" => 5 }.freeze
  TRAINER_NAME = "Arena Trainee"
  TRAINER_TYPE = :YOUNGSTER
  TRAINER_TEAM = [[:RATTATA, 8], [:EKANS, 9]].freeze
  QUICK_START_TEAM = [[:PIKACHU, 10]].freeze

  module_function

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
    selected = objects
    OBJECT_EVENTS.each do |name, event_id|
      event = $game_map.events[event_id]
      next if !event
      visible = selected.include?(name)
      event.transparent = !visible
      event.through = !visible
    end
  end

  def open
    choices = ["Manage arena objects", "Challenge the sample trainer"]
    choices << "Leave the arena" if $game_map.map_id == MAP_ID
    choices << "Close"
    choice = pbMessage("Arena Demo", choices, choices.length - 1)
    case choice
    when 0 then manage_objects
    when 1 then challenge_trainer
    when 2 then leave if $game_map.map_id == MAP_ID
    end
  end

  def manage_objects
    loop do
      placed = objects
      summary = placed.empty? ? "No objects selected." : "Selected: #{placed.join(', ')}"
      choices = ["Add an object", "Remove an object", "View layout", "Back"]
      choice = pbMessage("Arena layout (#{placed.length}/#{MAX_OBJECTS})\n#{summary}",
                         choices, choices.length - 1)
      case choice
      when 0 then add_object
      when 1 then remove_object
      when 2
        pbMessage(placed.empty? ? "The arena is empty." : "Arena objects: #{placed.join(', ')}")
      else
        break
      end
    end
  end

  def add_object
    placed = objects
    if placed.length >= MAX_OBJECTS
      pbMessage("The demo supports up to #{MAX_OBJECTS} objects.")
      return
    end
    available = OBJECTS - placed
    return if available.empty?
    choice = pbMessage("Choose an arena object to add.", available + ["Cancel"], available.length)
    return if choice < 0 || choice >= available.length
    placed << available[choice]
    refresh_objects
    pbMessage("#{available[choice]} added to your arena layout.")
  end

  def remove_object
    placed = objects
    if placed.empty?
      pbMessage("There are no objects to remove.")
      return
    end
    choice = pbMessage("Choose an object to remove.", placed + ["Cancel"], placed.length)
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
    foe = NPCTrainer.new(TRAINER_NAME, TRAINER_TYPE)
    foe.party = TRAINER_TEAM.map { |species, level| Pokemon.new(species, level, foe) }
    pbMessage("#{TRAINER_NAME} is ready for a battle!")
    TrainerBattle.start(foe)
  end
end

class PokemonGlobalMetadata
  attr_accessor :arena_demo_objects
  attr_accessor :arena_demo_return
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
