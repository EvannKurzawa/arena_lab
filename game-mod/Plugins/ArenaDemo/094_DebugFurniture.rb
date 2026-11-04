# Editable showroom in the new quadrant. Existing layouts keep their coordinates.
module ArenaDemo
  module DebugFurniture
    # Shelf packing uses the visible height as well as the collision footprint.
    # One empty tile separates neighbours and rows; Tesla sparks have their own
    # reserved cell within a three-wide display.
    def debug_furniture_layout
      items = FURNITURE_STOCK.keys.reject { |item| [ArenaDevices::TELEPORT,ArenaDevices::BUTTON].include?(item.to_s) }
      items += [ArenaDevices::BUTTON.to_sym] * items.count { |item| ArenaDevices.coil?(item) }
      x,top,row_height = 124,128,0
      items.map do |item|
        width = ArenaFurnitureRules.width(item)
        height = item.to_s == ArenaFurnitureRules::STAND ? 3 : 2
        if EXTRA_FURNITURE.key?(item)
          image = furniture_bitmap(item)
          width = [width,(image.width/32.0).ceil].max
          height = [height,(image.height/32.0).ceil].max
        end
        coil = ArenaDevices.coil?(item)
        width,height = 3,3 if coil
        if x+width > 150
          x,top,row_height = 124,top+row_height+1,0
        end
        anchor = [x+(coil ? 1 : 0),top+height-1-(coil ? 1 : 0)]
        x += width+1
        row_height = [row_height,height].max
        [item,*anchor]
      end
    end

    def debug_raise_furniture(placed,records)
      item,x,y = placed.values_at('item','x','y')
      return unless ArenaFurnitureRules.raised?(item)
      cells = ArenaFurnitureRules.relief_cells(item,x,y)
      placed['arena_under_surfaces'] = cells.map { |px,py| { 'x'=>px,'y'=>py,'surface'=>records[tile_edit_key(px,py)]&.dup } }
      cells.each do |px,py|
        stair = item.to_s == ArenaFurnitureRules::STAND && py == y-1 && [x,x+3].include?(px) ? 8 : nil
        height = item.to_s == ArenaFurnitureRules::STAND && py == y-1 && !stair ? 0 : 1
        records[tile_edit_key(px,py)] = { 'floor'=>'field','ground'=>'wood','height'=>height,'stair'=>stair,'platform_style'=>'wood' }
      end
    end

    def compact_debug_furniture(placements,records)
      layout = debug_furniture_layout
      buttons = 0
      moving = layout.each_with_index.filter_map do |(item,x,y),i|
        old = if item.to_s == ArenaDevices::BUTTON
                point = [132+buttons*8,124]
                buttons += 1
                point
              else
                [124+(i%8)*8,132+(i/8)*6]
              end
        placed = placements.find { |p| p['kind']=='furniture' && p['item'].to_s==item.to_s && p.values_at('x','y')==old }
        [placed,x,y] if placed
      end
      # A user-edited display is left as it is. Migrate only an intact v1 set,
      # and never overwrite furniture or terrain added to the compact area.
      return unless moving.length == layout.length
      others = placements - moving.map(&:first)
      candidate = records.transform_values(&:dup)
      moving.each do |placed,_,_|
        (placed['arena_under_surfaces'] || []).each do |entry|
          key = tile_edit_key(entry['x'],entry['y'])
          entry['surface'] ? candidate[key]=entry['surface'].dup : candidate.delete(key)
        end
      end
      proposed = moving.map { |placed,x,y| placed.merge('x'=>x,'y'=>y) }
      occupied = others.flat_map { |p| ArenaFurnitureRules.cells(p['item'],p['x'],p['y']) }
      return unless proposed.all? do |placed|
        ArenaFurnitureRules.cells(placed['item'],placed['x'],placed['y']).all? do |x,y|
          state = tile_surface_state(candidate,x,y)
          !occupied.include?([x,y]) && state['floor']=='field' && state['ground']=='plain' && state['height'].to_i==0 && !state['stair']
        end
      end
      proposed.each { |placed| debug_raise_furniture(placed,candidate) }
      records.replace(candidate)
      moving.zip(proposed).each { |(placed,_,_),replacement| placed.replace(replacement) }
    end

    def ensure_debug_furniture
      return unless $PokemonGlobal && defined?(ArenaDevices)
      return if @seeding_debug_furniture || (defined?(Visits) && Visits.snapshot)
      version = $PokemonGlobal.instance_variable_get(:@arena_debug_furniture_version).to_i
      return if version >= 2
      @seeding_debug_furniture = true
      begin
        placements = custom_placements
        records = tile_edit_records
        if version == 1
          compact_debug_furniture(placements,records)
          $PokemonGlobal.instance_variable_set(:@arena_debug_furniture_version,2)
          return
        end
        occupied = placements.flat_map { |p| ArenaFurnitureRules.cells(p['item'],p['x'],p['y']) }
        centre = (37..61).flat_map { |y| (37..61).map { |x| [x,y] } }.sort_by { |x,y| [(x-49).abs+(y-49).abs,y,x] }.find do |x,y|
          !occupied.include?([x,y]) && !relief_reserved.include?([x,y]) &&
            !tile_is_void?(x,y,records) && relief_code(records,x,y) == 0 && !relief_wall?(records,x,y) &&
            !ArenaMaterials::UNSAFE_GROUNDS.include?(tile_surface_state(records,x,y)['ground'])
        end
        return unless centre
        # Keep the large empty field available around the compact display.
        (120..190).each do |y|
          (120..190).each do |x|
            records[tile_edit_key(x,y)] ||= { 'floor'=>'field', 'ground'=>'plain' }
          end
        end
        add = proc { |item,x,y| placements << { 'kind'=>'furniture', 'item'=>item.to_s, 'x'=>x, 'y'=>y } }
        # Both endpoints append together to preserve existing portal pairs.
        add.call(ArenaDevices::TELEPORT,*centre)
        add.call(ArenaDevices::TELEPORT,124,124)
        debug_furniture_layout.each do |item,x,y|
          add.call(item,x,y)
          debug_raise_furniture(placements.last,records)
        end
        $PokemonGlobal.instance_variable_set(:@arena_debug_furniture_version,2)
      ensure
        @seeding_debug_furniture = false
      end
    end

    def custom_placements
      values = super
      ensure_debug_furniture
      values
    end

    def tile_edit_records
      values = super
      ensure_debug_furniture
      values
    end
  end
  singleton_class.prepend(DebugFurniture)
end
