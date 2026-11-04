# Small original pixel drawings generated with the engine's own Bitmap API.
module ArenaDemo::DeviceArt
  SPARK_FRAMES = 18
  SPARK_FPS = 18
  module_function
  def color(r, g, b, a = 255); Color.new(r, g, b, a); end
  def line(image, x0, y0, x1, y1, ink)
    count = [(x1 - x0).abs, (y1 - y0).abs, 1].max
    (0..count).each do |i|
      image.set_pixel((x0 + (x1 - x0) * i.to_f / count).round,
        (y0 + (y1 - y0) * i.to_f / count).round, ink)
    end
  end
  def ring(image, x, y, radius, ink)
    64.times do |i|
      angle = i * Math::PI / 32
      image.set_pixel((x + Math.cos(angle) * radius).round, (y + Math.sin(angle) * radius).round, ink)
    end
  end
  def arrow(image, direction, ink, cy = 48)
    _dir, dx, dy = ArenaDevices::DIRECTIONS.fetch(direction)
    ex, ey = 16 + dx * 8, cy + dy * 8
    line(image, 16 - dx * 5, cy - dy * 5, ex, ey, ink)
    line(image, ex, ey, ex - dx * 5 + dy * 4, ey - dy * 5 - dx * 4, ink)
    line(image, ex, ey, ex - dx * 5 - dy * 4, ey - dy * 5 + dx * 4, ink)
  end
  # Authored silhouettes on a 16x16 grid, drawn as crisp 2x2 pixel clusters.
  SPARK_SHAPES = [
    [[18,2],[17,9],[21,7],[19,13],[23,12],[22,15],[30,12],
     [26,18],[22,17],[23,21],[18,19],[20,25],[16,23],[14,30],
     [13,22],[10,24],[12,18],[7,20],[9,16],[2,18],[6,13],
     [10,14],[8,9],[13,12],[12,5],[15,8]],
    [[12,2],[17,8],[15,11],[19,10],[18,14],[24,9],[23,13],
     [30,14],[24,17],[26,20],[20,18],[21,23],[17,21],[19,30],
     [14,25],[15,20],[10,22],[12,17],[6,19],[8,15],[2,12],
     [9,11],[9,7],[14,13],[13,8]],
    [[21,3],[18,10],[21,9],[19,14],[25,13],[23,16],[30,20],
     [23,20],[24,24],[18,20],[17,25],[14,23],[11,29],[12,21],
     [8,23],[11,18],[5,17],[7,14],[2,9],[10,12],[9,7],
     [14,11],[15,4],[17,8]]
  ].freeze
  def spark(phase)
    phase %= SPARK_FRAMES
    @sparks ||= {}
    @sparks[phase] ||= begin
      image = Bitmap.new(32,32)
      points = SPARK_SHAPES[(phase / 2) % SPARK_SHAPES.length].map { |x,y| [x / 2,y / 2] }
      mask = Array.new(16) { Array.new(16, false) }
      # Scan-convert the outline without smoothing or a translucent halo.
      16.times do |y|
        cuts = []
        points.each_with_index do |p,i|
          q = points[(i+1) % points.length]
          next unless (p[1] <= y && q[1] > y) || (q[1] <= y && p[1] > y)
          cuts << p[0] + (y-p[1]).to_f * (q[0]-p[0]) / (q[1]-p[1])
        end
        cuts.sort.each_slice(2) do |left,right|
          (left.ceil..right.floor).each { |x| mask[y][x] = true }
        end
      end
      inside = proc { |x,y| x.between?(0,15) && y.between?(0,15) && mask[y][x] }
      outline = color(184,112,40)
      gold = color(248,208,72)
      white = color(255,248,200)
      16.times do |y|
        16.times do |x|
          next unless mask[y][x]
          edge = !inside.call(x-1,y) || !inside.call(x+1,y) ||
                 !inside.call(x,y-1) || !inside.call(x,y+1)
          # Warm lower-right rim and pale upper highlights.
          ink = if edge then (inside.call(x,y-1) && inside.call(x-1,y) ? outline : gold)
                else white end
          image.fill_rect(x*2,y*2,2,2,ink)
        end
      end
      radius = 1
      (-radius..radius).each do |dy|
        span = radius-dy.abs
        (-span..span).each { |dx| image.fill_rect(16+dx*2,16+dy*2,2,2,white) }
      end
      motes = [[5,5],[26,5],[27,26],[5,26],[17,2],[2,22]]
      x,y = motes[(phase / 3) % motes.length]
      image.fill_rect((x/2)*2,(y/2)*2,2,2,phase.even? ? gold : white)
      image
    end
  end
  WEB_LINKS = { 'D' => 1, 'L' => 2, 'R' => 4, 'U' => 8 }.freeze
  def web_connections(x, y, objects)
    WEB_LINKS.sum do |direction, bit|
      _dir, dx, dy = ArenaDevices::DIRECTIONS.fetch(direction)
      objects.any? { |p| p[1] == ArenaDevices::WEB && p[2,2] == [x+dx,y+dy] } ? bit : 0
    end
  end
  def floor_glyph(item, links = 0)
    image = Bitmap.new(32, 64)
    if item == ArenaDevices::RUNE
      # Two continuous rings and four cardinal strokes; no tiny runic noise.
      32.times do |x|
        32.times do |y|
          r = Math.sqrt((x - 15.5)**2 + (y - 15.5)**2)
          ink = if r.between?(12, 14) then color(242, 66, 213)
                elsif r.between?(14, 15) then color(82, 28, 100)
                elsif r.between?(9, 10) then color(138, 48, 179) end
          image.set_pixel(x, y + 32, ink) if ink
        end
      end
      [[15, 33, 2, 6], [15, 57, 2, 6], [1, 47, 6, 2], [25, 47, 6, 2]].each do |rect|
        image.fill_rect(*rect, color(255, 174, 244))
      end
      [[16,43],[21,48],[16,53],[11,48],[16,43]].each_cons(2) do |p,q|
        line(image,*p,*q,color(174,48,190))
      end
    else
      # A sparse, legible web with eight spokes and two intact thread rings.
      # A single offset shadow supplies contrast without a thick black halo.
      points = [[16,33],[26,37],[30,48],[26,59],[16,62],[5,58],[1,48],[5,37]]
      segments = points.map { |p| [[16,48],p] }
      [0.48, 0.86].each do |scale|
        ring = points.map { |x,y| [(16+(x-16)*scale).round,(48+(y-48)*scale).round] }
        (ring+[ring.first]).each_cons(2) { |p,q| segments << [p,q] }
      end
      # Matching edge endpoints join neighbouring tiles without a gap.
      edges = { 1 => [[7,63],[16,63],[25,63]], 2 => [[0,39],[0,48],[0,57]],
                4 => [[31,39],[31,48],[31,57]], 8 => [[7,32],[16,32],[25,32]] }
      edges.each do |bit, points|
        points.each { |p| segments << [[16,48],p] } if links & bit != 0
      end
      segments.each { |(x,y),(u,v)| line(image,x,y+1,u,[v+1,63].min,color(61,78,96,210)) }
      segments.each do |p,q|
        line(image,*p,*q,color(255,255,255))
        # Widen the main cross to anchor the web visibly on pale floor tiles.
        line(image,p[0]+1,p[1],q[0]+1,q[1],color(255,255,255)) if p[0] == q[0]
      end
      image.fill_rect(15,47,3,3,color(255,255,255))
    end
    image
  end
  def coil(direction, disabled, phase)
    image = Bitmap.new(96,96)
    _dir, dx, dy = ArenaDevices::DIRECTIONS.fetch(direction)
    ds = File.file?('Graphics/ArenaDevices/device-art-style.txt') && File.read('Graphics/ArenaDevices/device-art-style.txt').strip == 'DS'
    heads = ds ? { 'R' => [58,32], 'L' => [38,32], 'U' => [48,26], 'D' => [48,38] } :
                 { 'R' => [58,26], 'L' => [40,26], 'U' => [48,25], 'D' => [48,29] }
    head = heads.fetch(direction)
    arc = []
    unless disabled
      target = [48+dx*32,48+dy*32]
      bend = [(head[0]+target[0])/2+dy*(phase%3-1)*2,
              (head[1]+target[1])/2+dx*(phase%3-1)*2]
      arc = [head,bend,target]
    end
    body = Bitmap.new("Graphics/ArenaDevices/coil-#{direction}.png")
    image.blt(32,0,body,body.rect)
    body.dispose
    # Keep the south-facing discharge visible over the front of the pedestal.
    arc.each_cons(2) do |p,q|
      [-1,0,1].each { |offset| line(image,p[0]+offset,p[1],q[0]+offset,q[1],color(248,208,72)) }
      line(image,*p,*q,color(255,248,200))
    end
    image.fill_rect(head[0]-1,head[1]-1,2,2,color(255,248,200)) unless disabled
    image
  end
  def bitmap(item, disabled = false, phase = 0, links = 0, coil_direction = nil)
    phase = 0 unless ArenaDevices::CONVEYORS.include?(item) || ArenaDevices.coil?(item)
    phase %= ArenaDevices.coil?(item) ? 9 : 4
    phase = 0 if disabled && ArenaDevices.coil?(item)
    @cache ||= {}
    key = [item, disabled, phase, links, coil_direction]
    return @cache[key] if @cache[key] && !@cache[key].disposed?
    if [ArenaDevices::RUNE, ArenaDevices::WEB].include?(item)
      return @cache[key] = floor_glyph(item, links)
    end
    if ArenaDevices.coil?(item)
      direction = coil_direction || (ArenaDevices.direction(item) ? item.split('_').last : 'R')
      return @cache[key] = coil(direction, disabled, phase)
    end
    image = Bitmap.new(32, 64)
    dark, steel, light = color(31, 37, 53), color(95, 115, 137), color(190, 212, 225)
    cyan, purple, yellow = color(72, 235, 246), color(164, 78, 235), color(255, 232, 79)
    root = 'Graphics/ArenaDevices/'
    file = if ArenaDevices.coil?(item) then 'coil'
           elsif ArenaDevices::MAGNETS.include?(item) then 'antenna-' + item.split('_').last
           elsif item == ArenaDevices::BUTTON then disabled ? 'button-down' : 'button-up'
           elsif item == ArenaDevices::RUNE then 'rune'
           elsif item == ArenaDevices::WEB then 'web'
           elsif item == ArenaDevices::TELEPORT then 'teleporter' end
    if file
      source = Bitmap.new(root + file + '.png')
      image.blt(0, 0, source, source.rect)
      source.dispose
    elsif ArenaDevices::CONVEYORS.include?(item)
      sheet = Bitmap.new(root + 'conveyor-sheet.png')
      row = { 'R' => 0, 'L' => 2, 'U' => 4, 'D' => 6 }.fetch(item.split('_').last)
      image.blt(0, 32, sheet, Rect.new(phase * 32, row * 32, 32, 32))
      sheet.dispose
    end
    @cache[key] = image
  end
