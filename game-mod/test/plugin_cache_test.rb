require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'zlib'
require 'open3'
require 'rbconfig'

class PluginCacheTest < Minitest::Test
  def setup
    @project = Dir.mktmpdir('arena-cache-')
    @plugin = File.join(@project, 'Plugins', 'ArenaDemo')
    FileUtils.mkdir_p(@plugin)
    FileUtils.mkdir_p(File.join(@project, 'Data'))
    File.write(File.join(@plugin, 'meta.txt'), "Name = Arena Demo\nVersion = 0.7.0\n")
    @new_code = "# live mode\ndef choose_at_title; select_mode(:offline); end\n"
    File.binwrite(File.join(@plugin, '007_ConnectionMode.rb'), @new_code)
    @other = ['PEMK', { version: '0.1.0' }, [['core.rb', Zlib::Deflate.deflate('unchanged upstream')]]]
    @cache = File.join(@project, 'Data', 'PluginScripts.rxdata')
    @old = Marshal.dump([@other, ['Arena Demo', { version: '0.6.0', essentials: ['21.1'] }, [['007_ConnectionMode.rb', Zlib::Deflate.deflate('old chooser')]]]])
    File.binwrite(@cache, @old)
  end
  def teardown
    FileUtils.remove_entry(@project)
  end
  def run_update
    tool = File.expand_path('../../tools/sync-plugin-cache.rb', __dir__)
    Open3.capture3(RbConfig.ruby, '--disable-gems', '-e',
      'path = ARGV.shift; eval(File.read(path), TOPLEVEL_BINDING, path)', tool, @project)
  end
  def test_future_dated_old_cache_is_updated_without_changing_other_plugins
    future = Time.now + 86_400
    File.utime(future, future, @cache)
    output, error, status = run_update
    assert status.success?, output + error
    entries = Marshal.load(File.binread(@cache))
    assert_equal @other, entries[0]
    assert_equal '0.7.0', entries[1][1][:version]
    assert_equal ['21.1'], entries[1][1][:essentials]
    assert_equal @new_code, Zlib::Inflate.inflate(entries[1][2][0][1])
    assert_equal @old, File.binread(@cache + '.before-arena-0.7.0.bak')
    assert_includes output, 'cache verified'
    _output, error, status = run_update
    assert status.success?, error
    assert_equal @old, File.binread(@cache + '.before-arena-0.7.0.bak')
  end
  def test_unexpected_format_is_refused_without_overwriting_the_cache
    File.binwrite(@cache, Marshal.dump(:unexpected))
    before = File.binread(@cache)
    _output, error, status = run_update
    refute status.success?
    assert_includes error, 'Unexpected plugin cache format'
    assert_equal before, File.binread(@cache)
  end
  def test_missing_cache_is_left_for_the_native_first_compile
    File.delete(@cache)
    output, error, status = run_update
    assert status.success?, error
    assert_includes output, 'debug engine will compile'
    refute File.exist?(@cache)
  end
end
