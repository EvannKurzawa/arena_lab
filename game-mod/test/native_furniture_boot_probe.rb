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
      sprites.each(&:dispose)
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
