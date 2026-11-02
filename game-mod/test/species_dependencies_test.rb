require 'minitest/autorun'
require 'tmpdir'
require_relative '../tools/repair_species_dependencies'
class SpeciesDependenciesTest < Minitest::Test
  def fixture
    Dir.mktmpdir do |game|
      pbs = File.join(game, 'PBS')
      FileUtils.mkdir_p(File.join(pbs, 'Gen 8 backup'))
      File.write(File.join(pbs, 'pokemon.txt'), "[MEOWTH]\nName = Miaouss\nEvolutions = PERSIAN,Level,28,PERRSERKER,None,\n[PERSIAN]\nName = Persian\n")
      yield game, pbs
    end
  end
  def test_restores_original_missing_species_without_overwriting_custom_pbs
    fixture do |game,pbs|
      original = File.binread(File.join(pbs,'pokemon.txt'))
      File.write(File.join(pbs,'Gen 8 backup/pokemon.txt'), "[MEOWTH]\nName = Meowth\n[PERRSERKER]\nName = Perrserker\n[CHESPIN]\nName = Chespin\n")
      assert_equal 2, ArenaSpeciesRepair.repair(game)
      assert_equal original, File.binread(File.join(pbs,'pokemon.txt'))
      restored = ArenaSpeciesRepair.sections(File.join(pbs,'pokemon_arena_dependencies.txt')).to_h
      assert_equal %w[PERRSERKER CHESPIN], restored.keys
      assert_equal 0, ArenaSpeciesRepair.repair(game)
    end
  end
  def test_missing_backup_fails_without_changing_any_pbs
    fixture do |game,pbs|
      original = File.binread(File.join(pbs,'pokemon.txt'))
      assert_raises(RuntimeError) { ArenaSpeciesRepair.repair(game) }
      assert_equal original, File.binread(File.join(pbs,'pokemon.txt'))
      refute File.exist?(File.join(pbs,'pokemon_arena_dependencies.txt'))
    end
  end
end
