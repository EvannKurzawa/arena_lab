# Original game decorations, delivered through SharedAssets by Arena Update.
module ArenaDemo
  RETIRED_FURNITURE = %w[ARENA_FURNITURE_HGSS_SPIKES ARENA_FURNITURE_RSE_BREAKABLE_DOOR].freeze
  EXTRA_FURNITURE_ART = {
    'rse-mud-ball' => 'Boule de Boue',
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
    # Floor tiles sort below players; a tall event sorts at its low anchor.
    def relief_bitmap(records, x, y)
      placements = records.equal?(@editor_surface_edits) && @editor_placements ? @editor_placements : custom_placements
      placed = placements.find do |p|
        p['kind'] == 'furniture' && p['item'].to_s == ArenaFurnitureRules::STAND &&
          ArenaFurnitureRules.relief_cells(p['item'],p['x'],p['y']).include?([x,y])
      end
      return super unless placed
      @stand_floor_tiles ||= {}
      dx,dy = x-placed['x'], y-placed['y']+2
      @stand_floor_tiles[[dx,dy]] ||= begin
        tile = Bitmap.new(32,32)
        tile.blt(0,0,furniture_bitmap(ArenaFurnitureRules::STAND.to_sym),Rect.new(dx*32,dy*32,32,32))
        tile
      end
    end

    def purge_retired_furniture!(placements = nil)
      return unless $PokemonGlobal
      unless $PokemonGlobal.arena_retired_furniture_removed
        if $bag && $bag.respond_to?(:pockets)
          retired = RETIRED_FURNITURE
          $bag.pockets.each do |pocket|
            pocket.delete_if { |entry| entry.is_a?(Array) && retired.include?(entry[0].to_s) }
          end
        end
        $PokemonGlobal.arena_retired_furniture_removed = true
      end
      placements.delete_if do |entry|
        entry.is_a?(Hash) && entry['kind'] == 'furniture' && RETIRED_FURNITURE.include?(entry['item'].to_s)
      end if placements
    end

    def remove_legacy_stands!(placements,records)
      changed = []
      placements.dup.each do |p|
        next unless p['kind'] == 'furniture' && p['item'].to_s == ArenaFurnitureRules::STAND
        saved = p['arena_under_surfaces']
        next if saved && saved.length >= 8
        next unless $bag.add(placement_item(p),1)
        (saved || [{'x'=>p['x'],'y'=>p['y'],'surface'=>p['arena_under_surface']}]).each do |entry|
          key = tile_edit_key(entry['x'],entry['y'])
          entry['surface'] ? records[key] = entry['surface'].dup : records.delete(key)
          changed << [entry['x'],entry['y']]
        end
        placements.delete(p)
      end
      # A retired stand could leave its exact two-wide wood/stair footprint
      # after its event was lost. Remove only isolated, unoccupied remnants.
      records.keys.each do |key|
        x,y = key.split(',').map(&:to_i)
        next unless x && y
        cells = [[x,y],[x+1,y],[x,y+1],[x+1,y+1]]
        next unless cells.all? do |px,py|
          r=records[tile_edit_key(px,py)]
          r && r['height']==1 && r['ground']=='wood' && r['platform_style']=='wood' &&
            (py==y ? !r['stair'] : r['stair']==8) && !editor_occupied(placements,px,py)
        end
        next if [[x-1,y],[x+2,y],[x,y-1],[x+1,y-1],[x-1,y+1],[x+2,y+1]].any? { |px,py| relief_code(records,px,py).to_i > 0 }
        cells.each do |px,py|
          base = tile_surface_state(records,px,y+2)
          records[tile_edit_key(px,py)] = base.merge('height'=>0,'stair'=>nil)
          changed << [px,py]
        end
      end
      changed.uniq.each { |px,py| apply_tile_surface($game_map,px,py,tile_surface_state(records,px,py)) if $game_map }
    end

    def migrate_raised_furniture!(placements, records)
      placements.dup.each do |placed|
        next unless placed['kind'] == 'furniture' && ArenaFurnitureRules.raised?(placed['item'])
        item = placed['item'].to_s
        saved = placed['arena_under_surfaces']
        next if item == ArenaFurnitureRules::STAND && saved && saved.length >= 8
        next if item != ArenaFurnitureRules::STAND && saved && saved.length >= 2
        x, y = placed.values_at('x','y')
        original = saved || [{ 'x'=>x,'y'=>y,'surface'=>placed['arena_under_surface'] }]
        original.each do |entry|
          key = tile_edit_key(entry['x'],entry['y'])
          entry['surface'] ? records[key] = entry['surface'].dup : records.delete(key)
        end
        occupied = placements.reject { |other| other.equal?(placed) }.flat_map do |other|
          ArenaFurnitureRules.cells(other['kind'] == 'furniture' ? other['item'] : nil,other['x'],other['y'])
        end
        preferred = item == ArenaFurnitureRules::STAND ? [x,y+2] : [x,y]
        anchors = [preferred] + (0...MAP_HEIGHT).flat_map { |py| (0...MAP_WIDTH).map { |px| [px,py] } }
          .sort_by { |px,py| [(px-preferred[0]).abs+(py-preferred[1]).abs,py,px] }
        destination = anchors.uniq.find do |px,py|
          cells = ArenaFurnitureRules.relief_cells(item,px,py)
          floor = item == ArenaFurnitureRules::STAND ? ArenaFurnitureRules.stand_row(px,py) : cells
          all = (cells+floor).uniq
          all.all? do |tx,ty|
            next false unless tx.between?(0,MAP_WIDTH-1) && ty.between?(0,MAP_HEIGHT-1)
            state = tile_surface_state(records,tx,ty)
            !occupied.include?([tx,ty]) && !relief_reserved.include?([tx,ty]) &&
              !tile_is_void?(tx,ty,records) && !relief_wall?(records,tx,ty) &&
              relief_code(records,tx,ty).to_i == 0 && !state['stair'] &&
              !%w[quicksand water deep_water lava].include?(state['ground'])
          end
        end
        if destination
          px,py = destination
          cells = ArenaFurnitureRules.relief_cells(item,px,py)
          high = item == ArenaFurnitureRules::STAND ? ArenaFurnitureRules.stand_row(px,py-2) : cells
          stairs = item == ArenaFurnitureRules::STAND ? ArenaFurnitureRules.stand_row(px,py-1) : []
          under = cells.map do |tx,ty|
            key = tile_edit_key(tx,ty)
            original_surface = records[key]&.dup
            state = tile_surface_state(records,tx,ty)
            code = stairs.include?([tx,ty]) ? 8 : 1
            records[key] = state.merge('height'=>1,'stair'=>code == 1 ? nil : code,
              'platform_style'=>'wood','ground'=>'wood')
            { 'x'=>tx,'y'=>ty,'surface'=>original_surface }
          end
          placed['x'],placed['y'] = px,py
          placed['arena_under_surfaces'] = under
          placed.delete('arena_under_surface')
          cells.each { |tx,ty| apply_tile_surface($game_map,tx,ty,tile_surface_state(records,tx,ty)) if $game_map }
        elsif $bag.add(placement_item(placed),1)
          placements.delete(placed)
        else
          original.each do |entry|
            key = tile_edit_key(entry['x'],entry['y'])
            entry['surface'] ? records[key] = entry['surface'].dup : records.delete(key)
          end
        end
      end
    end

    def custom_placements
      placements = super
      purge_retired_furniture!(placements) unless defined?(Visits) && Visits.snapshot
      return placements if !$PokemonGlobal || (defined?(Visits) && Visits.snapshot)
      return placements if $PokemonGlobal.arena_wide_furniture_layout_version.to_i >= 5
      records = tile_edit_records
      remove_legacy_stands!(placements,records)
      migrate_raised_furniture!(placements,records)
      placements.dup.each do |placed|
        next unless placed['kind'] == 'furniture' && ArenaFurnitureRules.width(placed['item']) > 1
        next if placed['item'].to_s == ArenaFurnitureRules::STAND
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
      placements.each do |p|
        next unless p['kind'] == 'furniture' && p['item'].to_s == ArenaFurnitureRules::STAND
        [1,2].each do |dx|
          px,py = p['x']+dx,p['y']-1
          key = tile_edit_key(px,py)
          next unless records[key] && records[key]['height'].to_i == 0
          saved = (p['arena_under_surfaces'] || []).find { |e| e['x']==px && e['y']==py }
          ground = saved && saved['surface'] && saved['surface']['ground']
          ground ||= tile_surface_state(records,px,p['y'])['ground']
          next if records[key]['ground'] == ground
          records[key] = records[key].merge('ground'=>ground)
          apply_tile_surface($game_map,px,py,records[key]) if $game_map
        end
      end
      $PokemonGlobal.arena_wide_furniture_layout_version = 5
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
      image = ExpeditionTerrain.source("ArenaFurniture/#{EXTRA_FURNITURE.fetch(item)[1]}")
      raise "Missing shared furniture graphic: #{item}" unless image
      image
    end

    def ensure_custom_inventory
      super
      purge_retired_furniture!($PokemonGlobal&.arena_demo_placements)
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
      placements = @editor_placements if @editor_surface_edits && @editor_placements
      super(placements)
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
      refresh_map_renderer if @editor_surface_edits
    end

    def editor_occupied(placements, x, y)
      placements.find do |placed|
        item = placed['kind'] == 'furniture' ? placed['item'] : nil
        ArenaFurnitureRules.cells(item,placed['x'],placed['y']).include?([x,y])
      end
    end

    def material_catalog_description(entry)
      return super unless entry[:furniture_catalog] && EXTRA_FURNITURE.key?(entry[:item])
      return "4 cases de large, 3 vers le haut.\nCase choisie : sol bas, a gauche." if entry[:item].to_s == ArenaFurnitureRules::STAND
      width = ArenaFurnitureRules.width(entry[:item])
      "En réserve : #{entry[:qty]}\nOccupe #{width} #{width == 1 ? 'case' : 'cases'}"
    end

    def valid_relief_records?(records, placements)
      return false unless super
      grid = relief_grid(records)
      cells = placements.flat_map { |p| ArenaFurnitureRules.cells(p['kind'] == 'furniture' ? p['item'] : nil,p['x'],p['y']) }
      surfaces = placements.flat_map do |p|
        if p['kind'] == 'furniture' && p['item'].to_s == ArenaFurnitureRules::STAND
          ArenaFurnitureRules.stand_row(p['x'],p['y']-2) + ArenaFurnitureRules.stand_row(p['x'],p['y'])
        else
          ArenaFurnitureRules.cells(p['kind'] == 'furniture' ? p['item'] : nil,p['x'],p['y'])
        end
      end
      surfaces.all? { |x,y| !ArenaRelief.wall?(grid,x,y) && ArenaRelief.at(grid,x,y).to_i <= 1 } &&
        cells.length == cells.uniq.length && placements.all? do |p|
          x,y = p.values_at('x','y')
          if p['kind'] == 'furniture' && p['item'].to_s == ArenaFurnitureRules::STAND
            ArenaFurnitureRules.stand_row(x,y-2).all? { |px,py| ArenaRelief.at(grid,px,py) == 1 } &&
              ArenaFurnitureRules.stand_stairs(x,y-1).all? { |px,py| ArenaRelief.at(grid,px,py) == 8 } &&
              [[x+1,y-1],[x+2,y-1]].all? { |px,py| ArenaRelief.at(grid,px,py) == 0 } &&
              ArenaFurnitureRules.stand_row(x,y).all? { |px,py| ArenaRelief.at(grid,px,py) == 0 }
          else
            ArenaFurnitureRules.cells(p['kind'] == 'furniture' ? p['item'] : nil,x,y).map { |px,py| ArenaRelief.at(grid,px,py) }.uniq.length == 1
          end
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
      if !removing && kind == 'furniture' && ArenaFurnitureRules.width(selected[:item]) > 1 &&
         selected[:item].to_s != ArenaFurnitureRules::STAND
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
      anchor_x, anchor_y = removing ? current.values_at('x','y') : [x,y]
      item = removing ? placement_item(current) : selected[:item]
      footprint = ArenaFurnitureRules.relief_cells(item,anchor_x,anchor_y)
      candidate = records.dup
      if removing
        saved = current['arena_under_surfaces'] || [{ 'x'=>anchor_x, 'y'=>anchor_y,
          'surface'=>current['arena_under_surface'] }]
        saved.each do |entry|
          key = tile_edit_key(entry['x'],entry['y'])
          entry['surface'] ? candidate[key] = entry['surface'].dup : candidate.delete(key)
        end
        proposed = placements - [current]
      else
        is_stand = item.to_s == ArenaFurnitureRules::STAND
        top = is_stand ? ArenaFurnitureRules.stand_row(anchor_x,anchor_y-2) : footprint
        stairs = is_stand ? ArenaFurnitureRules.stand_stairs(anchor_x,anchor_y-1) : []
        low = is_stand ? ArenaFurnitureRules.stand_row(anchor_x,anchor_y) : []
        all = (footprint+low).uniq
        unless all.all? { |px,py| valid_editor_tile?(px,py) }
          pbMessage('Estrade : liberez un rectangle de 4 cases de large sur 3 vers le haut depuis la case choisie.')
          return false
        end
        states = all.map { |px,py| [px,py,tile_surface_state(records,px,py)] }
        valid = states.all? do |px,py,state|
          state['height'].to_i == 0 && !state['stair'] && !relief_wall?(records,px,py) &&
            !tile_is_void?(px,py,records) && !%w[quicksand water deep_water lava].include?(state['ground']) &&
            !relief_reserved.include?([px,py]) && !editor_occupied(placements,px,py)
        end
        unless valid && furniture_placements(placements).length < MAX_ARENA_FURNITURE
          pbMessage(is_stand ? 'Estrade : 4 cases de large sur 3 vers le haut, libres, seches et au niveau du sol.' : 'Choisissez deux cases libres et seches au niveau du sol.')
          return false
        end
        under_surfaces = footprint.map do |px,py|
          state = tile_surface_state(records,px,py)
          stair = stairs.include?([px,py])
          height = is_stand && py == anchor_y-1 && !stair ? 0 : 1
          candidate[tile_edit_key(px,py)] = state.merge('height' => height, 'stair' => stair ? 8 : nil,
            'platform_style' => 'wood', 'ground' => height == 0 ? state['ground'] : 'wood')
          { 'x'=>px, 'y'=>py, 'surface'=>records[tile_edit_key(px,py)]&.dup }
        end
        placed = { 'kind' => kind, 'item' => selected[:item].to_s, 'x' => x, 'y' => y,
                   'arena_under_surfaces' => under_surfaces }
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
      footprint.each { |px,py| apply_tile_surface($game_map,px,py,tile_surface_state(records,px,py)) }
      refresh_custom_placements(placements)
      true
    end

    def edit_tile(placements, records, x, y)
      current = editor_occupied(placements, x, y)
      return super unless current && ArenaFurnitureRules.raised?(placement_item(current))
      message = placement_item(current).to_s == ArenaFurnitureRules::STAND ? 'Retirer toute cette estrade et ses marches ?' : "Meuble surélevé : retirez les escaliers d'accès avant son retrait."
      choice = pbMessage(message, ['Retirer', 'Retour'], -1)
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
      self.visible = false if item.to_s == ArenaFurnitureRules::STAND
      # Raised furniture paints the summit; the native relief supplies its front.
      self.y += 6 * self.zoom_y if item.to_s == 'ARENA_FURNITURE_HGSS_RED_CARPET'
      self.z -= 32 if ArenaFurnitureRules.walkable?(item)
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_extra_furniture_stock_added
  attr_accessor :arena_wide_furniture_layout_version
  attr_accessor :arena_retired_furniture_removed
end
ArenaDemo.singleton_class.prepend(ArenaDemo::ExtraFurnitureIntegration)
Sprite_Character.prepend(ArenaDemo::ExtraFurnitureFloorGraphic) if defined?(Sprite_Character)
ArenaDemo.register_bag_items if defined?(GameData::Item)
