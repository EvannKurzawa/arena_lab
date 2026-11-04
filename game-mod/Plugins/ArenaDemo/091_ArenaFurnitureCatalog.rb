# Secret Base-inspired furniture. Native artwork stays local.
module ArenaDemo
  BASIC_FURNITURE = {
    :ARENA_FURNITURE_CHAIR_BLUE => ['Chaise bleue', [64, 5152, 32, 32]],
    :ARENA_FURNITURE_CHAIR_RED => ['Chaise rouge', [64, 5184, 32, 32]],
    :ARENA_FURNITURE_STOOL => ['Tabouret vert', [192, 5120, 32, 32]],
    :ARENA_FURNITURE_ARMCHAIR => ['Fauteuil confortable', [128, 5088, 64, 64]],
    :ARENA_FURNITURE_SOFA => ['Canapé bleu', [64, 5024, 96, 64]],
    :ARENA_FURNITURE_DESK => ['Petit bureau bleu', [0, 6784, 96, 64]],
    :ARENA_FURNITURE_ROUND_TABLE => ['Petite table ronde', [192, 6784, 64, 64]],
    :ARENA_FURNITURE_BOOKCASE => ['Petite bibliothèque', [64, 5472, 64, 64]],
    :ARENA_FURNITURE_LEAF_PLANT => ['Plante feuillue', [64, 5536, 32, 64]],
    :ARENA_FURNITURE_FERN => ['Fougère en pot', [96, 5536, 32, 64]],
    :ARENA_FURNITURE_PALM => ['Palmier en pot', [160, 5520, 32, 64]],
    :ARENA_FURNITURE_TOPIARY => ['Arbuste taillé', [128, 5536, 32, 64]],
    :ARENA_FURNITURE_BIN => ['Corbeille', [64, 5344, 32, 64]],
    :ARENA_FURNITURE_CONSOLE => ['Console de jeu', [128, 5376, 32, 32]],
    :ARENA_FURNITURE_STONE_STATUE => ['Statue de pierre', [64, 5248, 32, 64]],
    :ARENA_FURNITURE_JADE_STATUE => ['Statue de jade', [96, 5248, 32, 64]],
    :ARENA_FURNITURE_PIKACHU_DOLL => ['Poupée Pikachu', :PIKACHU],
    :ARENA_FURNITURE_BULBASAUR_DOLL => ['Poupée Bulbizarre', :BULBASAUR],
    :ARENA_FURNITURE_CHARMANDER_DOLL => ['Poupée Salamèche', :CHARMANDER],
    :ARENA_FURNITURE_SQUIRTLE_DOLL => ['Poupée Carapuce', :SQUIRTLE]
  }.transform_values(&:freeze).freeze
  old_stock = FURNITURE_STOCK
  remove_const(:FURNITURE_STOCK)
  const_set(:FURNITURE_STOCK, old_stock.merge(BASIC_FURNITURE.transform_values { |data|
    [data[0], 'Object rock', 2].freeze
  }).freeze)

  module_function

  def catalog_furniture?(item)
    BASIC_FURNITURE.key?(item)
  end

  def furniture_bitmap(item)
    @basic_furniture_art ||= {}
    cached = @basic_furniture_art[item]
    return cached if cached && !cached.disposed?
    spec = BASIC_FURNITURE.fetch(item)[1]
    if spec.is_a?(Symbol)
      source = ExpeditionTerrain.source("Pokemon/Icons/#{spec}")
      raise "Missing local Pokemon icon for #{spec}" unless source
      rect = Rect.new(0, 0, source.height, source.height)
      points = []
      rect.height.times do |y|
        rect.width.times { |x| points << [x, y] if source.get_pixel(x, y).alpha > 0 }
      end
      unless points.empty?
        xs, ys = points.transpose
        rect = Rect.new(xs.min, ys.min, xs.max - xs.min + 1, ys.max - ys.min + 1)
      end
    else
      source = ExpeditionTerrain.source('Tilesets/Interior general')
      raise 'Missing local Essentials Interior general tileset' unless source
      rect = Rect.new(*spec)
    end
    plant = %i[ARENA_FURNITURE_LEAF_PLANT ARENA_FURNITURE_FERN ARENA_FURNITURE_PALM ARENA_FURNITURE_TOPIARY].include?(item)
    if plant
      points = []
      rect.height.times { |y| rect.width.times { |x| points << [rect.x+x,rect.y+y] if source.get_pixel(rect.x+x,rect.y+y).alpha > 0 } }
      unless points.empty?
        xs,ys = points.transpose
        rect = Rect.new(xs.min,ys.min,xs.max-xs.min+1,ys.max-ys.min+1)
      end
    end
    canvas_width = item == :ARENA_FURNITURE_SOFA ? 96 : (item == :ARENA_FURNITURE_ARMCHAIR ? 64 : 32)
    image = Bitmap.new(canvas_width, 64)
    # Preserve full seat proportions; plants share a visible 32x40 envelope.
    limit_w, limit_h = spec.is_a?(Symbol) ? [28, 28] : [canvas_width, plant ? 40 : 64]
    scale = [limit_w.to_f / rect.width, limit_h.to_f / rect.height, 1.0].min
    w, h = [(rect.width * scale).round, 1].max, [(rect.height * scale).round, 1].max
    left, top = (canvas_width - w) / 2, 64 - h - (spec.is_a?(Symbol) ? 5 : 0)
    h.times do |y|
      w.times do |x|
        image.set_pixel(left + x, top + y,
          source.get_pixel(rect.x + (x / scale).floor, rect.y + (y / scale).floor))
      end
    end
    if spec.is_a?(Symbol)
      # A small base distinguishes a decorative doll from a live follower.
      (60..63).each { |y| (4..27).each { |x| image.set_pixel(x, y, Color.new(130, 94, 57)) } }
    end
    @basic_furniture_art[item] = image
  end

  def furniture_catalog_preview(entry)
    @furniture_catalog_previews ||= {}
    item = entry[:item]
    key = item || :remove
    cached = @furniture_catalog_previews[key]
    return cached if cached && !cached.disposed?
    art = Bitmap.new(96, 96)
    if entry[:action] == :remove
      art.fill_rect(20, 44, 56, 8, Color.new(235, 105, 95))
    else
      if catalog_furniture?(item)
        source = furniture_bitmap(item)
        rect = Rect.new(0, 0, source.width, source.height)
      else
        # Existing boulder/rock/tree use their original native idle pose.
        source = ExpeditionTerrain.source("Characters/#{FURNITURE_STOCK.fetch(item)[1]}")
        rect = Rect.new(0, 0, source.width / 4, source.height / 4) if source
      end
      if source
        # Normalize visible artwork, not its transparent sprite-sheet padding.
        points = []
        rect.height.times do |y|
          rect.width.times { |x| points << [rect.x + x, rect.y + y] if source.get_pixel(rect.x + x, rect.y + y).alpha > 0 }
        end
        unless points.empty?
          xs, ys = points.transpose
          visible = Rect.new(xs.min, ys.min, xs.max - xs.min + 1, ys.max - ys.min + 1)
          scale = 72.0 / [visible.width, visible.height].max
          tw, th = (visible.width * scale).round, (visible.height * scale).round
          art.stretch_blt(Rect.new((96 - tw) / 2, (96 - th) / 2, tw, th), source, visible)
        end
      end
    end
    @furniture_catalog_previews[key] = art
  end

  module FurnitureCatalogIntegration
    def ensure_custom_inventory
      super
      return unless $PokemonGlobal && $bag
      return if $PokemonGlobal.arena_basic_furniture_stock_added
      # Count placed copies too, so a partially completed grant is retryable.
      placed = $PokemonGlobal.arena_demo_placements || []
      complete = BASIC_FURNITURE.keys.all? do |item|
        used = placed.count { |p| p['kind'] == 'furniture' && p['item'].to_s == item.to_s }
        missing = [2 - $bag.quantity(item) - used, 0].max
        missing == 0 || $bag.add(item, missing)
      end
      $PokemonGlobal.arena_basic_furniture_stock_added = true if complete
    end

    def choose_catalog(entries, title)
      furniture = entries.any? { |entry| FURNITURE_STOCK.key?(entry[:item]) }
      furniture ||= title.downcase.include?('furniture') && entries.all? { |entry| entry[:action] == :remove }
      return super unless furniture
      options = entries.map { |entry| entry.merge(:furniture_catalog => true,
        :name => entry[:action] == :remove ? 'Retirer un meuble' : entry[:name]) }
      choose_material_catalog(options, 'Choisissez un meuble de votre Sac.')
    end

    def material_catalog_preview(entry)
      return furniture_catalog_preview(entry) if entry[:furniture_catalog]
      super
    end

    def material_catalog_description(entry)
      return super unless entry[:furniture_catalog]
      return 'Choisir un meuble à retirer' if entry[:action] == :remove
      width = defined?(ArenaFurnitureRules) ? ArenaFurnitureRules.width(entry[:item]) : 1
      "En réserve : #{entry[:qty]}\nOccupe #{width} #{width == 1 ? 'case' : 'cases'}"
    end

    def refresh_custom_placements(placements = custom_placements)
      super
      return unless $game_map && $game_map.map_id == MAP_ID
      furniture = furniture_placements(placements)
      MAX_ARENA_FURNITURE.times do |slot|
        event = $game_map.events[FURNITURE_SLOT_BASE + slot]
        next unless event
        item = furniture[slot] && placement_item(furniture[slot])
        event.instance_variable_set(:@arena_furniture_item, catalog_furniture?(item) ? item : nil)
        next unless catalog_furniture?(item)
        event.walk_anime = false
        event.instance_variable_set(:@step_anime, false)
      end
    end
  end

  module FurnitureCharacterGraphic
    def refresh_graphic
      item = @character.instance_variable_get(:@arena_furniture_item)
      unless ArenaDemo.catalog_furniture?(item)
        @arena_furniture_graphic = nil
        return super
      end
      return if @arena_furniture_graphic == item && @charbitmap && !@charbitmap.disposed?
      @charbitmap&.dispose
      @bushbitmap&.dispose
      @bushbitmap = nil
      @charbitmap = ArenaDemo.furniture_bitmap(item).clone
      @charbitmapAnimated = false
      @arena_furniture_graphic = item
      @tile_id, @cw, @ch = 384, @charbitmap.width, @charbitmap.height
      self.src_rect.set(0, 0, @cw, @ch)
      self.ox, self.oy = @cw / 2, @ch
      @character.sprite_size = [@cw, @ch]
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_basic_furniture_stock_added
end
ArenaDemo.singleton_class.prepend(ArenaDemo::FurnitureCatalogIntegration)
Sprite_Character.prepend(ArenaDemo::FurnitureCharacterGraphic) if defined?(Sprite_Character)
ArenaDemo.register_bag_items if defined?(GameData::Item)
