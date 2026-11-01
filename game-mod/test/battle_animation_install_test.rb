require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'

INSTALLER = File.expand_path('../tools/install_battle_animation_data.rb', __dir__)
eval(File.read(INSTALLER).split('game, source = ARGV').first, TOPLEVEL_BINDING, INSTALLER)

class BattleAnimationInstallTest < Minitest::Test
  def animation(name, frames = 2)
    PBAnimation.new.tap do |a|
      a.instance_variable_set(:@name, name)
      a.instance_variable_set(:@graphic, 'fixture')
      a.instance_variable_set(:@array, Array.new(frames) { [] })
    end
  end

  def table(entries)
    PBAnimations.new.tap { |a| a.instance_variable_set(:@array, entries) }
  end

  def setup
    @root = Dir.mktmpdir('arena-animation-install-', File.expand_path('../..', __dir__))
    @game, @pack = File.join(@root, 'game'), File.join(@root, 'pack')
    [@game, @pack].each { |p| FileUtils.mkdir_p(File.join(p, 'Data')) }
    @target = File.join(@game, 'Data/PkmnAnimations.rxdata')
    @source = File.join(@pack, 'Data/PkmnAnimations.rxdata')
    @original = Marshal.dump(table([animation('Move:TACKLE'), animation('Move:CUSTOM')]))
    File.binwrite(@target, @original)
    File.binwrite(@source, Marshal.dump(table([animation('Move:FLY'), animation(''), animation('Move:NATUREPOWER', 1)])))
    [@game, @pack].each { |p| FileUtils.mkdir_p(File.join(p, 'Graphics/Animations')) }
    File.write(File.join(@game, 'Graphics/Animations/fixture.png'), 'old image')
    File.write(File.join(@pack, 'Graphics/Animations/fixture.png'), 'new image')
    File.write(File.join(@game, 'Data/Animations.rxdata'), 'field animations must stay intact')
  end

  def teardown; FileUtils.remove_entry(@root); end
  def install; Open3.capture3(RbConfig.ruby, '--disable-gems', INSTALLER, @game, @source); end

  def test_pack_merge_keeps_custom_records_adjacent_phases_assets_and_backups
    out, err, result = install
    assert result.success?, out + err
    merged = Marshal.load(File.binread(@target)).entries
    assert_equal ['Move:TACKLE', 'Move:CUSTOM', 'Move:FLY', '', ''], merged.map(&:name)
    mapping = Marshal.load(File.binread(File.join(@game, 'Data/move2anim.dat')))
    assert_equal 2, mapping[0][:FLY]
    assert_equal 2, merged[mapping[0][:FLY] + 1].frames.length
    refute mapping[0].key?(:NATUREPOWER), 'blank placeholders must not hide working native fallbacks'
    assert_equal @original, File.binread(File.join(@game, 'Data/ArenaLab-BattleAnimations-before-Gen9.rxdata'))
    assert_equal 'old image', File.read(File.join(@game, 'Data/ArenaLab-BattlePackAssetBackup/Graphics/Animations/fixture.png'))
    assert_equal 'new image', File.read(File.join(@game, 'Graphics/Animations/fixture.png'))
    assert_equal 'field animations must stay intact', File.read(File.join(@game, 'Data/Animations.rxdata'))
  end

  def test_install_is_idempotent_and_refuses_to_overwrite_later_edits
    assert install[2].success?
    first = File.binread(@target)
    assert install[2].success?
    assert_equal first, File.binread(@target)
    edited = first + 'local edit'
    File.binwrite(@target, edited)
    _, err, result = install
    refute result.success?
    assert_includes err, 'were edited'
    assert_equal edited, File.binread(@target)
  end
end
