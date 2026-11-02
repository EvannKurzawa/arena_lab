# Small original pixel drawings generated with the engine's own Bitmap API.
module ArenaDemo::DeviceArt
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
  def spark(phase)
    phase %= 9
    @sparks ||= {}
    @sparks[phase] ||= begin
      image = Bitmap.new(32, 32)
      # Filled, irregular electric glow with a few sharp, branching tips.
      # Pixel-cluster shading keeps the orb organic instead of a geometric star.
      blue, cyan, pale, white = color(27,65,190),color(59,154,242),color(142,219,255),color(245,255,255)
      32.times do |y|
        32.times do |x|
          dx,dy = x-15.5,y-15.5
          angle = Math.atan2(dy,dx)
          edge = 9.0 + 0.9*Math.sin(angle*5 + phase*0.43) + 0.55*Math.sin(angle*9 - phase*0.31)
          distance = Math.sqrt(dx*dx + dy*dy)
          ink = if distance > edge then nil
                elsif distance > edge-2.1 then blue
                elsif distance > edge-4.7 then cyan
                else pale end
          image.set_pixel(x,y,ink) if ink
        end
      end
      4.times do |arm|
        angle = arm*Math::PI/2 + Math::PI/4 + phase*0.07
        bend = ((phase+arm)%3-1)*0.28
        p0 = [(16+Math.cos(angle)*7).round,(16+Math.sin(angle)*7).round]
        p1 = [(16+Math.cos(angle+bend)*11).round,(16+Math.sin(angle+bend)*11).round]
        p2 = [(16+Math.cos(angle+bend-0.24)*15).round.clamp(1,30),(16+Math.sin(angle+bend-0.24)*15).round.clamp(1,30)]
        [p0,p1,p2].each_cons(2) do |a,b|
          [-1,0,1].each { |offset| line(image,a[0]+offset,a[1],b[0]+offset,b[1],blue) }
          line(image,*a,*b,pale)
        end
      end
      image.fill_rect(13,13,6,6,white)
      image.fill_rect(10,11,2,2,pale)
      image.fill_rect(20,18,2,2,pale)
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
      [-1,0,1].each { |offset| line(image,p[0]+offset,p[1],q[0]+offset,q[1],color(25,97,224)) }
      line(image,*p,*q,color(164,250,255))
    end
    image.fill_rect(head[0]-1,head[1]-1,2,2,color(205,255,255)) unless disabled
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
