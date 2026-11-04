# Essentials has one BGS channel. A combined loop keeps both devices audible
# during magnetic movement without overlapping repeated sound effects.
module ArenaDemo::DeviceAmbience
  module_function

  def visible_coil?
    dx = $game_map.display_x.to_f / Game_Map::X_SUBPIXELS
    dy = $game_map.display_y.to_f / Game_Map::Y_SUBPIXELS
    disabled = ArenaDemo::Devices.disabled
    ArenaDevices.furniture(ArenaDemo::Devices.wire).each_with_index.any? do |entry,slot|
      next false unless ArenaDevices.coil?(entry[1]) && !disabled.include?(slot)
      # Coil body: 32x64, anchored at the bottom of its map tile. Do not count
      # the transparent padding of the 96x96 discharge bitmap as visible.
      x, y = entry[2]*32-dx, entry[3]*32-dy
      x < Graphics.width && x+32 > 0 && y-32 < Graphics.height && y+32 > 0
    end
  end

  def stop
    if @track && $game_system && $game_system.playing_bgs&.name == @track
      $game_system.bgs_play(@previous)
    end
    @track = @previous = nil
  end

  def update
    unless $game_system && ArenaDemo::Devices.active? && $scene.is_a?(Scene_Map) &&
           $game_temp && !$game_temp.in_battle && !@battle
      stop
      return
    end
    tesla = visible_coil?
    magnet = ArenaDemo::Devices.instance_variable_get(:@transport_kind) == :magnet
    track = if magnet then tesla ? 'Arena Magnet Tesla' : 'Arena Magnet'
            elsif tesla then 'Arena Tesla Hum' end
    unless track && FileTest.audio_exist?('Audio/BGS/' + track)
      stop
      return
    end
    current = $game_system.playing_bgs
    return if @track == track && current&.name == track
    # Capture external ambience changes too, and never restore over another
    # scene's BGS when our own loop has already been replaced.
    @previous = current&.clone unless @track && current&.name == @track
    @track = track
    pbBGSPlay(track, magnet ? 95 : 90, 100)
  end

  def battle(started)
    @battle = started
    stop if started
  end
end

module ArenaDemo::DeviceAmbienceScene
  def disposeSpritesets
    ArenaDemo::DeviceAmbience.stop
    super
  end
end
Scene_Map.prepend(ArenaDemo::DeviceAmbienceScene)
EventHandlers.add(:on_leave_map, :arena_device_ambience, proc { ArenaDemo::DeviceAmbience.stop })
EventHandlers.add(:on_start_battle, :arena_device_ambience, proc { ArenaDemo::DeviceAmbience.battle(true) })
EventHandlers.add(:on_end_battle, :arena_device_ambience, proc { ArenaDemo::DeviceAmbience.battle(false) })
