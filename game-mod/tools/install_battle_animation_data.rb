# Standalone Marshal adapter for Essentials' animation data; no assets shipped.
require 'digest'
require 'fileutils'
class PBAnimations < Array
  def entries; @array; end
end
class PBAnimation < Array
  attr_reader :name, :graphic
  def frames; @array; end
end
class PBAnimTiming; end
class Color
  def self._load(data); allocate.tap { |v| v.instance_variable_set(:@raw, data) }; end
  def _dump(_depth); @raw; end
end
class Tone < Color; end
class Table < Color; end

game, source = ARGV
abort 'Usage: install_battle_animation_data.rb GAME_ROOT PACK_DATA' unless game && source
pack = Marshal.load(File.binread(source))
abort 'Unexpected battle animation format' unless pack.is_a?(PBAnimations) && pack.entries.is_a?(Array)
if ARGV.include?('--inspect')
  named = pack.entries.compact.select { |a| a.name.to_s.start_with?('Move:', 'OppMove:') }
  puts "#{pack.entries.length} records; #{named.length} move records"
  puts "Missing/short: #{named.select { |a| !a.frames || a.frames.length <= 1 }.map(&:name).inspect}"
  [:MUDSLAP, :FUSIONBOLT].each { |m| a = named.find { |v| v.name == "Move:#{m}" }; puts [m, a&.name, a&.frames&.length, a&.graphic].inspect }
  exit
end
target = File.join(game, 'Data/PkmnAnimations.rxdata')
backup = File.join(game, 'Data/ArenaLab-BattleAnimations-before-Gen9.rxdata')
marker = File.join(game, 'Data/ArenaLab-BattleAnimations-Gen9.txt')
source_hash = Digest::SHA256.file(source).hexdigest
target_hash = Digest::SHA256.file(target).hexdigest
if File.file?(marker)
  expected_source, expected_target = File.read(marker).split
  abort 'Installed battle animations were edited; preserve and review before reinstalling.' unless expected_source == source_hash && expected_target == target_hash
  puts 'Battle animation data already installed.'
  exit
end
original = Marshal.load(File.binread(target))
abort 'Unexpected installed battle animation format' unless original.is_a?(PBAnimations) && original.entries.is_a?(Array)
FileUtils.copy_file(target, backup) unless File.file?(backup)
pack_root = File.dirname(File.dirname(File.expand_path(source)))
['Graphics/Animations', 'Audio/SE'].each do |folder|
  Dir.glob(File.join(pack_root, folder, '**', '*')).each do |asset|
    next unless File.file?(asset)
    relative = asset.delete_prefix(pack_root + '/')
    destination = File.join(game, relative)
    next if File.file?(destination) && Digest::SHA256.file(destination).hexdigest == Digest::SHA256.file(asset).hexdigest
    if File.file?(destination)
      saved_asset = File.join(game, 'Data/ArenaLab-BattlePackAssetBackup', relative)
      FileUtils.mkdir_p(File.dirname(saved_asset))
      FileUtils.copy_file(destination, saved_asset) unless File.file?(saved_asset)
    end
    FileUtils.mkdir_p(File.dirname(destination))
    FileUtils.copy_file(asset, destination)
  end
end
# Keep the whole pack contiguous: charging/impact variants use adjacent IDs.
# Blank placeholders have no names in the compiler; suppress their Move names
# so an unavailable pack move cannot mask an existing/default animation.
pack.entries.each do |a|
  next unless a && a.frames && a.frames.length <= 1
  a.instance_variable_set(:@name, '') if a.name.to_s.match?(/\A(?:Opp)?Move:/)
end
original.entries.concat(pack.entries)
payload = Marshal.dump(original)
File.binwrite(target + '.arena-tmp', payload)
FileUtils.mv(target + '.arena-tmp', target, force: true)
# Rebuild with the engine's naming convention now; no debug key press needed.
mapping = [{}, {}]
original.entries.each_with_index do |a, index|
  next unless a && (match = a.name.to_s.match(/\A(OppMove|Move):\s*([A-Z0-9_]+)\s*\z/))
  mapping[match[1] == 'Move' ? 0 : 1][match[2].to_sym] = index
end
map_path = File.join(game, 'Data/move2anim.dat')
FileUtils.copy_file(map_path, map_path + '.before-Gen9') if File.file?(map_path) && !File.file?(map_path + '.before-Gen9')
File.binwrite(map_path + '.arena-tmp', Marshal.dump(mapping))
FileUtils.mv(map_path + '.arena-tmp', map_path, force: true)
File.write(marker, "#{source_hash} #{Digest::SHA256.hexdigest(payload)}\n")
puts "Installed #{pack.entries.length} battle animation records; #{mapping[0].length} direct move mappings. Backup retained."
