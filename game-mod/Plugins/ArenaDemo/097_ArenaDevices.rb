module ArenaDemo::Devices
  module_function

  def scope; ArenaDemo::FieldObstacles.scope; end
  def install
    # Following EX aliases player methods after ArenaDemo loads. Prepending
    # afterwards prevents its alias from pointing back into this wrapper.
    Game_Player.prepend(ArenaDemo::DevicePlayerMovement) unless Game_Player.ancestors.include?(ArenaDemo::DevicePlayerMovement)
    Sprite_Character.prepend(ArenaDemo::DeviceCharacterArt) unless Sprite_Character.ancestors.include?(ArenaDemo::DeviceCharacterArt)
    if defined?(FollowingPkmn) && !FollowingPkmn.singleton_class.ancestors.include?(ArenaDemo::DeviceFollowerVisibility)
      FollowingPkmn.singleton_class.prepend(ArenaDemo::DeviceFollowerVisibility)
    end
  end
  def network?; ArenaDemo::FieldObstacles.network?; end
  def editing?; ArenaDemo.instance_variable_get(:@custom_mode_active); end
  def active?; $game_map && $game_map.map_id == ArenaDemo::MAP_ID && !editing?; end

  def disabled
    current = scope
    @disabled_scope, @disabled = current, [] if @disabled_scope != current
    @disabled ||= []
  end

  def apply_disabled(values)
    pbSEPlay('Arena Tesla Button') if @disabled_scope == scope && (values - disabled).any?
    @disabled_scope, @disabled, @button_pending = scope, values.dup, nil
    ArenaDemo::DeviceAmbience.update
  end

  def clear
    @web_hiding = false
    @effect_hiding = {}
    end_transport(false)
    ArenaDemo::DeviceAmbience.stop
    (@spark_sprites || []).each(&:dispose)
    @spark_sprites = []
    @darkness&.dispose unless @darkness&.disposed?
    @darkness = nil
    @blind = @forced = @queued = false
    @blind_until = nil
    @disabled_scope = @disabled = @point = @blocked_at = @button_pending = @teleport_latch = nil
    @chain = []
  end

  def wire; ArenaDemo.device_wire(ArenaDemo.custom_placements); end
  def bind_sparks(values)
    @spark_wire = values
  end

  def update_sparks
    unless $game_map && $game_map.map_id == ArenaDemo::MAP_ID && $scene.is_a?(Scene_Map)
      (@spark_sprites || []).each(&:dispose)
      @spark_sprites = []
      return
    end
    values = editing? ? (@spark_wire || wire) : wire
    points = ArenaDevices.sparks(values, editing? ? [] : disabled).values
    @spark_sprites ||= []
    @spark_sprites.pop.dispose while @spark_sprites.length > points.length
    points.each_with_index do |(x, y), index|
      sprite = @spark_sprites[index]
      sprite = @spark_sprites[index] = Sprite.new(Spriteset_Map.viewport) if !sprite || sprite.disposed?
      sprite.bitmap = ArenaDemo::DeviceArt.spark((System.uptime * ArenaDemo::DeviceArt::SPARK_FPS).floor % ArenaDemo::DeviceArt::SPARK_FRAMES)
      sprite.x = x * 32 - $game_map.display_x.to_f / Game_Map::X_SUBPIXELS
      sprite.y = y * 32 - $game_map.display_y.to_f / Game_Map::Y_SUBPIXELS
      sprite.z = 80
    end
  end
  def object_at(x, y)
    ArenaDevices.furniture(wire).find { |entry| entry[2, 2] == [x, y] }
  end

  def web_step?(player)
    return false unless active?
    start = [player.instance_variable_get(:@move_initial_x), player.instance_variable_get(:@move_initial_y)]
    objects = ArenaDevices.furniture(wire)
    objects.any? { |p| p[1] == ArenaDevices::WEB && [start, [player.x, player.y]].include?(p[2, 2]) }
  end

  def forcing?; active? && (@busy || @queued || @forced); end
  def sliding?; active? && !!@transport_kind; end
  def magnet_facing
    return nil unless @transport_kind == :magnet && @magnet_started
    [2,4,8,6][((System.uptime - @magnet_started) * 16 / 1.25).floor % 4]
  end
  def hiding_follower?; !!(@transport_kind || @web_hiding || (@effect_hiding && @effect_hiding.values.any?)); end

  def hide_for_effect(reason, hidden)
    @effect_hiding ||= {}
    @effect_hiding[reason] = hidden
    sync_follower_visibility
  end

  def sync_follower_visibility
    return unless defined?(FollowingPkmn)
    changed = false
    if hiding_follower?
      if FollowingPkmn.active? && !FollowingPkmn.hidden?
        @restore_follower = true
        FollowingPkmn.hide_follower
        changed = true
      end
    elsif @restore_follower
      @restore_follower = nil
      FollowingPkmn.unhide_follower(false)
      ArenaDemo::FollowingIntegration.settle_local_follower if defined?(ArenaDemo::FollowingIntegration)
      changed = true
    end
    PEMK::Presence.emit_now(:pos) if changed && defined?(PEMK::Presence)
  end

  def update_web_follower
    @web_hiding = active? && $game_player &&
      if $game_player.moving?
        web_step?($game_player)
      else
        ArenaDevices.furniture(wire).any? { |p| p[1] == ArenaDevices::WEB && p[2,2] == [$game_player.x,$game_player.y] }
      end
    sync_follower_visibility
  end

  def begin_transport(kind)
    return if @transport_kind == kind
    end_transport
    @transport_kind, @transport_player = kind, $game_player
    @transport_animation = [$game_player.walk_anime, $game_player.instance_variable_get(:@step_anime)]
    $game_player.walk_anime = false
    $game_player.instance_variable_set(:@step_anime, false)
    $game_player.instance_variable_set(:@arena_device_sliding, true)
    $game_player.pattern = $game_player.instance_variable_get(:@original_pattern) || 0
    sync_follower_visibility
    if kind == :magnet
      @magnet_started = System.uptime
    end
    ArenaDemo::DeviceAmbience.update
    PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
  end

  def end_transport(update_audio = true)
    player, animation = @transport_player, @transport_animation
    @transport_kind = @transport_player = @transport_animation = nil
    if player && animation
      player.walk_anime = animation[0]
      player.instance_variable_set(:@step_anime, animation[1])
      player.instance_variable_set(:@arena_device_sliding, false)
      player.direction = @transport_exit_direction if @transport_exit_direction
    end
    @magnet_started = @transport_exit_direction = nil
    ArenaDemo::DeviceAmbience.update if update_audio
    sync_follower_visibility
    PEMK::Presence.emit_now(:pos) if player && defined?(PEMK::Presence)
  end

  def update_blindness(now = System.uptime)
    if @blind_until && now >= @blind_until
      @darkness&.dispose unless @darkness&.disposed?
      @darkness, @blind_until, @blind = nil, nil, false
    end
    if @darkness
      @darkness.visible = $scene.is_a?(Scene_Map) && !$game_temp.in_battle
      @darkness.update
    end
  end

  def stepped(event)
    return unless active? && event.equal?($game_player) && !@busy
    @queued = true
  end

  def push_button(slot)
    coil = ArenaDevices.partner(wire, slot)
    return unless coil && !disabled.include?(coil)
    return if @button_pending && System.uptime - @button_pending < 3
    if network?
      PEMK::Presence.emit_now(:pos)
      @button_pending = System.uptime if ArenaDemo::Visits.send_request(:arena_device_request,
        :room => ArenaDemo::Visits.scope, :slot => slot)
    else
      disabled << coil
      ArenaDemo::DeviceAmbience.update
      pbSEPlay('Arena Tesla Button')
      ArenaDemo.refresh_custom_placements
    end
  end

  def teleport_phase(outgoing)
    started = System.uptime
    loop do
      fraction = [(System.uptime - started) / 0.45, 1.0].min
      scale = outgoing ? 1.0 - fraction * 0.95 : 0.05 + fraction * 0.95
      $game_player.instance_variable_set(:@arena_teleport_scale, scale)
      $game_player.direction = [2, 4, 8, 6][(fraction * 12).floor % 4]
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break if fraction == 1.0
    end
  end

  def teleport(target)
    return if @teleport_latch == [$game_player.x, $game_player.y]
    return if $game_map.events.values.any? { |event| !event.through && !event.transparent && [event.x, event.y] == target }
    player, direction = $game_player, $game_player.direction
    previous_menu = $game_temp.in_menu
    menu_captured = true
    $game_temp.in_menu = true
    @busy = true
    hide_for_effect(:teleport, true)
    PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
    # Reuse the installed Pokemon teleport sound; no external audio is bundled.
    pbSEPlay('Arena HGSS Teleport')
    teleport_phase(true)
    player.moveto(*target)
    @teleport_latch = target
    $game_temp.followers&.map_transfer_followers
    PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
    teleport_phase(false)
  ensure
    player&.instance_variable_set(:@arena_teleport_scale, nil)
    player.direction = direction if player && direction
    $game_temp.in_menu = previous_menu if menu_captured
    @busy = false
    hide_for_effect(:teleport, false) if player
    PEMK::Presence.emit_now(:pos) if player && defined?(PEMK::Presence)
  end

  def update
    ArenaDemo::DeviceAmbience.update
    return if @busy
    map = $game_map&.map_id
    if @map != map
      previous = @map
      @map = map
      clear if previous == ArenaDemo::MAP_ID
    end
    update_sparks
    update_web_follower
    return unless active? && $scene.is_a?(Scene_Map) && $game_temp && $game_player
    update_blindness
    return if $game_temp.in_battle || $game_temp.in_menu || $game_temp.message_window_showing || pbMapInterpreterRunning?
    return if $game_player.moving? || $game_player.jumping? || $game_player.move_route_forcing || $game_player.lock?
    point = [$game_player.x, $game_player.y]
    if @point != point || @queued
      @blocked_at = nil if @point != point
      @teleport_latch = nil if @teleport_latch && point != @teleport_latch
      @point, @queued = point, false
      objects = ArenaDevices.furniture(wire)
      slot = objects.index { |p| p[2, 2] == point }
      item = slot && objects[slot][1]
      push_button(slot) if item == ArenaDevices::BUTTON
      if item == ArenaDevices::RUNE
        pbSEPlay('Arena Blind Rune') if FileTest.audio_exist?('Audio/SE/Arena Blind Rune')
        @blind = true
        @blind_until = System.uptime + 60.0
        @darkness ||= ArenaDemo::DeviceDarkness.new
      end
      if item == ArenaDevices::TELEPORT && @teleport_latch != point
        end_transport
        target = ArenaDevices.teleport_target(wire, *point)
        teleport(target) if target
        @forced = false
        return
      end
      direction = ArenaDevices::CONVEYORS.include?(item) ? ArenaDevices.direction(item)[0] : ArenaDevices.attraction(wire, *point)
      if direction && @blocked_at != point
        @chain ||= []
        if @chain.include?(point) || @chain.length >= 200
          @blocked_at, @forced = point, false
          @chain = []
          end_transport
          return
        end
        if $game_player.can_move_in_direction?(direction)
          @chain << point
          @forced = true
          begin_transport(ArenaDevices::CONVEYORS.include?(item) ? :conveyor : :magnet)
          @transport_exit_direction = direction if @transport_kind == :magnet
          $game_player.move_generic(direction)
        else
          @blocked_at, @forced, @chain = point, false, []
          end_transport
        end
      else
        @forced, @chain = false, []
        end_transport
      end
    end
    # Retry only while standing on a button whose response was lost.
    if @button_pending && System.uptime - @button_pending >= 3
      @button_pending = nil
      @queued = true
    end
  end
