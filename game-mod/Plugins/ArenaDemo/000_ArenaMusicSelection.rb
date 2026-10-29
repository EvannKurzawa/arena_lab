module ArenaDemo
  module MusicSelection
    module_function

    def select(files, current = nil)
      safe = files.reject do |path|
        name = File.basename(path, File.extname(path))
        name.match?(/battle|trainer|encounter|victory|fanfare|evolution|champion|jingle|title|game.?over/i)
      end
      candidates = safe.select do |path|
        File.basename(path, File.extname(path)).match?(/town|city|village|route|forest|cave|overworld|field|home|house|lab|pok[eé]mon.?cent(?:er|re)|gym/i)
      end
      # Local packages may use area names without an English category word.
      candidates = safe if candidates.empty?
      decoded = candidates.reject { |path| path.match?(/\.midi?\z/i) }
      candidates = decoded unless decoded.empty?
      candidates.find { |path| File.basename(path, File.extname(path)).casecmp?(current.to_s) } ||
        candidates.sort.first
    end
  end
end
