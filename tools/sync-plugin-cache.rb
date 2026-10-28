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
before = File.binread(cache)
entries = Marshal.load(before)
abort 'Unexpected plugin cache format' unless entries.is_a?(Array)

changed = false
targets = [
  ['Arena Demo', File.join(project, 'Plugins', 'ArenaDemo')],
  ['Following Pokemon EX', File.join(project, 'Plugins', 'Following Pokemon EX')]
]
targets.each do |name, plugin_dir|
  next unless File.file?(File.join(plugin_dir, 'meta.txt'))
  version = File.read(File.join(plugin_dir, 'meta.txt'))[/^Version\s*=\s*(\S+)/i, 1]
  abort "Missing #{name} version" unless version
  files = Dir.glob('**/*.rb', base: plugin_dir).sort
  abort "No installed #{name} scripts" if files.empty?
  scripts = files.map do |relative|
    [relative, Zlib::Deflate.deflate(File.binread(File.join(plugin_dir, relative)))]
  end
  matches = entries.select { |entry| entry.is_a?(Array) && entry[0] == name }
  abort "Duplicate #{name} cache entries" if matches.length > 1
  if matches.empty?
    entries << [name, { :version => version }, scripts]
    changed = true
    puts "Added #{name} to the compiled plugin cache (#{files.length} scripts)."
    next
  end
  entry = matches.first
  abort "Unexpected #{name} cache metadata" unless entry[1].is_a?(Hash)
  next if entry[1][:version] == version && entry[2] == scripts
  entry[1][:version] = version
  entry[2] = scripts
  changed = true
  puts "Updated #{name} in the compiled plugin cache (#{files.length} scripts)."
end

if changed
  backup = cache + '.before-arena-plugin-sync.bak'
  begin
    File.open(backup, File::WRONLY | File::CREAT | File::EXCL | File::BINARY) { |file| file.write(before) }
  rescue Errno::EEXIST
  end
  temporary = cache + '.arena.tmp'
  begin
    File.binwrite(temporary, Marshal.dump(entries))
    File.rename(temporary, cache)
  ensure
    File.delete(temporary) if File.file?(temporary)
  end
else
  puts 'Arena Demo and Following Pokemon EX compiled plugin cache entries are current.'
end
