# frozen_string_literal: true
require 'zlib'
require 'digest'
game = File.expand_path('runtime/essentials-v21.1-base', __dir__)
cache = File.join(game, 'Data/PluginScripts.rxdata')
Marshal.load(File.binread(cache)).each do |name, meta, scripts|
  puts "#{name} #{meta[:version]}"
  scripts.each do |file, compressed|
    next unless name == 'Arena Demo'
    code = Zlib::Inflate.inflate(compressed)
    installed = File.join(game, 'Plugins/ArenaDemo', file)
    puts "  #{file}: #{File.file?(installed) && Digest::SHA256.hexdigest(File.binread(installed)) == Digest::SHA256.hexdigest(code) ? 'current' : 'different'}"
  end
end
puts "Error files: #{Dir.glob(File.join(game, '*')).select { |path| File.basename(path).match?(/error|crash/i) }.inspect}"
