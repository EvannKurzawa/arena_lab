require 'digest'
adapter = File.expand_path('../game-mod/tools/install_battle_animation_data.rb', __dir__)
eval(File.read(adapter).split('game, source = ARGV').first, TOPLEVEL_BINDING, adapter)

def canonical(value)
  case value
  when String then [:string, value.b.unpack1('H*')]
  when Symbol, Numeric, NilClass, TrueClass, FalseClass then value
  else
    [value.class.name,
     (value.map { |item| canonical(item) } if value.is_a?(Array)),
     value.instance_variables.sort.map { |key| [key, canonical(value.instance_variable_get(key))] }]
  end
end

ARGV.each do |path|
  data = File.binread(path)
  animations = Marshal.load(data)
  puts "roundtrip_sha256=#{Digest::SHA256.hexdigest(Marshal.dump(animations))}"
  puts "#{path}: bytes=#{data.bytesize} sha256=#{Digest::SHA256.hexdigest(data)}"
  puts "records=#{animations.entries.length} semantic_sha256=#{Digest::SHA256.hexdigest(Marshal.dump(canonical(animations)))}"
end
