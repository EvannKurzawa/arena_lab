# Interactive surfaces reuse Essentials movement, Surf and step callbacks.
module ArenaDemo
  module_function

  def surf_ground?(records, x, y)
    state = tile_surface_state(records, x, y)
    state['floor'] == 'field' && ArenaMaterials::SURF_GROUNDS.include?(state['ground'])
  end

  def runtime_surf?(event)
    event && event.equal?($game_player) && defined?($PokemonGlobal) && $PokemonGlobal && ($PokemonGlobal.surfing || @arena_surf_probe)
  end

  def surf_probe?
    @arena_surf_probe == true
  end

  def with_surf_probe
    previous = @arena_surf_probe
    @arena_surf_probe = true
    yield
  ensure
    @arena_surf_probe = previous
  end

  def runtime_tile_blocked?(x, y, event)
    return false if runtime_surf?(event) && surf_ground?(tile_edit_records, x, y)
    tile_is_void?(x, y)
  end

  def try_arena_surf
    return unless $game_map && $game_map.map_id == MAP_ID && $game_player
    return if $PokemonGlobal.surfing || @editor_surface_edits || @quicksand_running
    dx, dy = ArenaRelief::DIRECTIONS[$game_player.direction]
    return unless dx && surf_ground?(tile_edit_records, $game_player.x + dx, $game_player.y + dy)
    # Probe access without changing vehicle or bypassing the native Surf keys.
    accessible = with_surf_probe do
      $game_player.passable?($game_player.x, $game_player.y, $game_player.direction)
    end
    arena_start_surf if accessible
  end

  def arena_start_surf
    return false unless $game_player.can_ride_vehicle_with_follower?
    return false unless pbConfirmMessage('Utiliser Surf pour traverser cette eau ?')
    # Arena testing has no badge progression. Keep the native vehicle, jump,
    # follower checks and dismount rather than silently failing a story gate.
    pbStartSurfing
    true
  end

  def quicksand_at?(x, y)
    state = tile_surface_state(tile_edit_records, x, y)
    state['floor'] == 'field' && state['ground'] == 'quicksand'
  end

  def quicksand_tick(player, progress)
    previous_direction = player.direction
    player.direction = [2, 4, 8, 6][(progress * 16).floor % 4]
    player.opacity = (255 * (1.0 - progress)).round
    player.y_offset = (progress * 18).round
    PEMK::Presence.emit_now(:dir) if player.direction != previous_direction && defined?(PEMK::Presence)
  end

  def quicksand_wait
    duration = 1.25
    started = System.uptime
    loop do
      progress = [(System.uptime - started) / duration, 1.0].min
      quicksand_tick($game_player, progress)
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break if progress >= 1.0
    end
  end

  def quicksand_step(event)
    return false unless event && event.equal?($game_player) && $game_map && $game_map.map_id == MAP_ID
    return false if @quicksand_running || @editor_surface_edits || !quicksand_at?(event.x, event.y)
    @quicksand_running = true
    old_menu, old_opacity = $game_temp.in_menu, event.opacity
    old_y_offset = event.instance_variable_get(:@y_offset) || 0
    old_walk = event.walk_anime || $PokemonGlobal.ice_sliding
    begin
      $game_temp.in_menu = true
      $PokemonGlobal.ice_sliding = false
      event.walk_anime = false
      # Send the entered trap before the nonadjacent return. The server accepts
      # that return only from a quicksand tile of this room's saved layout.
      PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
      pbSEPlay("Player fall", 80, 70)
      quicksand_wait
      start = map_start
      event.moveto(start[0], start[1])
      event.direction = start[2]
      $game_temp.surf_base_coords = nil
      $game_temp.ending_surf = false
      pbCancelVehicles
      pbUpdateVehicle
      $PokemonTemp.followers&.map_transfer_followers if defined?($PokemonTemp) && $PokemonTemp.respond_to?(:followers)
      PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
      true
    ensure
      event.opacity = old_opacity
      event.y_offset = old_y_offset
      event.walk_anime = old_walk
      $game_temp.in_menu = old_menu
      @quicksand_running = false
    end
  end
end

EventHandlers.add(:on_player_interact, :arena_native_surf, proc { ArenaDemo.try_arena_surf })
EventHandlers.add(:on_step_taken, :arena_quicksand, proc { |event| ArenaDemo.quicksand_step(event) })

if defined?(Game_Map)
  module ArenaDemo::SurfAccessProbe
    def playerPassable?(x, y, direction, self_event = nil)
      if @map_id == ArenaDemo::MAP_ID && ArenaDemo.surf_probe? &&
         self_event.equal?($game_player) && ArenaDemo.surf_ground?(ArenaDemo.tile_edit_records, x, y)
        return true
      end
      super
    end
  end
  Game_Map.prepend(ArenaDemo::SurfAccessProbe)
end

if defined?(HiddenMoveHandlers::CanUseMove)
  native_surf_check = HiddenMoveHandlers::CanUseMove[:SURF]
  HiddenMoveHandlers::CanUseMove.add(:SURF, proc do |move, pokemon, showmsg|
    if $game_map && $game_map.map_id == ArenaDemo::MAP_ID
      next false if $PokemonGlobal.surfing || !$game_player.can_ride_vehicle_with_follower?
      next false unless $game_player.pbFacingTerrainTag.can_surf_freely
      ArenaDemo.with_surf_probe { $game_player.passable?($game_player.x, $game_player.y, $game_player.direction) }
    else
      native_surf_check.call(move, pokemon, showmsg)
    end
  end)
end
