# Explicit temporary debug release migration, applied once per local profile.
# Preserve the previous party in saved metadata for later recovery.
module ArenaDemo
  module DebugParty
    VERSION = 2
    SPECIES = :MEW
    MOVES = [:CUT, :SURF, :ROCKSMASH, :STRENGTH].freeze
    module_function

    def build_party
      raise 'Dark Lugia assets are not installed.' unless defined?(ArenaDemo::DarkLugia) && ArenaDemo::DarkLugia.register
      kyurem = Pokemon.new(:KYUREM, 100, $player)
      kyurem.form = 1   # White; Essentials uses glowing form 3 during battle.
      giratina = Pokemon.new(:GIRATINA, 100, $player)
      giratina.item = :GRISEOUSORB   # Keeps Origin Forme outside battle too.
      giratina.form = 1
      mew = Pokemon.new(SPECIES, 100, $player)
      mew.moves.clear
      MOVES.each { |move| mew.learn_move(move) }
      party = [kyurem, ArenaDemo::DarkLugia.make(100),
               Pokemon.new(:ZEKROM, 100, $player), Pokemon.new(:LUGIA, 100, $player),
               giratina, mew]
      party.each(&:heal)
      party
    end

    def apply(save = true)
      return false unless $player && $PokemonGlobal
      return false if $PokemonGlobal.arena_debug_party_version == VERSION
      party = build_party
      previous = $player.party
      backup = $PokemonGlobal.arena_debug_party_backup
      version = $PokemonGlobal.arena_debug_party_version
      backups = $PokemonGlobal.arena_debug_party_backups
      $PokemonGlobal.arena_debug_party_backups = (backups || {}).merge(VERSION => previous.dup)
      $PokemonGlobal.arena_debug_party_backup ||= previous.dup
      $player.party = party
      $PokemonGlobal.arena_debug_party_version = VERSION
      if save && !Game.save
        $player.party = previous
        $PokemonGlobal.arena_debug_party_backup = backup
        $PokemonGlobal.arena_debug_party_version = version
        $PokemonGlobal.arena_debug_party_backups = backups
        return false
      end
      true
    rescue StandardError
      if previous
        $player.party = previous
        $PokemonGlobal.arena_debug_party_backup = backup
        $PokemonGlobal.arena_debug_party_version = version
        $PokemonGlobal.arena_debug_party_backups = backups
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
  attr_accessor :arena_debug_party_version, :arena_debug_party_backup, :arena_debug_party_backups
end
EventHandlers.add(:on_frame_update, :arena_debug_party, proc { ArenaDemo::DebugParty.update })
