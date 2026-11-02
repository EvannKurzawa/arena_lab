# Runs only in tools/test-native-furniture.py's disposable copy of the game.
if defined?(Game) && ENV['ARENA_FURNITURE_PROBE']
module ArenaDemo::NativeFurnitureProbe
  def set_up_system
    path = ENV.fetch('ARENA_FURNITURE_PROBE')
    lines = []
    begin
      check = proc { |ok, label| raise("FAIL: #{label}") unless ok; lines << "PASS: #{label}" }
      SaveData.initialize_bootup_values
      SaveData.load_new_game_values
      $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
      $map_factory = PokemonMapFactory.new(100)
      $game_player.moveto(49, 53)
      ArenaDemo.ensure_custom_inventory
      national = GameData::Species.each_species.map(&:id)
      check.call(national.length == 650 && national.last == :DARKLUGIA && !national.include?(:PERRSERKER), 'national dex remains Gen 1-5 plus Dark Lugia')
      dependencies = Compiler.with_arena_species_dependencies { GameData::Species.each_species.map(&:id) }
      check.call(dependencies.include?(:PERRSERKER) && dependencies.length > 650, 'compiler retains internal post-Gen5 evolution dependencies')
      check.call(Thread.current[:arena_compiling_species].nil?, 'compiler scope restores national filter')
      check.call(!ArenaDemo::PokedexRoster.supported_form?(:MEOWTH, 2) && !ArenaDemo::PokedexRoster.supported_form?(:CHARIZARD, 1), 'Galarian and Mega forms excluded from playable roster')
      check.call(ArenaDemo::PokedexRoster.supported_form?(:GIRATINA, 1) && ArenaDemo::PokedexRoster.supported_form?(:KYUREM, 2) && ArenaDemo::PokedexRoster.supported_form?(:PICHU, 1), 'pre-Gen6 alternate forms remain available')
      meowth = Pokemon.new(:MEOWTH, 20)
      meowth.form = 2
      check.call(meowth.form == 0, 'Galarian Meowth cannot be selected')
      meowth.form_simple = 1
      meowth.forced_form = 2
      check.call(meowth.form == 0 && meowth.form_simple == 0, 'alternate form assignment paths obey Gen5 limit')
      kyurem = Pokemon.new(:KYUREM, 70)
      kyurem.form = 2
      check.call(kyurem.form == 2, 'Black Kyurem remains playable')
      check.call(ArenaDemo::BASIC_FURNITURE.length == 20, '20 additional furniture types')
      check.call(ArenaDemo::BASIC_FURNITURE.keys.all? { |item| $bag.quantity(item) == 2 }, 'fresh save receives two copies each')
      ArenaDemo.ensure_custom_inventory
      check.call(ArenaDemo::BASIC_FURNITURE.keys.all? { |item| $bag.quantity(item) == 2 }, 'reopening does not duplicate stock')
      Object.send(:define_method, :pbMessage) { |*| -1 }
      Object.send(:define_method, :pbUpdateSceneMap) { }
      records = ArenaDemo.tile_edit_records
      placements = ArenaDemo.custom_placements
      check.call(ArenaDemo.editor_apply_relief(records, [], 40, 40, 1), 'native platform fixture')
      sprites = []
      ArenaDemo::BASIC_FURNITURE.each_key.with_index do |item, i|
        x, y = 40 + i % 5 * 2, 40 + i / 5 * 3
        ArenaDemo.editor_apply_placement(placements, records, 'furniture', { item: item }, x, y)
        event = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE + i]
        check.call(event && event.instance_variable_get(:@arena_furniture_item) == item, "native placed event: #{item}")
        sprite = Sprite_Character.new(nil, event)
        sprite.update
        check.call(sprite.bitmap && [sprite.bitmap.width, sprite.bitmap.height] == [32, 64], "native graphic: #{item}")
        check.call([sprite.src_rect.x, sprite.src_rect.y, sprite.src_rect.width, sprite.src_rect.height] == [0, 0, 32, 64], "native frame: #{item}")
        check.call(!event.through && !event.walk_anime && event.width == 1 && event.height == 1, "solid static single-cell furniture: #{item}")
        sprites << sprite
      end
      check.call(placements.length == 20, 'all 20 furniture placements retained')
      first = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE]
      first_item = ArenaDemo::BASIC_FURNITURE.keys.first
      first.instance_variable_set(:@arena_furniture_item, nil)
      sprites.first.update
      first.instance_variable_set(:@arena_furniture_item, first_item)
      sprites.first.update
      check.call([sprites.first.bitmap.width, sprites.first.bitmap.height] == [32, 64], 'native sprite safely switches back from original obstacle art')
      check.call(!ArenaDemo.furniture_bitmap(first_item).disposed?, 'sprite changes never dispose shared preview artwork')
      if defined?(ArenaDemo::FieldObstacles)
        check.call(ArenaDemo::BASIC_FURNITURE.keys.none? { |item| ArenaDemo::FieldObstacles::MOVES.key?(item) }, 'new furniture does not acquire the original obstacle HM behavior')
      end
      payload = ArenaDemo.visit_snapshot_payload
      decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
      check.call(decoded && decoded[:placements] == placements, 'native visit snapshot round trip')
      check.call(Game.save('Data/furniture-probe-save.rxdata'), 'disposable save written')
      Game.load(SaveData.read_from_file('Data/furniture-probe-save.rxdata'))
      check.call(ArenaDemo.custom_placements == placements, 'native furniture survives save and load')
      # Actual native visual picker, controlled only by this probe's input shim.
      ArenaMaterialCatalogWindow.prepend(Module.new do
        def initialize(entries, *args)
          super
          if entries.any? { |e| e[:furniture_catalog] }
            self.index = entries.index { |e| e[:item] == $furniture_pick_item } || 0
            $furniture_window = self
          end
        end
        def update
          super
          return unless @entries.any? { |e| e[:furniture_catalog] }
          $furniture_picker_frames += 1
          self.index = @entries.index { |e| e[:item] == $furniture_pick_item } || 0 if $furniture_picker_frames == 1
          $furniture_picker_shot = Graphics.snap_to_bitmap if $furniture_picker_frames == 3
          $furniture_picker_action = $furniture_next_action if $furniture_picker_frames == 4
        end
      end)
      Input.singleton_class.prepend(Module.new do
        def trigger?(key)
          action = $furniture_picker_action
          if action
            return false unless (action == :confirm && key == Input::USE) || (action == :cancel && key == Input::BACK)
            $furniture_picker_action = nil
            return true
          end
          super
        end
      end)
      shots = []
      before = Marshal.dump([$bag, $PokemonGlobal])
      [[:ARENA_FURNITURE_LEAF_PLANT, :confirm, '-picker-plant.png'],
       [:ARENA_FURNITURE_PIKACHU_DOLL, :confirm, '-picker-doll.png'],
       [:ARENA_FURNITURE_SOFA, :cancel, '-picker-cancel.png']].each do |item, action, suffix|
        $furniture_pick_item, $furniture_next_action = item, action
        $furniture_picker_frames = 0
        chosen = ArenaDemo.choose_catalog(ArenaDemo.bag_catalog('furniture'), 'Choose furniture you own')
        check.call(action == :confirm ? chosen[:item] == item : chosen.nil?, "native picker #{action}: #{item}, got #{chosen.inspect}")
        check.call($furniture_window.disposed?, 'picker window disposed')
        check.call($furniture_window.width <= Graphics.width - 216, 'list leaves room for large preview')
        shots << [$furniture_picker_shot, path.sub(/\.log$/, suffix)]
      end
      check.call(before == Marshal.dump([$bag, $PokemonGlobal]), 'browsing and cancelling never changes stock or layout')
      check.call(ArenaDemo::EXTRA_FURNITURE.length == 34, '34 extra furniture types')
      check.call(ArenaDemo::EXTRA_FURNITURE.keys.all? { |item| $bag.quantity(item) == 2 }, 'extra stock granted once')
      placements.clear
      records.clear
      ArenaDemo::EXTRA_FURNITURE.each_key.with_index do |item, i|
        x, y = 38 + i % 8 * 3, 38 + i / 8 * 4
        x,y = 54,56 if item.to_s == ArenaFurnitureRules::STAND
        ArenaDemo.editor_apply_placement(placements, records, 'furniture', { item: item }, x, y)
        event = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE + i]
        check.call(placements.length == i + 1 && event.instance_variable_get(:@arena_furniture_item) == item, "extra native placement: #{item}")
        sprite = Sprite_Character.new(nil, event)
        sprite.update
        expected = ArenaDemo.furniture_bitmap(item)
        check.call(sprite.bitmap && [sprite.bitmap.width, sprite.bitmap.height] == [expected.width,expected.height], "extra native graphic: #{item}")
        check.call(event.width == ArenaFurnitureRules.width(item), "extra native footprint: #{item}")
        if item.to_s == ArenaFurnitureRules::STAND
          check.call(!sprite.visible, 'stand uses floor tiles instead of a tall overlapping event')
          check.call(ArenaDemo.relief_bitmap(records,x,y-2).width == 32 && ArenaDemo.relief_bitmap(records,x,y-1).height == 32,
            'stand top and stairs render in the native ground layer')
        elsif ArenaFurnitureRules.raised?(item)
          check.call(sprite.visible && sprite.y == event.screen_y, "raised furniture remains visible and aligned: #{item}")
        end
        check.call(event.through == ArenaFurnitureRules.walkable?(item), "extra native collision: #{item}")
        if item.to_s == ArenaFurnitureRules::STAND
          check.call(ArenaDemo.relief_code(records,x,y-2) == 1 && ArenaDemo.relief_code(records,x,y-1) == 8 && ArenaDemo.relief_code(records,x,y) == 0,
            'stand native floor, integrated stairs, and platform')
          grid = ArenaDemo.relief_grid(records)
          check.call(ArenaRelief.step?(grid,x,y,x,y-1) && ArenaRelief.step?(grid,x+3,y,x+3,y-1), 'stand original side stairs are traversable')
          check.call(ArenaRelief.wall?(grid,x+1,y-1) && ArenaRelief.wall?(grid,x+2,y-1), 'stand original central facade blocks passage')
        elsif ArenaFurnitureRules.raised?(item)
          check.call(ArenaDemo.relief_code(records,x,y) == 1, "raised native floor: #{item}")
        end
        sprites << sprite
      end
      payload = ArenaDemo.visit_snapshot_payload
      decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
      expected = placements.map { |p| p.reject { |key,_| %w[arena_under_surface arena_under_surfaces].include?(key) } }
      check.call(decoded && decoded[:placements] == expected, 'extra native visit snapshot round trip')
      check.call(Game.save('Data/furniture-probe-save.rxdata'), 'extra disposable save written')
      Game.load(SaveData.read_from_file('Data/furniture-probe-save.rxdata'))
      check.call(ArenaDemo.custom_placements == placements, 'extra furniture and underlying ground survive save and load')
      sprites.each(&:dispose)
      # Render a real map composition, not only isolated sprite bitmaps.
      placements, records = ArenaDemo.custom_placements, ArenaDemo.tile_edit_records
      placements.clear
      records.clear
      [[:ARENA_FURNITURE_RSE_STAND,45,46],[:ARENA_FURNITURE_RSE_SOLID_BOARD,49,46],
       [:ARENA_FURNITURE_DPPT_LABMACHINE,52,48],[:ARENA_FURNITURE_TREE_LEAFY,43,51],
       [:ARENA_FURNITURE_TREE_PINE,47,51],[:ARENA_FURNITURE_DPPT_BIGOILDRUM,51,52],
       [:ARENA_FURNITURE_SNOWBALL,45,48],[:ARENA_FURNITURE_HGSS_RED_CARPET,49,48],
       [:ARENA_FURNITURE_CHANDELIER,43,48],[:ARENA_FURNITURE_LAMPE,43,46],
       [:ARENA_FURNITURE_DPPT_OILDRUM,54,51],[:ARENA_FURNITURE_DPPT_TRASHCAN,54,49],
       [:ARENA_FURNITURE_RSE_RED_FLOWER,45,52],[:ARENA_FURNITURE_RSE_BIG_PLANT,49,52]].each do |item,x,y|
        ArenaDemo.editor_apply_placement(placements,records,'furniture',{item:item},x,y)
      end
      check.call(placements.length == 14, 'native visual scene retains all scaled furniture')
      check.call(GameData::Item.get(:ARENA_FURNITURE_HGSS_RED_CARPET).real_name == 'Tapis rouge', 'saved bag item names refreshed')
      $game_player.moveto(49,50)
      $game_player.center(49,49)
      $scene = Scene_Map.new
      $scene.createSpritesets
      4.times { $scene.updateSpritesets; Graphics.update }
      shots << [Graphics.snap_to_bitmap,path.sub(/\.log$/, '-revised-map.png')]
      sparks = Bitmap.new(288,32)
      9.times { |phase| sparks.blt(phase*32,0,ArenaDemo::DeviceArt.spark(phase),Rect.new(0,0,32,32)) }
      shots << [sparks,path.sub(/\.log$/, '-tesla-frames.png')]
      $PokemonGlobal.arena_wide_furniture_layout_version = 0
      legacy_tree = {'kind'=>'furniture','item'=>'ARENA_FURNITURE_TREE_LEAFY','x'=>44,'y'=>44}
      legacy_snow = {'kind'=>'furniture','item'=>'ARENA_FURNITURE_SNOWBALL','x'=>45,'y'=>44}
      $PokemonGlobal.arena_demo_placements = [legacy_tree,legacy_snow]
      before_bag = Marshal.dump($bag)
      ArenaDemo.custom_placements
      distance = (legacy_tree['x']-44).abs + (legacy_tree['y']-44).abs
      check.call(distance == 1 && !ArenaFurnitureRules.cells(legacy_tree['item'],legacy_tree['x'],legacy_tree['y']).include?([45,44]) && legacy_snow.values_at('x','y') == [45,44], 'legacy crowded layout expands with minimal furniture relocation')
      check.call(Marshal.dump($bag) == before_bag, 'legacy expansion preserves inventory')
      shots.each do |bitmap, filename|
        raw = ''.b
        bitmap.height.times do |y|
          raw << 0.chr
          bitmap.width.times do |x|
            color = bitmap.get_pixel(x, y)
            raw << [color.red, color.green, color.blue, color.alpha].map(&:to_i).pack('C4')
          end
        end
        chunk = proc { |type, data| [data.bytesize].pack('N') + type + data + [Zlib.crc32(type + data)].pack('N') }
        png = "\x89PNG\r\n\x1a\n".b + chunk.call('IHDR', [bitmap.width, bitmap.height, 8, 6, 0, 0, 0].pack('NNCCCCC')) +
          chunk.call('IDAT', Zlib::Deflate.deflate(raw)) + chunk.call('IEND', ''.b)
        File.binwrite(filename, png)
        bitmap.dispose
      end
      lines << "#{lines.length} native furniture checks passed. Disposable game only."
      File.write(path, lines.join("\n"))
      exit! 0
    rescue Exception => error
      lines << [error.class, error.message, error.backtrace&.first(8)].inspect
      File.write(path, lines.join("\n"))
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeFurnitureProbe)
end
