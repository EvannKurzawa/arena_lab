module ArenaDemo
  DEVICE_STOCK = {
    :ARENA_CONVEYOR_D => ['Tapis roulant', 8], :ARENA_MAGNET_D => ['Antenne magnétique', 4],
    :ARENA_WEB => ["Toile d'araignée", 8], :ARENA_TELEPORTER => ['Téléporteurs (lot de 2)', 4],
    :ARENA_TESLA => ['Bobine Tesla et bouton', 4], :ARENA_BLIND_RUNE => ['Rune cécité', 4]
  }.freeze
  device_items = ArenaDevices::ITEMS.to_h do |item|
    base = if ArenaDevices::CONVEYORS.include?(item) then :ARENA_CONVEYOR_D
           elsif ArenaDevices::MAGNETS.include?(item) then :ARENA_MAGNET_D
           elsif item == ArenaDevices::BUTTON || ArenaDevices.coil?(item) then :ARENA_TESLA
           else item.to_sym end
    [item.to_sym, [DEVICE_STOCK.fetch(base)[0], 'Object rock', 0].freeze]
  end
  previous_stock = FURNITURE_STOCK
  remove_const(:FURNITURE_STOCK)
  const_set(:FURNITURE_STOCK, previous_stock.merge(device_items).freeze)

  module DeviceEditor
    def device_stock_item(item)
      return :ARENA_CONVEYOR_D if ArenaDevices::CONVEYORS.include?(item.to_s)
      return :ARENA_MAGNET_D if ArenaDevices::MAGNETS.include?(item.to_s)
      return :ARENA_TESLA if item.to_s == ArenaDevices::BUTTON || ArenaDevices.coil?(item)
      item.to_sym
    end

    def device_inventory_counts(placements)
      counts = Hash.new(0)
      placements.each do |p|
        item = p['item'].to_s
        next unless ArenaDevices.item?(item)
        next if item == ArenaDevices::BUTTON
        counts[device_stock_item(item)] += item == ArenaDevices::TELEPORT ? 0.5 : 1
      end
      counts.transform_values(&:to_i)
    end

    def ensure_custom_inventory
      super
      return unless $PokemonGlobal && $bag
      return if $PokemonGlobal.arena_devices_stock_added
      placed = device_inventory_counts($PokemonGlobal.arena_demo_placements || [])
      complete = DEVICE_STOCK.all? do |item, (_name, quantity)|
        missing = [quantity - $bag.quantity(item) - placed[item].to_i, 0].max
        missing == 0 || $bag.add(item, missing)
      end
      $PokemonGlobal.arena_devices_stock_added = true if complete
    end

    def bag_catalog(kind)
      entries = super
      return entries unless kind == 'furniture'
      return entries.reject { |entry| ArenaDevices.item?(entry[:item]) } if @device_legacy_replace
      entries.reject { |entry| ArenaDevices.item?(entry[:item]) && !DEVICE_STOCK.key?(entry[:item]) }
    end

    def editor_choose_placement(kind, placements)
      entry = super
      return entry unless entry && ArenaDevices.item?(entry[:item])
      configure_device(entry)
    end

    def configure_device(entry)
      item = entry[:item].to_s
      return entry.dup unless ArenaDevices::CONVEYORS.include?(item) || ArenaDevices::MAGNETS.include?(item) || ArenaDevices.coil?(item)
      labels = ['Bas', 'Gauche', 'Droite', 'Haut']
      prompt = if ArenaDevices.coil?(item)
                 'De quel côté de la bobine placer la case électrifiée ?'
               elsif ArenaDevices::MAGNETS.include?(item)
                 "Attirer les joueurs situés de quel côté de l'antenne ?"
               else 'Direction du tapis roulant ?' end
      choice = pbMessage(prompt, labels + ['Annuler'], -1)
      return nil unless choice && choice.between?(0, 3)
      base = item.sub(/_[DLRU]\z/, '')
      entry.merge(:placed_item => "#{base}_#{ArenaDevices::DIRECTIONS.keys[choice]}")
    end

    def device_wire(placements)
      placements.map { |p| [p['kind'] == 'furniture' ? 0 : 1, p['item'].to_s, p['x'], p['y']] }
    end

    def device_pair_records(placements, placement)
      wire = device_wire(placements)
      furniture = furniture_placements(placements)
      slot = furniture.index(placement)
      other = ArenaDevices.partner(wire, slot)
      [placement, other && furniture[other]].compact
    end

    def remove_device(placements, placement)
      records = device_pair_records(placements, placement)
      # Return one kit for a whole pair, including when its button is selected.
      item = device_stock_item(placement['item'])
      return false unless $bag.add(item, 1)
      records.each { |record| placements.delete(record) }
      refresh_custom_placements(placements)
      true
    end

    def device_tile_valid?(placements, edits, x, y)
      valid_editor_tile?(x, y) && !editor_occupied(placements, x, y) &&
        !tile_is_void?(x, y, edits) && tile_surface_state(edits, x, y)['ground'] != 'quicksand' &&
        !tile_surface_state(edits, x, y)['stair'] && !relief_wall?(edits, x, y) &&
        !surf_ground?(edits, x, y) && !ArenaDevices.sparks(device_wire(placements)).value?([x, y])
    end

    def editor_apply_ground(edits, placements, x, y, selected)
      if ArenaDevices.sparks(device_wire(placements)).value?([x, y])
        return pbMessage("Retirez d'abord la bobine avant de modifier le sol de son étincelle.")
      end
      super
    end

    def editor_apply_placement(placements, edits, kind, selected, x, y)
      current = editor_occupied(placements, x, y)
      if selected[:action] != :remove && ArenaDevices.sparks(device_wire(placements)).value?([x, y])
        return pbMessage('Cette case est réservée à une étincelle Tesla. Retirez ou réorientez la bobine.')
      end
      if current && ArenaDevices.item?(current['item'])
        return remove_device(placements, current) if selected[:action] == :remove && kind == 'furniture'
        return pbMessage("Retirez d'abord cet objet (et son partenaire éventuel).")
      end
      return super unless kind == 'furniture' && ArenaDevices.item?(selected[:item]) && selected[:action] != :remove
      unless device_tile_valid?(placements, edits, x, y)
        return pbMessage('Choisissez une case de sol libre, hors eau, paroi et escalier.')
      end
      item = selected[:item].to_s
      selected[:placed_item] ||= 'ARENA_TESLA_R' if item == ArenaDevices::COIL
      pair = [ArenaDevices::TELEPORT, ArenaDevices::COIL].include?(item)
      pending = selected[:device_first]
      if pair && (!pending || selected[:device_draft] != placements.object_id)
        selected[:device_first], selected[:device_draft] = [x, y], placements.object_id
        pbMessage(item == ArenaDevices::TELEPORT ? 'Première dalle choisie. Choisissez la seconde case puis appuyez sur Entrée. X annule la pose du lot.' : 'Bobine choisie. Choisissez la case du gros bouton rouge puis appuyez sur Entrée. X annule la pose du lot.')
        return
      end
      if pair && (pending == [x, y] || !device_tile_valid?(placements, edits, *pending))
        return pbMessage('Les deux éléments doivent occuper deux cases libres différentes.')
      end
      required = pair ? 2 : 1
      if item == ArenaDevices::COIL
        anchor = pending || [x, y]
        _direction, dx, dy = ArenaDevices.direction(selected[:placed_item])
        spark = [anchor[0] + dx, anchor[1] + dy]
        unless device_tile_valid?(placements, edits, *spark) && spark != [x, y] &&
            (!pair || !pending || tile_surface_state(edits, *anchor)['height'] == tile_surface_state(edits, *spark)['height'])
          return pbMessage("La case de l'étincelle doit rester libre, accessible et différente du bouton.")
        end
      end
      return pbMessage('La capacité de mobilier est atteinte.') if furniture_placements(placements).length + required > MAX_ARENA_FURNITURE
      return pbMessage("Il n'y a plus de cet objet dans le Sac.") unless $bag.remove(selected[:item], 1)
      first = pair ? pending : [x, y]
      placed = selected[:placed_item] || item
      placements << { 'kind' => 'furniture', 'item' => placed, 'x' => first[0], 'y' => first[1] }
      if pair
        partner_item = item == ArenaDevices::COIL ? ArenaDevices::BUTTON : item
        placements << { 'kind' => 'furniture', 'item' => partner_item, 'x' => x, 'y' => y }
        selected.delete(:device_first)
      end
      refresh_custom_placements(placements)
      true
    end

    def place_from_bag(placements, kind, x, y, edits = tile_edit_records)
      return super unless kind == 'furniture'
      entry = choose_catalog(bag_catalog(kind), 'Choisissez un meuble de votre Sac.')
      return unless entry
      entry = configure_device(entry) if ArenaDevices.item?(entry[:item])
      editor_apply_placement(placements, edits, kind, entry, x, y) if entry
    end

    def replace_placement(placements, placement)
      return pbMessage("Retirez d'abord cet objet (et son partenaire éventuel).") if ArenaDevices.item?(placement['item'])
      @device_legacy_replace = true
      super
    ensure
      @device_legacy_replace = false
    end

    def edit_tile(placements, edits, x, y)
      current = editor_occupied(placements, x, y)
      return super unless current && ArenaDevices.item?(current['item'])
      choice = pbMessage('Objet interactif : retirer aussi son partenaire éventuel ?', ['Retirer', 'Retour'], -1)
      remove_device(placements, current) if choice == 0
      :continue
    end

    def reconcile_editor_inventory(original, draft)
      super(original.reject { |p| ArenaDevices.item?(p['item']) }, draft.reject { |p| ArenaDevices.item?(p['item']) })
      before, after = device_inventory_counts(original), device_inventory_counts(draft)
      (before.keys | after.keys).each do |item|
        difference = after.fetch(item, 0) - before.fetch(item, 0)
        $bag.add(item, difference) if difference > 0
        $bag.remove(item, -difference) if difference < 0
      end
    end

    def refresh_custom_placements(placements = custom_placements)
      super
      return unless $game_map && $game_map.map_id == MAP_ID
      furniture = furniture_placements(placements)
      MAX_ARENA_FURNITURE.times do |slot|
        event = $game_map.events[FURNITURE_SLOT_BASE + slot]
        next unless event
        item = furniture[slot] && furniture[slot]['item']
        device = ArenaDevices.item?(item)
        event.instance_variable_set(:@arena_device_item, device ? item : nil)
        event.instance_variable_set(:@arena_device_slot, slot)
        next unless device
        event.through = !ArenaDevices.blocked?(item, slot, Devices.disabled)
        event.walk_anime = false
        event.instance_variable_set(:@step_anime, false)
      end
      Devices.bind_sparks(device_wire(placements))
    end

    def runtime_tile_blocked?(x, y, event)
      if $game_map && $game_map.map_id == MAP_ID && !@custom_mode_active &&
          ArenaDevices.sparks(device_wire(custom_placements), Devices.disabled).value?([x, y])
        return true
      end
      super
    end

    def decode_visit_snapshot(*args)
      return nil unless args[1].is_a?(Array) && ArenaDevices.valid_pairs?(args[1])
      result = super
      return nil unless result && ArenaDevices.valid_sparks?(args[1], args[0], args[2] || '0' * 10000, relief_reserved)
      result
    end

    def custom_mode
      reset_devices = !multiplayer? && $game_map && $game_map.map_id == MAP_ID
      Devices.clear if reset_devices
      super
    ensure
      Devices.clear if reset_devices
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_devices_stock_added
end
ArenaDemo.singleton_class.prepend(ArenaDemo::DeviceEditor)
ArenaDemo.register_bag_items if defined?(GameData::Item)
