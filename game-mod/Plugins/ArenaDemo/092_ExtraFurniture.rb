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
    'rse-pretty-flowers' => 'Jolies fleurs de Hoenn',
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
    'dppt-pottedplant' => 'Plante en pot de Sinnoh',
    'dppt-pokeflower' => 'Fleur Pokémon',
    'dppt-prettyflowers' => 'Jolies fleurs de Sinnoh',
    'dppt-daintyflowers' => 'Fleurs délicates',
    'cogne-cogne' => 'Cogne-Cogne',
    'chandelier' => 'Chandelier',
    'lampe' => 'Lampe',
    'tree-leafy' => 'Arbre feuillu',
    'tree-pine' => 'Sapin',
    'hgss-red-carpet' => "Tapis rouge d'entrée HGSS",
    'hgss-spikes' => "Pics d'Ébènelle HGSS",
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
      furniture_placements(placements).each_with_index do |placed, slot|
        item = placement_item(placed)
        next unless EXTRA_FURNITURE.key?(item)
        event = $game_map.events[FURNITURE_SLOT_BASE + slot]
        event.through = ArenaFurnitureRules.walkable?(item) if event
      end
    end

    def editor_apply_placement(placements, records, kind, selected, x, y)
      current = editor_occupied(placements, x, y)
      removing = selected[:action] == :remove
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
      if @device_legacy_replace && chosen && ArenaFurnitureRules.raised?(chosen[:item])
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
      self.z -= 32 if ArenaFurnitureRules.walkable?(item)
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_extra_furniture_stock_added
end
ArenaDemo.singleton_class.prepend(ArenaDemo::ExtraFurnitureIntegration)
Sprite_Character.prepend(ArenaDemo::ExtraFurnitureFloorGraphic) if defined?(Sprite_Character)
ArenaDemo.register_bag_items if defined?(GameData::Item)
