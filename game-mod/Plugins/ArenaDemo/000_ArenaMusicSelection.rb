module ArenaDemo
  module MusicSelection
    module_function

    def select(files, current = nil)
      candidates = files.select do |path|
        name = File.basename(path, File.extname(path))
        name.match?(/town|city|village|route|forest|cave|overworld|field|home|house|lab|pok[eé]mon.?cent(?:er|re)|gym/i) &&
          !name.match?(/battle|trainer|encounter|victory|fanfare|evolution|champion/i)
      end
      decoded = candidates.reject { |path| path.match?(/\.midi?\z/i) }
      candidates = decoded unless decoded.empty?
      candidates.find { |path| File.basename(path, File.extname(path)).casecmp?(current.to_s) } ||
        candidates.sort.first
    end
  end
end
