if defined?(Game) && ENV['ARENA_DEVICES_PROBE']
module ArenaDeviceProbeMessages
  def pbMessage(*args)
    ($device_probe_messages ||= []) << args[0]
    0
  end
end
Object.prepend(ArenaDeviceProbeMessages)
module ArenaDeviceProbeCatalogInput
  def trigger?(key)
    capture = $device_probe_catalog_capture
    if capture && key == Input::BACK && caller_locations(1, 1).first.base_label == 'choose_material_catalog'
      Game.device_screenshot(capture)
      $device_probe_catalog_capture = nil
      return true
    end
    super
  end
end
Input.singleton_class.prepend(ArenaDeviceProbeCatalogInput)
module ArenaDemo::NativeDevicesProbe
  def device_layout(entries, edits = {})
    $PokemonGlobal.arena_demo_placements = entries.map do |item, x, y|
      { 'kind' => 'furniture', 'item' => item, 'x' => x, 'y' => y }
    end
    $PokemonGlobal.arena_demo_tile_edits = edits
    ArenaDemo::FieldObstacles.reset
    ArenaDemo.apply_tile_edits($game_map, edits)
    ArenaDemo.refresh_custom_placements
  end

  def device_frames(count)
    count.times do
      Graphics.update; Input.update; pbUpdateSceneMap
      if ArenaDemo::Devices.sliding?
        raise 'Walking during forced slide' if $game_player.walk_anime || $game_player.pattern != ($game_player.instance_variable_get(:@original_pattern) || 0)
        if ArenaDemo::Devices.instance_variable_get(:@transport_kind) == :conveyor
          raise 'Follower visible on conveyor' unless FollowingPkmn.hidden?
          @conveyor_sampled = true
        else
          @magnet_sampled = true
        end
      end
    end
  end

  def device_step(direction)
    started = System.uptime
    $game_player.move_generic(direction)
    300.times do
      device_frames(1)
      return System.uptime - started unless $game_player.moving? || $game_player.jumping? || ArenaDemo::Devices.forcing?
    end
    raise 'Forced movement failed to finish within 300 frames'
  end

  def device_screenshot(path)
    bitmap = Graphics.snap_to_bitmap
    rows = String.new.b
    bitmap.height.times do |y|
      rows << "\0"
      bitmap.width.times do |x|
        pixel = bitmap.get_pixel(x, y)
        rows << [pixel.red, pixel.green, pixel.blue, pixel.alpha].map(&:to_i).pack('C4')
      end
    end
    chunk = proc { |type, data| [data.bytesize].pack('N') + type + data + [Zlib.crc32(type + data)].pack('N') }
    File.binwrite(path, "\x89PNG\r\n\x1a\n".b + chunk.call('IHDR', [bitmap.width, bitmap.height, 8, 6, 0, 0, 0].pack('NNCCCCC')) +
      chunk.call('IDAT', Zlib::Deflate.deflate(rows)) + chunk.call('IEND', ''.b))
    bitmap.dispose
  end

  def set_up_system
    path = ENV.fetch('ARENA_DEVICES_PROBE')
    lines = []
    begin
      check = proc { |ok, label| raise "FAIL: #{label}" unless ok; lines << "PASS: #{label}"; File.write(path, lines.join("\n")) }
      SaveData.initialize_bootup_values
      SaveData.load_new_game_values
      ArenaDemo::Devices.install
      $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
      $map_factory = PokemonMapFactory.new(100)
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup(100)
      $scene = Scene_Map.new
      $scene.createSpritesets
      ArenaDemo.ensure_custom_inventory
      check.call(ArenaDemo::DEVICE_STOCK.all? { |item, (_name, qty)| $bag.quantity(item) == qty }, 'all six device kits granted in native Bag')
      catalog = ArenaDemo.bag_catalog('furniture').select { |entry| ArenaDemo::DEVICE_STOCK.key?(entry[:item]) }
      catalog = catalog.map { |entry| entry.merge(:furniture_catalog => true) }
      check.call(catalog.length == 6 && catalog.all? { |entry| ArenaDemo.material_catalog_preview(entry).width == 96 }, 'all six device previews render through the real furniture catalog path')
      $device_probe_catalog_capture = path.sub('.log', '-catalog.png')
      result = ArenaDemo.choose_material_catalog(catalog, 'Objets interactifs', catalog.length - 1)
      check.call(result.nil? && File.file?(path.sub('.log', '-catalog.png')), 'real furniture picker opens, draws its selected preview and closes normally')
      $player.party = [Pokemon.new(:MEW, 10)]
      FollowingPkmn.start_following(900, false) unless FollowingPkmn.get
      FollowingPkmn.toggle(true, false)
      FollowingPkmn.refresh(false)
      device_layout([['ARENA_CONVEYOR_R', 50, 50], ['ARENA_CONVEYOR_R', 51, 50]])
      $game_player.moveto(49, 50)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [52, 50], 'conveyors carry player across consecutive tiles and release on ordinary ground')
      check.call(@conveyor_sampled && !FollowingPkmn.hidden? && $game_player.walk_anime, 'conveyor freezes walking, hides follower throughout and restores both at exit')
      device_layout([['ARENA_CONVEYOR_R', 50, 50], ['ARENA_CONVEYOR_R', 51, 50], ['ARENA_FURNITURE_ROCK', 52, 50]])
      $game_player.moveto(49, 50)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [51, 50], 'conveyor stops before solid furniture')
      device_layout([['ARENA_CONVEYOR_R', 50, 50], ['ARENA_CONVEYOR_R', 51, 50]], {'52,50' => {'floor' => 'void', 'ground' => 'plain'}})
      $game_player.moveto(49, 50)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [51, 50], 'conveyor stops on its last safe tile before void')
      device_layout([['ARENA_MAGNET_L', 55, 50]])
      $game_player.moveto(50, 49)
      device_step(2)
      check.call([$game_player.x, $game_player.y] == [54, 50], 'magnet attracts on its configured half-line until adjacent')
      check.call(@magnet_sampled && $game_player.walk_anime, 'magnet slides without walking and restores normal movement')
      device_layout([['ARENA_MAGNET_L', 55, 50], ['ARENA_FURNITURE_ROCK', 52, 50]])
      $game_player.moveto(50, 49)
      device_step(2)
      check.call([$game_player.x, $game_player.y] == [51, 50], 'magnetic attraction stops at the intervening object')
      device_layout([])
      $game_player.moveto(49, 50)
      normal = device_step(6)
      device_layout([[ArenaDevices::WEB, 50, 50]])
      $game_player.moveto(49, 50)
      slowed = device_step(6)
      check.call((slowed / normal).between?(3.4, 4.6), "web traversed at one-quarter native speed (ratio #{(slowed / normal).round(2)})")
      after = device_step(2)
      clear = device_step(2)
      check.call(after > clear * 3.4, 'web slowdown also applies leaving the tile and clears afterwards')
      device_layout([[ArenaDevices::TELEPORT, 50, 50], [ArenaDevices::TELEPORT, 56, 50]])
      $player.party = [Pokemon.new(:MEW, 10)]
      FollowingPkmn.start_following(900, false) unless FollowingPkmn.get
      FollowingPkmn.toggle(true, false)
      FollowingPkmn.refresh(false)
      $game_player.moveto(49, 50)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [56, 50], 'paired teleporter animation completes at the other pad')
      follower = FollowingPkmn.get_event
      check.call(follower && [follower.x, follower.y] == [56, 50], 'teleporter transfers the active native follower with the player')
      device_frames(8)
      check.call([$game_player.x, $game_player.y] == [56, 50], 'arrival pad does not instantly teleport back')
      device_step(4)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [50, 50], 'teleporter works again after stepping off and back on')
      device_layout([[ArenaDevices::COIL, 51, 50], [ArenaDevices::BUTTON, 50, 50]])
      coil = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE]
      check.call(!coil.through, 'active Tesla spark is impassable')
      $game_player.moveto(49, 50)
      device_step(6)
      check.call(ArenaDemo::Devices.disabled == [0] && !coil.through, 'red floor button disables spark while coil stays solid')
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [50, 50], 'player cannot cross the disabled coil')
      device_layout([])
      draft = []
      selected = { :item => :ARENA_TELEPORTER }
      old_quantity = $bag.quantity(:ARENA_TELEPORTER)
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', selected, 53, 52)
      check.call(draft.empty? && $bag.quantity(:ARENA_TELEPORTER) == old_quantity, 'first endpoint consumes no kit and places no orphan')
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', selected, 54, 52)
      check.call(draft.length == 2 && $bag.quantity(:ARENA_TELEPORTER) == old_quantity - 1, 'second endpoint atomically places a two-pad kit')
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', { :action => :remove }, 54, 52)
      check.call(draft.empty? && $bag.quantity(:ARENA_TELEPORTER) == old_quantity, 'removing either endpoint returns exactly one kit and removes both')
      tesla = { :item => :ARENA_TESLA }
      stock = $bag.quantity(:ARENA_TESLA)
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', tesla, 53, 52)
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', tesla, 55, 52)
      check.call(draft.map { |p| p['item'] } == ['ARENA_TESLA_R', ArenaDevices::BUTTON] && $bag.quantity(:ARENA_TESLA) == stock - 1, 'Tesla editor creates coil and red button as one kit')
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', { :action => :remove }, 55, 52)
      check.call(draft.empty? && $bag.quantity(:ARENA_TESLA) == stock, 'removing red button also removes its coil and returns one kit')
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', selected, 53, 52)
      ArenaDemo.editor_apply_placement(draft, {}, 'furniture', selected, 54, 52)
      ArenaDemo.reconcile_editor_inventory([], draft)
      check.call($bag.quantity(:ARENA_TELEPORTER) == old_quantity, 'cancelling a paired draft returns one kit instead of two pads')
      device_layout([[ArenaDevices::RUNE, 50, 50]])
      $game_player.moveto(49, 50)
      device_step(6)
      mask = ArenaDemo::Devices.instance_variable_get(:@darkness)
      check.call(mask && !mask.disposed? && mask.radius == 64, 'blind rune creates the native unlit-cave vision circle')
      check.call(mask.instance_variable_get(:@center) == [$game_player.screen_x, $game_player.screen_y - 16], 'blindness circle stays centered on the player at native window size')
      Graphics.transition(0)
      device_screenshot(path.sub('.log', '-darkness.png'))
      deadline = ArenaDemo::Devices.instance_variable_get(:@blind_until)
      check.call(deadline && (deadline - System.uptime).between?(58,60), 'rune starts a sixty-second timer')
      ArenaDemo::Devices.update_blindness(deadline - 0.01)
      check.call(!mask.disposed?, 'blindness remains before sixty seconds')
      ArenaDemo::Devices.update_blindness(deadline)
      check.call(mask.disposed?, 'blindness expires at sixty seconds')
      ArenaDemo::Devices.clear
      check.call(mask.disposed?, 'room/editor reset disposes the blindness mask')
      device_layout([['ARENA_CONVEYOR_R', 47, 50], ['ARENA_MAGNET_L', 49, 50],
        [ArenaDevices::WEB, 51, 50], [ArenaDevices::TELEPORT, 53, 50], [ArenaDevices::TELEPORT, 55, 50],
        [ArenaDevices::COIL, 47, 52], [ArenaDevices::BUTTON, 49, 52], [ArenaDevices::RUNE, 51, 52]])
      $game_player.moveto(51, 54)
      device_frames(3)
      Graphics.transition(0)
      device_screenshot(path.sub('.log', '-objects.png'))
      $scene.dispose
      lines << "#{lines.length} native device checks passed. No player save read or written."
      File.write(path, lines.join("\n"))
      exit! 0
    rescue Exception => error
      lines << [error.class, error.message, error.backtrace&.first(50)].inspect
      File.write(path, lines.join("\n"))
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeDevicesProbe)
end
