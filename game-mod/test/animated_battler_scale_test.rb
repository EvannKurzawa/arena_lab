require 'minitest/autorun'
module ArenaDemo; end
class Battle
  class Scene
    class BattlerSprite; end
  end
end
Rect = Struct.new(:x, :y, :width, :height)
class Bitmap
  attr_reader :width, :height, :target
  def initialize(w, h); @width, @height = w, h; end
  def get_pixel(*); Struct.new(:alpha).new(255); end
  def clear; end
  def stretch_blt(target, *); @target = target; end
  def dispose; @disposed = true; end
  def disposed?; @disposed; end
end
class AnimatedBitmap
  attr_reader :width, :height, :bitmap
  def initialize(path)
    @width, @height = path.end_with?('.gif') ? [117, 99] : [224, 224]
    @bitmap = Bitmap.new(@width, @height)
  end
  def currentIndex; 0; end
  def update; end
  def dispose; @bitmap.dispose; end
end
require_relative '../Plugins/ArenaDemo/094_AnimatedBattlers'
class AnimatedBattlerScaleTest < Minitest::Test
  def test_large_back_sprite_grows_canvas_instead_of_shrinking_art
    canvas = ArenaDemo::AnimatedBattlers::Canvas.new('kyurem.gif', Bitmap.new(160, 160))
    assert_equal [234, 198], [canvas.width, canvas.height]
    assert_equal [0, 0, 234, 198], canvas.bitmap.target.to_a
    canvas.dispose
    assert canvas.disposed?
  end
  def test_dark_lugia_strip_is_already_scaled
    canvas = ArenaDemo::AnimatedBattlers::Canvas.new('[2,8]LUGIA_1.png', Bitmap.new(192, 192))
    assert_equal [224, 224], [canvas.width, canvas.height]
    assert_equal [0, 0, 224, 224], canvas.bitmap.target.to_a
  end
end
