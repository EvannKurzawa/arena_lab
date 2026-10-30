# Compose the player's native Essentials artwork. No procedural pixel textures,
# external art downloads or game graphics are distributed with this plugin.
module ArenaDemo
  module ExpeditionTerrain
    # Native path/patch families whose backgrounds match their surrounding floor.
    FLOORS = {
      'grassland' => [nil, 'Dirt'], 'forest' => [nil, 'Dirt'],
      'meadow' => [nil, 'Dirt'], 'storm' => [nil, 'Dirt'],
      'bamboo' => [nil, 'Dirt'], 'lake' => [nil, 'Dirt'],
      'swamp' => ['Green cave floor', 'Dirt cave highlight'],
      'desert' => ['Sand', nil], 'coast' => ['Sand', nil],
      'volcano' => ['Red cave floor', 'Red cave highlight'],
      'canyon' => ['Brown cave floor', 'Brown cave sand'],
      'snow' => ['White path', nil],
      'crystal' => ['Snow cave floor', 'Snow cave ice border'],
      'ruins' => [nil, 'Dirt'], 'power' => ['Gravel', nil]
    }.freeze
    OFFSETS = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]].freeze
    module_function

    def source(name, lava = false, transparent_ground = false)
      @sources ||= {}
      key = [name, lava, transparent_ground]
      return @sources[key] if @sources.key?(key)
      path = pbResolveBitmap("Graphics/#{name}")
      return @sources[key] = nil unless path
      bitmap = Bitmap.new(path)
      if transparent_ground
        bitmap.height.times do |y|
          bitmap.width.times do |x|
            color = bitmap.get_pixel(x, y)
            next unless color.green > color.red * 1.05 && color.green > color.blue * 1.05
            bitmap.set_pixel(x, y, Color.new(0, 0, 0, 0))
          end
        end
      end
      if lava
        # Keep native stone shorelines; only blue water pixels become molten.
        bitmap.height.times do |y|
          bitmap.width.times do |x|
            color = bitmap.get_pixel(x, y)
            next unless color.blue > color.red * 1.2 && color.blue > color.green * 1.05
            bitmap.set_pixel(x, y, Color.new([245 + color.red / 12, 255].min,
              [65 + color.green * 0.65, 240].min, 28 + color.red / 6, color.alpha))
          end
        end
      end
      @sources[key] = bitmap
    end

    def atlas(image, sheet, id)
      bitmap = source("Tilesets/#{sheet}")
      return false unless bitmap
      x, y = (id - 384) % 8 * 32, (id - 384) / 8 * 32
      return false if y + 32 > bitmap.height
      image.blt(0, 0, bitmap, Rect.new(x, y, 32, 32))
      true
    end

    def autotile(image, name, mask = 255, lava = false, transparent_ground = false)
      bitmap = source("Autotiles/#{name}", lava, transparent_ground)
      return false unless bitmap
      if bitmap.height == 32
        image.blt(0, 0, bitmap, Rect.new(0, 0, 32, 32))
        return true
      end
      # Use the engine's 8-neighbor lookup and quarter-tile table. Diagonals
      # select inward corners too, so shorelines do not become square boxes.
      index = TileDrawingHelper::NEIGHBORS_TO_AUTOTILE_INDEX.fetch(mask)
      pattern = TileDrawingHelper::AUTOTILE_PATTERNS[index / 8][index % 8]
      pattern.each_with_index do |quarter, i|
        quarter -= 1
        image.blt(i % 2 * 16, i / 2 * 16, bitmap,
          Rect.new(quarter % 6 * 16, quarter / 6 * 16, 16, 16))
      end
      true
    end

    def floor(image, biome, variant = 0)
      return if biome == 'power' && atlas(image, 'Factory interior', 426 + variant % 2)
      name = FLOORS.fetch(biome)[0]
      return if name && autotile(image, name)
      atlas(image, 'Outside', 385 + variant % 4)
    end

    def cliff(image, biome, mask)
      return if biome == 'ruins' && atlas(image, 'Ruins interior', 402)
      return if biome == 'power' && atlas(image, 'Factory interior', 443)
      # Native 3x3 cliff families replace repeated boxed boulder textures.
      origin = ['snow', 'crystal'].include?(biome) ? 1296 : 504
      sheet = source('Tilesets/Caves')
      return unless sheet
      [[1, 64], [1, 4], [16, 64], [16, 4]].each_with_index do |(vertical, horizontal), i|
        has_v, has_h = mask & vertical != 0, mask & horizontal != 0
        row = has_v ? 1 : (i < 2 ? 0 : 2)
        col = has_h ? 1 : (i.even? ? 0 : 2)
        tile = origin + row * 8 + col
        # The center of the source family has a cave mouth; use summit rock.
        if row == 1 && col == 1 && origin == 504
          surface = source('Autotiles/Brown cave floor')
          image.blt(i % 2 * 16, i / 2 * 16, surface, Rect.new(32 + i % 2 * 16, 64 + i / 2 * 16, 16, 16)) if surface
          next
        end
        tile = 1305 if row == 1 && col == 1
        sx = (tile - 384) % 8 * 32 + i % 2 * 16
        sy = (tile - 384) / 8 * 32 + i / 2 * 16
        image.blt(i % 2 * 16, i / 2 * 16, sheet, Rect.new(sx, sy, 16, 16))
      end
    end

    def grass(image, biome)
      native = Bitmap.new(32, 32)
      atlas(native, 'Outside', 391)
      if ['snow', 'crystal', 'desert', 'coast', 'volcano', 'canyon'].include?(biome)
        32.times do |y|
          32.times do |x|
            color = native.get_pixel(x, y)
            next unless color.alpha > 0 && color.green > color.red * 1.1
            rgb = if ['snow', 'crystal'].include?(biome)
                    [150 + color.red / 4, 170 + color.green / 4, 190 + color.blue / 4]
                  elsif biome == 'volcano'
                    [115 + color.red / 4, 110 + color.green / 5, 105 + color.blue / 4]
                  else
                    [175 + color.red / 4, 140 + color.green / 4, 65 + color.blue / 4]
                  end
            native.set_pixel(x, y, Color.new(*rgb, color.alpha))
          end
        end
      end
      image.blt(0, 0, native, Rect.new(0, 0, 32, 32))
      native.dispose
    end

    def tree_bitmap
      sheet = source('Tilesets/Outside')
      return nil unless sheet
      image = Bitmap.new(64, 96)
      image.blt(0, 0, sheet, Rect.new(128, (800 - 384) / 8 * 32, 64, 96))
      image
    end

    def scenery_bitmap(name, biome, x = 0, y = 0)
      return tree_bitmap if name == 'Object tree 1'
      return nil unless name == 'Object boulder' && ['snow', 'crystal'].include?(biome)
      image = Bitmap.new(32, biome == 'snow' ? 32 : 64)
      if biome == 'snow'
        atlas(image, 'Caves', (x + y).even? ? 1349 : 1351)
      else
        sheet = source('Tilesets/Caves')
        image.blt(0, 0, sheet, Rect.new(192, 3840, 32, 64)) if sheet
      end
      image
    end

    def mask_for(cells, x, y, code)
      mask = 0
      OFFSETS.each_with_index do |(dx, dy), i|
        nx, ny = x + dx, y + dy
        match = if nx < 0 || ny < 0 || nx >= ExpeditionLayout::SIZE || ny >= ExpeditionLayout::SIZE
                  code == 111
                else
                  neighbor = cells.getbyte(ny * ExpeditionLayout::SIZE + nx)
                  neighbor == code || (code == 112 && neighbor == 118)
                end
        mask |= 1 << i if match
      end
      mask
    end

    def bitmap(biome, code, mask, variant = 0)
      @cache ||= {}
      key = [biome, code, mask, variant]
      return @cache[key] if @cache[key] && !@cache[key].disposed?
      image = Bitmap.new(32, 32)
      floor(image, biome, variant)
      case code
      when 112
        name = FLOORS.fetch(biome)[1]
        if name
          autotile(image, name, mask)
        elsif biome != 'power'
          autotile(image, 'Dirt', mask, false, true)
        end
      when 118
        atlas(image, 'Outside', 725 + variant % 2)
      when 119, 108
        autotile(image, code == 108 ? 'Sea' : 'Still water', mask, code == 108)
      when 111
        cliff(image, biome, mask)
      when 97
        autotile(image, 'Light grass', mask)
      when 103
        grass(image, biome)
        if biome == 'meadow'
          flowers = source('Autotiles/Flowers1')
          image.blt(0, 0, flowers, Rect.new(0, 0, 32, 32)) if flowers && variant == 0
        end
      end
      @cache[key] = image
    end

    def tile(map, x, y)
      data = Expeditions.data_for(map)
      return nil unless data && x.between?(0, 63) && y.between?(0, 63)
      cells = data['cells']
      code = cells.getbyte(y * ExpeditionLayout::SIZE + x)
      mask = [97, 108, 111, 112, 119].include?(code) ? mask_for(cells, x, y, code) : 255
      variant = [98, 103].include?(code) ? ((x * 73856093) ^ (y * 19349663)) % 4 : 0
      bitmap(data['biome'], code, mask, variant)
    end

    def clear
      [@cache, @sources].compact.each do |collection|
        collection.each_value { |image| image.dispose if image && !image.disposed? }
        collection.clear
      end
    end
  end

  module ExpeditionTreeGraphic
    def refresh_graphic
      data = Expeditions.data_for(@character.map) if @character && ExpeditionLayout.map?(@character.map.map_id)
      native_tree = data && @character.respond_to?(:name) && @character.name == 'Wilderness scenery' &&
                    (@character.character_name == 'Object tree 1' ||
                     (@character.character_name == 'Object boulder' && ['snow', 'crystal'].include?(data['biome'])))
      if native_tree
        return if @arena_native_tree && @charbitmap && !@charbitmap.disposed?
        super
        image = ExpeditionTerrain.scenery_bitmap(@character.character_name, data['biome'], @character.x, @character.y)
        return unless image
        @charbitmap.dispose if @charbitmap
        @charbitmap = image
        @charbitmapAnimated = false
        @tile_id = 384 # One image, rather than a four-direction character sheet.
        @cw, @ch = image.width, image.height
        @spriteoffset = false
        self.src_rect.set(0, 0, @cw, @ch)
        self.ox, self.oy = @cw / 2, @ch
        @character.sprite_size = [@cw, @ch]
        @arena_native_tree = true
      else
        @arena_native_tree = false
        super
      end
    end
  end

  module ExpeditionTileRenderer
    def refresh_tile(tile, x, y, map, layer, tile_id)
      super
      return unless ExpeditionLayout.map?(map.map_id)
      display_x = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      display_y = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      display_x = ((display_x + Graphics.width / 2) * TilemapRenderer::ZOOM_X) - Graphics.width / 2 if TilemapRenderer::ZOOM_X != 1
      display_y = ((display_y + Graphics.height / 2) * TilemapRenderer::ZOOM_Y) - Graphics.height / 2 if TilemapRenderer::ZOOM_Y != 1
      map_x = x + display_x / TilemapRenderer::DISPLAY_TILE_WIDTH
      map_y = y + display_y / TilemapRenderer::DISPLAY_TILE_HEIGHT
      image = ExpeditionTerrain.tile(map, map_x, map_y)
      return unless image
      tile.bitmap = layer == 0 ? image : nil
      tile.src_rect = Rect.new(0, 0, 32, 32)
      tile.animated = false
      tile.is_autotile = false
      tile.filename = ''
      tile.visible = layer == 0
      tile.shows_reflection = false
      tile.bridge = false
      tile.z = 0
    end
  end
end

TilemapRenderer.prepend(ArenaDemo::ExpeditionTileRenderer) if defined?(TilemapRenderer)
Sprite_Character.prepend(ArenaDemo::ExpeditionTreeGraphic) if defined?(Sprite_Character)
EventHandlers.add(:on_enter_map, :arena_expedition_weather, proc { |_old_id|
  if ArenaDemo::Expeditions.active?
    biome = ArenaDemo::Expeditions.region($game_map.map_id)['biome']
    weather = { 'snow' => :Snow, 'storm' => :Storm, 'swamp' => :Fog }.fetch(biome, :None)
    $game_screen.weather(weather, weather == :None ? 0 : 3, 0)
  else
    ArenaDemo::ExpeditionTerrain.clear
  end
})