end

class ArenaDemo::DeviceDarkness < DarknessSprite
  def refresh
    @center = [$game_player.screen_x, $game_player.screen_y - 16]
    @darkness.fill_rect(0, 0, Graphics.width, Graphics.height, Color.black)
    cx, cy = @center
    radius = @radius
    (1..5).each do |fade|
      (cx - radius..cx + radius).each do |x|
        height = Math.sqrt([radius * radius - (x - cx)**2, 0].max)
        @darkness.fill_rect(x, cy - height, 1, height * 2, Color.new(0, 0, 0, 255.0 * (5 - fade) / 5))
      end
      radius = (radius * 0.9).floor
    end
  end
  def update
    super
    refresh if @center != [$game_player.screen_x, $game_player.screen_y - 16]
  end
end

module ArenaDemo::DevicePlayerMovement
  def update_pattern
    if ArenaDemo::Devices.sliding?
      @pattern = @original_pattern || 0
      direction = ArenaDemo::Devices.magnet_facing
      if direction && @direction != direction
        self.direction = direction
        PEMK::Presence.emit_now(:dir) if defined?(PEMK::Presence)
      end
      return
    end
    super
  end

  def update_command_new
    return if ArenaDemo::Devices.forcing?
    super
  end

  def update_move
    previous = @move_time
    slow = ArenaDemo::Devices.web_step?(self)
    @move_time = previous * 4 if slow && previous
    super
  ensure
    @move_time = previous if slow && previous && @move_time == previous * 4
  end
end
module ArenaDemo::DeviceFollowerVisibility
  def unhide_follower(*args)
    return if ArenaDemo::Devices.hiding_follower?
    super
  end
end
EventHandlers.add(:on_step_taken, :arena_devices, proc { |event| ArenaDemo::Devices.stepped(event) })
EventHandlers.add(:on_frame_update, :arena_devices, proc { ArenaDemo::Devices.install; ArenaDemo::Devices.update })
