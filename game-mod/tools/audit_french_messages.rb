# Audit every literal _INTL/_ISPRINTF template in the installed Essentials source.
# Output remains in the private runtime because it includes upstream text.
require 'json'
def load_data(path); Marshal.load(File.binread(path)); end
def nil_or_empty?(value); value.nil? || value.empty?; end
root = File.expand_path('../..', __dir__)
game = File.join(root, 'tools/runtime/essentials-v21.1-base')
load File.join(root, 'upstream/pokemon-essentials/Data/Scripts/001_Technical/003_Intl_Messages.rb')
%w[021_French 023_FrenchFollowers 024_FrenchNetwork 025_FrenchEngineMessages 026_FrenchCoreReview 090_FrenchBattleWording].each do |name|
  path = File.join(root, "game-mod/Plugins/ArenaDemo/#{name}.rb")
  eval(File.read(path).gsub("\t", '  '), TOPLEVEL_BINDING, path)
end
# Reviewed unchanged labels: French cognates, proper names, formats and one
# background resource ID. Changes here must be reviewed, not silently ignored.
unchanged = ["Poké Balls", "six", "Brave", "Docile", "Pokémon", "Jan.", "Mar.", "Sep.", "Nov.",
 "Machine", "Simple", "Trio 1", "Trio 2", "Trio 3", "PikaPika 1", "PikaPika 2", "Pokéathlon",
 "Pokédex<r>{1}/{2}", "Pokédex", "Options", "Type", "{1} Pokémon", "????? Pokémon", "INFO",
 "Badges", "Type {1}/{2}", "Inst", "TEMPO", "accents", "Voltorb Flip bg", "{1} - {2} Pokémon",
 "Version={1}", "Version", "Pokémon {1}", "Nature", "Poké Ball", "Description", "Alpha:", "Angle:",
 "Volume:", "Position/Zoom/Angle", "Base {1}", "Variables", "Badge {1}", "Contact visible", "Terrain", "[GLOBAL]"]
sources = {}
Dir.glob(game + '/Data/Scripts/**/*.rb').each do |path|
  File.read(path).scan(/_(?:INTL|ISPRINTF)\(\s*("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')/m).flatten.each do |literal|
    next if literal.match?(/#[$@{]/)
    # Only a quoted, non-interpolated literal from trusted engine source is
    # evaluated. This reproduces Ruby escapes exactly, including \\n vs \n.
    key = eval(literal)
    (sources[key] ||= []) << path.delete_prefix(game + '/')
  end
end
rows = Dir.chdir(game) do
  MessageTypes.load_message_files('french')
  sources.map do |key, paths|
    translated = _INTL(key)
    flags = []
    asset = key.start_with?('Graphics/', 'Audio/', 'Data/') || key == 'Voltorb Flip bg'
    flags << 'untranslated' if !asset && translated == key && key.match?(/[A-Za-z]{3}/) && !unchanged.include?(key)
    flags << 'English syntax' if !asset && translated.match?(/\b(you|your|pocket|holding|fainted)\b|\w's\b/i)
    placeholders = /\{\d+(?:\:[^}]+)?\}/
    flags << 'changed placeholders' unless key.scan(placeholders).sort == translated.scan(placeholders).sort
    flags << 'changed asset ID' if asset && key != translated
    { english: key, french: translated, source: paths.uniq,
      status: asset ? 'resource' : unchanged.include?(key) ? 'reviewed unchanged' : 'translated', flags: flags }
  end
end
output = File.join(game, '../french_messages_audit.json')
File.write(output, JSON.pretty_generate(rows))
File.binwrite(File.join(game, '../french_messages_audit.dat'), Marshal.dump(rows.map { |row| [row[:english], row[:french]] }))
failures = rows.reject { |row| row[:flags].empty? }
puts "#{rows.length} Essentials templates audited; #{failures.length} failures. Report: #{File.expand_path(output)}"
failures.each { |row| puts row.to_json }
exit(failures.empty? ? 0 : 1)
