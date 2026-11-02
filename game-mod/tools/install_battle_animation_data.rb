# Standalone Marshal adapter for Essentials' animation data; no assets shipped.
require 'digest'
require 'fileutils'
require 'stringio'
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

# Compare values, including frame/timing data, rather than Marshal object links
# or String encoding metadata. Essentials may change those when saving.
def animation_content(value)
  case value
  when String then [:string, value.b.unpack1('H*')]
  when Symbol, Numeric, NilClass, TrueClass, FalseClass then value
  else
    [value.class.name,
     (value.map { |item| animation_content(item) } if value.is_a?(Array)),
     (value.map { |key, item| [animation_content(key), animation_content(item)] } if value.is_a?(Hash)),
     value.instance_variables.sort.map { |key| [key, animation_content(value.instance_variable_get(key))] }]
  end
end

def animation_digest(data)
  stream = StringIO.new(data)
  value = Marshal.load(stream)
  raise 'Installed battle animations were edited or have an unexpected format; preserve and review before reinstalling.' unless value.is_a?(PBAnimations) && value.entries.is_a?(Array) && stream.eof?
  Digest::SHA256.hexdigest(Marshal.dump(animation_content(value)))
end

def write_animation_marker(path, source_hash, data)
  File.write(path + '.arena-tmp', "#{source_hash} #{Digest::SHA256.hexdigest(data)} #{animation_digest(data)}\n")
  FileUtils.mv(path + '.arena-tmp', path, force: true)
end

def prepare_animation_pack(pack)
  pack.entries.each do |a|
    next unless a && a.frames && a.frames.length <= 1
    a.instance_variable_set(:@name, '') if a.name.to_s.match?(/\A(?:Opp)?Move:/)
  end
end

game, source = ARGV
if source == '--verify-installed'
  begin
    marker = File.join(game, 'Data/ArenaLab-BattleAnimations-Gen9.txt')
    parts = File.read(marker).split
    raise 'Invalid battle animation marker' unless [2, 3].include?(parts.length) && parts.all? { |part| part.match?(/\A[0-9a-f]{64}\z/i) }
    data = File.binread(File.join(game, 'Data/PkmnAnimations.rxdata'))
    current_hash = Digest::SHA256.hexdigest(data)
    # Old installations need their original backup and verified pack to establish
    # a trusted content fingerprint if the byte fingerprint already differs.
    exit 2 if parts.length == 2 && current_hash != parts[1]
    if current_hash != parts[1]
      raise 'Installed battle animations were edited; preserve and review before reinstalling.' unless animation_digest(data) == parts[2]
    end
    write_animation_marker(marker, parts[0], data) if parts.length == 2 || current_hash != parts[1]
    puts 'Battle animation content verified; local data preserved.'
    exit
  rescue StandardError => error
    warn error.message
    exit 1
  end
end
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
  expected_source, expected_target, expected_content = File.read(marker).split
  abort 'Installed battle animation pack differs; preserve and review before reinstalling.' unless expected_source == source_hash
  data = File.binread(target)
  if expected_target != target_hash
    unless expected_content
      # Reproduce the original merge without installing anything. Only trust it
      # if its binary hash matches the old installation receipt exactly.
      reference = Marshal.load(File.binread(backup))
      prepare_animation_pack(pack)
      reference.entries.concat(pack.entries)
      reference_data = Marshal.dump(reference)
      abort 'Cannot verify original battle animations; preserve and review before reinstalling.' unless Digest::SHA256.hexdigest(reference_data) == expected_target
      expected_content = animation_digest(reference_data)
    end
    abort 'Installed battle animations were edited; preserve and review before reinstalling.' unless animation_digest(data) == expected_content
  end
  write_animation_marker(marker, source_hash, data)
  puts 'Battle animation content verified; local data preserved.'
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
prepare_animation_pack(pack)
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
write_animation_marker(marker, source_hash, payload)
puts "Installed #{pack.entries.length} battle animation records; #{mapping[0].length} direct move mappings. Backup retained."
