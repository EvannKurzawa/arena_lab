# Visual material picker using native Essentials windows and rendered tile art.
module ArenaDemo
  module_function

  def material_floor_entries(family = nil)
    entries = ArenaMaterials::FLOORS.filter_map do |key, data|
      { :name => data[0], :ground => key } if ArenaMaterials::VISIBLE_FLOORS.include?(key) && (family.nil? || data[1] == family)
    end
    entries << { :name => 'Vide (infranchissable)', :ground => 'void' } if family.nil? || family == :hazard
    entries
  end

  def material_style_entries
    PLATFORM_STYLES.filter_map { |key, data| { :name => data[0], :platform_style => key } if ArenaMaterials::VISIBLE_STYLES.include?(key) }
  end

  def material_catalog_description(entry)
    return "Plateforme entière\nSol et murs assortis" if entry[:platform_style]
    ground = entry[:ground]
    detail = if ArenaMaterials::SURF_GROUNDS.include?(ground)
               "Surf requis\nBloqué à pied"
             elsif ground == 'toxic'
               "Infranchissable\nDéchets toxiques"
             elsif ground == 'quicksand'
               "Piège : aspiration\nRetour à l'entrée"
             elsif ground == 'lava' || ground == 'void'
               'Infranchissable'
             elsif ground == 'ice'
               "Praticable\nSol glissant"
             elsif ground.start_with?('type_')
               "Praticable\nSol décoratif"
             else
               'Praticable'
             end
    detail
  end

  def material_catalog_preview(entry)
    @material_catalog_previews ||= {}
    key = [entry[:ground], entry[:platform_style]]
    cached = @material_catalog_previews[key]
    return cached if cached && !cached.disposed?
    image = Bitmap.new(96, 96)
    if entry[:platform_style]
      style = entry[:platform_style]
      ground = PLATFORM_STYLES.fetch(style)[1]
      2.times do |y|
        3.times do |x|
          mask = (y > 0 ? 1 : 0) | (y < 1 ? 16 : 0) | (x > 0 ? 64 : 0) | (x < 2 ? 4 : 0)
          tile = Bitmap.new(32, 32)
          draw_relief_cliff(tile, mask, ground, style)
          image.blt(x * 32, y * 32, tile, Rect.new(0, 0, 32, 32))
          tile.dispose
        end
      end
      3.times do |x|
        tile = Bitmap.new(32, 32)
        draw_relief_wall(tile, x > 0, x < 2, style, ground)
        image.blt(x * 32, 64, tile, Rect.new(0, 0, 32, 32))
        tile.dispose
      end
    elsif entry[:ground] == 'void'
      6.times do |y|
        6.times do |x|
          image.fill_rect(x * 16, y * 16, 16, 16, (x + y).even? ? Color.new(15, 20, 30) : Color.new(28, 34, 46))
        end
      end
    else
      tile = platform_floor_bitmap(entry[:ground])
      3.times { |y| 3.times { |x| image.blt(x * 32, y * 32, tile, Rect.new(0, 0, 32, 32)) } }
    end
    @material_catalog_previews[key] = image
  end

  def choose_material_catalog(entries, title, initial_index = 0)
    return nil if entries.empty?
    viewport = backdrop = window = header = sample = details = nil
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 100_000
    backdrop = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    backdrop.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(12, 18, 28, 190))
    list_width = [Graphics.width - 216, 280].max
    window = ArenaMaterialCatalogWindow.new(entries, list_width, Graphics.height - 88)
    window.viewport = viewport
    window.x, window.y, window.z = 8, 72, 1
    window.index = [[initial_index, 0].max, entries.length - 1].min
    header = Window_UnformattedTextPokemon.newWithSize(title, 0, 0, Graphics.width, 64, viewport)
    header.z = 2
    header.contents.font.size = 24
    header.refresh
    sample = BitmapSprite.new(176, 176, viewport)
    sample.x, sample.y, sample.z = Graphics.width - 192, 80, 2
    details = Window_UnformattedTextPokemon.newWithSize('', Graphics.width - 200, 264,
      200, [Graphics.height - 272, 96].max, viewport)
    details.z = 2
    details.contents.font.size = 24
    details.refresh
    last_index = nil
    loop do
      if last_index != window.index
        last_index = window.index
        entry = entries[last_index]
        sample.bitmap.fill_rect(0, 0, 176, 176, Color.new(28, 38, 50))
        art = material_catalog_preview(entry)
        sample.bitmap.stretch_blt(Rect.new(16, 16, 144, 144), art, Rect.new(0, 0, 96, 96))
        details.text = material_catalog_description(entry)
      end
      Graphics.update
      Input.update
      window.update
      pbUpdateSceneMap
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        pbPlayCancelSE
        return nil
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        return entries[window.index]
      end
    end
  ensure
    details&.dispose
    sample&.dispose
    header&.dispose
    window&.dispose
    backdrop&.dispose
    viewport&.dispose
  end
end

class ArenaMaterialCatalogWindow < Window_CommandPokemon
  def initialize(entries, width, max_height)
    @entries = entries
    super(entries.map { |entry| entry[:name] }, width)
    self.rowHeight = 64
    resizeToFit(@commands, width)
    # Native auto sizing adds window borders to the requested content width.
    # Fix the outer width and use whole rows so nothing overlaps the preview
    # and the last visible label never gets cut in half.
    self.width = width
    rows = [[(max_height - self.borderY) / 64, 1].max, entries.length].min
    self.height = self.borderY + rows * 64
    refresh
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    entry = @entries[index]
    art = ArenaDemo.material_catalog_preview(entry)
    contents.fill_rect(rect.x + 4, rect.y + 6, 48, 48, Color.new(28, 38, 50))
    contents.stretch_blt(Rect.new(rect.x + 4, rect.y + 6, 48, 48), art, Rect.new(0, 0, 96, 96))
    pbSetSystemFont(contents)
    contents.font.size = self.width < 360 ? 20 : 24
    # Qualifiers are shown in the side panel; splitting at the dash keeps type
    # names and their motif readable within the compact native game window.
    label = entry[:name].gsub(/\s*\([^)]*\)/, '')
    lines = []
    label.split(' — ').each do |part|
      part.split.each do |word|
        if lines.empty? || (!lines.last.empty? && contents.text_size("#{lines.last} #{word}").width > rect.width - 64)
          lines << word
        else
          lines[-1] = lines.last.empty? ? word : "#{lines.last} #{word}"
        end
      end
      lines << '' if lines.length == 1 && label.include?(' — ')
    end
    lines.reject!(&:empty?)
    lines.first(2).each_with_index do |line, i|
      y = rect.y + (lines.length > 1 ? 4 + i * 26 : 17)
      pbDrawShadowText(contents, rect.x + 62, y + (contents.text_offset_y || 0),
        rect.width - 62, 28, line, baseColor, shadowColor)
    end
  end
end
