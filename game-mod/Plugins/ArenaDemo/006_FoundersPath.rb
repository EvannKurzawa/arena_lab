module ArenaDemo
  ROUTE_MAP_ID = 103
  ROUTE_ENCOUNTERS = [[50, :RATTATA, 3, 5], [30, :CATERPIE, 3, 4], [20, :SPEAROW, 4, 6]].freeze

  module_function

  def trail_scout
    if multiplayer?
      pbMessage("Founders' Path is an offline expedition. Choose offline at login to explore and catch Pokemon here.")
      return
    end
    pbMessage("Founders' Path follows the old arena supply road. The first keepers trained with Pokemon they met in these fields.")
    if pbConfirmMessage("Walk to Founders' Path? Wild Pokemon live in the tall grass.")
      transfer_to(ROUTE_MAP_ID, 12, 16, 8)
    end
  end

  def return_from_route
    enter_town
  end

  def town_guide
    if multiplayer?
      pbMessage("Welcome to Arena Town. Your entrance-room attendant arranges private visits. The catching expedition is available offline.")
      return
    end
    unless $PokemonGlobal.arena_trail_supplies
      pbMessage("Our arena began as a meeting place for travelers and their Pokemon. Bring back a Rattata, Caterpie or Spearow from Founders' Path to continue that tradition.")
      $PokemonGlobal.arena_trail_supplies = true if pbReceiveItem(:POKEBALL, 10)
      return
    end
    caught = ROUTE_ENCOUNTERS.any? { |entry| $player.owned?(entry[1]) }
    if caught && !$PokemonGlobal.arena_trail_complete
      pbMessage("A new partner for your arena! The old keepers carved this promise into the gate: every great arena begins with a friendship.")
      $PokemonGlobal.arena_trail_complete = true if pbReceiveItem(:GREATBALL, 3)
    elsif $PokemonGlobal.arena_trail_complete
      pbMessage("Your arena carries the keepers' tradition now. Organize your new partner at the entrance PC, then train together inside.")
    else
      pbMessage("Talk to the trail scout nearby. Find a partner in the grass, then come back to me. We are looking for Rattata, Caterpie or Spearow.")
    end
    heal_team if pbConfirmMessage("Rest your team before the next expedition?")
  end

  module TrailEncounters
    def setup(map_id)
      super
      return unless map_id == ArenaDemo::ROUTE_MAP_ID
      # Keep this first route strictly offline; PEMK's server encounter export
      # and online reward authority are not extended by this small story slice.
      return if ArenaDemo.multiplayer?
      @step_chances[:Land] = 21
      @encounter_tables[:Land] = ArenaDemo::ROUTE_ENCOUNTERS.map(&:dup)
    end
  end
end

PokemonEncounters.prepend(ArenaDemo::TrailEncounters) if defined?(PokemonEncounters)

class PokemonGlobalMetadata
  attr_accessor :arena_trail_supplies
  attr_accessor :arena_trail_complete
end
