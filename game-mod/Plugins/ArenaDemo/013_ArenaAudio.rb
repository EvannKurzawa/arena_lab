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
      bgm = data.instance_variable_get(:@bgm)
      current = bgm && bgm.name.to_s
      track = ArenaDemo::MusicSelection.select(files, current)
      bgm = track ? RPG::AudioFile.new(File.basename(track, File.extname(track)), 80, 100) :
                    RPG::AudioFile.new('', 80, 100)
      data.instance_variable_set(:@bgm, bgm)
      data.instance_variable_set(:@autoplay_bgm, !!track)
      details = "map=#{map.map_id} track=#{bgm && bgm.name.inspect} " +
                "track_volume=#{bgm && bgm.volume} files=#{files.length} " +
                "music_volume=#{defined?($PokemonSystem) && $PokemonSystem && $PokemonSystem.bgmvolume}\n" +
                "available_tracks=#{files.map { |path| File.basename(path) }.sort.inspect}\n"
      begin
        File.write('Data/ArenaAudioDiagnostic.txt', details)
      rescue SystemCallError, IOError
        # Diagnostics must not interrupt transfers or playback.
      end
      track ? :selected : :unavailable
    end
  end

  module MapAudioPlayback
    def autoplay
      result = ArenaDemo::MapAudio.prepare(self)
      pbBGMStop if result == :unavailable
      super
    end
  end
end
Game_Map.prepend(ArenaDemo::MapAudioPlayback) if defined?(Game_Map)
