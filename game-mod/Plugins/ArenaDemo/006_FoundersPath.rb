module ArenaDemo
  VILLAGE_ENCOUNTERS = [[50, :RATTATA, 3, 5], [30, :CATERPIE, 3, 4], [20, :SPEAROW, 4, 6]].freeze
  ROUTE_ENCOUNTERS = VILLAGE_ENCOUNTERS  # Compatibility for older local saves/tests.

  module_function

  def trail_scout
    if multiplayer?
      pbMessage("Wild Pokemon live in the grassy patch just behind me. Catching is available offline.")
      return
    end
    pbMessage("Wild Pokemon roam in the grass. Walk into one, or face it and press Confirm, to battle and catch it.")
  end

  def village_house
    pbMessage("A cozy village home. The residents are out enjoying the day.")
  end

  def village_resident
    pbMessage("Welcome to Arena Village! The stadium is the heart of our town.")
  end

  def town_guide
    if multiplayer?
      pbMessage("Welcome to Arena Village. Your entrance-room attendant arranges private visits. Wild Pokemon encounters are available offline.")
      return
    end
    unless $PokemonGlobal.arena_trail_supplies
      pbMessage("Our arena began as a meeting place for travelers and their Pokemon. Catch a Rattata, Caterpie or Spearow in the village grass to continue that tradition.")
      $PokemonGlobal.arena_trail_supplies = true if pbReceiveItem(:POKEBALL, 10)
      return
    end
    caught = VILLAGE_ENCOUNTERS.any? { |entry| $player.owned?(entry[1]) }
    if caught && !$PokemonGlobal.arena_trail_complete
      pbMessage("A new partner for your arena! The old keepers carved this promise into the gate: every great arena begins with a friendship.")
      $PokemonGlobal.arena_trail_complete = true if pbReceiveItem(:GREATBALL, 3)
    elsif $PokemonGlobal.arena_trail_complete
      pbMessage("Your arena carries the keepers' tradition now. Organize your new partner at the entrance PC, then train together inside.")
    else
      pbMessage("Talk to the scout by the grass. Find a partner in the village grass, then come back to me. We are looking for Rattata, Caterpie or Spearow.")
    end
    heal_team if pbConfirmMessage("Rest your team before the next expedition?")
  end

  module TrailEncounters
    def setup(map_id)
      super
      return unless map_id == ArenaDemo::TOWN_MAP_ID
      # Keep this first catching area strictly offline; PEMK's encounter export
      # and online reward authority are not extended by this small story slice.
      return if ArenaDemo.multiplayer?
      @step_chances[:Land] = 21
      @encounter_tables[:Land] = ArenaDemo::VILLAGE_ENCOUNTERS.map(&:dup)
    end
  end
end

PokemonEncounters.prepend(ArenaDemo::TrailEncounters) if defined?(PokemonEncounters)

class PokemonGlobalMetadata
  attr_accessor :arena_trail_supplies
  attr_accessor :arena_trail_complete
end
