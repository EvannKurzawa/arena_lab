require 'minitest/autorun'
require 'tmpdir'
require_relative '../tools/install_custom_trainers'
class CustomTrainersInstallTest < Minitest::Test
  def fixture
    Dir.mktmpdir do |dir|
      game,cache = File.join(dir,'game'),File.join(dir,'cache')
      FileUtils.mkdir_p(File.join(game,'PBS'))
      CustomTrainerAssets::FILES.each do |relative|
        path=File.join(cache,relative)
        FileUtils.mkdir_p(File.dirname(path)); File.binwrite(path,'personal')
      end
      yield game,cache
    end
  end
  def test_split_pbs_and_private_assets_install_without_duplicate_gold
    fixture do |game,cache|
      File.write(File.join(game,'PBS/trainer_types.txt'),"[YOUNGSTER]\nName = Youngster\n")
      File.write(File.join(game,'PBS/trainer_types_other.txt'),"[ACE]\nName = Ace\n")
      2.times { CustomTrainerAssets.install(game,cache) }
      assert_equal 1,Dir.children(File.join(game,'PBS')).sum { |name| File.read(File.join(game,'PBS',name)).scan(/^\[GOLD\]\s*$/).length }
      CustomTrainerAssets::FILES.each { |p| assert_equal 'personal',File.binread(File.join(game,p)) }
    end
  end
  def test_existing_personal_pbs_and_runtime_sprites_are_preserved
    fixture do |game,cache|
      main=File.join(game,'PBS/trainer_types.txt')
      File.write(main,"[GOLD]\nName = My Gold\n")
      sprite=File.join(game,CustomTrainerAssets::FILES.first)
      FileUtils.mkdir_p(File.dirname(sprite)); File.binwrite(sprite,'edited')
      CustomTrainerAssets.install(game,cache)
      assert_equal "[GOLD]\nName = My Gold\n",File.read(main)
      refute File.exist?(File.join(game,'PBS/trainer_types_gold.txt'))
      assert_equal 'edited',File.binread(sprite)
    end
  end
  def test_runtime_asset_is_backed_up_when_cache_is_missing
    fixture do |game,cache|
      relative=CustomTrainerAssets::FILES.first
      FileUtils.rm(File.join(cache,relative))
      path=File.join(game,relative)
      FileUtils.mkdir_p(File.dirname(path)); File.binwrite(path,'my sprite')
      CustomTrainerAssets.install(game,cache)
      assert_equal 'my sprite',File.binread(File.join(cache,relative))
    end
  end
end
