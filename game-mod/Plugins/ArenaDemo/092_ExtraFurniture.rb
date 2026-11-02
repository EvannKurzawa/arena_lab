# Original game decorations, delivered through SharedAssets by Arena Update.
module ArenaDemo
  EXTRA_FURNITURE_ART = {
    'rse-mud-ball' => 'Boule de Boue',
    'rse-breakable-door' => 'Porte Cassable',
    'rse-sand-ornament' => 'Déco de Sable',
    'rse-solid-board' => 'Planche solide',
    'rse-stand' => 'Estrade',
    'rse-tire' => 'Pneu',
    'rse-fence-length' => 'Barrière verticale',
    'rse-fence-width' => 'Barrière horizontale',
    'rse-red-flower' => 'Fleurs rouges',
    'rse-tropical-plant' => 'Plante tropicale',
    'rse-big-plant' => 'Grande plante',
    'rse-colorful-plant' => 'Plante multicolore',
    'rse-gorgeous-plant' => 'Plante somptueuse',
    'rse-pretty-flowers' => 'Jolies fleurs',
    'dppt-container' => 'Conteneur',
    'dppt-crate' => 'Caisse en bois',
    'dppt-healingmachine' => 'Machine de soin',
    'dppt-labmachine' => 'Machine de laboratoire',
    'dppt-bigoildrum' => 'Set de barils',
    'dppt-oildrum' => 'Baril',
    'dppt-ironbeam' => 'Poutres métalliques',
    'dppt-gymstatue' => "Statue d'arène",
    'dppt-cardboardbox' => 'Carton',
    'dppt-trashcan' => 'Poubelle',
    'dppt-pottedplant' => 'Plante en pot',
    'dppt-pokeflower' => 'Fleur Pokémon',
    'dppt-prettyflowers' => 'Bouquet de fleurs',
    'dppt-daintyflowers' => 'Fleurs délicates',
    'cogne-cogne' => 'Cogne-Cogne',
    'chandelier' => 'Chandelier',
    'lampe' => 'Lampe',
    'tree-leafy' => 'Arbre feuillu',
    'tree-pine' => 'Sapin',
    'hgss-red-carpet' => 'Tapis rouge',
    'hgss-spikes' => 'Pics',
    'snowball' => 'Boule de neige'
  }.freeze
  EXTRA_FURNITURE = EXTRA_FURNITURE_ART.to_h { |stem, name|
    [("ARENA_FURNITURE_" + stem.upcase.tr('-', '_')).to_sym, [name, stem].freeze]
  }.freeze
  previous_stock = FURNITURE_STOCK
  remove_const(:FURNITURE_STOCK)
  const_set(:FURNITURE_STOCK, previous_stock.merge(EXTRA_FURNITURE.transform_values { |data|
    [data[0], 'Object rock', 2].freeze
  }).freeze)

  module ExtraFurnitureIntegration
    def custom_placements
      placements = super
      return placements if !$PokemonGlobal || (defined?(Visits) && Visits.snapshot)
      return placements if $PokemonGlobal.arena_wide_furniture_layout_version.to_i >= 1
      records = tile_edit_records
      placements.dup.each do |placed|
        next unless placed['kind'] == 'furniture' && ArenaFurnitureRules.width(placed['item']) > 1
        others = placements.reject { |p| p.equal?(placed) }.flat_map do |p|
          ArenaFurnitureRules.cells(p['kind'] == 'furniture' ? p['item'] : nil,p['x'],p['y'])
        end
        level = relief_code(records,placed['x'],placed['y']).to_i
        clear = proc do |x,y|
          ArenaFurnitureRules.cells(placed['item'],x,y).all? do |px,py|
            px.between?(0,MAP_WIDTH-1) && py.between?(0,MAP_HEIGHT-1) &&
              !others.include?([px,py]) && !relief_reserved.include?([px,py]) &&
              !tile_is_void?(px,py,records) && !relief_wall?(records,px,py) &&
              relief_code(records,px,py) == level && level <= 1 &&
              !ArenaMaterials::UNSAFE_GROUNDS.include?(tile_surface_state(records,px,py)['ground'])
          end
        end
        next if clear.call(placed['x'],placed['y'])
        points = (0...MAP_HEIGHT).flat_map { |y| (0...MAP_WIDTH).map { |x| [x,y] } }
        destination = points.sort_by { |x,y| [(x-placed['x']).abs+(y-placed['y']).abs,y,x] }.find { |x,y| clear.call(x,y) }
        if destination
          placed['x'], placed['y'] = destination
        elsif $bag.add(placement_item(placed),1)
          placements.delete(placed)
        end
      end
      $PokemonGlobal.arena_wide_furniture_layout_version = 1
      placements
    end

    def register_bag_items
      super
      EXTRA_FURNITURE.each do |item, (name, _stem)|
        data = GameData::Item.try_get(item)
        next unless data
        %i[@real_name @real_name_plural @real_portion_name @real_portion_name_plural].each do |key|
          data.instance_variable_set(key,name)
        end
      end
    end

    def catalog_furniture?(item)
      EXTRA_FURNITURE.key?(item) || super
    end

    def furniture_bitmap(item)
      return super unless EXTRA_FURNITURE.key?(item)
      if ArenaFurnitureRules.raised?(item)
        @raised_furniture_previews ||= {}
        return @raised_furniture_previews[item] ||= begin
          preview = Bitmap.new(32,64)
          original = ExpeditionTerrain.source("ArenaFurniture/#{EXTRA_FURNITURE.fetch(item)[1]}")
          rect = item.to_s == 'ARENA_FURNITURE_RSE_STAND' ? Rect.new(0,32,64,32) : Rect.new(8,32,16,32)
          preview.stretch_blt(Rect.new(0,32,32,32),original,rect)
          preview
        end
      end
      image = ExpeditionTerrain.source("ArenaFurniture/#{EXTRA_FURNITURE.fetch(item)[1]}")
      raise "Missing shared furniture graphic: #{item}" unless image
      image
    end

    def ensure_custom_inventory
      super
      return unless $PokemonGlobal && $bag
      return if $PokemonGlobal.arena_extra_furniture_stock_added
      placed = $PokemonGlobal.arena_demo_placements || []
      complete = EXTRA_FURNITURE.keys.all? do |item|
        used = placed.count { |p| p['kind'] == 'furniture' && p['item'].to_s == item.to_s }
        missing = [2 - $bag.quantity(item) - used, 0].max
        missing == 0 || $bag.add(item, missing)
      end
      $PokemonGlobal.arena_extra_furniture_stock_added = true if complete
    end

    def refresh_custom_placements(placements = custom_placements)
      super
      return unless $game_map && $game_map.map_id == MAP_ID
      MAX_ARENA_FURNITURE.times do |slot|
        event = $game_map.events[FURNITURE_SLOT_BASE + slot]
        event.width, event.height = 1,1 if event
      end
      furniture_placements(placements).each_with_index do |placed, slot|
        item = placement_item(placed)
        next unless EXTRA_FURNITURE.key?(item)
        event = $game_map.events[FURNITURE_SLOT_BASE + slot]
        if event
          event.through = ArenaFurnitureRules.walkable?(item)
          event.width = ArenaFurnitureRules.width(item)
        end
      end
    end

    def editor_occupied(placements, x, y)
      placements.find do |placed|
        item = placed['kind'] == 'furniture' ? placed['item'] : nil
        ArenaFurnitureRules.cells(item,placed['x'],placed['y']).include?([x,y])
      end
    end

    def material_catalog_description(entry)
      return super unless entry[:furniture_catalog] && EXTRA_FURNITURE.key?(entry[:item])
      width = ArenaFurnitureRules.width(entry[:item])
      "En réserve : #{entry[:qty]}\nOccupe #{width} #{width == 1 ? 'case' : 'cases'}"
    end

    def valid_relief_records?(records, placements)
      return false unless super
      grid = relief_grid(records)
      positions = placements.flat_map { |p| ArenaFurnitureRules.cells(p['kind'] == 'furniture' ? p['item'] : nil,p['x'],p['y']) }
      positions.all? { |x,y| !ArenaRelief.wall?(grid,x,y) && ArenaRelief.at(grid,x,y).to_i <= 1 } &&
        positions.length == positions.uniq.length && placements.all? do |p|
          ArenaFurnitureRules.cells(p['kind'] == 'furniture' ? p['item'] : nil,p['x'],p['y']).map { |x,y| ArenaRelief.at(grid,x,y) }.uniq.length == 1
        end
    end

    def decode_visit_snapshot(surface, placements, relief = '0' * (MAP_WIDTH * MAP_HEIGHT), styles = '0' * (MAP_WIDTH * MAP_HEIGHT))
      decoded = super
      return nil unless decoded && ArenaFurnitureRules.valid_footprints?(placements,surface,relief,relief_reserved)
      decoded
    end

    def editor_apply_placement(placements, records, kind, selected, x, y)
      current = editor_occupied(placements, x, y)
      removing = selected[:action] == :remove
      if !removing && kind == 'furniture' && ArenaFurnitureRules.width(selected[:item]) > 1
        cells = ArenaFurnitureRules.cells(selected[:item],x,y)
        level = relief_code(records,x,y)
        valid = cells.all? do |px,py|
          valid_editor_tile?(px,py) && !editor_occupied(placements,px,py) &&
            !relief_reserved.include?([px,py]) && !relief_wall?(records,px,py) &&
            relief_code(records,px,py) == level && level && level <= 1 &&
            !tile_is_void?(px,py,records) && !%w[quicksand water deep_water lava].include?(tile_surface_state(records,px,py)['ground'])
        end
        unless valid
          pbMessage('Ce meuble nécessite deux cases libres côte à côte, au même niveau.')
          return false
        end
      end
      current_raised = current && ArenaFurnitureRules.raised?(placement_item(current))
      adding_raised = !removing && ArenaFurnitureRules.raised?(selected[:item])
      return super unless current_raised || adding_raised
      return false unless valid_editor_tile?(x, y)
      unless kind == 'furniture' && (removing ? current_raised : !current)
        pbMessage("Retirez d'abord le meuble avant de le remplacer.")
        return false
      end
      key = tile_edit_key(x, y)
      candidate = records.dup
      if removing
        before = current['arena_under_surface']
        before ? candidate[key] = before.dup : candidate.delete(key)
        proposed = placements - [current]
      else
        state = tile_surface_state(records, x, y)
        unless state['height'].to_i == 0 && !state['stair'] && !relief_wall?(records, x, y) &&
               !tile_is_void?(x, y, records) && !%w[quicksand water deep_water lava].include?(state['ground']) &&
               !relief_reserved.include?([x, y]) && furniture_placements(placements).length < MAX_ARENA_FURNITURE
          pbMessage("Choisissez un sol bas libre et sec pour ce meuble surélevé.")
          return false
        end
        candidate[key] = state.merge('height' => 1, 'stair' => nil, 'platform_style' => 'wood', 'ground' => 'wood')
        placed = { 'kind' => kind, 'item' => selected[:item].to_s, 'x' => x, 'y' => y,
                   'arena_under_surface' => records[key]&.dup }
        proposed = placements + [placed]
      end
      if ($game_player && relief_wall?(candidate, $game_player.x, $game_player.y)) || !valid_relief_records?(candidate, proposed)
        pbMessage("Laissez la paroi libre et retirez les escaliers avant leur appui.")
        return false
      end
      if removing
        return false unless $bag.add(placement_item(current), 1)
        placements.delete(current)
      else
        return false unless $bag.remove(selected[:item], 1)
        placements << placed
      end
      records.replace(candidate)
      apply_tile_surface($game_map, x, y, tile_surface_state(records, x, y))
      refresh_custom_placements(placements)
      true
    end

    def edit_tile(placements, records, x, y)
      current = editor_occupied(placements, x, y)
      return super unless current && ArenaFurnitureRules.raised?(placement_item(current))
      choice = pbMessage("Meuble surélevé : retirez les escaliers d'accès avant son retrait.", ['Retirer', 'Retour'], -1)
      editor_apply_placement(placements, records, 'furniture', { action: :remove }, x, y) if choice == 0
      :continue
    end

    def choose_catalog(entries, title)
      chosen = super
      if @device_legacy_replace && chosen && (ArenaFurnitureRules.raised?(chosen[:item]) || ArenaFurnitureRules.width(chosen[:item]) > 1)
        pbMessage("Retirez d'abord le meuble, puis posez le meuble surélevé sur une case libre.")
        return nil
      end
      chosen
    end

    def replace_placement(placements, current)
      if ArenaFurnitureRules.raised?(placement_item(current))
        return pbMessage("Retirez d'abord le meuble surélevé et ses escaliers d'accès.")
      end
      super
    end
  end

  module ExtraFurnitureFloorGraphic
    def update
      super
      item = @character.instance_variable_get(:@arena_furniture_item)
      # Raised furniture paints the summit; the native relief supplies its front.
      self.y += 6 * self.zoom_y if item.to_s == 'ARENA_FURNITURE_HGSS_RED_CARPET'
      self.z -= 32 if ArenaFurnitureRules.walkable?(item)
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_extra_furniture_stock_added
  attr_accessor :arena_wide_furniture_layout_version
end
ArenaDemo.singleton_class.prepend(ArenaDemo::ExtraFurnitureIntegration)
Sprite_Character.prepend(ArenaDemo::ExtraFurnitureFloorGraphic) if defined?(Sprite_Character)
ArenaDemo.register_bag_items if defined?(GameData::Item)
