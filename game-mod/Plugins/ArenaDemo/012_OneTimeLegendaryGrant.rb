# Local one-time save migration. It runs only while the ignored marker exists,
# only for the primary offline profile, and removes the marker after saving.
module ArenaDemo
  module OneTimeLegendaryGrant
    module_function

    def marker_path
      control = ENV["ARENA_CONTROL_DIR"].to_s
      return nil if control.empty?
      project = File.expand_path("../../../..", control)
      File.join(project, ".arena-grant-zekrom-dialga")
    end

    def report(control, message)
      File.write(File.join(control, "legendary-gift-result.txt"), message + "\n")
    rescue StandardError
      nil
    end

    def update
      return if @finished
      path = marker_path
      return unless path && File.file?(path)
      control = ENV["ARENA_CONTROL_DIR"]
      return if defined?(PEMK) && PEMK.respond_to?(:instance) && PEMK.instance
      return unless defined?(ConnectionMode) && ConnectionMode.offline?
      return unless $player && $player.party && !$game_temp&.in_battle

      requested = [[:ZEKROM, 100], [:DIALGA, 100]]
      missing = requested.reject { |species, _level| $player.party.any? { |pkmn| pkmn.species == species } }
      if missing.empty?
        File.delete(path)
        report(control, "Already present; no duplicate Zekrom or Dialga was added.")
        @finished = true
        return
      end
      if $player.party.length + missing.length > 6
        report(control, "No Pokémon added: the party needs #{missing.length} open slot(s). Keep the marker and free party space, then relaunch.")
        @finished = true
        return
      end

      old_length = $player.party.length
      missing.each { |species, level| $player.party << Pokemon.new(species, level, $player) }
      unless Game.save
        $player.party.slice!(old_length, missing.length)
        report(control, "Save failed; no gift was committed. The one-time marker remains.")
        @finished = true
        return
      end
      File.delete(path)
      report(control, "Added #{missing.map { |species, _level| species }.join(' and ')} at level 100 to the primary offline party and saved successfully.")
      @finished = true
    rescue StandardError => e
      report(control, "Grant failed safely: #{e.class}: #{e.message}") if control
      @finished = true
    end
  end
end

EventHandlers.add(:on_frame_update, :arena_one_time_legendary_grant,
                  proc { ArenaDemo::OneTimeLegendaryGrant.update })
