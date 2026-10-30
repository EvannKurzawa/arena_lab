# Native Essentials textures, in-memory palettes and small tile mosaics.
# No source graphic is modified and monotype floors do not alter battle rules.
module ArenaDemo
  MATERIAL_FLOORS = {
    'pavers' => [:auto, 'Gravel', nil, 0x999a97, :pavers],
    'parquet' => [:atlas, 'Gyms interior', 426, nil, :parquet],
    'metal' => [:atlas, 'Factory interior', 426, nil, :metal],
    'dirt' => [:auto, 'Dirt', nil, 0x9b7952, nil],
    'moss' => [:auto, 'Green cave floor', nil, 0x668953, :leaf],
    'wood' => [:bridge, 'Outside', nil, nil, nil],
    'mud' => [:auto, 'Blue cave mud', nil, 0x635d43, nil],
    'roots' => [:auto, 'Dirt', nil, 0x786448, :roots],
    'ruins' => [:auto, 'Gravel', nil, 0x8d9471, :ruins],
    'crystal' => [:auto, 'Gravel', nil, 0x59677b, :blue_specks],
    'legacy_crystal' => [:auto, 'Snow cave floor', nil, 0x9581b7, :crystal],
    'toxic' => [:auto, 'Sea deep', nil, 0xbdc722, :toxic_bubbles],
    'marsh_water' => [:auto, 'Sea deep', nil, 0x705032, :marsh_ripples],
    'steel_blue' => [:atlas, 'Factory interior', 426, 0x45647e, :steel_panels],
    'holo_hex' => [:auto, 'Gravel', nil, 0x19374e, :holo_hex],
    'quicksand' => [:auto, 'Sand', nil, nil, nil],
    'arena' => [:atlas, 'Factory interior', 426, 0xb3b7bc, :court]
  }.freeze
  TYPE_FLOORS = {
    'normal' => ['pavers', 0xc4b9a0, :diamond, 0xe5dcc7],
    'fire' => ['ruins', 0x8c4939, :flame, 0xe8a34c],
    'water' => ['metal', 0x437fa6, :waves, 0x9ed0d6],
    'electric' => ['metal', 0x77734b, :circuit, 0xe5ca61],
    'grass' => ['moss', 0x4e8859, :leaf, 0xa8bd73],
    'ice' => ['crystal', 0xa9c6ce, :snowflake, 0xe5f0eb],
    'fighting' => ['parquet', 0xb89e6b, :tatami, 0x786644],
    'poison' => ['legacy_crystal', 0x80568e, nil, 0xc5a2c2],
    'ground' => ['dirt', 0xb49a67, :dunes, 0xd9c18b],
    'flying' => ['pavers', 0x8eafbe, :cloud, 0xdfe5df],
    'psychic' => ['ruins', 0xa3678e, nil, 0xe2c3bc],
    'bug' => ['wood', 0x94955a, :honeycomb, 0xd6bd75],
    'rock' => ['ruins', 0x898879, :fracture, 0x555b59],
    'ghost' => ['ruins', 0x242431, :haunted, 0x8be0d0],
    'dragon' => ['crystal', 0x666c9b, :scales, 0xb6b3cb],
    'dark' => ['pavers', 0x484453, nil, 0xa59aaf],
    'steel' => ['metal', 0x8f9b9d, :rivets, 0xd5d5c8],
    'fairy' => ['crystal', 0xc29eae, :stars, 0xf0dfbb]
  }.freeze
  WALL_PALETTES = {
    'desert' => [191, 153, 96], 'forest' => [109, 109, 65],
    'ruins' => [139, 147, 110], 'crystal' => [60, 83, 112],
    'industrial' => [145, 159, 164], 'wood' => [160, 113, 66],
    'swamp' => [91, 111, 76], 'arena' => [157, 169, 181]
  }.freeze
  module_function

  def material_color(hex, alpha = 255)
    Color.new((hex >> 16) & 255, (hex >> 8) & 255, hex & 255, alpha)
  end

  def material_tint(image, hex)
    r, g, b = (hex >> 16) & 255, (hex >> 8) & 255, hex & 255
    32.times do |y|
      32.times do |x|
        c = image.get_pixel(x, y)
        shade = 0.45 + (c.red * 0.30 + c.green * 0.59 + c.blue * 0.11) / 300.0
        image.set_pixel(x, y, Color.new([r * shade, 255].min, [g * shade, 255].min, [b * shade, 255].min, c.alpha))
      end
    end
  end

  def material_pixel(image, x, y, color)
    return unless x.between?(0, 31) && y.between?(0, 31)
    image.set_pixel(x, y, color) if image.get_pixel(x, y).alpha > 0
  end

  def material_line(image, points, color)
    points.each_cons(2) do |(x0, y0), (x1, y1)|
      count = [(x1 - x0).abs, (y1 - y0).abs, 1].max
      (0..count).each do |i|
        material_pixel(image, (x0 + (x1 - x0) * i.to_f / count).round,
          (y0 + (y1 - y0) * i.to_f / count).round, color)
      end
    end
  end

  def material_ring(image, cx, cy, radius, color)
    (-radius..radius).each do |dy|
      (-radius..radius).each do |dx|
        distance = dx * dx + dy * dy
        material_pixel(image, cx + dx, cy + dy, color) if distance <= radius * radius && distance >= (radius - 1)**2
      end
    end
  end

  def draw_material_motif(image, motif, hex = 0xa8aa98)
    color = material_color(hex)
    case motif
    when :toxic_bubbles
      [[7, 8, 3], [24, 22, 4]].each do |x, y, r|
        material_ring(image, x, y, r + 1, material_color(0x737c15))
        material_ring(image, x, y, r, material_color(0xebff50))
        material_pixel(image, x - 1, y - r, material_color(0xf7ffa5))
      end
      material_line(image, [[14, 15], [17, 14], [20, 15]], material_color(0xd5ee3e))
    when :marsh_ripples
      material_line(image, [[2, 8], [6, 7], [11, 8]], material_color(0xa18554))
      material_line(image, [[19, 23], [24, 22], [29, 23]], material_color(0x4b432b))
      [[4, 25], [6, 26], [25, 5]].each { |x, y| material_pixel(image, x, y, material_color(0x7e8950)) }
    when :steel_panels
      # Bevels, recessed joints and tiny lamps, rather than a bright emblem.
      image.fill_rect(0, 0, 32, 32, material_color(0x41617b))
      material_line(image, [[0, 31], [0, 0], [31, 0]], material_color(0x7499ad))
      material_line(image, [[1, 30], [30, 30], [30, 1]], material_color(0x243c53))
      material_line(image, [[5, 6], [26, 6]], material_color(0x4e728b))
      material_line(image, [[5, 24], [12, 24]], material_color(0x293f53))
      [21, 24].each { |x| image.fill_rect(x, 24, 2, 1, material_color(0x84d5e6)) }
      [[4, 4], [27, 27]].each { |x, y| material_pixel(image, x, y, material_color(0xa8b8c1)) }
    when :holo_hex
      image.fill_rect(0, 0, 32, 32, material_color(0x152d40))
      # A periodic honeycomb whose sides continue through tile boundaries.
      [-16, 0, 16, 32].each do |y|
        [-16, 0, 16, 32].each do |x|
          ox = x + ((y / 16).odd? ? 8 : 0)
          points = [[ox, y + 4], [ox + 8, y], [ox + 16, y + 4],
                    [ox + 16, y + 12], [ox + 8, y + 16], [ox, y + 12], [ox, y + 4]]
          material_line(image, points, material_color(0x2c647c))
          material_line(image, [[ox + 2, y + 4], [ox + 8, y + 1], [ox + 13, y + 4]], material_color(0x5bc7dc))
        end
      end
    when :sand_spiral
      points = (0..72).map do |i|
        angle = i * Math::PI / 12
        radius = 1.0 + i * 0.17
        [(15.5 + Math.cos(angle) * radius).round, (15.5 + Math.sin(angle) * radius * 0.68).round]
      end
      material_line(image, points, material_color(0x94703d))
      material_line(image, points.map { |x, y| [x, y - 1] }, material_color(0xd6b36e))
      material_ring(image, 16, 16, 2, material_color(0x735734))
    when :haunted
      # Staggered basalt slabs with matching joints at tile boundaries.
      image.fill_rect(0, 0, 32, 32, material_color(0x252936))
      [0, 16].each do |y|
        material_line(image, [[0, y], [31, y]], material_color(0x151a25))
        material_line(image, [[0, y + 1], [31, y + 1]], material_color(0x353c4b))
        x = y == 0 ? 8 : 24
        material_line(image, [[x, y], [x, y + 15]], material_color(0x151a25))
        material_line(image, [[x + 1, y + 2], [x + 1, y + 14]], material_color(0x303746))
      end
    when :blue_specks
      [[7, 9], [24, 21], [18, 4]].each do |x, y|
        [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
          material_pixel(image, x + dx, y + dy, material_color(0x3f768d))
        end
        material_pixel(image, x, y, material_color(0x63d8ff))
      end
    when :pavers, :ruins
      [0, 16].each { |y| material_line(image, [[0, y], [31, y]], color) }
      material_line(image, [[8, 0], [8, 15]], color)
      material_line(image, [[24, 16], [24, 31]], color)
      material_line(image, [[18, 4], [21, 7], [18, 12]], material_color(0x5d6557)) if motif == :ruins
    when :parquet, :tatami
      [3, 11, 19, 27].each { |y| material_line(image, [[0, y], [31, y]], color) }
      material_line(image, [[16, 4], [16, 10]], color)
      material_line(image, [[8, 12], [8, 18]], color)
      if motif == :parquet
        [0, 16].each { |x| material_line(image, [[x, 0], [x + 15, 15], [x, 30]], color) }
      elsif motif == :tatami
        [1, 5, 9, 13, 17, 21, 25, 29].each { |x| material_line(image, [[x, 0], [x, 31]], color) }
      end
    when :metal, :rivets
      material_line(image, [[0, 0], [31, 0], [31, 31]], material_color(0x596970))
      [[4, 4], [27, 4], [4, 27], [27, 27]].each { |x, y| material_ring(image, x, y, 1, color) }
    when :roots
      material_line(image, [[5, 0], [8, 8], [5, 16], [12, 25], [10, 31]], material_color(0xb49a67))
      material_line(image, [[8, 8], [18, 12], [22, 20], [31, 23]], material_color(0x4f4a37))
      material_line(image, [[12, 25], [21, 30]], material_color(0x4f4a37))
    when :mud
      material_ring(image, 9, 12, 4, color)
      material_line(image, [[18, 24], [21, 22], [28, 23]], color)
    when :crystal, :diamond
      material_line(image, [[16, 4], [23, 15], [16, 27], [9, 15], [16, 4], [16, 27]], color)
      material_line(image, [[9, 15], [23, 15]], color) if motif == :crystal
    when :court
      material_line(image, [[1, 0], [1, 31], [30, 31], [30, 0]], material_color(0xe7e6d9))
      material_ring(image, 16, 16, 7, material_color(0xb65f58))
      material_line(image, [[9, 16], [23, 16]], material_color(0x596777))
    when :flame, :fracture
      material_line(image, [[0, 24], [7, 18], [11, 20], [19, 9], [23, 11], [31, 0]], color)
      material_line(image, [[11, 20], [14, 29]], color)
      material_line(image, [[19, 9], [17, 2]], color)
    when :waves, :dunes
      [6, 22].each { |y| material_line(image, [[0, y], [6, y - 2], [13, y], [20, y + 2], [27, y], [31, y]], color) }
    when :circuit
      material_line(image, [[0, 7], [11, 7], [11, 22], [31, 22]], color)
      material_line(image, [[19, 0], [19, 12], [27, 12]], color)
      [[11, 7], [11, 22], [27, 12]].each { |x, y| material_ring(image, x, y, 2, color) }
    when :leaf
      material_line(image, [[7, 25], [24, 7], [24, 16], [16, 25], [7, 25], [7, 16], [16, 7], [24, 7]], color)
      material_line(image, [[12, 20], [11, 14]], color)
      material_line(image, [[17, 15], [22, 16]], color)
    when :snowflake
      [[[16, 5], [16, 27]], [[6, 10], [26, 22]], [[6, 22], [26, 10]],
       [[12, 7], [16, 11], [20, 7]], [[12, 25], [16, 21], [20, 25]]].each { |points| material_line(image, points, color) }
    when :bubbles
      [[8, 10, 4], [23, 22, 5], [24, 6, 2]].each { |x, y, r| material_ring(image, x, y, r, color) }
    when :cloud
      material_ring(image, 10, 17, 4, color)
      material_ring(image, 17, 13, 5, color)
      material_ring(image, 23, 17, 3, color)
      material_line(image, [[8, 21], [24, 21]], color)
    when :runes
      [5, 11].each { |r| material_ring(image, 16, 16, r, color) }
      material_line(image, [[16, 3], [16, 7]], color)
      material_line(image, [[3, 16], [7, 16]], color)
    when :honeycomb, :scales
      [[0, 0], [16, 0], [8, 16], [24, 16]].each do |x, y|
        material_line(image, [[x, y + 4], [x + 4, y], [x + 12, y], [x + 16, y + 4],
          [x + 12, y + 12], [x + 4, y + 12], [x, y + 4]], color)
        material_line(image, [[x + 4, y + 5], [x + 12, y + 5]], color) if motif == :scales
      end
    when :wisp
      material_line(image, [[8, 25], [20, 27], [25, 20], [22, 10], [15, 6], [10, 11], [12, 16], [17, 17]], color)
      material_ring(image, 17, 16, 2, color)
    when :moon
      17.times do |y|
        17.times do |x|
          a = (x - 8)**2 + (y - 8)**2 <= 64
          b = (x - 12)**2 + (y - 5)**2 < 49
          material_pixel(image, x + 7, y + 7, color) if a && !b
        end
      end
      material_pixel(image, 25, 7, color)
      material_pixel(image, 26, 23, color)
    when :stars
      [[10, 11], [24, 24]].each do |x, y|
        material_line(image, [[x, y - 5], [x + 2, y - 1], [x + 5, y], [x + 1, y + 2],
          [x, y + 5], [x - 2, y + 1], [x - 5, y], [x - 1, y - 2], [x, y - 5]], color)
      end
    end
  end

  def draw_bridge_planks(image)
    # Outside's bridge-tagged tiles start at ID 1616 (y=4928). Sample the
    # wooden beam's clean grain, avoiding rail edges and diagonal panels.
    # Long unbroken boards meet across tiles; no staggered masonry joints.
    source = ExpeditionTerrain.source('Tilesets/Outside')
    32.times do |y|
      32.times do |x|
        c = source.get_pixel(4 + x % 24, 4932 + y % 6)
        shade = (y / 8).even? ? 1.0 : 0.94
        image.set_pixel(x, y, Color.new(c.red * 0.85 * shade,
          c.green * 0.68 * shade, c.blue * 0.48 * shade))
      end
    end
    [0, 8, 16, 24].each do |y|
      material_line(image, [[0, y], [31, y]], material_color(0xc59a60))
      material_line(image, [[0, y + 6], [31, y + 6]], material_color(0x856039))
      material_line(image, [[0, y + 7], [31, y + 7]], material_color(0x513b28))
      [2, 29].each do |x|
        material_pixel(image, x, y + 3, material_color(0x644c33))
        material_pixel(image, x, y + 4, material_color(0xc9a773))
      end
    end
  end

  def draw_extra_material_floor(image, ground, decorate = true)
    if ground == 'type_ghost'
      draw_material_motif(image, :haunted)
      return true
    end
    return draw_liquid_floor(image, ground) if LIQUID_GROUNDS.include?(ground)
    if ground.start_with?('type_')
      data = TYPE_FLOORS[ground.delete_prefix('type_')]
      return false unless data
      base, palette, motif, accent = data
      draw_extra_material_floor(image, base, !motif.nil? && ground != 'type_fighting')
      material_tint(image, palette)
      draw_material_motif(image, motif, accent) if motif
      return true
    end
    data = MATERIAL_FLOORS[ground]
    return false unless data
    kind, name, id, palette, motif = data
    if kind == :bridge
      draw_bridge_planks(image)
    elsif kind == :auto
      ExpeditionTerrain.autotile(image, name)
    else
      ExpeditionTerrain.atlas(image, name, id)
    end
    if ground == 'quicksand'
      32.times do |y|
        32.times do |x|
          c = image.get_pixel(x, y)
          image.set_pixel(x, y, Color.new(c.red * 0.96, c.green * 0.96, c.blue * 0.96, c.alpha))
        end
      end
    end
    material_tint(image, palette) if palette
    if ground == 'toxic'
      # Lift the native water's deep shadows so the liquid itself is fluorescent,
      # rather than just drawing yellow bubbles over an olive surface.
      32.times do |y|
        32.times do |x|
          c = image.get_pixel(x, y)
          image.set_pixel(x, y, Color.new(135 + c.red * 0.60,
            [150 + c.green * 0.65, 255].min, 12 + c.blue * 0.50, c.alpha))
        end
      end
    end
    draw_material_motif(image, motif) if motif && decorate
    true
  end

  def material_wall_palette(style)
    WALL_PALETTES[style]
  end

  def material_overview_color(ground)
    if ground.to_s.start_with?('type_') && (data = TYPE_FLOORS[ground.delete_prefix('type_')])
      hex = data[1]
      return [(hex >> 16) & 255, (hex >> 8) & 255, hex & 255]
    end
    data = MATERIAL_FLOORS[ground]
    if data && data[3]
      hex = data[3]
      return [(hex >> 16) & 255, (hex >> 8) & 255, hex & 255]
    end
    { 'water' => [63, 119, 175], 'wood' => [149, 109, 66], 'parquet' => [169, 129, 80],
      'metal' => [140, 155, 163], 'grass' => [64, 151, 78], 'snow' => [224, 236, 247],
      'ice' => [100, 187, 220], 'volcanic' => [127, 61, 48], 'lava' => [245, 104, 28],
      'desert' => [207, 157, 75], 'plain' => [126, 137, 143], 'rock' => [145, 145, 148]
    }.fetch(ground, [126, 137, 143])
  end

  def decorate_material_wall(image, style)
    if ['industrial', 'wood'].include?(style)
      draw_constructed_wall(image, style)
      return
    end
    surface = { 'industrial' => 'metal', 'wood' => 'wood', 'ruins' => 'ruins', 'arena' => 'arena' }[style]
    if surface
      texture = platform_floor_bitmap(surface)
      (4..31).each do |y|
        32.times do |x|
          next if image.get_pixel(x, y).alpha == 0
          c = texture.get_pixel(x, y)
          shade = 0.45 + (32 - y) / 80.0
          image.set_pixel(x, y, Color.new(c.red * shade, c.green * shade, c.blue * shade, c.alpha))
        end
      end
    end
    motif = { 'forest' => :roots, 'swamp' => :roots, 'crystal' => :blue_specks }[style]
    draw_material_motif(image, motif, style == 'crystal' ? 0xd0bce2 : 0x66784c) if motif
  end

  def draw_constructed_wall(image, style)
    steel = style == 'industrial'
    texture = platform_floor_bitmap(steel ? 'metal' : 'wood')
    (4..31).each do |y|
      32.times do |x|
        next if image.get_pixel(x, y).alpha == 0
        # Turn the native grain/seams upright: the front face must read as
        # vertical construction rather than another strip of walking floor.
        c = texture.get_pixel(y, x)
        fade = 0.40 + (32 - y) / 150.0
        color = if steel
                  Color.new(c.red * fade, c.green * fade, [c.blue * fade + 12, 255].min)
                else
                  Color.new(c.red * fade, c.green * fade * 0.85, c.blue * fade * 0.70)
                end
        image.set_pixel(x, y, color)
      end
    end
    dark = material_color(steel ? 0x283947 : 0x423022)
    light = material_color(steel ? 0x8d9eaa : 0xa37a4d)
    beam = material_color(steel ? 0x435a6b : 0x69482e)
    # Continuous upper/lower beams give the wall a strong horizontal lip.
    [4, 5, 6, 28, 29, 30, 31].each { |y| material_line(image, [[0, y], [31, y]], beam) }
    material_line(image, [[0, 4], [31, 4]], light)
    material_line(image, [[0, 7], [31, 7]], dark)
    material_line(image, [[0, 28], [31, 28]], dark)
    [0, 1, 2, 29, 30, 31].each { |x| material_line(image, [[x, 7], [x, 31]], beam) }
    material_line(image, [[3, 8], [3, 27]], light)
    material_line(image, [[28, 8], [28, 27]], dark)
    if steel
      [[6, 11], [25, 11], [6, 24], [25, 24]].each { |x, y| material_ring(image, x, y, 1, light) }
      material_line(image, [[15, 8], [15, 27]], dark)
    else
      # A braced timber support below the deck, distinct from the floorboards.
      [0, 1, 2].each { |dy| material_line(image, [[5, 24 + dy], [26, 9 + dy]], beam) }
      material_line(image, [[5, 24], [26, 9]], light)
      [[6, 24], [25, 11]].each { |x, y| material_pixel(image, x, y, dark) }
    end
  end
end
