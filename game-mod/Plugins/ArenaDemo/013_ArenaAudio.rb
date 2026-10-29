# Apply audio selection to loaded maps too, including serialized older saves.
module ArenaDemo
  module MapAudio
    module_function

    def prepare(map)
      return unless [100, 101, 102].include?(map.map_id)
      data = map.instance_variable_get(:@map)
      return unless data
      files = Dir.glob('Audio/BGM/*').select do |path|
        File.file?(path) && path.match?(/\.(ogg|wav|mp3|flac|opus|midi?)\z/i)
      end
      decoded = files.reject { |path| path.match?(/\.midi?\z/i) }
      files = decoded unless decoded.empty?
      bgm = data.instance_variable_get(:@bgm)
      current = bgm && bgm.name.to_s
      unless files.any? { |path| File.basename(path, File.extname(path)).casecmp?(current.to_s) }
        track = files.sort.find { |path| File.basename(path).match?(/town|city|route/i) } || files.sort.first
        bgm = RPG::AudioFile.new(File.basename(track, File.extname(track)), 80, 100) if track
      end
      if bgm && !bgm.name.to_s.empty?
        bgm.volume = 80 if bgm.volume.to_i <= 0
        data.instance_variable_set(:@bgm, bgm)
        data.instance_variable_set(:@autoplay_bgm, true)
      end
      details = "map=#{map.map_id} track=#{bgm && bgm.name.inspect} " +
                "track_volume=#{bgm && bgm.volume} files=#{files.length} " +
                "music_volume=#{defined?($PokemonSystem) && $PokemonSystem && $PokemonSystem.bgmvolume}\n"
      begin
        File.write('Data/ArenaAudioDiagnostic.txt', details)
      rescue SystemCallError, IOError
        # Diagnostics must not interrupt transfers or playback.
      end
    end
  end

  module MapAudioPlayback
    def autoplay
      ArenaDemo::MapAudio.prepare(self)
      super
    end
  end
end
Game_Map.prepend(ArenaDemo::MapAudioPlayback) if defined?(Game_Map)
