if defined?(Game) && ENV['ARENA_DEVICES_PROBE']
module ArenaFollowerTeleportProbe
  def teleport_phase(outgoing)
    (@follower_teleport_samples ||= []) << [FollowingPkmn.hidden?, ArenaDemo::FollowingIntegration.descriptor[:follower_species]]
    super
  end
end
ArenaDemo::Devices.singleton_class.prepend(ArenaFollowerTeleportProbe)
module ArenaFollowerQuicksandProbe
  def quicksand_tick(player, progress)
    (@follower_quicksand_samples ||= []) << [FollowingPkmn.hidden?, ArenaDemo::FollowingIntegration.descriptor[:follower_species]]
    super
  end
end
ArenaDemo.singleton_class.prepend(ArenaFollowerQuicksandProbe)
module ArenaDialogSaveProbe
  def save_to_file(path)
    return super unless $capture_attendant_save
    $captured_attendant_save = Marshal.load(Marshal.dump(compile_save_hash))
  end
end
SaveData.singleton_class.prepend(ArenaDialogSaveProbe)
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
module ArenaDeviceProbeAudio
  def se_play(*args)
    ($device_se_calls ||= []) << args
    super
  end
  def bgs_play(*args)
    ($device_bgs_calls ||= []) << args
    super
  end
