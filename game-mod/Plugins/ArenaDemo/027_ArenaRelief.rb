# Two logical heights on Map 100; all artwork comes from the local Essentials.
module ArenaDemo
  PLATFORM_STYLES = ArenaMaterials::STYLES
  module_function

  def platform_style_grid(records = tile_edit_records)
    grid = '0' * (MAP_WIDTH * MAP_HEIGHT)
    records.each do |key, record|
      next unless record.is_a?(Hash) && (record['height'] == 1 || record['stair']) && record['floor'] != 'void'
      x, y = key.split(',').map(&:to_i)
      next unless x && y && x.between?(0, 99) && y.between?(0, 99)
      grid.setbyte(y * MAP_WIDTH + x, ArenaMaterials::ALPHABET[ArenaRelief::STYLES.index(record['platform_style']) || 0].ord)
    end
    grid
  end

  def platform_style_at(records, x, y)
    record = records[tile_edit_key(x, y)]
    style = record.is_a?(Hash) && record['platform_style']
    PLATFORM_STYLES.key?(style) ? style : 'mountain'
  end

  def editor_choose_platform_style
    entry = choose_material_catalog(material_style_entries, 'Choisissez le style de toute la plateforme.')
    entry ? { :platform_style => entry[:platform_style] } : nil
  end

  def connected_platform(records, x, y)
    return [] unless relief_code(records, x, y).to_i > 0
    points = [[x, y]]
    seen = { tile_edit_key(x, y) => true }
    index = 0
    while index < points.length
      px, py = points[index]
      index += 1
      ArenaRelief::DIRECTIONS.each_value do |dx, dy|
        nx, ny = px + dx, py + dy
        key = tile_edit_key(nx, ny)
        next if seen[key] || relief_code(records, nx, ny).to_i <= 0
        seen[key] = true
        points << [nx, ny]
      end
    end
    points
  end

  def editor_apply_platform_style(records, x, y, style)
    return false unless PLATFORM_STYLES.key?(style)
    return false if defined?(Visits) && Visits.locked?
    points = connected_platform(records, x, y)
    if points.empty?
      pbMessage("Choisissez le dessus d'une plateforme ou un escalier, pas une paroi.")
      return false
    end
    points.each do |px, py|
      record = tile_surface_state(records, px, py)
      record['platform_style'] = style
      record['ground'] = PLATFORM_STYLES[style][1]
      records[tile_edit_key(px, py)] = record
      apply_tile_surface($game_map, px, py, record)
    end
    true
  end

  def relief_reserved
    [[INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 16],
     [INITIAL_FIELD_X + 10, INITIAL_FIELD_Y + 16],
     [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 4],
     [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 18]]
  end

  def relief_grid(records = tile_edit_records)
    grid = "0" * (MAP_WIDTH * MAP_HEIGHT)
    records.each do |key, record|
      next unless record.is_a?(Hash) && record["floor"] != "void"
      coords = key.split(",").map(&:to_i)
      next unless coords.length == 2 && coords.all? { |n| n.between?(0, 99) }
      code = record["stair"] || (record["height"] == 1 ? 1 : 0)
      grid.setbyte(coords[1] * MAP_WIDTH + coords[0], 48 + code)
    end
    grid
  end

  def valid_relief_records?(records, placements)
    surface = "1" * (MAP_WIDTH * MAP_HEIGHT)
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        state = tile_surface_state(records, x, y)
        surface.setbyte(y * MAP_WIDTH + x, 48) if tile_is_void?(x, y, records) || state['ground'] == 'quicksand'
      end
    end
    positions = placements.map { |p| [p["x"], p["y"]] }
    ArenaRelief.valid?(relief_grid(records), surface, relief_reserved, positions)
  end

  def editor_choose_relief
    choice = pbMessage("Relief : les flèches indiquent le sens de montée. Un escalier occupe la case haute, entre sol et plateforme.",
      ["Ajouter une plateforme", "Retirer le relief", "Escalier vers le haut ↑",
       "Escalier vers la droite →", "Escalier vers le bas ↓", "Escalier vers la gauche ←", "Retour"], -1)
    return nil unless choice && choice.between?(0, 5)
    { :relief => [1, 0, 8, 6, 2, 4][choice] }
  end

  def relief_tool_name(code)
    { 0 => "suppression du relief", 1 => "plateforme",
      8 => "escalier vers le haut", 6 => "escalier vers la droite",
      2 => "escalier vers le bas", 4 => "escalier vers la gauche" }.fetch(code)
  end

  def editor_apply_relief(records, placements, x, y, code)
    return false unless valid_editor_tile?(x, y) && !relief_reserved.include?([x, y])
    return false unless ArenaRelief::CODES.include?(code)
    if tile_is_void?(x, y, records) || tile_surface_state(records, x, y)['ground'] == 'quicksand' || editor_occupied(placements, x, y)
      pbMessage("Choisissez une case de sol libre. Retirez d'abord son occupant.")
      return false
    end
    record = tile_surface_state(records, x, y)
    record["height"] = code == 0 ? 0 : 1
    record["stair"] = code > 1 ? code : nil
    candidate = records.merge(tile_edit_key(x, y) => record)
    if $game_player && relief_wall?(candidate, $game_player.x, $game_player.y)
      pbMessage("Déplacez-vous avant d'ajouter une paroi sur votre case.")
      return false
    end
    unless valid_relief_records?(candidate, placements)
      pbMessage("L'escalier doit relier un sol bas à une plateforme dans le sens de montée. Retirez les escaliers avant leurs appuis.")
      return false
    end
    records[tile_edit_key(x, y)] = record
    apply_tile_surface($game_map, x, y, record)
    true
  end

  def relief_code(records, x, y, surf = false)
    return 0 if surf && surf_ground?(records, x, y)
    return nil if tile_is_void?(x, y, records)
    record = records[tile_edit_key(x, y)]
    return 0 unless record.is_a?(Hash)
    record["stair"] || (record["height"] == 1 ? 1 : 0)
  end

  def relief_step?(records, x, y, direction, surf = false)
    return false if tile_is_void?(x, y, records) && !(surf && surf_ground?(records, x, y))
    return false if relief_wall?(records, x, y)
    offset = ArenaRelief::DIRECTIONS[direction]
    return true unless offset
    nx, ny = x + offset[0], y + offset[1]
    return false if relief_wall?(records, nx, ny)
    a, b = relief_code(records, x, y, surf), relief_code(records, nx, ny, surf)
    return false unless a && b
    return true if a > 1 && a == b && direction != a && direction != 10 - a
    return false if a > 1 && direction != a && direction != 10 - a
    return false if b > 1 && direction != b && direction != 10 - b
    (a > 1 ? (direction == a ? 1 : 0) : a) ==
      (b > 1 ? (10 - direction == b ? 1 : 0) : b)
  end

  def relief_wall?(records, x, y)
    return false unless x.between?(0, MAP_WIDTH - 1) && y.between?(0, MAP_HEIGHT - 1)
    code = relief_code(records, x, y)
    (!code || code == 0) && relief_code(records, x, y - 1) == 1
  end

  def relief_cliff_sheet(style = 'mountain')
    @relief_cliff_sheets ||= {}
    cached = @relief_cliff_sheets[style]
    return cached if cached && !cached.disposed?
    sheet = Bitmap.new(96, 96)
    sheet.blt(0, 0, ExpeditionTerrain.source('Tilesets/Caves'), Rect.new(0, style == 'snow' ? 3648 : 480, 96, 96))
    # The cave atlas uses opaque black outside the cliff silhouette. Only this
    # private crop is keyed; shared expedition artwork and dark rock are intact.
    96.times do |y|
      96.times do |x|
        color = sheet.get_pixel(x, y)
        if color.red == 0 && color.green == 0 && color.blue == 0
          sheet.set_pixel(x, y, Color.new(0, 0, 0, 0))
        elsif style == 'volcano'
          shade = (color.red * 0.30 + color.green * 0.59 + color.blue * 0.11) * 0.72
          sheet.set_pixel(x, y, Color.new([shade + 18, 255].min, shade * 0.66, shade * 0.55, color.alpha))
        elsif style == 'mountain'
          # Reuse native rock shading with a grey mountain palette. Grass
          # retains its warm earth face; snow uses the installed snow family.
          shade = (color.red * 0.30 + color.green * 0.59 + color.blue * 0.11).round
          sheet.set_pixel(x, y, Color.new(shade, shade, [shade + 3, 255].min, color.alpha))
        elsif material_wall_palette(style)
          shade = (color.red * 0.30 + color.green * 0.59 + color.blue * 0.11) / 160.0
          r, g, b = material_wall_palette(style)
          sheet.set_pixel(x, y, Color.new([r * shade, 255].min, [g * shade, 255].min, [b * shade, 255].min, color.alpha))
        end
      end
    end
    @relief_cliff_sheets[style] = sheet
  end

  def draw_platform_floor(image, ground)
    return draw_liquid_floor(image, ground) if LIQUID_GROUNDS.include?(ground)
    case ground
    when 'grass' then ExpeditionTerrain.autotile(image, 'Light grass')
    when 'snow' then ExpeditionTerrain.autotile(image, 'White path')
    when 'ice'
      image.blt(0, 0, ice_surface_bitmap, Rect.new(0, 0, 32, 32))
    when 'desert' then ExpeditionTerrain.autotile(image, 'Sand')
    when 'rock' then ExpeditionTerrain.autotile(image, 'Gravel')
    when 'volcanic'
      ExpeditionTerrain.autotile(image, 'Red cave floor')
      32.times do |y|
        32.times do |x|
          c = image.get_pixel(x, y)
          shade = (c.red * 0.30 + c.green * 0.59 + c.blue * 0.11) * 0.65
          image.set_pixel(x, y, Color.new([shade + 15, 255].min, shade * 0.72, shade * 0.63, c.alpha))
        end
      end
    when 'lava' then ExpeditionTerrain.autotile(image, 'Sea deep', 255, true)
    else
      return if draw_extra_material_floor(image, ground)
      ExpeditionTerrain.atlas(image, 'Outside', 401)
    end
  end

  def round_platform_corners(image, mask, sheet, draw_rim = true)
    [[1, 64, 0, 0], [1, 4, 31, 0], [16, 64, 0, 31], [16, 4, 31, 31]].each do |v, h, ox, oy|
      next unless mask & v == 0 && mask & h == 0
      6.times do |py|
        6.times do |px|
          distance = (5 - px)**2 + (5 - py)**2
          x, y = ox == 0 ? px : 31 - px, oy == 0 ? py : 31 - py
          if distance > 25
            image.set_pixel(x, y, Color.new(0, 0, 0, 0))
          elsif draw_rim && distance > 9
            rim = sheet.get_pixel(32 + px, 6)
            image.set_pixel(x, y, rim) if rim.alpha > 0
          end
        end
      end
    end
  end

  def platform_floor_bitmap(ground)
    @platform_floors ||= {}
    cached = @platform_floors[ground]
    return cached if cached && !cached.disposed?
    bitmap = Bitmap.new(32, 32)
    draw_platform_floor(bitmap, ground)
    @platform_floors[ground] = bitmap
  end

  def draw_relief_cliff(image, mask, ground = 'rock', style = 'mountain')
    sheet = relief_cliff_sheet(style)
    image.blt(0, 0, platform_floor_bitmap(ground), Rect.new(0, 0, 32, 32))
    # Full summit tiles with thin, unscaled native stone lips. A continuous
    # right-angle outline replaces the artificial shrunken corner cut-outs.
    [[1, 0, 0, 32, 2, 32, 6], [64, 0, 0, 2, 32, 14, 32],
     [4, 30, 0, 2, 32, 80, 32]].each do |bit, x, y, w, h, sx, sy|
      image.blt(x, y, sheet, Rect.new(sx, sy, w, h)) if mask & bit == 0
    end
    round_platform_corners(image, mask, sheet)
  end

  def draw_relief_wall(image, left, right, style = 'mountain', ground = 'rock')
    sheet = relief_cliff_sheet(style)
    # Full-size bottom-row rock art. The upper lip provides a margin beyond
    # the last playable tile, so feet stop before the actual cliff face.
    image.blt(0, 0, sheet, Rect.new(left ? 32 : 0, 64, 16, 32))
    image.blt(16, 0, sheet, Rect.new(right ? 48 : 80, 64, 16, 32))
    # Cap the native face with the selected summit material; keep the cliff's
    # outer alpha and its rock/snow texture below the lip.
    floor = platform_floor_bitmap(ground)
    4.times do |y|
      32.times do |x|
        image.set_pixel(x, y, floor.get_pixel(x, y)) if image.get_pixel(x, y).alpha > 0
      end
    end
    decorate_material_wall(image, style)
    # The same arc continues into both ends of the rock face. Middle wall
    # segments keep their full width, with no repeated rounded seams.
    round_platform_corners(image, (left ? 64 : 0) | (right ? 4 : 0), sheet, false)
  end

  def relief_bitmap(records, x, y)
    code = relief_code(records, x, y)
    if relief_wall?(records, x, y)
      style = platform_style_at(records, x, y - 1)
      ground = tile_surface_state(records, x, y - 1)['ground']
      left = relief_wall?(records, x - 1, y) || relief_code(records, x - 1, y).to_i > 0
      right = relief_wall?(records, x + 1, y) || relief_code(records, x + 1, y).to_i > 0
      @relief_walls ||= {}
      key = [left, right, style, ground]
      wall = @relief_walls[key]
      return wall if wall && !wall.disposed?
      wall = Bitmap.new(32, 32)
      draw_relief_wall(wall, left, right, style, ground)
      return @relief_walls[key] = wall
    end
    return nil unless code && code > 0
    mask = 0
    ExpeditionTerrain::OFFSETS.each_with_index do |(dx, dy), i|
      neighbor = relief_code(records, x + dx, y + dy)
      connected = neighbor && neighbor > 0
      direction = ArenaRelief::DIRECTIONS.key([dx, dy])
      connected &&= relief_step?(records, x, y, direction) if direction
      mask |= 1 << i if connected
    end
    # Stair rails join only to stairs ascending in the same direction.
    sides = ArenaRelief::DIRECTIONS.keys.select do |d|
      dx, dy = ArenaRelief::DIRECTIONS[d]
      relief_code(records, x + dx, y + dy) == code
    end
    style = platform_style_at(records, x, y)
    ground = tile_surface_state(records, x, y)['ground']
    key = [code, mask, sides, style, ground]
    @relief_bitmaps ||= {}
    bitmap = @relief_bitmaps[key]
    return bitmap if bitmap && !bitmap.disposed?
    bitmap = Bitmap.new(32, 32)
    draw_relief_cliff(bitmap, mask, ground, style)
    if code > 1
      sheet = ExpeditionTerrain.source('Tilesets/Caves')
      # Installed cave stone steps, turned to the selected ascent direction.
      turns = { 8 => 0, 6 => 1, 2 => 2, 4 => 3 }.fetch(code)
      32.times do |py|
        32.times do |px|
          tx, ty = px, py
          turns.times { tx, ty = 31 - ty, tx }
          bitmap.set_pixel(tx, ty, sheet.get_pixel(96 + px, 608 + py))
        end
      end
      # Native rock strips at exposed sides; compatible adjacent segments merge.
      rails = Bitmap.new(32, 32)
      draw_relief_cliff(rails, 0, ground, style)
      rails.blt(0, 30, relief_cliff_sheet(style), Rect.new(32, 6, 32, 2))
      [2, 4, 6, 8].each do |d|
        next if d == code || d == 10 - code || sides.include?(d)
        rect = { 2 => [0, 28, 32, 4], 4 => [0, 0, 4, 32],
                 6 => [28, 0, 4, 32], 8 => [0, 0, 32, 4] }.fetch(d)
        bitmap.blt(rect[0], rect[1], rails, Rect.new(*rect))
      end
      rails.dispose
    end
    @relief_bitmaps[key] = bitmap
  end