end

module ArenaDemo::DeviceCatalogArt
  def furniture_catalog_preview(entry)
    return super unless ArenaDevices.item?(entry[:item])
    @device_previews ||= {}
    cached = @device_previews[entry[:item]]
    return cached if cached && !cached.disposed?
    image = Bitmap.new(96, 96)
    source = ArenaDemo::DeviceArt.bitmap(entry[:item].to_s)
    rect = ArenaDevices.coil?(entry[:item]) ? Rect.new(24,16,48,64) : Rect.new(0,16,32,48)
    image.stretch_blt(Rect.new(16, 0, 64, 96), source, rect)
    @device_previews[entry[:item]] = image
  end
  def material_catalog_description(entry)
    return super unless ArenaDevices.item?(entry[:item])
    pair = [ArenaDevices::TELEPORT, ArenaDevices::COIL].include?(entry[:item].to_s)
    "En réserve : #{entry[:qty]}\n#{pair ? 'Lot lié : 2 cases' : 'Occupe 1 case'}"
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::DeviceCatalogArt)

module ArenaDemo::DeviceCharacterArt
  def refresh_graphic
    item = @character.instance_variable_get(:@arena_device_item)
    unless ArenaDevices.item?(item)
      @arena_device_graphic = nil
      return super
    end
    slot = @character.instance_variable_get(:@arena_device_slot)
    if item == ArenaDevices::BUTTON
      slot = ArenaDevices.partner(ArenaDemo::Devices.wire, slot)
    end
    disabled = ArenaDemo::Devices.disabled.include?(slot)
    links, coil_direction = 0, nil
    if item == ArenaDevices::WEB
      links = ArenaDemo::DeviceArt.web_connections(@character.x,@character.y,ArenaDevices.furniture(ArenaDemo::Devices.wire))
    elsif ArenaDevices.coil?(item)
      target = ArenaDevices.spark_target(ArenaDemo::Devices.wire,slot)
      if target
        coil_direction = ArenaDevices::DIRECTIONS.find { |_key, (_dir,dx,dy)| [@character.x+dx,@character.y+dy] == target }&.first
      end
    end
    phase = if ArenaDevices.coil?(item) && !disabled then (System.uptime * 12).floor % 9
            elsif ArenaDevices::CONVEYORS.include?(item) then (System.uptime * 8).floor % 4
            else 0 end
    key = [item, disabled, phase, links, coil_direction]
    return if @arena_device_graphic == key && @charbitmap && !@charbitmap.disposed?
    @charbitmap&.dispose
    @bushbitmap&.dispose
    @bushbitmap = nil
    @charbitmap = ArenaDemo::DeviceArt.bitmap(item, disabled, phase, links, coil_direction).clone
    @charbitmapAnimated = false
    @arena_device_graphic = key
    @tile_id, @cw, @ch = 384, @charbitmap.width, @charbitmap.height
    self.src_rect.set(0, 0, @cw, @ch)
    self.ox, self.oy = @cw / 2, 64
    @character.sprite_size = [@cw, @ch]
  end

  def update(*args)
    super
    item = @character.instance_variable_get(:@arena_device_item)
    self.z -= 33 if ArenaDevices.floor?(item)
    scale = @character.instance_variable_get(:@arena_teleport_scale)
    if scale
      self.zoom_x *= scale
      self.zoom_y *= scale
    end
  end
end
