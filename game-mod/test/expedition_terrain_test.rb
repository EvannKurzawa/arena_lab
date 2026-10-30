require_relative 'expedition_world_test'
require_relative '../../upstream/pokemon-essentials/Data/Scripts/006_Map renderer/004_TileDrawingHelper'

Color = Struct.new(:red, :green, :blue, :alpha)
Rect = Struct.new(:x, :y, :width, :height)
class Rect
  def set(x, y, width, height); self.x, self.y, self.width, self.height = x, y, width, height; end
end
class Bitmap
  attr_reader :width, :height, :filename, :blits, :changed_pixels
  def initialize(width, height = nil)
    @filename = height ? nil : width.to_s
    @width = height ? width : (@filename.include?('Tilesets') ? 256 : 96)
    @height = height || (@filename.include?('Tilesets') ? 4096 : 128)
    @blits, @changed_pixels = [], []
  end
  def blt(x, y, source, rect)
    raise 'Read outside native source' if rect.x < 0 || rect.y < 0 || rect.x + rect.width > source.width || rect.y + rect.height > source.height
    @blits << [x, y, source, rect.to_a]
  end
  def get_pixel(x, _y)
    x < 16 ? Color.new(130, 90, 70, 255) : Color.new(40, 100, 200, 255)
  end
  def set_pixel(x, y, color); @changed_pixels << [x, y, color]; end
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end
end
def pbResolveBitmap(path); path + '.png'; end
class Game_Map
  X_SUBPIXELS = Y_SUBPIXELS = 4
end
module Graphics
  def self.width; 640; end
  def self.height; 480; end
end
class TilemapRenderer
  ZOOM_X = ZOOM_Y = 1
  DISPLAY_TILE_WIDTH = DISPLAY_TILE_HEIGHT = 32
  def refresh_tile(*); end
end
require_relative '../Plugins/ArenaDemo/017_ExpeditionTerrain'

class ExpeditionTerrainTest < Minitest::Test
  Terrain = ArenaDemo::ExpeditionTerrain
  Tile = Struct.new(:bitmap, :src_rect, :animated, :is_autotile, :filename, :visible, :shows_reflection, :bridge, :z)
  def teardown; Terrain.clear; end

  def test_native_assets_cover_all_biomes_and_all_neighbor_masks
    ArenaDemo::ExpeditionLayout::BIOMES.each_key do |biome|
      'abgpovwl'.bytes.each do |code|
        image = Terrain.bitmap(biome, code, 255)
        assert_equal [32, 32], [image.width, image.height]
        refute_empty image.blits
        assert_same image, Terrain.bitmap(biome, code, 255)
      end
    end
    256.times do |mask|
      image = Bitmap.new(32, 32)
      assert Terrain.autotile(image, 'Still water', mask)
      assert_equal 4, image.blits.length
    end
  end

  def test_native_shoreline_diagonals_change_inner_corners_and_lava_keeps_stone
    full = Terrain.bitmap('lake', 119, 255)
    missing_diagonal = Terrain.bitmap('lake', 119, 127)
    refute_equal full.blits.last(4).map(&:last), missing_diagonal.blits.last(4).map(&:last)
    lava = Terrain.source('Autotiles/Sea', true)
    refute_empty lava.changed_pixels
    assert lava.changed_pixels.all? { |x, _y, color| x >= 16 && color.red > color.blue }
    original = Terrain.source('Autotiles/Still water')
    assert_empty original.changed_pixels
    Terrain.clear
    assert lava.disposed?
    assert full.disposed?
  end

  def test_scrolling_resolves_the_correct_map_cell_and_hides_original_upper_layers
    data = { 'biome' => 'forest', 'cells' => 'b' * 4096 }
    data['cells'].setbyte(10 * 64 + 12, 103)
    holder = Object.new
    holder.instance_variable_set(:@arena_expedition_region, data)
    map = Object.new
    map.instance_variable_set(:@map, holder)
    def map.map_id; 110; end
    def map.display_x; 8 * 32 * 4; end
    def map.display_y; 6 * 32 * 4; end
    tile = Tile.new
    renderer = TilemapRenderer.new
    renderer.refresh_tile(tile, 4, 4, map, 0, 401)
    assert_same Terrain.tile(map, 12, 10), tile.bitmap
    assert tile.visible
    renderer.refresh_tile(tile, 4, 4, map, 1, 402)
    assert_nil tile.bitmap
    refute tile.visible
  end

  class SceneryHarness
    attr_accessor :src_rect, :ox, :oy
    attr_reader :base_calls
    def initialize(character)
      @character = character
      @base_calls = 0
      @src_rect = Rect.new(0, 0, 32, 32)
    end
    def refresh_graphic
      @base_calls += 1
      @charbitmap.dispose if @charbitmap
      @charbitmap = Bitmap.new(32, 32)
    end
    prepend ArenaDemo::ExpeditionTreeGraphic
  end
  def test_scenery_uses_one_full_tree_frame_and_preserves_other_maps
    data = Object.new
    data.instance_variable_set(:@arena_expedition_region, { 'biome' => 'forest' })
    map = Struct.new(:map_id).new(110)
    map.instance_variable_set(:@map, data)
    character = Struct.new(:map, :name, :character_name, :x, :y, :sprite_size).new(map, 'Wilderness scenery', 'Object tree 1', 10, 10)
    sprite = SceneryHarness.new(character)
    sprite.refresh_graphic
    assert_equal [64, 96], character.sprite_size
    assert_equal [0, 0, 64, 96], sprite.src_rect.to_a
    assert_equal [32, 96], [sprite.ox, sprite.oy]
    native = sprite.instance_variable_get(:@charbitmap)
    sprite.refresh_graphic
    assert_equal 1, sprite.base_calls
    assert_same native, sprite.instance_variable_get(:@charbitmap)
    map.map_id = 101
    sprite.refresh_graphic
    assert_equal 2, sprite.base_calls
    assert native.disposed?
    map.map_id = 110
    player = Struct.new(:map, :character_name).new(map, 'trainer_PLAYER')
    player_sprite = SceneryHarness.new(player)
    player_sprite.refresh_graphic
    assert_equal 1, player_sprite.base_calls, 'Player and follower characters need not expose an event name'
  end
end
