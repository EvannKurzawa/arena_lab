if defined?(Game) && ENV['ARENA_FURNITURE_PROBE']
module ArenaTeslaNativeAudioProbe
  def bgs_play(*args)
    ($tesla_native_audio_calls ||= []) << args
    super
  end
end
Audio.singleton_class.prepend(ArenaTeslaNativeAudioProbe)
module ArenaDemo::NativeShowroomProbe
  def set_up_system
    lines = []
    begin
      check = proc { |ok,label| raise("FAIL: #{label}") unless ok; lines << "PASS: #{label}" }
      SaveData.initialize_bootup_values
      SaveData.load_new_game_values
      $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
      $map_factory = PokemonMapFactory.new(100)
      $game_player.moveto(49,53)
      ArenaDemo.ensure_custom_inventory
      placements = ArenaDemo.custom_placements
      ArenaDemo.apply_tile_edits($game_map)
      ArenaDemo.refresh_custom_placements
      check.call([$game_map.width,$game_map.height] == [200,200], 'native 200x200 map')
      payload = ArenaDemo.visit_snapshot_payload
      check.call(!!ArenaDemo.decode_visit_snapshot(payload[:surface],payload[:placements],payload[:relief],payload[:styles]), 'native visit snapshot')
      check.call(ArenaDevices.teleport_target(payload[:placements],49,49) == [124,124], 'portal from centre to showroom')
      check.call(ArenaDevices.teleport_target(payload[:placements],124,124) == [49,49], 'return portal')
      placements.each_with_index do |placed,i|
        event = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE+i]
        check.call(event && [event.x,event.y] == placed.values_at('x','y'), "native event #{placed['item']}")
        check.call(event.width == ArenaFurnitureRules.width(placed['item']), "native footprint #{placed['item']}")
        sprite = Sprite_Character.new(nil,event)
        sprite.update
        check.call(sprite.bitmap && sprite.bitmap.width > 0, "native sprite #{placed['item']}")
        sprite.dispose
      end
      frames = Array.new(ArenaDemo::DeviceArt::SPARK_FRAMES) { |i| ArenaDemo::DeviceArt.spark(i) }
      check.call(frames.length == 18 && frames.all? { |b| b.width==32 && b.height==32 }, '18 native animated spark frames')
      %i[ARENA_FURNITURE_RSE_RED_FLOWER ARENA_FURNITURE_FERN ARENA_FURNITURE_LEAF_PLANT ARENA_FURNITURE_DPPT_POTTEDPLANT].each do |item|
        image = ArenaDemo.furniture_bitmap(item)
        pixels = []
        image.height.times { |y| image.width.times { |x| pixels << [x,y] if image.get_pixel(x,y).alpha > 0 } }
        xs,ys = pixels.transpose
        check.call((xs.max-xs.min+1) <= 32 && (ys.max-ys.min+1).between?(32,40), "harmonized native plant #{item}")
      end
      check.call($game_map.data[180,185,0] >= 48, 'empty showroom building space is rendered')
      check.call(Marshal.load(Marshal.dump($PokemonGlobal)).instance_variable_get(:@arena_debug_furniture_version) == 2, 'showroom save marker')
      placements.replace([
        {'kind'=>'furniture','item'=>'ARENA_TESLA_R','x'=>49,'y'=>50},
        {'kind'=>'furniture','item'=>'ARENA_TESLA_BUTTON','x'=>49,'y'=>52}
      ])
      ArenaDemo.refresh_custom_placements
      $scene = Scene_Map.new
      $game_player.center(49,51)
      check.call(ArenaDemo::DeviceAmbience.visible_coil?, 'Tesla coil intersects native camera')
      ArenaDemo::DeviceAmbience.update
      check.call($game_system.playing_bgs&.name == 'Arena Tesla Hum', 'native Tesla BGS starts')
      check.call(($tesla_native_audio_calls || []).any? { |args| args[0].include?('Arena Tesla Hum') && args[1] > 0 }, 'Tesla reaches native audio backend with nonzero volume')
      count = $tesla_native_audio_calls.length
      20.times { ArenaDemo::Devices.update }
      check.call($tesla_native_audio_calls.length == count, 'normal frame updates do not restart Tesla loop')
      ArenaDemo::Devices.apply_disabled([0])
      check.call($game_system.playing_bgs.nil?, 'native Tesla BGS stops on disable')
      lines << "#{lines.length} native furniture checks passed. Disposable showroom only."
      File.write(ENV.fetch('ARENA_FURNITURE_PROBE'),lines.join("\n"))
      exit! 0
    rescue Exception => error
      lines << [error.class,error.message,error.backtrace&.first(8)].inspect
      File.write(ENV.fetch('ARENA_FURNITURE_PROBE'),lines.join("\n"))
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeShowroomProbe)
end
