# frozen_string_literal: true
require 'zlib'
require 'digest'

# Update only our entry in an already compiled, trusted local Essentials cache.
# This avoids a stale plugin when cache/source mtimes came from different clocks.
project = File.expand_path(ARGV.fetch(0))
plugin = File.join(project, 'Plugins', 'ArenaDemo')
cache = File.join(project, 'Data', 'PluginScripts.rxdata')
abort 'Missing installed ArenaDemo metadata' unless File.file?(File.join(plugin, 'meta.txt'))
unless File.file?(cache)
  puts 'No compiled plugin cache yet; the debug engine will compile installed plugins.'
  exit
end
version = File.read(File.join(plugin, 'meta.txt'))[/^Version\s*=\s*(\S+)/i, 1]
abort 'Missing ArenaDemo version' unless version
before = File.binread(cache)
entries = Marshal.load(before)
abort 'Unexpected plugin cache format' unless entries.is_a?(Array)
matches = entries.select { |entry| entry.is_a?(Array) && entry[0] == 'Arena Demo' }
if matches.empty?
  puts 'ArenaDemo is not compiled yet; the debug engine will compile installed plugins.'
  exit
end
abort 'Duplicate ArenaDemo cache entries' unless matches.length == 1
entry = matches.first
abort 'Unexpected ArenaDemo cache metadata' unless entry[1].is_a?(Hash)
files = Dir.glob('**/*.rb', base: plugin).sort
abort 'No installed ArenaDemo scripts' if files.empty?
scripts = files.map do |relative|
  [relative, Zlib::Deflate.deflate(File.binread(File.join(plugin, relative)))]
end
changed = entry[1][:version] != version || entry[2] != scripts
if changed
  backup = cache + ".before-arena-#{version}.bak"
  begin
    File.open(backup, File::WRONLY | File::CREAT | File::EXCL | File::BINARY) { |file| file.write(before) }
  rescue Errno::EEXIST
  end
  entry[1][:version] = version
  entry[2] = scripts
  temporary = cache + '.arena.tmp'
  begin
    File.binwrite(temporary, Marshal.dump(entries))
    File.rename(temporary, cache)
  ensure
    File.delete(temporary) if File.file?(temporary)
  end
end
digest = Digest::SHA256.hexdigest(scripts.map { |name, code| name + Zlib::Inflate.inflate(code) }.join)
puts "ArenaDemo #{version} cache verified (#{files.length} scripts, #{digest[0, 12]}#{changed ? ', updated' : ''})."
