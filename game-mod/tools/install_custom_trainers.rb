require 'fileutils'
module CustomTrainerAssets
  FILES = ['Graphics/Characters/trainer_GOLD.png', 'Graphics/Trainers/GOLD.png', 'Audio/BGM/Battle GOLD.ogg'].freeze
  def self.install(game, cache)
    game = File.expand_path(game).tr('\\', '/')
    cache = File.expand_path(cache).tr('\\', '/')
    pbs = File.join(game, 'PBS')
    FileUtils.mkdir_p(pbs)
    source = File.expand_path('../PBS/trainer_types_gold.txt', __dir__)
    target = File.join(pbs, 'trainer_types_gold.txt')
    files = Dir.children(pbs).select { |name| name.match?(/\Atrainer_types.*\.txt\z/i) }.map { |name| File.join(pbs,name) }
    gold_files = files.select { |p| File.read(p, encoding: 'UTF-8').match?(/^\s*\[GOLD\]\s*$/) }
    # Remove only our unchanged generated sidecar if Gold is already provided
    # by another personal PBS file. Never alter that personal definition.
    if gold_files.length > 1 && gold_files.include?(target) && File.binread(target) == File.binread(source)
      File.delete(target)
    end
    FileUtils.cp(source, target) if gold_files.empty?
    # Merge published custom definitions into the main PBS, avoiding duplicate
    # IDs when the author's local file already contains the same trainers.
    custom = File.expand_path('../PBS/trainer_types_custom.txt', __dir__)
    if File.file?(custom)
      main = File.join(pbs, 'trainer_types.txt')
      contents = File.file?(main) ? File.read(main, encoding: 'bom|utf-8') : ''
      additions = File.read(custom, encoding: 'bom|utf-8').split(/(?=^\[)/)
      ids = additions.filter_map { |section| section[/\A\[([^\]]+)\]/,1] }
      parts = contents.split(/(?=^\[)/).reject { |section| ids.include?(section[/\A\[([^\]]+)\]/,1]) }
      merged = parts.join.rstrip + "\n" + additions.join
      File.write(main, merged) unless merged == contents
    end
    FILES.each do |relative|
      installed, cached = File.join(game, relative), File.join(cache, relative)
      if File.file?(installed) && !File.file?(cached)
        FileUtils.mkdir_p(File.dirname(cached))
        FileUtils.cp(installed, cached)
      elsif !File.file?(installed) && File.file?(cached)
        FileUtils.mkdir_p(File.dirname(installed))
        FileUtils.cp(cached, installed)
      elsif !File.file?(installed)
        puts "Personal Gold asset absent: #{relative}; supply it privately in tools/runtime/custom-trainer-assets."
      end
    end
  end
end
if $PROGRAM_NAME == __FILE__
  CustomTrainerAssets.install(ARGV.fetch(0), ARGV.fetch(1))
  puts 'Gold trainer configuration and private asset cache ready.'
end
