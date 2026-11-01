# Local expeditions use Essentials' map setup hook, saves and WildBattle.
# Templates and tile samples are prepared locally by build_arena_map.rb.
module ArenaDemo
  module Expeditions
    Layout = ExpeditionLayout
    module_function

    def state; $PokemonGlobal && $PokemonGlobal.arena_expedition; end
    def region(map_id)
      return nil unless Layout.map?(map_id) && state
      state['regions'][Layout.index(map_id)]
    end
    def active?; $game_map && Layout.map?($game_map.map_id) && !!state; end

    def depart
      return unless $game_map && $game_map.map_id == TOWN_MAP_ID
      if ArenaDemo.multiplayer? || (defined?(Visits) && Visits.locked?)
        pbMessage('Expeditions are available offline. Disconnect at the arena attendant first.')
        return
      end
      if !$player || $player.able_pokemon_count == 0
        pbMessage('Bring an able Pokemon before leaving the village.')
        return
      end
      return unless Outings.departure_allowed?
      return unless pbConfirmMessage("#{Outings.allowance_text}.\nLeave on a new 20-minute expedition? Returning home ends this outing.")
      previous = state
      reservation = nil
      # This is the only random roll outside the private generator. Keep it
      # separate from terrain generation and ensure consecutive seeds differ.
      seed = rand(0x7fffffff)
      seed = (seed + 1) & 0x7fffffff if previous && previous['seed'] == seed
      begin
        plan = generate(seed)
        reservation = Outings.start(plan)
        $PokemonGlobal.arena_expedition = plan
        ArenaDemo.prepare_village_return
        ArenaDemo.transfer_to(Layout::FIRST_MAP + Layout::HOME, Layout::SIZE / 2, Layout::SIZE - 8, 8)
        unless active?
          $PokemonGlobal.arena_expedition = previous
          Outings.cancel(reservation)
        end
      rescue OutingLedger::LimitReached, IOError, SystemCallError => error
        $PokemonGlobal.arena_expedition = previous
        Outings.cancel(reservation)
        pbMessage("The expedition could not start: #{error.message}")
      rescue StandardError
        $PokemonGlobal.arena_expedition = previous
        Outings.cancel(reservation)
        raise
      end
    end

    def generate(seed)
      window = nil
      if defined?(Window_UnformattedTextPokemon) && defined?(Graphics)
        window = Window_UnformattedTextPokemon.newWithSize('Preparing expedition...', 0, 0, Graphics.width, 96)
        window.z = 99999
      end
      plan = Layout.build(seed) do |done, total|
        next unless window
        window.text = "Creating wilderness... #{done}/#{total}"
        window.update
        Graphics.update
        Input.update if defined?(Input)
      end
      assign_species(plan)
    ensure
      window.dispose if window && !window.disposed?
    end

    def return_home
      return unless active?
      return unless pbConfirmMessage('Return to the village? You keep your Pokemon and items. The next departure creates a new wilderness.')
      ArenaDemo.transfer_to(TOWN_MAP_ID, 16, 20, 8)
      Outings.close_current unless active?
    end

    def guide
      pbMessage("WILDERNESS EXPEDITIONS\nWalk south through the village gate to explore a new wilderness. Each departure changes the landscape.")
      pbMessage("#{Outings.allowance_text}. Each outing lasts 20 real minutes. An ongoing battle finishes before you return home.")
      pbMessage('Each area has up to five local species. Approach visible Pokemon to battle and catch them. Use Expedition in the Space-key pause menu to return home.')
    end

    def menu
      return unless active?
      i = Layout.index($game_map.map_id)
      data = region($game_map.map_id)
      name = Layout::BIOMES.fetch(data['biome'])[0]
      choice = pbMessage("#{name} - sector #{i % Layout::SIDE + 1},#{i / Layout::SIDE + 1}. Time left: #{Outings.time_text}.\nThe camp is in sector 2,4. Clear paths lead to neighboring sectors.",
                         ['Area chances', 'Return to village', 'Cancel'], -1)
      if choice == 0
        Layout::BIOMES.values.each_slice(4) do |rows|
          pbMessage(rows.map { |row| "#{row[0]}: #{row[1]}%" }.join("\n"))
        end
        pbMessage('These are fixed chances for each of the 15 random sectors, with repeats allowed. The starting sector is always grassland.')
      elsif choice == 1
        return_home
      end
    end

    def portal(direction)
      return unless active? && !ArenaDemo.multiplayer?
      return if Outings.expired?
      destination = Layout.neighbor(Layout.index($game_map.map_id), direction)
      return unless destination
      x, y = $game_player.x, $game_player.y
      x = Layout::SIZE - 2 if direction == 4
      x = 1 if direction == 6
      y = Layout::SIZE - 2 if direction == 8
      y = 1 if direction == 2
      x, y = landing_position(region(Layout::FIRST_MAP + destination), x, y)
      ArenaDemo.transfer_to(Layout::FIRST_MAP + destination, x, y, direction)
    end

    # Old saved sectors may have a bend immediately behind a crossing. Land
    # inside the camp-connected component, never on a cliff or isolated ledge.
    def landing_position(data, x, y)
      occupied = data['decorations'].to_h { |dx, dy, _| [dy * Layout::SIZE + dx, true] }
      reachable = Layout.reachable_cells(data['cells'], occupied)
      candidates = reachable.keys.select do |pos|
        cx, cy = pos % Layout::SIZE, pos / Layout::SIZE
        cx.between?(1, Layout::SIZE - 2) && cy.between?(1, Layout::SIZE - 2) &&
          !occupied[pos] && !Layout.blocked?(data['cells'].getbyte(pos))
      end
      position = candidates.min_by { |pos| (pos % Layout::SIZE - x).abs + (pos / Layout::SIZE - y).abs }
      raise 'No accessible expedition landing' unless position
      [position % Layout::SIZE, position / Layout::SIZE]
    end

    def event(id, name, x, y, character, script, touch = false)
      result = RPG::Event.new(x, y)
      result.id, result.name = id, name
      page = result.pages[0]
      page.graphic.character_name = character
      page.through = touch || id == 900
      page.trigger = touch ? 1 : 0
      page.direction_fix = true
      page.list = []
      page.list << RPG::EventCommand.new(355, 0, [script]) if script
      page.list << RPG::EventCommand.new(0)
      result
    end

    def prepare(map_id, map, _tileset)
      return unless Layout.map?(map_id)
      data = region(map_id)
      # A missing/unsupported expedition must never generate a new landscape
      # underneath a loaded player. Fail with an actionable message instead.
      raise 'Missing expedition layout. Return to Arena Village before entering the wilderness.' unless data
      assign_region_species(state, Layout.index(map_id))
      palette = load_data('Data/ArenaExpeditionPalette.rxdata')
      map.width = map.height = Layout::SIZE
      map.data = Table.new(Layout::SIZE, Layout::SIZE, 3)
      cells = data['cells']
      Layout::SIZE.times do |y|
        Layout::SIZE.times do |x|
          code = cells.getbyte(y * Layout::SIZE + x)
          key = code == 103 ? 'grass' : (code == 112 ? 'path' : 'ground')
          stack = palette.fetch(key)
          3.times { |z| map.data[x, y, z] = stack[z] }
        end
      end
      events = { 900 => event(900, 'Arena follower anchor', 0, 0, '', nil) }
      data['decorations'].each_with_index do |(x, y, character), i|
        next unless pbResolveBitmap("Graphics/Characters/#{character}")
        events[100 + i] = event(100 + i, 'Wilderness scenery', x, y, character, nil)
      end
      i = Layout.index(map_id)
      id = 1
      [2, 4, 6, 8].each do |direction|
        next unless Layout.neighbor(i, direction)
        (-1..1).each do |offset|
          x = direction == 4 ? 0 : (direction == 6 ? Layout::SIZE - 1 : Layout::SIZE / 2 + offset)
          y = direction == 8 ? 0 : (direction == 2 ? Layout::SIZE - 1 : Layout::SIZE / 2 + offset)
          events[id] = event(id, 'Wilderness crossing', x, y, '', "ArenaDemo::Expeditions.portal(#{direction})", true)
          id += 1
        end
      end
      if i == Layout::HOME
        events[20] = event(20, 'Village return guide', Layout::SIZE / 2, Layout::SIZE - 5,
                           'trainer_YOUNGSTER', 'ArenaDemo::Expeditions.return_home')
      end
      map.events = events
      map.instance_variable_set(:@arena_expedition_region, data)
    end

    def data_for(map)
      map.instance_variable_get(:@map)&.instance_variable_get(:@arena_expedition_region)
    end

    def code_at(map, x, y)
      return nil unless x.between?(0, Layout::SIZE - 1) && y.between?(0, Layout::SIZE - 1)
      data_for(map)&.fetch('cells')&.getbyte(y * Layout::SIZE + x)
    end

    def spawn_tile?(map, x, y); code_at(map, x, y) == 103; end

    def encounter_pool(biome)
      @pools ||= {}
      @pools[biome] ||= begin
        types = Layout::BIOMES.fetch(biome)[2]
        pool = []
        GameData::Species.each do |data|
          next unless data.form == 0 && data.generation.between?(1, 5)
          next if (data.types & types).empty?
          next if ['Legendary', 'Mythical', 'UltraBeast'].any? { |flag| data.has_flag?(flag) }
          # Ocean-only Pokemon need water movement; this first version places
          # approachable creatures on shore grass instead.
          next if [:Sea, :Rare].include?(data.habitat)
          total = data.base_stat_total
          weight = total < 350 ? 12 : (total < 480 ? 5 : 1)
          weight *= 4 if data.types.include?(types.first)
          pool << [weight, data.id]
        end
        pool
      end
    end

    def assign_region_species(plan, index)
      data = plan['regions'][index]
      return data['encounters'] if data.key?('encounters')
      candidates = encounter_pool(data['biome']).map(&:dup).uniq { |row| row[1] }
      rng = Layout::RNG.new(plan['seed'].to_i ^ ((index + 1) * 2654435761) ^ 0x5eedcafe)
      selected = []
      [5, candidates.length].min.times do
        roll = rng.rand(candidates.sum { |row| row[0] })
        position = candidates.index { |row| roll -= row[0]; roll < 0 }
        selected << candidates.delete_at(position)
      end
      data['encounters'] = selected
    end

    def assign_species(plan)
      plan['regions'].each_index { |index| assign_region_species(plan, index) }
      plan
    end

    def encounter(map)
      data = data_for(map)
      return nil unless data
      pool = assign_region_species(state, Layout.index(map.map_id))
      return nil if pool.empty?
      roll = rand(pool.sum { |row| row[0] })
      selected = pool.find { |row| roll -= row[0]; roll < 0 }
      i = Layout.index(map.map_id)
      distance = (i % Layout::SIDE - Layout::HOME % Layout::SIDE).abs +
                 (i / Layout::SIDE - Layout::HOME / Layout::SIDE).abs
      level = 3 + distance * 4 + rand(5)
      [selected[1], level]
    end

    # Load/reload the same saved layout. Game.load_map may use either serialized
    # maps or regenerated templates; both routes retain the expedition state.
    def recover_loaded_map
      return unless active?
      position = [$game_player.x, $game_player.y, $game_player.direction]
      ArenaDemo.reset_saved_player_movement
      $game_map.setup($game_map.map_id)
      x, y = position.first(2)
      x, y = landing_position(region($game_map.map_id), x, y)
      $game_player.moveto(x, y)
      $game_player.direction = position[2]
      $game_player.center(x, y)
    end
  end

  module ExpeditionCollision
    OFFSETS = { 1 => [-1, 1], 2 => [0, 1], 3 => [1, 1], 4 => [-1, 0],
                6 => [1, 0], 7 => [-1, -1], 8 => [0, -1], 9 => [1, -1] }.freeze
    def passable?(x, y, direction, self_event = nil)
      return super unless ExpeditionLayout.map?(@map_id)
      offset = OFFSETS[direction]
      return false if offset && ExpeditionLayout.blocked?(Expeditions.code_at(self, x + offset[0], y + offset[1]))
      super
    end
    def passableStrict?(x, y, direction, self_event = nil)
      return false if ExpeditionLayout.map?(@map_id) && ExpeditionLayout.blocked?(Expeditions.code_at(self, x, y))
      super
    end
    def terrain_tag(x, y, count_bridge = false)
      if ExpeditionLayout.map?(@map_id)
        # All physical terrain rules are explicit above: water/lava are barriers
        # in this version. Do not inherit Surf, ledges or ice from sample art.
        return GameData::TerrainTag.get(Expeditions.spawn_tile?(self, x, y) ? :Grass : :None)
      end
      super
    end
    def name
      data = Expeditions.data_for(self) if ExpeditionLayout.map?(@map_id)
      return ExpeditionLayout::BIOMES.fetch(data['biome'])[0] if data
      super
    end
    def metadata
      data = Expeditions.data_for(self) if ExpeditionLayout.map?(@map_id)
      return super unless data
      key = [@map_id, data['biome']]
      if @arena_expedition_metadata_key != key
        @arena_expedition_metadata_key = key
        @arena_expedition_metadata = GameData::MapMetadata.new({
          :id => @map_id, :real_name => name, :outdoor_map => true,
          :announce_location => true, :can_bicycle => true,
          :snap_edges => true
        })
      end
      @arena_expedition_metadata
    end
  end

  module ExpeditionLoad
    def load_map(*args)
      result = super
      Expeditions.recover_loaded_map
      result
    end
  end
end

class PokemonGlobalMetadata
  attr_accessor :arena_expedition
end

EventHandlers.add(:on_game_map_setup, :arena_expedition, proc { |id, map, tileset|
  ArenaDemo::Expeditions.prepare(id, map, tileset)
})
Game_Map.prepend(ArenaDemo::ExpeditionCollision) if defined?(Game_Map)
Game.singleton_class.prepend(ArenaDemo::ExpeditionLoad) if defined?(Game)

MenuHandlers.add(:pause_menu, :arena_expedition, {
  'name' => 'Expedition', 'order' => 65,
  'condition' => proc { ArenaDemo::Expeditions.active? },
  'effect' => proc { |menu|
    menu.pbEndScene
    ArenaDemo::Expeditions.menu
    true
  }
})
