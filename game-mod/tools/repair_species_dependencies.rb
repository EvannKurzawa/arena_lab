# Restore compiler dependencies accidentally omitted by the national-dex filter.
# Uses only the user's existing Essentials backup; no external Pokemon data.
require 'fileutils'
module ArenaSpeciesRepair
  module_function
  def sections(path)
    text = File.read(path, encoding: 'bom|utf-8')
    text.split(/(?=^\[[A-Z0-9_]+\])/).filter_map { |part|
        match = part.match(/\A\[([A-Z0-9_]+)\]/)
        [match[1], part] if match
      }
  end
  def repair(game)
    game = File.expand_path(game).tr('\\', '/')
    pbs = File.join(game, 'PBS')
    return 0 unless File.directory?(pbs)
    pokemon_files = Dir.children(pbs).select { |name| name.match?(/\Apokemon.*\.txt\z/i) }.map { |name| File.join(pbs, name) }
    active = pokemon_files.reject { |f| File.basename(f).start_with?('pokemon_forms', 'pokemon_metrics') }
    return 0 if active.empty?
    present = active.flat_map { |f| sections(f).map(&:first) }.uniq
    referenced = pokemon_files.flat_map do |file|
      File.read(file, encoding: 'bom|utf-8').scan(/^Evolutions\s*=\s*(.*)$/).flat_map { |line| line[0].strip.split(',').each_slice(3).map { |v| v[0]&.strip } }
    end.compact.uniq
    missing = referenced - present
    return 0 if missing.empty?
    sources = Dir.children(pbs).select { |name| name.match?(/gen\s*8.*backup/i) }.flat_map do |directory|
      folder = File.join(pbs, directory)
      next [] unless File.directory?(folder)
      Dir.children(folder).select { |name| name.match?(/\Apokemon(?:_[a-z0-9]+)?\.txt\z/i) && !name.start_with?('pokemon_forms', 'pokemon_metrics') }.map { |name| File.join(folder, name) }
    end
    candidates = sources.flat_map { |f| sections(f) }.to_h
    unavailable = missing - candidates.keys
    raise "Missing species dependencies: #{unavailable.join(', ')}. Restore the original Essentials v21.1 PBS/Gen 8 backup folder; your PBS files were preserved." unless unavailable.empty?
    additions = candidates.reject { |id,_| present.include?(id) }
    target = File.join(pbs, 'pokemon_arena_dependencies.txt')
    # A prior repair may already be present. Additive writes retain custom data.
    previous = File.file?(target) ? File.binread(target) : ''.b
    output = previous + "\r\n".b + additions.values.join("\r\n").encode('UTF-8').b
    File.binwrite(target + '.tmp', output)
    File.rename(target + '.tmp', target)
    puts "Restored #{additions.length} internal compiler species dependencies; playable roster remains Gen 1-5 + Dark Lugia."
    additions.length
  end
end
ArenaSpeciesRepair.repair(File.expand_path(ARGV.fetch(0))) if $PROGRAM_NAME == __FILE__
