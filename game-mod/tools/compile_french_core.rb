# Compile a locally obtained Essentials v21.1 Text_french.dat_core folder into
# Essentials' native messages_french_core.dat. Third-party translations stay in
# the ignored private runtime, separate from distributable source code.
source_dir, output_path = ARGV
abort 'Usage: ruby compile_french_core.rb SOURCE_DIR OUTPUT_DAT' unless source_dir && output_path
# PowerShell passes absolute Windows paths. Glob treats backslashes as escapes,
# so normalize before constructing the search pattern.
source_dir = File.expand_path(source_dir)
abort "Translation folder missing: #{source_dir}" unless File.directory?(source_dir)

section_ids = {
  'SPECIES_NAMES' => 1, 'SPECIES_CATEGORIES' => 2, 'POKEDEX_ENTRIES' => 3,
  'SPECIES_FORM_NAMES' => 4, 'MOVE_NAMES' => 5, 'MOVE_DESCRIPTIONS' => 6,
  'ITEM_NAMES' => 7, 'ITEM_NAME_PLURALS' => 8, 'ITEM_DESCRIPTIONS' => 9,
  'ABILITY_NAMES' => 10, 'ABILITY_DESCRIPTIONS' => 11, 'TYPE_NAMES' => 12,
  'TRAINER_TYPE_NAMES' => 13, 'SCRIPT_TEXTS' => 24, 'RIBBON_NAMES' => 25,
  'RIBBON_DESCRIPTIONS' => 26, 'ITEM_PORTION_NAMES' => 28,
  'ITEM_PORTION_NAME_PLURALS' => 29
}

decode = lambda do |value|
  value.gsub('<<1>>', "\1").gsub('<<r>>', "\r").gsub('<<n>>', "\n")
       .gsub('<<[>>', '[').gsub('<<]>>', ']').gsub('<<t>>', "\t")
end
all_text = []
total = 0
Dir.glob(File.join(source_dir, '*.txt')).sort.each do |path|
  section = File.basename(path, '.txt')
  section_id = section_ids[section]
  abort "Unexpected translation section: #{section}" unless section_id
  lines = File.read(path, encoding: 'UTF-8').delete_prefix("\uFEFF").lines.map(&:strip)
  lines.reject! { |line| line.empty? || line.start_with?('#') || line == "[#{section}]" }
  # Pack 1.2 repeats Darmanitan's French dex entry on two consecutive lines.
  # Repair this known packaging typo without dropping legitimate equal pairs
  # (e.g. Pokemon whose English and French names are identical).
  if section == 'POKEDEX_ENTRIES'
    duplicate = "Sa puissance augmente à mesure que la flamme de son corps s'intensifie. La température de celle-ci peut parfois dépasser les 1 400 °C."
    index = lines.each_cons(2).find_index { |a, b| a == duplicate && b == duplicate }
    lines.delete_at(index + 1) if index
  end
  abort "Malformed translation pairs in #{path}" unless lines.length.even?
  entries = {}
  lines.each_slice(2) do |original, translated|
    key = decode.call(original).strip.gsub(/\s{2,}/, ' ')
    entries[key] = decode.call(translated)
  end
  all_text[section_id] = entries
  total += entries.length
end
abort 'No translated species found' unless all_text[1] && all_text[1]['Bulbasaur'] == 'Bulbizarre'
abort 'No French script texts found' unless all_text[24] && !all_text[24].empty?
File.open(output_path, 'wb') { |file| Marshal.dump(all_text, file) }
puts "Compiled #{total} French entries into #{output_path}"
