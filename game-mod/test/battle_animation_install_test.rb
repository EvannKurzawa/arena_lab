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
  def verify; Open3.capture3(RbConfig.ruby, '--disable-gems', INSTALLER, @game, '--verify-installed'); end

  def rewrite_without_content_change
    value = Marshal.load(File.binread(@target))
    first = value.entries.first
    name = first.remove_instance_variable(:@name)
    first.instance_variable_set(:@name, name)
    File.binwrite(@target, Marshal.dump(value))
  end

  def legacy_marker
    marker = File.join(@game, 'Data/ArenaLab-BattleAnimations-Gen9.txt')
    File.write(marker, File.read(marker).split.first(2).join(' ') + "\n")
    marker
  end

  def test_engine_resave_updates_receipt_without_reinstalling_any_data
    assert install[2].success?
    before = File.binread(@target)
    rewrite_without_content_change
    rewritten = File.binread(@target)
    refute_equal before, rewritten
    File.write(File.join(@game, 'Graphics/Animations/fixture.png'), 'custom sprite')
    mapping = File.binread(File.join(@game, 'Data/move2anim.dat'))
    out, err, result = verify
    assert result.success?, out + err
    assert_equal rewritten, File.binread(@target)
    assert_equal 'custom sprite', File.read(File.join(@game, 'Graphics/Animations/fixture.png'))
    assert_equal mapping, File.binread(File.join(@game, 'Data/move2anim.dat'))
    assert verify[2].success?
    assert_equal 5, Marshal.load(File.binread(@target)).entries.length
  end

  def test_legacy_rewrite_requires_pack_then_reconstructs_original_receipt
    assert install[2].success?
    marker = legacy_marker
    rewrite_without_content_change
    rewritten = File.binread(@target)
    assert_equal 2, verify[2].exitstatus
    out, err, result = install
    assert result.success?, out + err
    assert_equal rewritten, File.binread(@target)
    assert_equal 3, File.read(marker).split.length
    assert verify[2].success?
  end

  def test_unchanged_legacy_installation_migrates_without_pack
    assert install[2].success?
    marker = legacy_marker
    FileUtils.rm_f(@source)
    assert verify[2].success?
    assert_equal 3, File.read(marker).split.length
  end

  def test_real_frame_edit_is_preserved_and_rejected
    assert install[2].success?
    value = Marshal.load(File.binread(@target))
    value.entries.first.frames << [123]
    File.binwrite(@target, Marshal.dump(value))
    edited = File.binread(@target)
    marker = File.join(@game, 'Data/ArenaLab-BattleAnimations-Gen9.txt')
    receipt = File.binread(marker)
    _, err, result = verify
    refute result.success?
    assert_includes err, 'were edited'
    assert_equal edited, File.binread(@target)
    assert_equal receipt, File.binread(marker)
  end

  def test_legacy_migration_refuses_a_changed_backup
    assert install[2].success?
    legacy_marker
    rewrite_without_content_change
    backup = Marshal.load(@original)
    backup.entries.first.frames << []
    File.binwrite(File.join(@game, 'Data/ArenaLab-BattleAnimations-before-Gen9.rxdata'), Marshal.dump(backup))
    original = File.binread(@target)
    _, err, result = install
    refute result.success?
    assert_includes err, 'Cannot verify original'
    assert_equal original, File.binread(@target)
  end

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
