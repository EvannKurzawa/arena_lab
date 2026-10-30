# Audit actual installed optional plugins, rather than a few hand-picked phrases.
def load_data(path); Marshal.load(File.binread(path)); end
def nil_or_empty?(value); value.nil? || value.empty?; end
root = File.expand_path('../..', __dir__)
load File.join(root, 'upstream/pokemon-essentials/Data/Scripts/001_Technical/003_Intl_Messages.rb')
%w[021_French 023_FrenchFollowers 024_FrenchNetwork 025_FrenchEngineMessages 026_FrenchCoreReview].each do |name|
  path = File.join(root, "game-mod/Plugins/ArenaDemo/#{name}.rb")
  code = File.binread(path).force_encoding(Encoding::UTF_8).gsub("\t", '  ')
  eval(code, TOPLEVEL_BINDING, path)
end
game = File.join(root, 'tools/runtime/essentials-v21.1-base')
Dir.chdir(game) do
  MessageTypes.load_message_files('french')
  original = load_data('Data/messages_core.dat')[MessageTypes::SCRIPT_TEXTS]
  french = load_data('Data/messages_french_core.dat')[MessageTypes::SCRIPT_TEXTS]
  gaps = original.keys.reject { |key| french.key?(key) }.select { |key| key.gsub(/\{[^}]*\}/, '').match?(/[A-Za-z]{3}/) }
  missing = gaps.select { |key| MessageTypes.getFromHash(MessageTypes::SCRIPT_TEXTS, key.dup) == key }
  raise "Untranslated engine additions: #{missing.join("\n")}" unless missing.empty?
  puts "PASS: #{gaps.length} missing English core messages covered by the plugin"
  ['Following Pokemon EX', 'PEMK'].each do |plugin|
    paths = Dir.glob("Plugins/#{plugin}/**/*.rb")
    raise "Missing installed #{plugin}" if paths.empty?
    keys = paths.flat_map do |path|
      File.read(path).scan(/_INTL\("((?:\\.|[^"\\])*)"/).flatten
    end.map { |key| key.gsub('\\\\') { '\\' }.gsub('\\"', '"') }.uniq
    missing = keys.select { |key| _INTL(key) == key }
    raise "Untranslated #{plugin}: #{missing.join("\n")}" unless missing.empty?
    keys.each do |key|
      translated = _INTL(key)
      raise "Changed placeholders: #{key}" unless key.scan(/\{\d+\}/).sort == translated.scan(/\{\d+\}/).sort
    end
    puts "PASS: #{plugin}: #{keys.length} literal _INTL keys translated, placeholders preserved"
  end
end