end
Audio.singleton_class.prepend(ArenaDeviceProbeAudio)
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
      if @follower_mirror_id
        PEMK::Remotes.apply_pos(PEMK::Presence.build(:pos).merge(id: @follower_mirror_id))
      end
      Graphics.update; Input.update; pbUpdateSceneMap
      if @follower_mirror_id
        follower = ArenaDemo::FollowingIntegration.followers.fetch(@follower_mirror_id)
        leader = PEMK::Remotes.players.fetch(@follower_mirror_id)
        dx,dy = follower.screen_x-leader.screen_x, follower.screen_y-leader.screen_y
        (@follower_motion_gaps ||= []) << Math.sqrt(dx*dx+dy*dy)
        if @last_follower_vector
          change = Math.sqrt((dx-@last_follower_vector[0])**2 + (dy-@last_follower_vector[1])**2)
          @follower_motion_jump = [@follower_motion_jump || 0, change].max
        end
        @last_follower_vector = [dx,dy]
      end
      if ArenaDemo::Devices.sliding?
        raise 'Walking during forced slide' if $game_player.walk_anime || $game_player.pattern != ($game_player.instance_variable_get(:@original_pattern) || 0)
        if ArenaDemo::Devices.instance_variable_get(:@transport_kind) == :conveyor
          raise 'Follower visible on conveyor' unless FollowingPkmn.hidden?
          @conveyor_sampled = true
        else
          raise 'Follower visible during magnetic attraction' unless FollowingPkmn.hidden?
          raise 'Magnetic sound missing' unless $game_system.playing_bgs&.name == 'Arena Magnet'
          @magnet_sampled = true
          (@magnet_directions ||= []) << $game_player.direction
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

  def device_screenshot(path, bitmap = nil)
    bitmap ||= Graphics.snap_to_bitmap
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
      check.call(FileTest.audio_exist?('Audio/BGS/Arena Magnet'), 'magnetic loop is installed and resolvable by the engine')
      check.call(FileTest.audio_exist?('Audio/SE/Arena Tesla Button'), 'requested Myinstants button MP3 is installed and resolvable')
      check.call(FileTest.audio_exist?('Audio/SE/Arena Blind Rune'), 'personal blindness rune MP3 is installed and resolvable')
      wave = File.binread('Audio/BGS/Arena Magnet.wav')
      check.call(wave[0, 4] == 'RIFF' && wave[8, 4] == 'WAVE' && wave[40, 4].unpack1('V') == wave.bytesize - 44, 'magnetic loop has a complete PCM WAV payload')
      ArenaDemo::Devices.install
      missing_types = ArenaDemo::TRAINER_PROFILES.values.map { |p| p[:type] }.uniq.reject { |id| GameData::TrainerType.exists?(id) }
      check.call(missing_types.empty?, "all trainer profiles have registered types: #{missing_types.inspect}")
      gold = ArenaDemo::TRAINER_PROFILES.fetch(:ARENA_TRAINER_GOLD)
      check.call(gold[:team].first == [:GYARADOS,82,true] && GameData::TrainerType.get(:GOLD).battle_BGM == 'Battle GOLD',
        'Gold profile retains shiny Gyarados and personal battle music')
      check.call(!!pbResolveBitmap('Graphics/Trainers/GOLD') && !!pbResolveBitmap('Graphics/Characters/trainer_GOLD') && FileTest.audio_exist?('Audio/BGM/Battle GOLD'),
        'Gold personal battle/map sprites and music resolve in the local runtime')
      orbs = 9.times.map { |phase| ArenaDemo::DeviceArt.spark(phase) }
      pixels = orbs.map do |orb|
        32.times.flat_map { |y| 32.times.map { |x| orb.get_pixel(x,y) } }
      end
      check.call(pixels.all? { |frame| frame.count { |p| p.alpha > 0 } >= 640 }, 'all nine spark frames are solid orbs covering most of the tile')
      check.call(pixels.map { |frame| frame.map { |p| [p.red,p.green,p.blue,p.alpha] } }.uniq.length == 9, 'spark animation has nine distinct blue frames')
      board = Bitmap.new(288, 144)
      board.fill_rect(0,0,288,144,Color.new(165,224,203))
      orbs.each_with_index { |orb,i| board.blt(i*32,0,orb,orb.rect) }
      [ArenaDevices::RUNE,ArenaDevices::WEB].each_with_index do |item,i|
        glyph = ArenaDemo::DeviceArt.bitmap(item)
        board.stretch_blt(Rect.new(16+i*96,48,80,80),glyph,Rect.new(0,32,32,32))
      end
      board.stretch_blt(Rect.new(208,48,80,80),orbs.first,Rect.new(0,0,32,32))
      device_screenshot(path.sub('.log','-glyphs.png'),board)
      connected = Bitmap.new(384,256)
      connected.fill_rect(0,0,384,256,Color.new(165,224,203))
      %w[R L U D].each_with_index do |direction,i|
        coil = ArenaDemo::DeviceArt.bitmap("ARENA_TESLA_#{direction}")
        connected.blt(i*96,0,coil,coil.rect)
        _dir,dx,dy = ArenaDevices::DIRECTIONS.fetch(direction)
        connected.blt(i*96+32+dx*32,32+dy*32,orbs.first,orbs.first.rect)
        off = ArenaDemo::DeviceArt.bitmap("ARENA_TESLA_#{direction}",true)
        endpoint = [48+dx*32,48+dy*32]
        check.call(coil.get_pixel(*endpoint).alpha > 0 && off.get_pixel(*endpoint).alpha == 0,
          "#{direction} coil reaches its orb centre and disconnects when disabled")
      end
      patch = Bitmap.new(64,64)
      webs = [[0,ArenaDevices::WEB,0,0],[0,ArenaDevices::WEB,1,0],
              [0,ArenaDevices::WEB,0,1],[0,ArenaDevices::WEB,1,1]]
      webs.each do |p|
        links = ArenaDemo::DeviceArt.web_connections(p[2],p[3],webs)
        glyph = ArenaDemo::DeviceArt.bitmap(ArenaDevices::WEB,false,0,links)
        patch.blt(p[2]*32,p[3]*32,glyph,Rect.new(0,32,32,32))
      end
      check.call([7,16,25].all? { |n| patch.get_pixel(31,n).alpha == 255 && patch.get_pixel(32,n).alpha == 255 },
        'adjacent horizontal webs have three unbroken shared threads')
      check.call([7,16,25].all? { |n| patch.get_pixel(n,31).alpha == 255 && patch.get_pixel(n,32).alpha == 255 },
        'adjacent vertical webs have three unbroken shared threads')
      check.call(ArenaDemo::DeviceArt.web_connections(0,0,webs) == 5 &&
        ArenaDemo::DeviceArt.web_connections(0,0,[webs.first]) == 0,
        'web links follow neighbouring placements and disappear when removed')
      connected.stretch_blt(Rect.new(16,112,128,128),patch,patch.rect)
      patch.dispose
      device_screenshot(path.sub('.log','-connections.png'),connected)
      $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
      $map_factory = PokemonMapFactory.new(100)
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup(100)
      $scene = Scene_Map.new
      $scene.createSpritesets
      live_interpreter = $game_system.map_interpreter
      live_interpreter.setup([RPG::EventCommand.new(355,0,['ArenaDemo.multiplayer_attendant']),RPG::EventCommand.new(0,0,[])],4,102)
      $capture_attendant_save = true
      Game.save('arena-probe-in-memory-only')
      # The checkpoint's final rename intentionally fails: no file is written.
      # Inspect the actual serialized snapshot, rather than claiming a disk save.
      check.call($captured_attendant_save && !$captured_attendant_save[:game_system].map_interpreter.running?, 'native save serialization excludes a running entrance dialogue from its in-memory snapshot')
      $capture_attendant_save = false
      check.call($game_system.map_interpreter.equal?(live_interpreter) && live_interpreter.running?, 'native connection save leaves the live guide interaction intact')
      live_interpreter.setup(nil,0,100)
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
      check.call(@magnet_sampled && $game_player.walk_anime && !FollowingPkmn.hidden? && $game_system.playing_bgs&.name != 'Arena Magnet', 'magnet hides follower, loops audio and restores both at arrival')
      check.call(@magnet_directions.uniq.sort == [2,4,6,8] && $game_player.direction == 6,
        'magnetic attraction spins through four facings like quicksand and stops facing the antenna')
      check.call(($device_bgs_calls || []).any? { |args| args[0].include?('Arena Magnet') && args[1] > 0 }, 'magnetic loop reaches the native Audio backend at nonzero volume')
      device_layout([['ARENA_MAGNET_L', 55, 50], ['ARENA_FURNITURE_ROCK', 52, 50]])
      $game_player.moveto(50, 49)
      device_step(2)
      check.call([$game_player.x, $game_player.y] == [51, 50], 'magnetic attraction stops at the intervening object')
      check.call(!FollowingPkmn.hidden? && $game_system.playing_bgs&.name != 'Arena Magnet', 'blocked magnet restores follower and stops audio')
      device_layout([])
      $game_player.moveto(49, 50)
      normal = 3.times.map do
        $game_player.moveto(49, 50)
        device_step(6)
      end.sort[1]
      device_layout([[ArenaDevices::WEB, 50, 50]])
      $game_player.moveto(49, 50)
      slowed = 3.times.map do
        $game_player.moveto(49, 50)
        device_step(6)
      end.sort[1]
      check.call((slowed / normal).between?(3.4, 4.6), "web traversed at one-quarter native speed (ratio #{(slowed / normal).round(2)})")
      after = device_step(2)
      clear = device_step(2)
      check.call(after > clear * 3.4, 'web slowdown also applies leaving the tile and clears afterwards')
      device_layout([[ArenaDevices::WEB,50,50],[ArenaDevices::WEB,51,50]])
      $game_player.moveto(49,50)
      device_step(6)
      check.call(FollowingPkmn.hidden?, 'follower disappears on entry into a web')
      device_step(6)
      check.call(FollowingPkmn.hidden?, 'follower stays hidden across adjacent webs')
      device_step(6)
      check.call(!FollowingPkmn.hidden?, 'follower returns on the first non-web tile')
      FollowingPkmn.toggle(false,false)
      $game_player.moveto(49,50)
      device_step(6)
      device_step(4)
      check.call(!FollowingPkmn.active?, 'web exit preserves an explicitly disabled follower')
      FollowingPkmn.toggle(true,false)
      FollowingPkmn.refresh(false)
      device_layout([[ArenaDevices::TELEPORT, 50, 50], [ArenaDevices::TELEPORT, 56, 50]])
      $player.party = [Pokemon.new(:MEW, 10)]
      FollowingPkmn.start_following(900, false) unless FollowingPkmn.get
      FollowingPkmn.toggle(true, false)
      FollowingPkmn.refresh(false)
      $game_player.moveto(49, 50)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [56, 50], 'paired teleporter animation completes at the other pad')
      follower = FollowingPkmn.get_event
      check.call(follower && (follower.x-56).abs + (follower.y-50).abs == 1, 'teleporter restores follower on an adjacent tile without player overlap')
      samples = ArenaDemo::Devices.instance_variable_get(:@follower_teleport_samples)
      check.call(samples.length >= 2 && samples.all? { |hidden,species| hidden && species.empty? }, 'teleport hides local follower and outgoing remote descriptor throughout both spin phases')
      device_frames(8)
      check.call([$game_player.x, $game_player.y] == [56, 50], 'arrival pad does not instantly teleport back')
      device_step(4)
      device_step(6)
      check.call([$game_player.x, $game_player.y] == [50, 50], 'teleporter works again after stepping off and back on')
      device_layout([], {'50,50' => {'floor' => 'field', 'ground' => 'quicksand'}})
      $game_player.moveto(49,50)
      device_step(6)
      samples = ArenaDemo.instance_variable_get(:@follower_quicksand_samples)
      check.call(samples && samples.length > 4 && samples.all? { |hidden,species| hidden && species.empty? }, 'quicksand hides local follower and outgoing remote descriptor throughout the spin')
      follower = FollowingPkmn.get_event
      check.call(!FollowingPkmn.hidden? && (follower.x-$game_player.x).abs + (follower.y-$game_player.y).abs == 1, 'quicksand restores follower adjacent to the returned player')
      device_frames(2)
      check.call(!ArenaDemo::FollowingIntegration.descriptor[:follower_species].empty?, 'restored follower is visible and announced after quicksand')
      device_layout([])
      ArenaDemo::FollowingIntegration.install_follower_hooks
      $game_player.moveto(50,50)
      $game_temp.in_menu = false
      leader = PEMK::RemotePlayer.new(777, $game_map)
      leader.spawn_at(50,50,2,$game_player.character_name)
      PEMK::Remotes.players[777] = leader
      descriptor = ArenaDemo::FollowingIntegration.descriptor.merge(follower_x: 50, follower_y: 49, follower_dir: 2)
      ArenaDemo::FollowingIntegration.sync_remote(777,leader,descriptor)
      remote = ArenaDemo::FollowingIntegration.followers.fetch(777)
      [2,4,6,8].each do |direction|
        dx = direction == 6 ? -1 : direction == 4 ? 1 : 0
        dy = direction == 2 ? -1 : direction == 8 ? 1 : 0
        follower.end_movement
        follower.moveto(50+dx,50+dy)
        follower.direction = direction
        remote.accept_position(leader, descriptor.merge(follower_x: follower.x, follower_y: follower.y, follower_dir: direction))
        remote.follow_remote(leader,true)
        device_frames(20)
        check.call((follower.screen_x-remote.screen_x).abs <= 1 && (follower.screen_y-remote.screen_y).abs <= 1, "#{direction} local and remote follower margins settle to the same spacing")
      end
      local_patterns, remote_patterns = [], []
      45.times do
        device_frames(1)
        local_patterns << follower.pattern
        remote_patterns << remote.pattern
      end
      check.call(local_patterns.uniq.length > 1 && remote_patterns.uniq.length > 1, 'both local and remote followers animate while their players stand still')
      follower.end_movement
      follower.moveto(49,50)
      $game_player.direction = follower.direction = 6
      leader.spawn_at(50,50,6,$game_player.character_name)
      remote.accept_position(leader, descriptor.merge(follower_x: 49, follower_y: 50, follower_dir: 6))
      remote.follow_remote(leader,true)
      @follower_mirror_id = 777
      [6,6,2,2,4,4,8,8,6,4,6,4].each { |direction| device_step(direction) }
      @follower_mirror_id = nil
      check.call(@follower_motion_gaps.max <= 64,
        "remote follower follows its native path without drifting away through turns/reversals (max #{@follower_motion_gaps.max.round(1)}px)")
      check.call(@follower_motion_jump <= 16, "walking, corners and reversals avoid abrupt remote follower jumps (max #{@follower_motion_jump.round(1)}px/frame)")
      ArenaDemo::FollowingIntegration.dispose_remote(777)
      PEMK::Remotes.players.delete(777)
      device_layout([[ArenaDevices::COIL, 51, 50], [ArenaDevices::BUTTON, 50, 50]])
      coil = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE]
      check.call(!coil.through, 'active Tesla spark is impassable')
      $game_player.moveto(49, 50)
      device_step(6)
      check.call(ArenaDemo::Devices.disabled == [0] && !coil.through, 'red floor button disables spark while coil stays solid')
      check.call(($device_se_calls || []).any? { |args| args[0].include?('Arena Tesla Button') && args[1] > 0 },
        'red button sends the requested MP3 to the native sound backend')
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
      check.call(($device_se_calls || []).any? { |args| args[0].include?('Arena Blind Rune') && args[1] > 0 },
        'stepping onto blindness rune sends personal MP3 to the native sound backend')
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
        ['ARENA_MAGNET_R', 49, 48], ['ARENA_MAGNET_U', 51, 48], ['ARENA_MAGNET_D', 53, 48],
        [ArenaDevices::WEB, 51, 50], [ArenaDevices::TELEPORT, 53, 50], [ArenaDevices::TELEPORT, 55, 50],
        [ArenaDevices::COIL, 47, 52], [ArenaDevices::BUTTON, 49, 52], [ArenaDevices::RUNE, 51, 52]])
      $game_player.moveto(51, 54)
      device_frames(12)
      spark_sprites = ArenaDemo::Devices.instance_variable_get(:@spark_sprites)
      check.call(spark_sprites.length == 1 && !spark_sprites.first.disposed?, 'one persistent live sprite renders the Tesla orb without duplicate disposal')
      Graphics.transition(0)
      device_screenshot(path.sub('.log', '-objects.png'))
      device_layout([['ARENA_TESLA_R',47,50],[ArenaDevices::BUTTON,47,52],
        ['ARENA_TESLA_L',52,50],[ArenaDevices::BUTTON,52,52],
        ['ARENA_TESLA_U',56,51],[ArenaDevices::BUTTON,56,53],
        ['ARENA_TESLA_D',60,49],[ArenaDevices::BUTTON,60,51],
        [ArenaDevices::WEB,48,54],[ArenaDevices::WEB,49,54],
        [ArenaDevices::WEB,48,55],[ArenaDevices::WEB,49,55]])
      $game_player.moveto(53,55)
      device_frames(6)
      check.call(ArenaDemo::Devices.instance_variable_get(:@spark_sprites).length == 4,
        'all four compact directional coils render their live orb in the native map')
      device_screenshot(path.sub('.log','-connections-map.png'))
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
