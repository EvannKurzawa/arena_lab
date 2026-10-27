# Preserve errors during server-save restoration, before the map scene can show
# Essentials' normal error UI. Log only exception details, never save contents.
module ArenaDemo
  module LoadDiagnostics
    def load(save_data)
      PEMK.log("arena: restoring saved game") if defined?(PEMK) && ENV["ARENA_DIAGNOSTICS"] == "1"
      result = super
      PEMK.log("arena: saved game restored") if defined?(PEMK) && ENV["ARENA_DIAGNOSTICS"] == "1"
      result
    rescue Exception => error
      if defined?(PEMK) && !error.is_a?(SystemExit)
        PEMK.log("arena: load failed #{error.class}: #{error.message}")
        (error.backtrace || []).first(20).each { |line| PEMK.log("arena: #{line}") }
      end
      raise
    end
  end
end
unless Game.singleton_class.ancestors.include?(ArenaDemo::LoadDiagnostics)
  Game.singleton_class.prepend(ArenaDemo::LoadDiagnostics)
end