end

module ArenaDemo::ReliefCollision
  def passable?(x, y, direction, self_event = nil)
    if @map_id == ArenaDemo::MAP_ID
      return false unless ArenaDemo.relief_step?(ArenaDemo.tile_edit_records, x, y, direction, ArenaDemo.runtime_surf?(self_event))
      # Map#passable? is also called on the destination with reversed direction.
      # Both ends use the same symmetric edge rule; object checks remain native.
    end
    super
  end

  def passableStrict?(x, y, direction, self_event = nil)
    if @map_id == ArenaDemo::MAP_ID
      return false unless ArenaDemo.relief_step?(ArenaDemo.tile_edit_records, x, y, direction)
    end
    super
  end
end
Game_Map.prepend(ArenaDemo::ReliefCollision) if defined?(Game_Map)

if defined?(TilemapRenderer)
  module ArenaDemo::ReliefRenderer
    def refresh_tile(tile, x, y, map, layer, tile_id)
      tile.instance_variable_set(:@arena_relief_overlay, false)
      super
      return unless map.map_id == ArenaDemo::MAP_ID && layer == 1
      dx = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      dy = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      dx = ((dx + Graphics.width / 2) * TilemapRenderer::ZOOM_X) - Graphics.width / 2
      dy = ((dy + Graphics.height / 2) * TilemapRenderer::ZOOM_Y) - Graphics.height / 2
      mx = x + dx / TilemapRenderer::DISPLAY_TILE_WIDTH
      my = y + dy / TilemapRenderer::DISPLAY_TILE_HEIGHT
      bitmap = ArenaDemo.relief_bitmap(ArenaDemo.surface_records_for_render, mx, my)
      return unless bitmap
      tile.bitmap = bitmap
      tile.instance_variable_set(:@arena_relief_overlay, true)
      # Keep the native ground on layer 0 visible through cliff corner alpha.
      tile.visible = true
      tile.priority = 0
      tile.z = 1
      tile.shows_reflection = tile.bridge = false
      tile.src_rect = Rect.new(0, 0, 32, 32)
      tile.animated = tile.is_autotile = false
      tile.filename = ""
    end

    def refresh_tile_z(tile, map, y, layer, tile_id)
      super
      tile.z = 1 if tile.instance_variable_get(:@arena_relief_overlay)
    end
  end
  TilemapRenderer.prepend(ArenaDemo::ReliefRenderer)
end

module ArenaDemo::ReliefOverview
  def draw_global_overview(bitmap, records, placements)
    super
    records.each do |key, record|
      x, y = key.split(',').map(&:to_i)
      next unless record["height"] == 1 || record["stair"]
      color = record["stair"] ? Color.new(255, 218, 105) : Color.new(*material_overview_color(record['ground']))
      bitmap.fill_rect(x * 2, y * 2, 2, 2, color)
    end
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::ReliefOverview)
