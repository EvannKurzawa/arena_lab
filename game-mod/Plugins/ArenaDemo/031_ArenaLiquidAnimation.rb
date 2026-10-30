# Animate shared floor bitmaps, including cached platform tops and wall rims.
# Native Essentials water frames are reused; no external artwork is bundled.
module ArenaDemo
  LIQUID_GROUNDS = %w[water lava marsh_water toxic].freeze
  module_function

  def draw_liquid_floor(image, ground)
    source = ExpeditionTerrain.source('Autotiles/Sea deep', ground == 'lava')
    return false unless source
    frame = (@liquid_art_frame || 0) % [source.width / 96, 1].max
    index = TileDrawingHelper::NEIGHBORS_TO_AUTOTILE_INDEX.fetch(255)
    pattern = TileDrawingHelper::AUTOTILE_PATTERNS[index / 8][index % 8]
    pattern.each_with_index do |quarter, i|
      quarter -= 1
      image.blt(i % 2 * 16, i / 2 * 16, source,
        Rect.new(frame * 96 + quarter % 6 * 16, quarter / 6 * 16, 16, 16))
    end
    if ground == 'marsh_water' || ground == 'toxic'
      material_tint(image, ground == 'toxic' ? 0xbdc722 : 0x705032)
    end
    if ground == 'toxic'
      32.times do |y|
        32.times do |x|
          c = image.get_pixel(x, y)
          image.set_pixel(x, y, Color.new(135 + c.red * 0.60,
            [150 + c.green * 0.65, 255].min, 12 + c.blue * 0.50, c.alpha))
        end
      end
    end
    true
  end

  def animate_liquid_bitmap(bitmap, ground, key)
    return unless bitmap && !bitmap.disposed? && LIQUID_GROUNDS.include?(ground)
    @liquid_frames ||= {}
    frames = @liquid_frames[key] ||= Array.new(4) do |frame|
      @liquid_art_frame = frame
      image = Bitmap.new(32, 32)
      yield image
      image
    end
    # Slower heavy liquids, continuous movement independent of game FPS.
    delay = { 'water' => 0.20, 'lava' => 0.40, 'marsh_water' => 0.32, 'toxic' => 0.26 }.fetch(ground)
    bitmap.clear
    bitmap.blt(0, 0, frames[(System.uptime / delay).floor % frames.length], Rect.new(0, 0, 32, 32))
  ensure
    @liquid_art_frame = 0
  end

  def update_liquid_animation
    return unless $game_map && $game_map.map_id == MAP_ID
    tick = (System.uptime * 10).floor
    return if @liquid_update_tick == tick
    @liquid_update_tick = tick
    (@platform_floors || {}).each do |ground, bitmap|
      animate_liquid_bitmap(bitmap, ground, [:floor, ground]) { |image| draw_platform_floor(image, ground) }
    end
    (@relief_bitmaps || {}).each do |key, bitmap|
      code, mask, sides, style, ground = key
      next unless code == 1
      animate_liquid_bitmap(bitmap, ground, [:top, key]) do |image|
        with_liquid_floor_frame(ground) { draw_relief_cliff(image, mask, ground, style) }
      end
    end
    (@relief_walls || {}).each do |key, bitmap|
      left, right, style, ground = key
      animate_liquid_bitmap(bitmap, ground, [:wall, key]) do |image|
        with_liquid_floor_frame(ground) { draw_relief_wall(image, left, right, style, ground) }
      end
    end
  end

  def with_liquid_floor_frame(ground)
    original = platform_floor_bitmap(ground)
    temporary = Bitmap.new(32, 32)
    draw_platform_floor(temporary, ground)
    @platform_floors[ground] = temporary
    yield
  ensure
    @platform_floors[ground] = original
    temporary.dispose if temporary
  end
end

if defined?(TilemapRenderer)
  module ArenaDemo::LiquidAnimation
    def update
      ArenaDemo.update_liquid_animation
      super
    end
  end
  TilemapRenderer.prepend(ArenaDemo::LiquidAnimation)
end
