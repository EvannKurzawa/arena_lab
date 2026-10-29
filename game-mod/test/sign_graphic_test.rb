require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

class SignGraphicTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir('arena-sign-')
    @scope = Module.new
    @scope.const_set(:PROJECT, @root)
    source = File.read(File.expand_path('../tools/build_arena_map.rb', __dir__))
    @scope.module_eval(source[/def resolve_arena_sign_graphic\(source_map\).*?^end/m])
    @helper = Object.new.extend(@scope)
    @map = Object.new
    @map.instance_variable_set(:@events, {})
  end
  def teardown; FileUtils.remove_entry(@root); end

  def test_missing_sign_character_uses_installed_boundary_marker
    assert_equal ['Object boulder', 0], @helper.resolve_arena_sign_graphic(@map)
  end

  def test_native_sign_tile_is_reused_without_a_character_file
    sign = Object.new
    sign.instance_variable_set(:@name, 'Town sign')
    sign.instance_variable_set(:@x, 4)
    sign.instance_variable_set(:@y, 5)
    table = Object.new
    def table.[](x, y, layer); layer == 2 ? 500 : 0; end
    @map.instance_variable_set(:@data, table)
    @map.instance_variable_set(:@events, { 1 => sign })
    assert_equal ['', 500], @helper.resolve_arena_sign_graphic(@map)
  end

  def test_existing_local_sign_charset_can_be_used
    directory = File.join(@root, 'Graphics/Characters')
    FileUtils.mkdir_p(directory)
    File.write(File.join(directory, 'Village sign.png'), '')
    assert_equal ['Village sign', 0], @helper.resolve_arena_sign_graphic(@map)
  end
end
