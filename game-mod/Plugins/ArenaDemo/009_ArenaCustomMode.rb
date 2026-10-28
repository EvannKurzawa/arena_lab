# Offline, tile-by-tile arena editor and its two dedicated Bag pockets.
module ArenaDemo
  FURNITURE_POCKET = 7
  TRAINER_POCKET = 8
  FURNITURE_SLOT_BASE = 200
  TRAINER_SLOT_BASE = 300
  MAX_ARENA_FURNITURE = 80
  MAX_ARENA_TRAINERS = 16
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

  def valid_editor_tile?(x, y)
    return false unless x.is_a?(Integer) && y.is_a?(Integer)
    return false unless x.between?(1, 23) && y.between?(1, 17)
    return false if [[10, 16], [12, 4], [12, 17]].include?([x, y])
    return false if $game_player && [$game_player.x, $game_player.y] == [x, y]
    return false if defined?(Visits) && Visits.locked?
    true
  end

  def editor_occupied(placements, x, y)
    placements.find { |placement| placement["x"] == x && placement["y"] == y }
  end

  def edit_tile(placements, x, y)
    occupied = editor_occupied(placements, x, y)
    remove_label = occupied && occupied["kind"] == "trainer" ? "Kick trainer" : "Remove"
    actions = occupied ? [remove_label, "Replace", "Validate edit", "Cancel custom mode"] :
                          ["Add object", "Add trainer", "Validate edit", "Cancel custom mode"]
    choice = pbMessage(occupied ? "This tile has an arena occupant." : "This tile is empty.", actions, -1)
    return :commit if choice == 2
    return :cancel if choice == 3
    if occupied
      if choice == 0
        $bag.add(placement_item(occupied), 1)
        placements.delete(occupied)
        refresh_custom_placements(placements)
      elsif choice == 1
        replace_placement(placements, occupied)
      end
    elsif choice == 0
      place_from_bag(placements, "furniture", x, y)
    elsif choice == 1
      place_from_bag(placements, "trainer", x, y)
    end
    return :continue
  end

  def place_from_bag(placements, kind, x, y)
    return unless valid_editor_tile?(x, y)
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
      if Input.repeat?(Input::UP)
        window.index = (window.index - 1) % entries.length
      elsif Input.repeat?(Input::DOWN)
        window.index = (window.index + 1) % entries.length
      elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
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
    return if multiplayer?
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

  def custom_mode
    player = original_player = original_camera = old_menu_state = nil
    menu_state_captured = false
    viewport = marker = help = nil
    return pbMessage("Custom mode is available only while your arena is offline.") if multiplayer?
    return unless $game_map && $game_map.map_id == MAP_ID
    ensure_custom_inventory
    original = custom_placements.map(&:dup)
    draft = original.map(&:dup)
    player = $game_player
    original_player = [player.x, player.y, player.direction, player.transparent, player.through]
    original_camera = [$game_map.display_x, $game_map.display_y]
    cursor = [player.x, player.y]
    old_menu_state = $game_temp.in_menu
    menu_state_captured = true
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 100_000
    marker = Sprite.new(viewport)
    marker.bitmap = Bitmap.new(Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
    marker.bitmap.fill_rect(0, 0, Game_Map::TILE_WIDTH, 3, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(0, Game_Map::TILE_HEIGHT - 3, Game_Map::TILE_WIDTH, 3, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(0, 0, 3, Game_Map::TILE_HEIGHT, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(Game_Map::TILE_WIDTH - 3, 0, 3, Game_Map::TILE_HEIGHT, Color.new(255, 220, 64, 255))
    help = Window_UnformattedTextPokemon.newWithSize(
      "Custom mode  |  Arrows: select tile  |  Z/Enter: edit  |  X/Esc: finish",
      0, 0, Graphics.width, 64, viewport
    )
    help.z = viewport.z + 1
    player.transparent = true
    player.through = true
    $game_temp.in_menu = true
    refresh_custom_placements(draft)
    pbMessage("Choose a tile with the arrow keys. Select it to add, remove or replace an occupant. Validate to save, or cancel to discard all edits.")
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
        cursor[0] = [[cursor[0], 1].max, 23].min
        cursor[1] = [[cursor[1], 1].max, 17].min
        center_camera_on(cursor[0], cursor[1])
      end
      marker.x = cursor[0] * Game_Map::TILE_WIDTH - ($game_map.display_x / Game_Map::X_SUBPIXELS)
      marker.y = cursor[1] * Game_Map::TILE_HEIGHT - ($game_map.display_y / Game_Map::Y_SUBPIXELS)
      if Input.trigger?(Input::USE)
        if !valid_editor_tile?(cursor[0], cursor[1]) && !editor_occupied(draft, cursor[0], cursor[1])
          pbMessage("This is a reserved arena tile. Choose an open floor tile.")
          next
        end
        action = edit_tile(draft, cursor[0], cursor[1])
        if action == :commit
          result = :commit
          break
        elsif action == :cancel
          result = :cancel
          break
        end
      elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        choice = pbMessage("Finish custom mode?", ["Validate and save", "Cancel all edits", "Keep editing"], -1)
        if choice == 0
          result = :commit
          break
        elsif choice == 1
          result = :cancel
          break
        end
      end
    end
    if result == :commit
      restore_editor_player(player, original_player, original_camera, old_menu_state)
      previous = $PokemonGlobal.arena_demo_placements
      $PokemonGlobal.arena_demo_placements = draft.map(&:dup)
      refresh_custom_placements
      unless Game.save
        $PokemonGlobal.arena_demo_placements = previous
        reconcile_editor_inventory(original, draft)
        refresh_custom_placements
        pbMessage("The edit could not be saved. Your previous arena layout was restored.")
      else
        pbMessage("Arena custom mode saved.")
      end
    else
      $PokemonGlobal.arena_demo_placements = original
      refresh_custom_placements
      # Reconcile the Bag pocket to the saved placements, preserving recruited
      # stock that was already available when the edit started.
      reconcile_editor_inventory(original, draft)
      pbMessage("Custom mode cancelled. Your previous arena was restored.") if draft != original
    end
  rescue StandardError => error
    if original && draft && $PokemonGlobal
      $PokemonGlobal.arena_demo_placements = original
      reconcile_editor_inventory(original, draft)
      refresh_custom_placements
    end
    pbMessage("Custom mode closed safely: #{error.message}")
  ensure
    restore_editor_player(player, original_player, original_camera, old_menu_state) if menu_state_captured
    help&.dispose
    marker.bitmap.dispose if marker && marker.bitmap && !marker.bitmap.disposed?
    marker&.dispose
    viewport&.dispose
  end

  def center_camera_on(x, y)
    center_x = x * Game_Map::TILE_WIDTH + Game_Map::TILE_WIDTH / 2
    center_y = y * Game_Map::TILE_HEIGHT + Game_Map::TILE_HEIGHT / 2
    $game_map.display_x = (center_x - Graphics.width / 2) * Game_Map::X_SUBPIXELS
    $game_map.display_y = (center_y - Graphics.height / 2) * Game_Map::Y_SUBPIXELS
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
    path = "Graphics/Characters/#{entry[:sprite]}"
    if pbResolveBitmap(path)
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
    return if multiplayer?
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

module ArenaDemo::CustomModeFlag
  def custom_mode
    ArenaDemo.instance_variable_set(:@custom_mode_active, true)
    super
  ensure
    ArenaDemo.instance_variable_set(:@custom_mode_active, false)
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeFlag)
