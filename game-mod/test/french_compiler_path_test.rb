require 'tmpdir'
require 'rbconfig'

compiler = File.expand_path('../tools/compile_french_core.rb', __dir__)
Dir.mktmpdir('ArenaFrenchPath', File.expand_path('../../tools/runtime', __dir__)) do |directory|
  source = File.join(directory, 'French source')
  Dir.mkdir(source)
  File.write(File.join(source, 'SPECIES_NAMES.txt'), "[SPECIES_NAMES]\nBulbasaur\nBulbizarre\n", encoding: 'UTF-8')
  File.write(File.join(source, 'SCRIPT_TEXTS.txt'), "[SCRIPT_TEXTS]\nNew Game\nNouvelle partie\n", encoding: 'UTF-8')
  paths = [source]
  paths << source.tr('/', '\\') if File::ALT_SEPARATOR == '\\'
  paths.each_with_index do |path, index|
    output = File.join(directory, "messages_#{index}.dat")
    raise "Compiler failed for #{path}" unless system(RbConfig.ruby, '--disable-gems', compiler, path, output)
    messages = Marshal.load(File.binread(output))
    raise 'Species translation missing' unless messages[1]['Bulbasaur'] == 'Bulbizarre'
    raise 'Script translation missing' unless messages[24]['New Game'] == 'Nouvelle partie'
  end
  puts "PASS: #{paths.length} path formats, including spaces and Windows launcher backslashes"
end
