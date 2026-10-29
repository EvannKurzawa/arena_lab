# Offline, tile-by-tile arena editor and its two dedicated Bag pockets.
module ArenaDemo
  FURNITURE_POCKET = 7
  TRAINER_POCKET = 8
  FURNITURE_SLOT_BASE = 200
  TRAINER_SLOT_BASE = 300
  MAX_ARENA_FURNITURE = 80
  MAX_ARENA_TRAINERS = 16
  MAP_WIDTH = 100
  MAP_HEIGHT = 100
  GROUND_FILE = "Data/ArenaDemoGround.txt"
  TILE_EDIT_MIGRATION_VERSION = 1
  INITIAL_FIELD_SIZE = 25
  INITIAL_FIELD_X = (MAP_WIDTH - INITIAL_FIELD_SIZE) / 2
  INITIAL_FIELD_Y = (MAP_HEIGHT - INITIAL_FIELD_SIZE) / 2
  SURFACE_TAGS = { "grass" => :Grass, "desert" => :Sand,
                   "ice" => :Ice, "rock" => :Rock }.freeze
  SURFACE_NAMES = { "plain" => "Concrete / plain", "grass" => "Grass",
                    "desert" => "Desert / sand", "ice" => "Ice",
                    "rock" => "Rock" }.freeze
  VISIT_SURFACE_CODES = { "void" => "0", "plain" => "1", "grass" => "2",
                          "desert" => "3", "ice" => "4", "rock" => "5" }.freeze
  FURNITURE_STOCK = {
    :ARENA_FURNITURE_BOULDER => ["Boulder", "Object boulder", 2],
    :ARENA_FURNITURE_ROCK    => ["Rock", "Object rock", 2],
    :ARENA_FURNITURE_TREE    => ["Tree", "Object tree 1", 2]
  }.freeze
  TRAINER_PROFILES = {
    :ARENA_TRAINER_ROOKIE => {
      :name => "Rookie", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:RATTATA, 8], [:EKANS, 9]]
    },
    :ARENA_TRAINER_TACTICIAN => {
      :name => "Tactician", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MAGNEMITE, 10], [:KOFFING, 10]]
    },
    :ARENA_TRAINER_LEADER => {
      :name => "Giovanni", :sprite => "trainer_LEADER_Giovanni", :type => :ROCKETBOSS,
      :team => [[:MEWTWO, 70], [:PERSIAN, 72], [:RHYPERIOR, 70], [:MEOWTH, 76]]
    },
    :ARENA_TRAINER_CHAMPION => {
      :name => "Blue", :sprite => "trainer_CHAMPION", :type => :CHAMPION,
      :team => [[:BLASTOISE, 67], [:PIDGEOT, 65], [:EXEGGUTOR, 62], [:ALAKAZAM, 70]]
    },
 :ARENA_TRAINER_PROFESSOR => {
      :name => "Oak", :sprite => "trainer_PROFESSOR", :type => :PROFESSOR,
      :team => [[:BLASTOISE, 95], [:CHARIZARD, 95], [:VENUSAUR, 95], [:PIKACHU, 95], [:EEVEE, 95]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_RED => {
      :name => "Red", :sprite => "trainer_POKEMONTRAINER_Red", :type => :POKEMONTRAINER_Red,
      :team => [[:CHARIZARD, 100], [:PIKACHU, 100], [:MEW, 100]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_LEAF => {
      :name => "Leaf", :sprite => "trainer_POKEMONTRAINER_Leaf", :type => :POKEMONTRAINER_Leaf,
      :team => [[:BULBASAUR, 10], [:PIDGEY, 8], [:MANKEY, 9]]
    },
 :ARENA_TRAINER_ELITEFOUR_AGATHA => {
      :name => "Agatha", :sprite => "trainer_ELITEFOUR_Agatha", :type => :ELITEFOUR_Agatha,
      :team => [[:ARBOK, 51], [:CROBAT, 50], [:HAUNTER, 52], [:GENGAR, 55]]
    },
 :ARENA_TRAINER_ELITEFOUR_LANCE => {
      :name => "Lance", :sprite => "trainer_ELITEFOUR_Lance", :type => :ELITEFOUR_Lance,
      :team => [[:GYARADOS, 51], [:DRAGONAIR, 50], [:AERODACTYL, 52], [:DRAGONITE, 55]]
    },
 :ARENA_TRAINER_ELITEFOUR_BRUNO => {
      :name => "Bruno", :sprite => "trainer_ELITEFOUR_Bruno", :type => :ELITEFOUR_Bruno,
      :team => [[:HITMONCHAN, 51], [:HITMONLEE, 50], [:HITMONTOP, 52], [:MACHAMP, 55]]
    },
 :ARENA_TRAINER_ELITEFOUR_LORELEI => {
      :name => "Lorelei", :sprite => "trainer_ELITEFOUR_Lorelei", :type => :ELITEFOUR_Lorelei,
      :team => [[:DEWGONG, 51], [:JYNX, 50], [:CLOYSTER, 52], [:LAPRAS, 55]]
    },
 :ARENA_TRAINER_LEADER_BROCK => {
      :name => "Brock", :sprite => "trainer_LEADER_Brock", :type => :LEADER_Brock,
      :team => [[:CROAGUNK, 15], [:SUDOWOODO, 17], [:ONIX, 19]]
    },
 :ARENA_TRAINER_LEADER_MISTY => {
      :name => "Misty", :sprite => "trainer_LEADER_Misty", :type => :LEADER_Misty,
      :team => [[:STARYU, 15], [:PSYDUCK, 17], [:TOGEPI, 19]]
    },
 :ARENA_TRAINER_LEADER_SURGE => {
      :name => "Surge", :sprite => "trainer_LEADER_Surge", :type => :LEADER_Surge,
      :team => [[:MAGNEMITE, 25], [:ELECTABUZZ, 27], [:RAICHU, 29]]
    },
 :ARENA_TRAINER_LEADER_ERIKA => {
      :name => "Erika", :sprite => "trainer_LEADER_Erika", :type => :LEADER_Erika,
      :team => [[:TANGELA, 25], [:VILEPLUME, 27], [:IVYSAUR, 29]]
    },
 :ARENA_TRAINER_LEADER_KOGA => {
      :name => "Koga", :sprite => "trainer_LEADER_Koga", :type => :LEADER_Koga,
      :team => [[:KOFFING, 25], [:GRIMER, 27], [:SKUNTANK, 29]]
    },
 :ARENA_TRAINER_LEADER_SABRINA => {
      :name => "Sabrina", :sprite => "trainer_LEADER_Sabrina", :type => :LEADER_Sabrina,
      :team => [[:MRMIME, 35], [:VENOMOTH, 37], [:ALAKAZAM, 39]]
    },
 :ARENA_TRAINER_LEADER_BLAINE => {
      :name => "Blaine", :sprite => "trainer_LEADER_Blaine", :type => :LEADER_Blaine,
      :team => [[:RAPIDASH, 35], [:ARCANINE, 37], [:MAGMORTAR, 39]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_BRENDAN => {
      :name => "Brendan", :sprite => "trainer_POKEMONTRAINER_Brendan", :type => :POKEMONTRAINER_Brendan,
      :team => [[:TREECKO, 10], [:ZIGZAGOON, 8], [:RALTS, 9]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_MAY => {
      :name => "May", :sprite => "trainer_POKEMONTRAINER_May", :type => :POKEMONTRAINER_May,
      :team => [[:BLAZIKEN, 100], [:ABSOL, 100], [:KYOGRE, 100]]
    }
  }.freeze

  module_function

  def register_bag_items
    FURNITURE_STOCK.each do |item, data|
      register_custom_bag_item(item, data[0], FURNITURE_POCKET,
                                "Place this furniture in your offline arena.")
    end
    TRAINER_PROFILES.each do |item, profile|
      register_custom_bag_item(item, profile[:name], TRAINER_POCKET,
                               "A trainer recruited to your offline arena.")
    end
  end

  def register_custom_bag_item(id, name, pocket, description)
    return if GameData::Item.exists?(id)
    GameData::Item.register({
      :id => id, :id_number => 9900 + GameData::Item::DATA.length,
      :real_name => name, :real_name_plural => name,
      :real_portion_name => name, :real_portion_name_plural => name,
      :pocket => pocket, :price => 0, :sell_price => 0, :bp_price => 0,
      :field_use => 0, :battle_use => 0, :flags => ["KeyItem"],
      :consumable => false, :show_quantity => true,
      :real_description => description
    })
  end

  def ensure_bag_pockets(bag = $bag, fresh = false)
    return unless bag && bag.respond_to?(:pockets)
    if fresh
      bag.instance_variable_set(:@arena_lab_bag_layout, 2)
    else
      migrate_bag_layout(bag)
    end
    (0..PokemonBag.pocket_count).each do |pocket|
      bag.pockets[pocket] ||= []
    end
    selections = bag.last_pocket_selections
    unless selections.is_a?(Array)
      selections = []
      bag.last_pocket_selections = selections
    end
    (0..PokemonBag.pocket_count).each do |pocket|
      value = selections[pocket]
      selections[pocket] = 0 unless value.is_a?(Integer) && value >= 0
    end
    viewed = bag.last_viewed_pocket
    unless viewed.is_a?(Integer) && viewed.between?(1, PokemonBag.pocket_count)
      bag.last_viewed_pocket = 1
    end
  end

  def migrate_bag_layout(bag)
    return if bag.instance_variable_get(:@arena_lab_bag_layout) == 2
    old = bag.pockets
    old_selections = bag.last_pocket_selections
    old_selections = [] unless old_selections.is_a?(Array)
    # Legacy pockets: 1 Items, 2 Medicine, 3 Balls, 4 TMs, 5 Berries,
    # 6 Mail, 7 Battle Items, 8 Key Items, then the two Arena pockets.
    remap = { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5,
              6 => 1, 7 => 1, 8 => 6, 9 => 7, 10 => 8 }
    migrated = Array.new(9) { [] }
    (1..10).each do |old_pocket|
      target = remap[old_pocket]
      next unless target && old[old_pocket].is_a?(Array)
      old[old_pocket].each do |entry|
        next unless entry.is_a?(Array) && entry.length >= 2
        found = migrated[target].find { |item| item[0] == entry[0] }
        found ? found[1] += entry[1].to_i : migrated[target] << [entry[0], entry[1].to_i]
      end
    end
    migrated[0] = old[0].is_a?(Array) ? old[0] : []
    bag.pockets.replace(migrated)
    selections = Array.new(9, 0)
    (1..5).each { |p| selections[p] = old_selections[p].to_i if old_selections[p].is_a?(Numeric) }
    selections[6] = old_selections[8].to_i if old_selections[8].is_a?(Numeric)
    selections[7] = old_selections[9].to_i if old_selections[9].is_a?(Numeric)
    selections[8] = old_selections[10].to_i if old_selections[10].is_a?(Numeric)
    bag.last_pocket_selections = selections
    viewed = bag.last_viewed_pocket
    bag.last_viewed_pocket = case viewed
                             when 1..5 then viewed
                             when 8 then 6
                             when 9 then 7
                             when 10 then 8
                             else 1
                             end
    bag.instance_variable_set(:@arena_lab_bag_layout, 2)
  end

  def ensure_custom_inventory
    return unless $PokemonGlobal && $bag
    ensure_bag_pockets($bag)
    return if $PokemonGlobal.arena_custom_stock_added
    FURNITURE_STOCK.each do |item, data|
      $bag.add(item, data[2]) unless $bag.has?(item)
    end
    $PokemonGlobal.arena_custom_stock_added = true
  end

  def furniture_placements(placements = custom_placements)
    placements.select { |placement| placement["kind"] == "furniture" }
  end

  def trainer_placements(placements = custom_placements)
    placements.select { |placement| placement["kind"] == "trainer" }
  end

  def custom_placements
    visit = defined?(Visits) && Visits.snapshot
    return visit[:placements] if visit && visit[:placements].is_a?(Array)
    ensure_custom_inventory
    values = $PokemonGlobal.arena_demo_placements
    unless values.is_a?(Array)
      values = []
      $PokemonGlobal.arena_demo_placements = values
    end
    values
  end

  def placement_item(placement)
    placement["item"].to_s.to_sym
  end

  def placement_sprite(placement)
    item = placement_item(placement)
    if placement["kind"] == "furniture"
      data = FURNITURE_STOCK[item]
      return data && data[1]
    end
    profile = TRAINER_PROFILES[item]
    profile && profile[:sprite]
  end

  def tile_edit_key(x, y)
    "#{x},#{y}"
  end

  def tile_edit_records
    visit = defined?(Visits) && Visits.snapshot
    return visit[:tile_edits] if visit && visit[:tile_edits].is_a?(Hash)
    return {} unless $PokemonGlobal
    records = $PokemonGlobal.arena_demo_tile_edits
    unless records.is_a?(Hash)
      records = {}
      $PokemonGlobal.arena_demo_tile_edits = records
    end
    # A broken editor build could persist an entire grid of explicit void
    # tiles. Clear only that unmistakably corrupt state once; normal layouts
    # and deliberate small void edits remain intact.
    unless $PokemonGlobal.arena_demo_void_recovery_version.to_i >= TILE_EDIT_MIGRATION_VERSION
      valid_records = records.count do |key, record|
        coords = key.to_s.split(",")
        record.is_a?(Hash) && coords.length == 2 &&
          coords.all? { |value| value.match?(/\A\d+\z/) } &&
          coords[0].to_i.between?(0, MAP_WIDTH - 1) &&
          coords[1].to_i.between?(0, MAP_HEIGHT - 1)
      end
      void_records = records.count { |_key, record| record.is_a?(Hash) && record["floor"] == "void" }
      if valid_records >= 100 && void_records.to_f / valid_records >= 0.90
        records = {}
        $PokemonGlobal.arena_demo_tile_edits = records
      end
      $PokemonGlobal.arena_demo_void_recovery_version = TILE_EDIT_MIGRATION_VERSION
    end
    records
  end

  def initial_field_tile?(x, y)
    x.is_a?(Integer) && y.is_a?(Integer) &&
      x.between?(INITIAL_FIELD_X, INITIAL_FIELD_X + INITIAL_FIELD_SIZE - 1) &&
      y.between?(INITIAL_FIELD_Y, INITIAL_FIELD_Y + INITIAL_FIELD_SIZE - 1)
  end

  # Saves made before the starting field was centered stored arena contents in
  # the old top-left 25x25 area. Move those contents once, along with a player
  # saved inside the old field, so they remain on walkable ground.
  def migrate_centered_arena_layout
    return unless $PokemonGlobal
    return if defined?(Visits) && Visits.snapshot
    return if $PokemonGlobal.arena_demo_centered_layout_migration_version.to_i >= 3
    dx = INITIAL_FIELD_X
    dy = INITIAL_FIELD_Y
    placements = $PokemonGlobal.arena_demo_placements
    if placements.is_a?(Array)
      placements.each do |placement|
        next unless placement.is_a?(Hash)
        next unless placement["x"].is_a?(Integer) && placement["y"].is_a?(Integer)
        next unless placement["x"].between?(0, INITIAL_FIELD_SIZE - 1) &&
                    placement["y"].between?(0, INITIAL_FIELD_SIZE - 1)
        placement["x"] += dx
        placement["y"] += dy
      end
    end
    records = $PokemonGlobal.arena_demo_tile_edits
    if records.is_a?(Hash)
      moved = records.dup
      records.each do |key, value|
        coords = key.to_s.split(",").map(&:to_i)
        next unless coords.length == 2 && coords[0].between?(0, INITIAL_FIELD_SIZE - 1) &&
                    coords[1].between?(0, INITIAL_FIELD_SIZE - 1)
        target = tile_edit_key(coords[0] + dx, coords[1] + dy)
        moved[target] = value unless moved.key?(target)
        moved.delete(key)
      end
      $PokemonGlobal.arena_demo_tile_edits = moved
    end
    if $game_map && $game_map.map_id == MAP_ID && $game_player &&
       $game_player.x.between?(0, INITIAL_FIELD_SIZE - 1) &&
       $game_player.y.between?(0, INITIAL_FIELD_SIZE - 1)
      $game_player.moveto($game_player.x + dx, $game_player.y + dy)
    end
    $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
  end

  def normalize_fixed_arena_events(map)
    return unless map && map.map_id == MAP_ID
    map.events.each do |id, event|
      next unless id.between?(1, 9)
      next unless event.x.between?(0, INITIAL_FIELD_SIZE - 1) &&
                  event.y.between?(0, INITIAL_FIELD_SIZE - 1)
      event.moveto(event.x + INITIAL_FIELD_X, event.y + INITIAL_FIELD_Y)
    end
  end

  def recover_player_from_void(map)
    return unless map && map.map_id == MAP_ID && $game_player
    return unless tile_is_void?($game_player.x, $game_player.y) ||
                  !map.passableStrict?($game_player.x, $game_player.y, 2, $game_player)
    start = map_start
    candidates = [[start[0], start[1]]]
    INITIAL_FIELD_SIZE.times do |dy|
      INITIAL_FIELD_SIZE.times do |dx|
        candidates << [INITIAL_FIELD_X + dx, INITIAL_FIELD_Y + dy]
      end
    end
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times { |x| candidates << [x, y] }
    end
    destination = candidates.uniq.find do |x, y|
      !tile_is_void?(x, y) && map.passableStrict?(x, y, 2, $game_player)
    end
    $game_player.moveto(*destination) if destination
  end

  def recover_centered_arena_state(map = $game_map)
    return unless map && map.map_id == MAP_ID
    migrate_centered_arena_layout
    normalize_fixed_arena_events(map)
    apply_tile_edits(map)
    refresh_objects if respond_to?(:refresh_objects)
    recover_player_from_void(map)
    write_floor_map_diagnostic(map)
  end

  # Essentials can load a serialized Game_Map directly when its save magic
  # number matches, bypassing Game_Map#setup. Re-setup Map 100 from the freshly
  # generated Data/Map100.rxdata instead of trying to patch potentially stale
  # serialized Table data in place. Player progression and arena edits live in
  # Game_Player/PokemonGlobal, so retain those and the player's current tile.
  def reload_saved_arena_map_from_data
    return unless $game_map && [MAP_ID, TOWN_MAP_ID, ENTRANCE_MAP_ID].include?($game_map.map_id) && $game_player
    return if instance_variable_get(:@reloading_saved_arena_map)
    instance_variable_set(:@reloading_saved_arena_map, true)
    map = $game_map
    map_id = map.map_id
    position = [$game_player.x, $game_player.y, $game_player.direction]
    reset_saved_player_movement
    map.setup(map_id)
    $game_map = map
    $game_player.moveto(position[0], position[1])
    $game_player.direction = position[2]
    recover_centered_arena_state(map) if map_id == MAP_ID
    $game_player.center($game_player.x, $game_player.y)
    map.autoplay
    write_floor_map_diagnostic(map) if map_id == MAP_ID
  ensure
    instance_variable_set(:@reloading_saved_arena_map, false)
  end

  def reset_saved_player_movement
    # Ice/forced routes are transient. A serialized flag can otherwise keep
    # calling move_forward without input after loading or repositioning.
    [:ice_sliding, :descending_waterfall, :ascending_waterfall].each do |flag|
      $PokemonGlobal.public_send("#{flag}=", false) if $PokemonGlobal.respond_to?("#{flag}=")
    end
    { :move_route_forcing => false, :move_route => nil, :original_move_route => nil,
      :move_route_index => 0, :original_move_route_index => 0,
      :move_timer => nil, :wait_count => 0, :wait_start => nil,
      :jump_count => 0, :jump_distance => 0, :jumping_on_spot => false,
      :through => false, :walk_anime => true, :direction_fix => false }.each do |key, value|
      $game_player.instance_variable_set("@#{key}", value)
    end
  end

  def write_floor_map_diagnostic(map)
    return unless map && map.map_id == MAP_ID
    path = File.join("Data", "ArenaFloorDiagnostic.txt")
    stack = 3.times.map { |z| map.data[INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 12, z] || 0 }
    nonempty = 0
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        nonempty += 1 if map.data[x, y, 0].to_i >= 48
      end
    end
    File.write(path, [
      "map_id=#{map.map_id} size=#{map.width}x#{map.height} tileset_id=#{map.tileset_id} tileset=#{map.tileset_name.inspect}",
      "center_stack=#{stack.inspect} generated_stack=#{base_ground_stack(map).inspect}",
      "renderable_layer0_tiles=#{nonempty}/#{MAP_WIDTH * MAP_HEIGHT}",
      "ground_file_paths=#{ground_file_paths.map { |file| [file, File.file?(file)] }.inspect}"
    ].join("\n") + "\n")
  rescue StandardError => error
    File.write(File.join("Data", "ArenaFloorDiagnostic.txt"), "diagnostic_error=#{error.class}: #{error.message}\n") rescue nil
  end

  def tile_surface_state(records, x, y)
    record = records[tile_edit_key(x, y)]
    unless record.is_a?(Hash)
      return { "floor" => (initial_field_tile?(x, y) ? "field" : "void"),
               "ground" => "plain" }
    end
    floor = record["floor"] == "void" ? "void" : "field"
    ground = SURFACE_NAMES.key?(record["ground"]) ? record["ground"] : "plain"
    { "floor" => floor, "ground" => ground }
  end

  # Network snapshot: 10,000 one-byte surface codes and at most 96 placements.
  def visit_snapshot_payload
    surface = String.new(capacity: MAP_WIDTH * MAP_HEIGHT)
    records = tile_edit_records
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        state = tile_surface_state(records, x, y)
        code = state["floor"] == "void" ? "void" : state["ground"]
        surface << VISIT_SURFACE_CODES.fetch(code, "1")
      end
    end
    placements = custom_placements.filter_map do |placement|
      next unless placement.is_a?(Hash)
      kind = { "furniture" => 0, "trainer" => 1 }[placement["kind"]]
      item = placement["item"].to_s
      x, y = placement.values_at("x", "y")
      next unless kind && item.match?(/\A[A-Z0-9_]{1,48}\z/) &&
                  x.is_a?(Integer) && x.between?(0, MAP_WIDTH - 1) &&
                  y.is_a?(Integer) && y.between?(0, MAP_HEIGHT - 1)
      next unless kind == 0 ? FURNITURE_STOCK.key?(item.to_sym) : TRAINER_PROFILES.key?(item.to_sym)
      [kind, item, x, y]
    end.first(MAX_ARENA_FURNITURE + MAX_ARENA_TRAINERS)
    { :surface => surface, :placements => placements }
  end

  def decode_visit_snapshot(surface, placements)
    return nil unless surface.is_a?(String) && surface.bytesize == MAP_WIDTH * MAP_HEIGHT
    codes = VISIT_SURFACE_CODES.invert
    bytes = surface.bytes
    return nil unless bytes.all? { |byte| byte.between?(48, 53) }
    return nil unless placements.is_a?(Array) && placements.length <= MAX_ARENA_FURNITURE + MAX_ARENA_TRAINERS
    tile_edits = {}
    bytes.each_with_index do |byte, index|
      x = index % MAP_WIDTH
      y = index / MAP_WIDTH
      state_name = codes[byte.chr]
      return nil unless state_name
      default = initial_field_tile?(x, y) ? "plain" : "void"
      next if state_name == default
      tile_edits[tile_edit_key(x, y)] = if state_name == "void"
                                           { "floor" => "void", "ground" => "plain" }
                                         else
                                           { "floor" => "field", "ground" => state_name }
                                         end
    end
    reserved = [[INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 16],
                [INITIAL_FIELD_X + 10, INITIAL_FIELD_Y + 16],
                [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 4],
                [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 18]]
    seen = {}
    decoded_placements = placements.map do |entry|
      return nil unless entry.is_a?(Array) && entry.length == 4
      kind_id, item, x, y = entry
      kind = { 0 => "furniture", 1 => "trainer" }[kind_id]
      return nil unless kind && item.is_a?(String) && item.match?(/\A[A-Z0-9_]{1,48}\z/) &&
                        x.is_a?(Integer) && x.between?(0, MAP_WIDTH - 1) &&
                        y.is_a?(Integer) && y.between?(0, MAP_HEIGHT - 1)
      known = kind == "furniture" ? FURNITURE_STOCK.key?(item.to_sym) : TRAINER_PROFILES.key?(item.to_sym)
      point = [x, y]
      return nil unless known && !seen[point] && !reserved.include?(point)
      return nil if (bytes[y * MAP_WIDTH + x] - 48) == 0
      seen[point] = true
      { "kind" => kind, "item" => item, "x" => x, "y" => y }
    end
    { :tile_edits => tile_edits.freeze, :placements => decoded_placements.freeze }
  rescue StandardError
    nil
  end

  def surface_records_for_render
    draft = instance_variable_get(:@editor_surface_edits)
    draft.is_a?(Hash) ? draft : tile_edit_records
  end

  def tile_is_void?(x, y, records = tile_edit_records)
    return true unless x.is_a?(Integer) && y.is_a?(Integer)
    return true unless x.between?(0, MAP_WIDTH - 1) && y.between?(0, MAP_HEIGHT - 1)
    record = records[tile_edit_key(x, y)]
    return record["floor"] == "void" if record.is_a?(Hash) && record.key?("floor")
    return !initial_field_tile?(x, y)
  end

  def base_ground_stack(map = $game_map)
    return nil unless map && map.map_id == MAP_ID
    cached = map.instance_variable_get(:@arena_demo_base_ground_stack)
    return cached.dup if valid_ground_stack?(map, cached)
    map.remove_instance_variable(:@arena_demo_base_ground_stack) if
      map.instance_variable_defined?(:@arena_demo_base_ground_stack)
    ground_file_paths.each do |ground_path|
      next unless File.file?(ground_path)
      stored = File.read(ground_path).strip.split(",").map { |value| Integer(value, 10) rescue nil }
      if valid_ground_stack?(map, stored)
        map.instance_variable_set(:@arena_demo_base_ground_stack, stored)
        return stored.dup
      end
    end
    best = nil
    regions = [[INITIAL_FIELD_X, INITIAL_FIELD_Y,
                [INITIAL_FIELD_X + INITIAL_FIELD_SIZE, map.width].min,
                [INITIAL_FIELD_Y + INITIAL_FIELD_SIZE, map.height].min],
               [0, 0, map.width, map.height]]
    regions.each do |left, top, right, bottom|
      (top...bottom).each do |y|
        (left...right).each do |x|
          stack = 3.times.map { |z| map.data[x, y, z] || 0 }
          if valid_ground_stack?(map, stack)
            best = stack
            break
          end
        end
        break if best
      end
      break if best
    end
    # Do not silently convert a missing floor into an empty stack (void).
    return nil unless best
    map.instance_variable_set(:@arena_demo_base_ground_stack, best)
    best.dup
  end

  def ground_file_paths
    paths = [GROUND_FILE, File.expand_path("../../Data/ArenaDemoGround.txt", __dir__)]
    if defined?(System) && System.respond_to?(:data_directory)
      paths << File.join(System.data_directory, "ArenaDemoGround.txt")
    end
    paths.map { |path| File.expand_path(path) }.uniq
  end

  def valid_ground_stack?(map, stack)
    return false unless map && stack.is_a?(Array) && stack.length == 3 && stack.any?(&:positive?)
    stack.all? do |tile_id|
      next true if tile_id == 0
      # Essentials' TilemapRenderer treats IDs 0..47 as the blank autotile
      # block. Such tiles can be passable and priority zero, but render black.
      next false if tile_id < 48
      passage = map.passages[tile_id]
      next false if passage.nil? || (passage & 0x0f) != 0
      next false if map.priorities[tile_id].to_i != 0
      true
    end
  end

  def terrain_tile_id(map, terrain_id)
    cache = map.instance_variable_get(:@arena_demo_terrain_tile_cache) || {}
    return cache[terrain_id] if cache.key?(terrain_id)
    tags = map.terrain_tags
    count = tags.respond_to?(:xsize) ? tags.xsize : tags.length
    tile_id = (0...count).find do |id|
      next false if id == 0
      next false unless GameData::TerrainTag.try_get(tags[id]).id == terrain_id
      passage = map.passages[id]
      next false if !passage || passage & 0x0f != 0
      map.priorities[id].to_i == 0
    end
    cache[terrain_id] = tile_id
    map.instance_variable_set(:@arena_demo_terrain_tile_cache, cache)
    tile_id
  end

  def surface_options(map = $game_map)
    options = [[SURFACE_NAMES["plain"], "plain"]]
    SURFACE_TAGS.each do |key, terrain_id|
      options << [SURFACE_NAMES[key], key]
    end
    options
  end

  def surface_stack(map, ground)
    return base_ground_stack(map) if ground == "plain"
    # The arena uses Lappet Town's tileset, which has no dependable Ice floor
    # art. Render Ice with the editor's dedicated tile bitmap instead.
    return base_ground_stack(map) if ground == "ice"
    terrain_id = SURFACE_TAGS[ground]
    tile_id = terrain_id && terrain_tile_id(map, terrain_id)
    return base_ground_stack(map) unless tile_id
    [tile_id, 0, 0]
  end

  def apply_tile_surface(map, x, y, record)
    return unless map && map.map_id == MAP_ID && map.data
    stack = if record["floor"] == "void"
              [0, 0, 0]
            else
              surface_stack(map, record["ground"] || "plain")
            end
    3.times { |z| map.data[x, y, z] = stack[z] || 0 }
    refresh_map_renderer
  end

  def refresh_map_renderer
    return unless $scene && $scene.respond_to?(:map_renderer)
    renderer = $scene.map_renderer
    renderer.refresh if renderer && renderer.respond_to?(:refresh)
  end

  def ice_surface_bitmap
    bitmap = instance_variable_get(:@ice_surface_bitmap)
    return bitmap if bitmap && !bitmap.disposed?
    bitmap = Bitmap.new(Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
    bitmap.fill_rect(0, 0, 32, 32, Color.new(92, 164, 202))
    bitmap.fill_rect(2, 2, 28, 28, Color.new(142, 210, 234))
    bitmap.fill_rect(4, 4, 10, 2, Color.new(205, 241, 250))
    bitmap.fill_rect(18, 6, 8, 2, Color.new(194, 235, 247))
    bitmap.fill_rect(7, 14, 2, 5, Color.new(221, 249, 255))
    bitmap.fill_rect(8, 18, 6, 2, Color.new(221, 249, 255))
    bitmap.fill_rect(13, 18, 2, 6, Color.new(221, 249, 255))
    bitmap.fill_rect(20, 11, 2, 7, Color.new(221, 249, 255))
    bitmap.fill_rect(16, 16, 5, 2, Color.new(221, 249, 255))
    bitmap.fill_rect(19, 25, 8, 2, Color.new(112, 185, 215))
    instance_variable_set(:@ice_surface_bitmap, bitmap)
    bitmap
  end

  def reset_surface_map(map)
    return unless map && map.map_id == MAP_ID && map.data
    ground = base_ground_stack(map)
    return unless ground
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        stack = initial_field_tile?(x, y) ? ground : [0, 0, 0]
        3.times { |z| map.data[x, y, z] = stack[z] || 0 }
      end
    end
  end

  def apply_tile_edits(map, records = tile_edit_records)
    return unless map && map.map_id == MAP_ID && records.is_a?(Hash)
    return unless base_ground_stack(map)
    reset_surface_map(map)
    records.each do |key, record|
      next unless record.is_a?(Hash)
      coords = key.to_s.split(",").map(&:to_i)
      next unless coords.length == 2 && coords[0].between?(0, MAP_WIDTH - 1) &&
                  coords[1].between?(0, MAP_HEIGHT - 1)
      apply_tile_surface(map, coords[0], coords[1], record)
    end
  end

  def fixed_event_tile?(x, y)
    return false unless $game_map && $game_map.map_id == MAP_ID
    return true if [x, y] == [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 16]
    $game_map.events.values.any? do |event|
      [1, 2, 9].include?(event.id) && event.x == x && event.y == y
    end
  end

  def refresh_custom_placements(placements = custom_placements)
    return unless $game_map && $game_map.map_id == MAP_ID
    furniture = furniture_placements(placements)
    trainers = trainer_placements(placements)
    MAX_ARENA_FURNITURE.times do |slot|
      event = $game_map.events[FURNITURE_SLOT_BASE + slot]
      next unless event
      placement = furniture[slot]
      if placement && (sprite = placement_sprite(placement))
        event.moveto(placement["x"], placement["y"])
        event.character_name = sprite
        event.transparent = false
        event.through = false
      else
        event.character_name = ""
        event.transparent = true
        event.through = true
      end
    end
    MAX_ARENA_TRAINERS.times do |slot|
      event = $game_map.events[TRAINER_SLOT_BASE + slot]
      next unless event
      placement = trainers[slot]
      if placement && (profile = TRAINER_PROFILES[placement_item(placement)])
        event.moveto(placement["x"], placement["y"])
        event.character_name = profile[:sprite]
        event.transparent = false
        event.through = false
        event.walk_anime = true
        event.instance_variable_set(:@direction_fix, false)
        commands = [
          RPG::EventCommand.new(355, 0, ["ArenaDemo.challenge_recruited_trainer(#{slot})"]),
          RPG::EventCommand.new(0, 0, [])
        ]
        event.instance_variable_set(:@list, commands)
      else
        event.character_name = ""
        event.transparent = true
        event.through = true
        event.instance_variable_set(:@list, [RPG::EventCommand.new(0, 0, [])])
      end
    end
  end

  def editor_selectable_tile?(x, y)
    return false unless x.is_a?(Integer) && y.is_a?(Integer)
    return false unless x.between?(0, MAP_WIDTH - 1) && y.between?(0, MAP_HEIGHT - 1)
    return false if $game_player && [$game_player.x, $game_player.y] == [x, y]
    return false if defined?(Visits) && Visits.locked?
    true
  end

  def valid_editor_tile?(x, y)
    return false unless editor_selectable_tile?(x, y)
    return false if fixed_event_tile?(x, y)
    true
  end

  def editor_occupied(placements, x, y)
    placements.find { |placement| placement["x"] == x && placement["y"] == y }
  end

  def editor_choose_mode
    choice = pbMessage("What would you like to edit?", ["Change ground", "Handle trainers", "Handle furniture", "Done"], -1)
    return nil unless choice && choice >= 0 && choice <= 2
    [:ground, :trainer, :furniture][choice]
  end

  def editor_choose_ground
    options = surface_options
    labels = options.map(&:first) + ["Make tiles void", "Cancel"]
    choice = pbMessage("Choose the ground to paint.", labels, -1)
    return nil if choice < 0 || choice >= options.length + 1
    return { :floor => "void" } if choice == options.length
    { :floor => "field", :ground => options[choice][1] }
  end

  def editor_choose_placement(kind, placements)
    entries = bag_catalog(kind).map(&:dup)
    entries << { :action => :remove, :name => "Remove an existing #{kind}", :qty => "" } if placements.any? { |p| p["kind"] == kind }
    if entries.empty?
      pbMessage(kind == "trainer" ? "Recruit a trainer from the arena guide first." : "There is no furniture in this Bag pocket.")
      return nil
    end
    choose_catalog(entries, kind == "trainer" ? "Choose a trainer you own" : "Choose furniture you own")
  end

  def editor_apply_ground(surface_edits, placements, x, y, selected)
    return false unless editor_selectable_tile?(x, y)
    if selected[:floor] == "void" && (editor_occupied(placements, x, y) || fixed_event_tile?(x, y))
      pbMessage("Remove the occupant or move the arena event before making this tile void.")
      return false
    end
    state = tile_surface_state(surface_edits, x, y)
    state["floor"] = selected[:floor]
    state["ground"] = selected[:floor] == "void" ? "plain" : selected[:ground]
    surface_edits[tile_edit_key(x, y)] = state
    apply_tile_surface($game_map, x, y, state)
    true
  end

  def editor_apply_placement(placements, surface_edits, kind, selected, x, y)
    return unless valid_editor_tile?(x, y)
    current = editor_occupied(placements, x, y)
    if selected[:action] == :remove
      unless current && current["kind"] == kind
        pbMessage("Select a tile containing a #{kind} to remove.")
        return
      end
      $bag.add(placement_item(current), 1)
      placements.delete(current)
      refresh_custom_placements(placements)
      return
    end
    if tile_surface_state(surface_edits, x, y)["floor"] == "void"
      pbMessage("Make this tile a normal field before placing a trainer or furniture.")
      return
    end
    if current
      action = pbMessage("This tile already has #{current['kind']}.", ["Replace it", "Remove it", "Cancel"], -1)
      if action == 1
        $bag.add(placement_item(current), 1)
        placements.delete(current)
        refresh_custom_placements(placements)
        return
      end
      return unless action == 0
    end
    same_kind_occupant = current && current["kind"] == kind
    if kind == "furniture" && furniture_placements(placements).length >= MAX_ARENA_FURNITURE && !same_kind_occupant
      pbMessage("Your arena has reached its furniture capacity.")
      return
    elsif kind == "trainer" && trainer_placements(placements).length >= MAX_ARENA_TRAINERS && !same_kind_occupant
      pbMessage("Your arena has reached its trainer capacity.")
      return
    end
    unless $bag.remove(selected[:item], 1)
      pbMessage("You have no more of that item in your Bag.")
      return
    end
    $bag.add(placement_item(current), 1) if current
    placements.delete(current) if current
    placements << { "kind" => kind, "item" => selected[:item].to_s, "x" => x, "y" => y }
    refresh_custom_placements(placements)
  end

  def edit_tile(placements, surface_edits, x, y)
    occupied = editor_occupied(placements, x, y)
    state = tile_surface_state(surface_edits, x, y)
    floor_label = state["floor"] == "void" ? "Make normal field" : "Make void"
    remove_label = occupied && occupied["kind"] == "trainer" ? "Kick trainer" : "Remove"
    actions = occupied ? ["Change ground type", remove_label, "Replace", floor_label,
                          "Done", "Validate edit", "Cancel custom mode"] :
                         ["Add object", "Add trainer", "Change ground type", floor_label,
                          "Done", "Validate edit", "Cancel custom mode"]
    status = state["floor"] == "void" ? "Void tile." : "Field tile: #{SURFACE_NAMES[state['ground']]}."
    choice = pbMessage("#{status} Tile (#{x}, #{y}).", actions, -1)
    return :commit if choice == 5
    return :cancel if choice == 6
    return :continue if choice == 4
    if choice == 3
      if state["floor"] == "field" && (occupied || fixed_event_tile?(x, y))
        pbMessage("Remove the occupant or move the arena event before making this tile void.")
        return :continue
      end
      state["floor"] = state["floor"] == "void" ? "field" : "void"
      state["ground"] = "plain" if state["floor"] == "field"
      surface_edits[tile_edit_key(x, y)] = state
      apply_tile_surface($game_map, x, y, state)
      return :continue
    elsif (occupied && choice == 0) || (!occupied && choice == 2)
      options = surface_options
      labels = options.map(&:first) + ["Cancel"]
      selected = pbMessage("Choose a ground type for tile (#{x}, #{y}).", labels, -1)
      if selected >= 0 && selected < options.length
        state["floor"] = "field"
        state["ground"] = options[selected][1]
        surface_edits[tile_edit_key(x, y)] = state
        apply_tile_surface($game_map, x, y, state)
      end
      return :continue
    end
    if occupied
      if choice == 1
        $bag.add(placement_item(occupied), 1)
        placements.delete(occupied)
        refresh_custom_placements(placements)
      elsif choice == 2
        replace_placement(placements, occupied)
      end
    elsif choice == 0
      place_from_bag(placements, "furniture", x, y, surface_edits)
    elsif choice == 1
      place_from_bag(placements, "trainer", x, y, surface_edits)
    end
    return :continue
  end

  def place_from_bag(placements, kind, x, y, surface_edits = tile_edit_records)
    return unless valid_editor_tile?(x, y)
    if tile_surface_state(surface_edits, x, y)["floor"] == "void"
      pbMessage("Make this tile a normal field before placing an object or trainer.")
      return
    end
    if kind == "furniture" && furniture_placements(placements).length >= MAX_ARENA_FURNITURE
      pbMessage("Your arena has reached its furniture capacity.")
      return
    elsif kind == "trainer" && trainer_placements(placements).length >= MAX_ARENA_TRAINERS
      pbMessage("Your arena has reached its trainer capacity.")
      return
    end
    entries = bag_catalog(kind)
    if entries.empty?
      pbMessage(kind == "trainer" ? "Recruit a trainer from the arena guide first." :
                                      "There is no furniture in this Bag pocket.")
      return
    end
    entry = choose_catalog(entries, kind == "trainer" ? "Recruited trainers" : "Arena furniture")
    return unless entry
    return unless $bag.remove(entry[:item], 1)
    placements << { "kind" => kind, "item" => entry[:item].to_s,
                    "x" => x, "y" => y }
    refresh_custom_placements(placements)
  end

  def replace_placement(placements, old_placement)
    kind_choice = pbMessage("Replace with which Bag tab?", ["Arena furniture", "Recruited trainers", "Cancel"], -1)
    return unless kind_choice == 0 || kind_choice == 1
    kind = kind_choice == 0 ? "furniture" : "trainer"
    entries = bag_catalog(kind)
    if entries.empty?
      pbMessage(kind == "trainer" ? "Recruit a trainer first." : "There is no furniture in this Bag pocket.")
      return
    end
    entry = choose_catalog(entries, kind == "trainer" ? "Recruited trainers" : "Arena furniture")
    return unless entry
    return unless $bag.remove(entry[:item], 1)
    $bag.add(placement_item(old_placement), 1)
    index = placements.index(old_placement)
    placements[index] = { "kind" => kind, "item" => entry[:item].to_s,
                          "x" => old_placement["x"], "y" => old_placement["y"] }
    refresh_custom_placements(placements)
  end

  def bag_catalog(kind)
    if kind == "furniture"
      FURNITURE_STOCK.map do |item, data|
        next if !$bag.has?(item)
        { :item => item, :name => data[0], :sprite => data[1], :qty => $bag.quantity(item) }
      end.compact
    else
      TRAINER_PROFILES.map do |item, profile|
        next if !$bag.has?(item)
        { :item => item, :name => profile[:name], :sprite => profile[:sprite], :qty => $bag.quantity(item) }
      end.compact
    end
  end

  def choose_catalog(entries, title)
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 100_000
    commands = entries.map { |entry| "#{entry[:name]}  x#{entry[:qty]}" }
    window = ArenaCatalogWindow.new(entries, commands)
    window.viewport = viewport
    window.x = [(Graphics.width - window.width) / 2, 0].max
    window.y = [(Graphics.height - window.height) / 2, 0].max
    window.z = viewport.z + 1
    help = Window_UnformattedTextPokemon.newWithSize(title, 0, 0, Graphics.width, 72, viewport)
    help.z = viewport.z + 1
    result = nil
    loop do
      Graphics.update
      Input.update
      window.update
      pbUpdateSceneMap
      # Window_CommandPokemon handles directional movement in update. Do not
      # apply the same key a second time here or rows will skip/wrap.
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        result = entries[window.index]
        pbPlayDecisionSE
        break
      end
    end
    result
  ensure
    help&.dispose
    window&.dispose
    viewport&.dispose
  end

  def recruit_trainer
    return pbMessage("Trainers can only be recruited while your arena is offline.") if multiplayer?
    ensure_custom_inventory
    available = TRAINER_PROFILES.reject do |item, _profile|
      $bag.has?(item) || trainer_placements.any? { |placement| placement_item(placement) == item }
    end
    if available.empty?
      pbMessage("You have already recruited every trainer available here.")
      return
    end
    entries = available.map do |item, profile|
      { :item => item, :name => profile[:name], :sprite => profile[:sprite], :qty => 1 }
    end
    entry = choose_catalog(entries, "Choose a trainer to recruit")
    return unless entry
    $bag.add(entry[:item], 1)
    pbMessage("#{entry[:name]} joined your arena staff!")
  end

  def challenge_recruited_trainer(slot)
    return unless $game_map && $game_map.map_id == MAP_ID
    return if $game_temp && $game_temp.in_battle
    placement = trainer_placements[slot]
    return unless placement
    profile = TRAINER_PROFILES[placement_item(placement)]
    return unless profile
    return pbMessage("You need a Pokemon able to battle first.") if !$player || $player.able_pokemon_count == 0
    return unless pbConfirmMessage("#{profile[:name]} is ready for a practice battle. Challenge them?")
    foe = NPCTrainer.new(profile[:name], profile[:type])
    foe.party = profile[:team].map { |species, level| Pokemon.new(species, level, foe) }
    TrainerBattle.start(foe)
  end

  def copy_tile_edits(records)
    return {} unless records.is_a?(Hash)
    records.each_with_object({}) do |(key, value), copy|
      copy[key] = value.dup if value.is_a?(Hash)
    end
  end

  def editor_zoom_key?
    Input.respond_to?(:triggerex?) && Input.triggerex?(:U)
  end

  def draw_global_overview(bitmap, surface_edits, placements)
    colors = {
      "void" => Color.new(14, 20, 31),
      "plain" => Color.new(126, 137, 143),
      "grass" => Color.new(64, 151, 78),
      "desert" => Color.new(207, 157, 75),
      "ice" => Color.new(100, 187, 220),
      "rock" => Color.new(115, 117, 125)
    }
    bitmap.clear
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        state = tile_surface_state(surface_edits, x, y)
        key = state["floor"] == "void" ? "void" : state["ground"]
        bitmap.fill_rect(x * 2, y * 2, 2, 2, colors[key] || colors["plain"])
      end
    end
    # Subtle ten-tile guides make large edits easier to orient, while a bright
    # outline shows the original 25x25 building footprint without fragmenting
    # every tile into a noisy checkerboard.
    grid = Color.new(34, 43, 57)
    0.step(MAP_WIDTH, 10) do |tile|
      bitmap.fill_rect(tile * 2, 0, 1, MAP_HEIGHT * 2, grid) if tile < MAP_WIDTH
      bitmap.fill_rect(0, tile * 2, MAP_WIDTH * 2, 1, grid) if tile < MAP_HEIGHT
    end
    field_border = Color.new(249, 225, 139)
    field_left = INITIAL_FIELD_X * 2
    field_top = INITIAL_FIELD_Y * 2
    field_size = INITIAL_FIELD_SIZE * 2
    bitmap.fill_rect(field_left, field_top, field_size, 2, field_border)
    bitmap.fill_rect(field_left, field_top + field_size - 2, field_size, 2, field_border)
    bitmap.fill_rect(field_left, field_top, 2, field_size, field_border)
    bitmap.fill_rect(field_left + field_size - 2, field_top, 2, field_size, field_border)
    placements.each do |placement|
      color = placement["kind"] == "trainer" ? Color.new(255, 96, 120) : Color.new(255, 236, 88)
      bitmap.fill_rect(placement["x"] * 2, placement["y"] * 2, 2, 2, color)
    end
  end

  def set_editor_zoom(index, cursor, marker, overview_marker, overview,
                      map_viewport, surface_edits, placements)
    renderer = $scene.map_renderer if $scene && $scene.respond_to?(:map_renderer)
    if index == 2
      renderer.arena_demo_set_zoom(1.0) if renderer && renderer.respond_to?(:arena_demo_set_zoom)
      map_viewport.visible = false
      overview.visible = true
      overview_scale = [Graphics.width * 0.9,
                        Graphics.height * 0.9].min / [MAP_WIDTH * 2, MAP_HEIGHT * 2].max
      overview.zoom_x = overview_scale
      overview.zoom_y = overview_scale
      overview.x = (Graphics.width - overview.bitmap.width * overview.zoom_x) / 2
      overview.y = (Graphics.height - overview.bitmap.height * overview.zoom_y) / 2
      draw_global_overview(overview.bitmap, surface_edits, placements)
      marker.visible = false
      overview_marker.zoom_x = overview.zoom_x / 3.0
      overview_marker.zoom_y = overview.zoom_y / 3.0
      overview_marker.x = overview.x + cursor[0] * 2 * overview.zoom_x
      overview_marker.y = overview.y + cursor[1] * 2 * overview.zoom_y
      overview_marker.visible = true
    else
      scale = index == 1 ? 0.5 : 1.0
      map_viewport.visible = true
      overview.visible = false
      overview_marker.visible = false
      marker.visible = true
      renderer.arena_demo_set_zoom(scale) if renderer && renderer.respond_to?(:arena_demo_set_zoom)
      center_camera_on(cursor[0], cursor[1], scale)
      marker.zoom_x = scale
      marker.zoom_y = scale
      marker.x = (Graphics.width / 2) - (Game_Map::TILE_WIDTH * scale / 2)
      marker.y = (Graphics.height / 2) - (Game_Map::TILE_HEIGHT * scale / 2)
    end
  end

  def editor_dialog(viewport, map_viewport, global_view)
    unless global_view
      viewport.visible = false
      map_viewport.visible = true
    end
    yield
  ensure
    unless global_view
      viewport.visible = true
      map_viewport.visible = true
    end
  end

  def reset_editor_zoom(map_viewport)
    renderer = $scene.map_renderer if $scene && $scene.respond_to?(:map_renderer)
    renderer.arena_demo_set_zoom(1.0) if renderer && renderer.respond_to?(:arena_demo_set_zoom)
    map_viewport.visible = true
  end

  def custom_mode
    player = original_player = original_camera = old_menu_state = nil
    menu_state_captured = false
    viewport = marker = overview_marker = overview = nil
    original_surface_edits = draft_surface_edits = nil
    map_viewport = nil
    return pbMessage("Custom mode is available only while your arena is offline.") if multiplayer?
    return unless $game_map && $game_map.map_id == MAP_ID
    ensure_custom_inventory
    original = custom_placements.map(&:dup)
    draft = original.map(&:dup)
    original_surface_edits = copy_tile_edits(tile_edit_records)
    draft_surface_edits = copy_tile_edits(original_surface_edits)
    @editor_surface_edits = draft_surface_edits
    apply_tile_edits($game_map, draft_surface_edits)
    player = $game_player
    original_player = [player.x, player.y, player.direction, player.transparent, player.through]
    original_camera = [$game_map.display_x, $game_map.display_y]
    cursor = [player.x, player.y]
    old_menu_state = $game_temp.in_menu
    menu_state_captured = true
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    # Essentials message windows use z=99999. Keep the overview behind them so
    # text and command prompts remain readable at the farthest zoom.
    viewport.z = 99_998
    marker = Sprite.new(viewport)
    marker.bitmap = Bitmap.new(Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
    marker.bitmap.fill_rect(0, 0, Game_Map::TILE_WIDTH, 3, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(0, Game_Map::TILE_HEIGHT - 3, Game_Map::TILE_WIDTH, 3, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(0, 0, 3, Game_Map::TILE_HEIGHT, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(Game_Map::TILE_WIDTH - 3, 0, 3, Game_Map::TILE_HEIGHT, Color.new(255, 220, 64, 255))
    overview_marker = Sprite.new(viewport)
    overview_marker.bitmap = Bitmap.new(6, 6)
    cursor_shadow = Color.new(10, 18, 24, 255)
    cursor_highlight = Color.new(255, 250, 196, 255)
    overview_marker.bitmap.fill_rect(0, 0, 6, 1, cursor_shadow)
    overview_marker.bitmap.fill_rect(0, 5, 6, 1, cursor_shadow)
    overview_marker.bitmap.fill_rect(0, 0, 1, 6, cursor_shadow)
    overview_marker.bitmap.fill_rect(5, 0, 1, 6, cursor_shadow)
    overview_marker.bitmap.fill_rect(1, 1, 4, 1, cursor_highlight)
    overview_marker.bitmap.fill_rect(1, 4, 4, 1, cursor_highlight)
    overview_marker.bitmap.fill_rect(1, 1, 1, 4, cursor_highlight)
    overview_marker.bitmap.fill_rect(4, 1, 1, 4, cursor_highlight)
    overview_marker.z = viewport.z + 2
    overview_marker.visible = false
    overview = Sprite.new(viewport)
    overview.bitmap = Bitmap.new(MAP_WIDTH * 2, MAP_HEIGHT * 2)
    overview.visible = false
    marker.z = viewport.z + 1
    overview.z = viewport.z
    map_viewport = $scene.map_renderer.viewport
    map_viewport.visible = true
    player.transparent = true
    player.through = true
    $game_temp.in_menu = true
    refresh_custom_placements(draft)
    editor_dialog(viewport, map_viewport, false) do
      pbMessage("Choose a tile with the arrows. Press U to change zoom. Press Enter to choose ground, trainer, or furniture mode, then Enter on tiles to apply it. Press X to leave the mode or finish editing.")
    end
    zoom_index = 0
    active_tool = nil
    reset_editor_zoom(map_viewport)
    draw_global_overview(overview.bitmap, draft_surface_edits, draft)
    result = :cancel
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      moved = false
      if Input.repeat?(Input::UP)
        cursor[1] -= 1
        moved = true
      elsif Input.repeat?(Input::DOWN)
        cursor[1] += 1
        moved = true
      elsif Input.repeat?(Input::LEFT)
        cursor[0] -= 1
        moved = true
      elsif Input.repeat?(Input::RIGHT)
        cursor[0] += 1
        moved = true
      end
      if moved
        cursor[0] = [[cursor[0], 0].max, MAP_WIDTH - 1].min
        cursor[1] = [[cursor[1], 0].max, MAP_HEIGHT - 1].min
        center_camera_on(cursor[0], cursor[1], (zoom_index == 1 ? 0.5 : 1.0)) if zoom_index != 2
      end
      if zoom_index == 2
        overview_marker.x = overview.x + cursor[0] * 2 * overview.zoom_x
        overview_marker.y = overview.y + cursor[1] * 2 * overview.zoom_y
      else
        scale = zoom_index == 1 ? 0.5 : 1.0
        tile_x = cursor[0] * Game_Map::TILE_WIDTH - ($game_map.display_x / Game_Map::X_SUBPIXELS)
        tile_y = cursor[1] * Game_Map::TILE_HEIGHT - ($game_map.display_y / Game_Map::Y_SUBPIXELS)
        marker.x = tile_x * scale
        marker.y = tile_y * scale
      end
      if editor_zoom_key?
        zoom_index = (zoom_index + 1) % 3
        set_editor_zoom(zoom_index, cursor, marker, overview_marker, overview,
                        map_viewport, draft_surface_edits, draft)
      end
      if Input.trigger?(Input::USE)
        unless editor_selectable_tile?(cursor[0], cursor[1])
          pbMessage("This tile can't be edited right now.")
          next
        end
        editor_dialog(viewport, map_viewport, zoom_index == 2) do
          if active_tool.nil?
            mode = editor_choose_mode
            if mode == :ground
              selected = editor_choose_ground
              if selected
                active_tool = { :kind => :ground, :selection => selected }
                label = selected[:floor] == "void" ? "void" : SURFACE_NAMES[selected[:ground]]
                pbMessage("Painting #{label}. Move with the arrows and press Enter on each tile. Press X to choose another mode.")
              end
            elsif mode == :trainer || mode == :furniture
              selected = editor_choose_placement(mode.to_s, draft)
              if selected
                active_tool = { :kind => mode, :selection => selected }
                label = selected[:action] == :remove ? "removing #{mode}s" : "placing #{selected[:name]}"
                pbMessage("#{label}. Move with the arrows and press Enter on each tile. Press X to choose another mode.")
              end
            end
          elsif active_tool[:kind] == :ground
            editor_apply_ground(draft_surface_edits, draft, cursor[0], cursor[1], active_tool[:selection])
          else
            editor_apply_placement(draft, draft_surface_edits, active_tool[:kind].to_s,
                                   active_tool[:selection], cursor[0], cursor[1])
          end
        end
        draw_global_overview(overview.bitmap, draft_surface_edits, draft)
      elsif (Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)) && active_tool
        active_tool = nil
        editor_dialog(viewport, map_viewport, zoom_index == 2) do
          pbMessage("Edit mode closed. Choose another category with Enter.")
        end
      elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        choice = editor_dialog(viewport, map_viewport, zoom_index == 2) do
          pbMessage("Finish custom mode?", ["Validate and save", "Cancel all edits", "Keep editing"], -1)
        end
        if choice == 0
          result = :commit
          break
        elsif choice == 1
          result = :cancel
          break
        end
      end
    end
    viewport.visible = false
    map_viewport.visible = true
    if result == :commit
      restore_editor_player(player, original_player, original_camera, old_menu_state)
      previous = $PokemonGlobal.arena_demo_placements
      previous_surface_edits = $PokemonGlobal.arena_demo_tile_edits
      $PokemonGlobal.arena_demo_placements = draft.map(&:dup)
      $PokemonGlobal.arena_demo_tile_edits = copy_tile_edits(draft_surface_edits)
      refresh_custom_placements
      unless Game.save
        $PokemonGlobal.arena_demo_placements = previous
        $PokemonGlobal.arena_demo_tile_edits = previous_surface_edits
        apply_tile_edits($game_map, original_surface_edits)
        reconcile_editor_inventory(original, draft)
        refresh_custom_placements
        pbMessage("The edit could not be saved. Your previous arena layout was restored.")
      else
        pbMessage("Arena custom mode saved.")
      end
    else
      $PokemonGlobal.arena_demo_placements = original
      apply_tile_edits($game_map, original_surface_edits)
      refresh_custom_placements
      # Reconcile the Bag pocket to the saved placements, preserving recruited
      # stock that was already available when the edit started.
      reconcile_editor_inventory(original, draft)
      pbMessage("Custom mode cancelled. Your previous arena was restored.") if draft != original
    end
  rescue StandardError => error
    if original && draft && $PokemonGlobal
      $PokemonGlobal.arena_demo_placements = original
      $PokemonGlobal.arena_demo_tile_edits = original_surface_edits if original_surface_edits
      apply_tile_edits($game_map, original_surface_edits) if original_surface_edits
      reconcile_editor_inventory(original, draft)
      refresh_custom_placements
    end
    viewport.visible = false if viewport
    map_viewport.visible = true if map_viewport
    pbMessage("Custom mode closed safely: #{error.message}")
  ensure
    @editor_surface_edits = nil
    reset_editor_zoom(map_viewport) if map_viewport
    restore_editor_player(player, original_player, original_camera, old_menu_state) if menu_state_captured
    overview.bitmap.dispose if overview && overview.bitmap && !overview.bitmap.disposed?
    overview&.dispose
    overview_marker.bitmap.dispose if overview_marker && overview_marker.bitmap && !overview_marker.bitmap.disposed?
    overview_marker&.dispose
    marker.bitmap.dispose if marker && marker.bitmap && !marker.bitmap.disposed?
    marker&.dispose
    viewport&.dispose
  end

  def center_camera_on(x, y, zoom = 1.0)
    center_x = x * Game_Map::TILE_WIDTH + Game_Map::TILE_WIDTH / 2
    center_y = y * Game_Map::TILE_HEIGHT + Game_Map::TILE_HEIGHT / 2
    $game_map.display_x = ((center_x - Graphics.width / (2.0 * zoom)) * Game_Map::X_SUBPIXELS).round
    $game_map.display_y = ((center_y - Graphics.height / (2.0 * zoom)) * Game_Map::Y_SUBPIXELS).round
  end

  def restore_editor_player(player, position, camera, menu_state)
    if player && position
      player.transparent = position[3]
      player.through = position[4]
      player.moveto(position[0], position[1])
      player.turn_down if position[2] == 2
      player.turn_left if position[2] == 4
      player.turn_right if position[2] == 6
      player.turn_up if position[2] == 8
    end
    if $game_map && camera
      $game_map.display_x = camera[0]
      $game_map.display_y = camera[1]
    end
    $game_temp.in_menu = menu_state if $game_temp
  end

  def reconcile_editor_inventory(original, draft)
    return unless $bag
    original_counts = Hash.new(0)
    draft_counts = Hash.new(0)
    original.each { |placement| original_counts[placement_item(placement)] += 1 }
    draft.each { |placement| draft_counts[placement_item(placement)] += 1 }
    (original_counts.keys | draft_counts.keys).each do |item|
      difference = draft_counts[item] - original_counts[item]
      $bag.add(item, difference) if difference > 0
      $bag.remove(item, -difference) if difference < 0
    end
  end
end

class ArenaCatalogWindow < Window_CommandPokemon
  @@arena_sprite_bitmaps = {}

  def initialize(entries, commands)
    @entries = entries
    super(commands, 360)
    self.rowHeight = 56
    resizeToFit(commands, 360)
    refresh
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    entry = @entries[index]
    path = entry[:sprite] ? "Graphics/Characters/#{entry[:sprite]}" : nil
    if path && pbResolveBitmap(path)
      bitmap = @@arena_sprite_bitmaps[entry[:sprite]]
      if !bitmap || bitmap.disposed?
        bitmap = RPG::Cache.load_bitmap("Graphics/Characters/", entry[:sprite])
        @@arena_sprite_bitmaps[entry[:sprite]] = bitmap
      end
      frame_width = [bitmap.width / 4, 32].min
      frame_height = bitmap.height / 4
      contents.blt(rect.x + 8, rect.y + 2, bitmap,
                   Rect.new(frame_width, 0, frame_width, frame_height))
    end
    pbDrawShadowText(contents, rect.x + 54,
                     rect.y + (contents.text_offset_y || 0),
                     rect.width - 54, rect.height,
                     @commands[index], baseColor, shadowColor)
  end
end

class PokemonGlobalMetadata
  attr_accessor :arena_demo_placements
  attr_accessor :arena_custom_stock_added
  attr_accessor :arena_demo_tile_edits
  attr_accessor :arena_demo_centered_layout_migrated
  attr_accessor :arena_demo_centered_layout_migration_version
  attr_accessor :arena_demo_void_recovery_version
end

if defined?(Settings)
  module ArenaDemo::ExtraBagPockets
    def bag_pocket_names
      names = super
      [names[0], names[1], names[2], names[3], names[4], names[7],
       _INTL("Arena Furniture"), _INTL("Recruited Trainers")]
    end
  end
  Settings.singleton_class.prepend(ArenaDemo::ExtraBagPockets)
end

# Keep the original item data intact while routing retired Mail and Battle
# Items pockets into Items in the Bag UI.
if defined?(GameData::Item)
  module ArenaDemo::RemappedItemPockets
    def pocket
      return ArenaDemo::FURNITURE_POCKET if ArenaDemo::FURNITURE_STOCK.key?(@id)
      return ArenaDemo::TRAINER_POCKET if ArenaDemo::TRAINER_PROFILES.key?(@id)
      raw_pocket = super
      return 1 if raw_pocket == 6 || raw_pocket == 7
      return 6 if raw_pocket == 8
      raw_pocket
    end
  end
  GameData::Item.prepend(ArenaDemo::RemappedItemPockets)
end

if defined?(PokemonBag)
  module ArenaDemo::BagPocketSizing
    def initialize(*args)
      super
      ArenaDemo.ensure_bag_pockets(self, true)
    end

    def last_viewed_index(pocket)
      ArenaDemo.ensure_bag_pockets(self)
      super
    end
  end
  PokemonBag.prepend(ArenaDemo::BagPocketSizing)
end

if defined?(PokemonBag_Scene)
  module ArenaDemo::BagTabDisplay
    def pbStartScene(bag, *args)
      ArenaDemo.ensure_bag_pockets(bag)
      ArenaDemo.ensure_custom_inventory if bag.equal?($bag)
      super
      width = [186, 12 + PokemonBag.pocket_count * 22].max
      icon = @sprites["pocketicon"]
      if icon && icon.bitmap.width < width
        replacement = BitmapSprite.new(width, icon.bitmap.height, @viewport)
        replacement.x, replacement.y, replacement.z = icon.x, icon.y, icon.z
        icon.dispose
        @sprites["pocketicon"] = replacement
        pbRefresh
      end
    end

    def pbRefresh
      pocket = @bag.last_viewed_pocket
      if pocket >= 9
        @bag.last_viewed_pocket = 8
        begin
          super
        ensure
          @bag.last_viewed_pocket = pocket
        end
        pbRefreshIndexChanged
      else
        super
      end
      return if !@sprites["pocketicon"]
      icon = @sprites["pocketicon"]
      return if icon.bitmap.width < 12 + PokemonBag.pocket_count * 22
      source = @pocketbitmap.bitmap
      pocket = @sprites["itemlist"].pocket
      if pocket >= 9
        icon.bitmap.clear
        other_pocket = pocket == 9 ? 10 : 9
        icon.bitmap.blt(6 + ((other_pocket - 1) * 22), 6, source, Rect.new(140, 28, 20, 20))
        icon.bitmap.blt(2 + ((pocket - 1) * 22), 2, source, Rect.new(196, 0, 28, 28))
      end
    end
  end
  PokemonBag_Scene.prepend(ArenaDemo::BagTabDisplay)
end

if defined?(GameData::Item)
  ArenaDemo.register_bag_items
end

if defined?(GameData)
  module ArenaDemo::RegisterCustomItemsAfterLoad
    def load_all(*args)
      result = super
      ArenaDemo.register_bag_items
      result
    end
  end
  GameData.singleton_class.prepend(ArenaDemo::RegisterCustomItemsAfterLoad)
end

module ArenaDemo::CustomModeRefresh
  def refresh_objects
    super
    [3, 4, 5, 6, 7, 8].each do |id|
      event = $game_map.events[id]
      next unless event
      event.transparent = true
      event.through = true
    end
    ArenaDemo.refresh_custom_placements
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeRefresh)

module ArenaDemo::CustomModeReception
  def arena_reception
    if multiplayer?
      pbMessage("Custom mode and trainer recruitment are available offline. I can still heal your team.")
      heal_team if pbConfirmMessage("Would you like me to heal your team?")
      return
    end
    ArenaDemo.ensure_custom_inventory
    loop do
      choice = pbMessage("Welcome to your arena. What would you like to do?",
                         ["Custom mode", "Recruit a trainer", "Heal my team", "Back"], -1)
      case choice
      when 0 then ArenaDemo.custom_mode
      when 1 then ArenaDemo.recruit_trainer
      when 2 then heal_team
      else break
      end
    end
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeReception)

module ArenaDemo::FreezePlayerInEditor
  def update(*args)
    return if ArenaDemo.instance_variable_get(:@custom_mode_active)
    super
  end
end
Game_Player.prepend(ArenaDemo::FreezePlayerInEditor) if defined?(Game_Player)

if defined?(Game_Map)
  module ArenaDemo::VoidTileCollision
    def passable?(x, y, direction, self_event = nil)
      if @map_id == ArenaDemo::MAP_ID
        offsets = { 1 => [-1, 1], 2 => [0, 1], 3 => [1, 1],
                    4 => [-1, 0], 6 => [1, 0],
                    7 => [-1, -1], 8 => [0, -1], 9 => [1, -1] }
        offset = offsets[direction]
        return false if offset && ArenaDemo.tile_is_void?(x + offset[0], y + offset[1])
      end
      super
    end

    def passableStrict?(x, y, direction, self_event = nil)
      return false if @map_id == ArenaDemo::MAP_ID && ArenaDemo.tile_is_void?(x, y)
      super
    end

    def terrain_tag(x, y, count_bridge = false)
      if @map_id == ArenaDemo::MAP_ID
        state = ArenaDemo.tile_surface_state(ArenaDemo.tile_edit_records, x, y)
        terrain_id = ArenaDemo::SURFACE_TAGS[state["ground"]]
        return GameData::TerrainTag.get(terrain_id) if state["floor"] == "field" && terrain_id
      end
      super
    end

    def setup(map_id)
      result = super
      ArenaDemo.recover_centered_arena_state(self) if map_id == ArenaDemo::MAP_ID
      result
    end
  end
  Game_Map.prepend(ArenaDemo::VoidTileCollision)
end

if defined?(Game) && Game.respond_to?(:load)
  module ArenaDemo::SavedArenaRecovery
    def load(*args)
      result = super
      ArenaDemo.reload_saved_arena_map_from_data
      result
    end
  end
  Game.singleton_class.prepend(ArenaDemo::SavedArenaRecovery)
end

if defined?(TilemapRenderer)
  module ArenaDemo::EditorTilemapZoom
    def arena_demo_set_zoom(scale)
      scale = scale.to_f
      @arena_demo_base_columns ||= @tiles_horizontal_count
      @arena_demo_base_rows ||= @tiles_vertical_count
      target_columns = [@arena_demo_base_columns,
                        (Graphics.width.to_f / (Game_Map::TILE_WIDTH * scale)).ceil + 2].max
      target_rows = [@arena_demo_base_rows,
                     (Graphics.height.to_f / (Game_Map::TILE_HEIGHT * scale)).ceil + 2].max
      while @tiles.length > target_columns
        @tiles.pop.each { |coord| coord.each(&:dispose) }
      end
      while @tiles.length < target_columns
        @tiles << Array.new(@tiles_vertical_count) do
          Array.new(3) { TilemapRenderer::TileSprite.new(@viewport) }
        end
      end
      @tiles.each do |column|
        while column.length > target_rows
          column.pop.each(&:dispose)
        end
        while column.length < target_rows
          column << Array.new(3) { TilemapRenderer::TileSprite.new(@viewport) }
        end
      end
      @tiles_horizontal_count = target_columns
      @tiles_vertical_count = target_rows
      @arena_demo_zoom_scale = scale
      ArenaDemo.instance_variable_set(:@editor_zoom_scale, scale)
      @tiles.each do |column|
        column.each do |coord|
          coord.each do |tile|
            tile.tone = @tone.clone
            tile.color = @color.clone
            tile.need_refresh = true
          end
        end
      end
      @need_refresh = true
    end

    def refresh_tile_coordinates(tile, x, y)
      scale = @arena_demo_zoom_scale || 1.0
      tile.x = ((x * TilemapRenderer::DISPLAY_TILE_WIDTH) - @pixel_offset_x) * scale
      tile.y = ((y * TilemapRenderer::DISPLAY_TILE_HEIGHT) - @pixel_offset_y) * scale
      tile.zoom_x = TilemapRenderer::ZOOM_X * scale
      tile.zoom_y = TilemapRenderer::ZOOM_Y * scale
    end

    def refresh_tile(tile, x, y, map, layer, tile_id)
      super
      if map.map_id == ArenaDemo::MAP_ID && layer == 0 && tile_id.to_i >= 48 &&
         !ArenaDemo.instance_variable_get(:@floor_renderer_diagnostic_written)
        ArenaDemo.instance_variable_set(:@floor_renderer_diagnostic_written, true)
        bitmap = tile.bitmap
        File.open(File.join("Data", "ArenaFloorDiagnostic.txt"), "a") do |file|
          file.puts "renderer_tile_id=#{tile_id} file=#{tile.filename.inspect} visible=#{tile.visible} bitmap=#{bitmap && [bitmap.width, bitmap.height].inspect} src=#{tile.src_rect.inspect}"
        end
      end
      return unless map.map_id == ArenaDemo::MAP_ID && layer == 0
      map_display_x = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      map_display_y = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      map_display_x = ((map_display_x + (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) -
                      (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
      map_display_y = ((map_display_y + (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) -
                      (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
      map_x = x + map_display_x / TilemapRenderer::DISPLAY_TILE_WIDTH
      map_y = y + map_display_y / TilemapRenderer::DISPLAY_TILE_HEIGHT
      state = ArenaDemo.tile_surface_state(ArenaDemo.surface_records_for_render, map_x, map_y)
      return unless state["floor"] == "field" && state["ground"] == "ice"
      tile.bitmap = ArenaDemo.ice_surface_bitmap
      tile.src_rect = Rect.new(0, 0, Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
      tile.animated = false
      tile.is_autotile = false
      tile.filename = ""
    end
  end
  TilemapRenderer.prepend(ArenaDemo::EditorTilemapZoom)
end

if defined?(Sprite_Character)
  module ArenaDemo::EditorCharacterZoom
    def update(*args)
      super
      scale = ArenaDemo.instance_variable_get(:@editor_zoom_scale) || 1.0
      self.x *= scale
      self.y *= scale
      self.zoom_x = TilemapRenderer::ZOOM_X * scale
      self.zoom_y = TilemapRenderer::ZOOM_Y * scale
    end
  end
  Sprite_Character.prepend(ArenaDemo::EditorCharacterZoom)
end

module ArenaDemo::CustomModeFlag
  def custom_mode
    ArenaDemo.instance_variable_set(:@custom_mode_active, true)
    super
  ensure
    ArenaDemo.instance_variable_set(:@custom_mode_active, false)
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeFlag)

# The desktop launcher sets this flag so an existing local save opens directly
# into the game. This avoids leaving the player at a black title transition
# where they believe another Enter press is needed. New installs still see the
# normal title menu because there is no save to continue.
if defined?(PokemonLoadScreen)
  module ArenaDemo::AutoContinueExistingSave
    def pbStartLoadScreen
      if ENV["ARENA_AUTO_CONTINUE"] == "1" && @save_data && !@save_data.empty?
        Game.load(@save_data)
        return
      end
      super
    end
  end
  PokemonLoadScreen.prepend(ArenaDemo::AutoContinueExistingSave)
end
