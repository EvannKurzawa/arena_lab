# Explicit temporary debug release migration, applied once per local profile.
# Preserve the previous party in saved metadata for later recovery.
module ArenaDemo
  module DebugParty
    VERSION = 1
    SPECIES = :MEW
    MOVES = [:CUT, :SURF, :ROCKSMASH, :STRENGTH].freeze
    module_function

    def apply(save = true)
      return false unless $player && $PokemonGlobal
      return false if $PokemonGlobal.arena_debug_party_version == VERSION
      pokemon = Pokemon.new(SPECIES, 100, $player)
      pokemon.moves.clear
      MOVES.each { |move| pokemon.learn_move(move) }
      pokemon.heal
      previous = $player.party
      backup = $PokemonGlobal.arena_debug_party_backup
      version = $PokemonGlobal.arena_debug_party_version
      $PokemonGlobal.arena_debug_party_backup ||= previous.dup
      $player.party = [pokemon]
      $PokemonGlobal.arena_debug_party_version = VERSION
      if save && !Game.save
        $player.party = previous
        $PokemonGlobal.arena_debug_party_backup = backup
        $PokemonGlobal.arena_debug_party_version = version
        return false
      end
      true
    rescue StandardError
      if previous
        $player.party = previous
        $PokemonGlobal.arena_debug_party_backup = backup
        $PokemonGlobal.arena_debug_party_version = version
      end
      raise
    end

    def update
      return if ENV.keys.any? { |key| key.start_with?('ARENA_') && key.end_with?('_PROBE') }
      return unless $scene.is_a?(Scene_Map) && $game_temp && !$game_temp.in_battle && !$game_temp.in_menu
      return if $game_temp.message_window_showing || pbMapInterpreterRunning? || $game_temp.player_transferring
      return if @retry_at && System.uptime < @retry_at
      changed = apply
      FollowingPkmn.refresh(false) if changed && defined?(FollowingPkmn) && FollowingPkmn.can_check?
      @retry_at = System.uptime + 5
    rescue StandardError => error
      @retry_at = System.uptime + 5
      echoln("[Arena Lab] Debug party migration failed: #{error.class}: #{error.message}")
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_debug_party_version, :arena_debug_party_backup
end
EventHandlers.add(:on_frame_update, :arena_debug_party, proc { ArenaDemo::DebugParty.update })
