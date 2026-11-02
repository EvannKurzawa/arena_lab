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
    @sparks ||= {}
    @sparks[phase] ||= begin
      image = Bitmap.new(32,32)
      shift = phase.even? ? 0 : 4
      points = [[4,24],[12,14+shift],[8,9],[23,3],[17,17-shift],[26,13],[18,29]]
      points.each_cons(2) do |p,q|
        [-1,0,1].each { |dx| line(image,p[0]+dx,p[1],q[0]+dx,q[1],color(40,115,235)) }
        line(image,*p,*q,color(255,252,160))
      end
      image
    end
  end
  def bitmap(item, disabled = false, phase = 0)
    phase = 0 unless ArenaDevices::CONVEYORS.include?(item) || item == ArenaDevices::COIL || item == ArenaDevices::TELEPORT
    @cache ||= {}
    key = [item, disabled, phase % 4]
    return @cache[key] if @cache[key] && !@cache[key].disposed?
    image = Bitmap.new(32, 64)
    dark, steel, light = color(31, 37, 53), color(95, 115, 137), color(190, 212, 225)
    cyan, purple, yellow = color(72, 235, 246), color(164, 78, 235), color(255, 232, 79)
    root = 'Graphics/ArenaDevices/'
    file = if ArenaDevices.coil?(item) then 'coil'
           elsif ArenaDevices::MAGNETS.include?(item) then 'antenna'
           elsif item == ArenaDevices::BUTTON then disabled ? 'button-down' : 'button-up'
           elsif item == ArenaDevices::RUNE then 'rune' end
    if file
      source = Bitmap.new(root + file + '.png')
      image.blt(0, 0, source, source.rect)
      source.dispose
      arrow(image, item.split('_').last, cyan, 48) if ArenaDevices::MAGNETS.include?(item)
    elsif ArenaDevices::CONVEYORS.include?(item)
      sheet = Bitmap.new(root + 'conveyor-sheet.png')
      row = { 'R' => 0, 'L' => 2, 'U' => 4, 'D' => 6 }.fetch(item.split('_').last)
      image.blt(0, 32, sheet, Rect.new(phase * 32, row * 32, 32, 32))
      sheet.dispose
    elsif item == ArenaDevices::WEB
      threads = Bitmap.new(32, 64)
      8.times do |i|
        angle = i * Math::PI / 4
        line(threads, 16, 48, (16 + Math.cos(angle) * 14).round, (48 + Math.sin(angle) * 14).round, Color.white)
      end
      [5, 10, 14].each do |r|
        8.times do |i|
          t, u = i * Math::PI / 4, (i + 1) * Math::PI / 4
          line(threads, (16 + Math.cos(t) * r).round, (48 + Math.sin(t) * r).round,
            (16 + Math.cos(u) * r).round, (48 + Math.sin(u) * r).round, Color.white)
        end
      end
      32.times do |x|
        (32...64).each do |y|
          next if threads.get_pixel(x,y).alpha == 0
          (-1..1).each { |dx| (-1..1).each { |dy| image.set_pixel(x+dx,y+dy,Color.black) if (x+dx).between?(0,31) && (y+dy).between?(0,63) } }
        end
      end
      image.blt(0,0,threads,threads.rect)
      threads.dispose
    elsif item == ArenaDevices::TELEPORT
      source = Bitmap.new(root + 'hgss-map.jpg')
      image.stretch_blt(Rect.new(2,34,28,28), source, Rect.new(36,60,23,23))
      source.dispose
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
    image.stretch_blt(Rect.new(16, 0, 64, 96), source, Rect.new(0, 16, 32, 48))
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
    phase = (System.uptime * 8).floor % 4
    key = [item, disabled, phase]
    return if @arena_device_graphic == key && @charbitmap && !@charbitmap.disposed?
    @charbitmap&.dispose
    @bushbitmap&.dispose
    @bushbitmap = nil
    @charbitmap = ArenaDemo::DeviceArt.bitmap(item, disabled, phase).clone
    @charbitmapAnimated = false
    @arena_device_graphic = key
    @tile_id, @cw, @ch = 384, 32, 64
    self.src_rect.set(0, 0, 32, 64)
    self.ox, self.oy = 16, 64
    @character.sprite_size = [32, 64]
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
