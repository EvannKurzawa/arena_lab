# frozen_string_literal: true
require 'securerandom'
require_relative '../Plugins/ArenaDemo/000_ReliefRules'
require_relative '../Plugins/ArenaDemo/000_FieldStateRules'

# Reactor-owned, temporary rooms. Loaded after PEMK by our launcher.
module ArenaVisitsServer
  MAPS = [100, 102].freeze
  ARENA_OFFSET = (100 - 25) / 2
  ARENA_SIZE = 25
  ARENA_START = [ARENA_OFFSET + 12, ARENA_OFFSET + 16].freeze
  ARENA_GUIDE = [ARENA_OFFSET + 10, ARENA_OFFSET + 16].freeze
  ARENA_TRAINER = [ARENA_OFFSET + 12, ARENA_OFFSET + 4].freeze
  ARENA_EXIT = [ARENA_OFFSET + 12, ARENA_OFFSET + 18].freeze
  ARENA_MAP_WIDTH = 100
  ARENA_MAP_HEIGHT = 100
  ARENA_SURFACE_BYTES = ARENA_MAP_WIDTH * ARENA_MAP_HEIGHT
  ARENA_MAX_PLACEMENTS = 96
  POSITIONS = [
    [[5, 6], [5, 9], [5, 12], [19, 6], [19, 9], [19, 12]],
    [[8, 6], [16, 8], [8, 10], [16, 12], [8, 14], [16, 14]],
    [[9, 7], [12, 7], [15, 7], [9, 11], [12, 11], [15, 11]]
  ].freeze
  TYPES = %i[
    arena_hello arena_open arena_invite arena_accept arena_decline arena_close
    arena_visit_request arena_visit_accept arena_visit_decline
    arena_field_request
  ].freeze

  def dispatch_frame(conn, env, type, authed, body)
    return reply(conn, type: :pong, t: ping_t(env[:t]), arena_visits: 12, arena_bind: @config.bind) if type == :ping
    if conn.data[:arena_local_world] && type == :save
      return reply(conn, type: :save_err, seq: env[:seq], reason: 'local_world')
    end
    return super unless TYPES.include?(type)
    return unless authed && !conn.closing && @online[authed].equal?(conn)
    return arena_error(conn, 'Unexpected body') if body
    if type == :arena_hello
      arena_detach_zone(conn)
      conn.data[:arena_cap] = true
      conn.data[:arena_local_world] ||= env[:local_world] == true
      return reply(conn, type: :arena_ready, version: 12)
    end
    return arena_error(conn, 'Restart the updated client') unless conn.data[:arena_cap]
    case type
    when :arena_open then arena_open(conn, env)
    when :arena_invite then arena_invite(conn, env)
    when :arena_accept then arena_accept(conn, env)
    when :arena_decline then arena_decline(conn, env)
    when :arena_close then arena_close(conn)
    when :arena_visit_request then arena_visit_request(conn)
    when :arena_visit_accept then arena_visit_decision(conn, env, true)
    when :arena_visit_decline then arena_visit_decision(conn, env, false)
    when :arena_field_request then arena_field_request(conn, env)
    end
  end

  def arena_error(conn, reason)
    reply(conn, type: :arena_error, reason: reason)
  end

  def arena_room(conn)
    conn.data[:arena_room]
  end

  def arena_open(conn, env)
    return arena_error(conn, 'An arena session is already open') if arena_room(conn)
    return arena_error(conn, 'Open your arena from its entrance room') unless conn.data[:map_id] == 102
    objects, layout, difficulty, surface, placements = env.values_at(
      :objects, :layout, :difficulty, :surface, :placements
    )
    valid = objects.is_a?(Array) && objects.length <= 6 && objects.uniq == objects &&
            objects.all? { |id| id.is_a?(Integer) && id.between?(0, 5) } &&
            layout.is_a?(Integer) && layout.between?(0, 2) &&
            difficulty.is_a?(Integer) && difficulty.between?(0, 2) &&
            valid_arena_surface?(surface) && valid_arena_placements?(placements, surface) &&
            ArenaRelief.valid?(env[:relief], surface,
              [ARENA_START, ARENA_GUIDE, ARENA_TRAINER, ARENA_EXIT], placements) &&
            ArenaRelief.valid_styles?(env[:styles], env[:relief])
    return arena_error(conn, 'Invalid or oversized arena customization. Reopen the game and try again.') unless valid
    room = { token: SecureRandom.hex(12), host: conn, guest: nil, field_states: {}, field_revision: 0,
             objects: objects.dup.freeze, layout: layout, difficulty: difficulty,
             surface: surface.dup.freeze,
             relief: env[:relief].dup.freeze,
             styles: env[:styles].dup.freeze,
             placements: placements.map { |entry| entry.dup.freeze }.freeze }
    arena_detach_zone(conn)
    conn.data[:arena_room] = room
    arena_state(conn)
  end

  def arena_state(conn)
    room = arena_room(conn)
    return reply(conn, type: :arena_state, phase: :closed) unless room
    reply(conn, type: :arena_state, phase: :open, room: room[:token],
          role: room[:host].equal?(conn) ? :host : :guest,
          host: room[:host].data[:account_id], guest: room[:guest]&.data&.fetch(:account_id),
          objects: room[:objects], layout: room[:layout], difficulty: room[:difficulty],
          surface: room[:surface], relief: room[:relief], styles: room[:styles], placements: room[:placements],
          field_states: room[:field_states], field_revision: room[:field_revision])
  end

  def arena_field_state(conn, room, extra = {})
    reply(conn, **{ type: :arena_field_state, room: room[:token], field_states: room[:field_states],
                   field_revision: room[:field_revision] }.merge(extra)) unless conn.closing
  end

  def arena_broadcast_field(room, extra = {})
    [room[:host], room[:guest]].compact.each { |member| arena_field_state(member, room, extra) }
  end

  def arena_reset_field_if_empty(room)
    return if room[:field_states].empty?
    return if [room[:host], room[:guest]].compact.any? { |c| !c.closing && c.data[:map_id] == 100 }
    room[:field_states] = {}
    room[:field_revision] += 1
    arena_broadcast_field(room)
  end

  def arena_field_request(conn, env)
    room = arena_room(conn)
    return arena_error(conn, 'No shared arena room') unless room && env[:room] == room[:token]
    reject = -> { arena_field_state(conn, room, request: env[:request], actor: conn.data[:account_id], rejected: true) }
    return reject.call unless conn.data[:map_id] == 100 && env[:field_revision].is_a?(Integer) &&
                              env[:field_revision] == room[:field_revision]
    slot, move, direction = env.values_at(:slot, :move, :direction)
    return reject.call unless env[:request].is_a?(Integer) && env[:request].between?(1, 0x7fffffff) &&
                              ArenaFieldState::DIRECTIONS.key?(direction) && slot.is_a?(Integer) && slot >= 0
    object = ArenaFieldState.furniture(room[:placements])[slot]
    return reject.call unless object
    point = room[:field_states].fetch(slot, object[2, 2])
    dx, dy = ArenaFieldState::DIRECTIONS.fetch(direction)
    position = conn.data[:last_pos]
    return reject.call unless point && position && position[0] == 100 &&
                              [position[1] + dx, position[2] + dy] == point
    players = [room[:host], room[:guest]].compact.filter_map do |member|
      pos = member.data[:last_pos]
      pos[1, 2] if !member.closing && pos && pos[0] == 100
    end
    proposed = ArenaFieldState.proposal(room[:placements], room[:field_states], slot, move, direction,
      room[:surface], room[:relief], [ARENA_START, ARENA_GUIDE, ARENA_TRAINER, ARENA_EXIT], players)
    return reject.call unless proposed
    room[:field_states] = proposed
    room[:field_revision] += 1
    arena_broadcast_field(room, request: env[:request], actor: conn.data[:account_id])
  end

  def valid_arena_surface?(surface)
    return false unless ArenaMaterials.valid_surface?(surface)
    [ARENA_START, ARENA_GUIDE, ARENA_TRAINER, ARENA_EXIT].all? do |x, y|
      !ArenaRelief.blocked_surface?(surface, x, y)
    end
  end

  def valid_arena_placements?(placements, surface)
    return false unless placements.is_a?(Array) && placements.length <= ARENA_MAX_PLACEMENTS
    occupied = {}
    placements.all? do |entry|
      next false unless entry.is_a?(Array) && entry.length == 4
      kind, item, x, y = entry
      next false unless [0, 1].include?(kind) && item.is_a?(String) &&
                        item.match?(/\A[A-Z0-9_]{1,48}\z/) &&
                        x.is_a?(Integer) && x.between?(0, ARENA_MAP_WIDTH - 1) &&
                        y.is_a?(Integer) && y.between?(0, ARENA_MAP_HEIGHT - 1)
      point = [x, y]
      next false if occupied[point] || [ARENA_START, ARENA_GUIDE, ARENA_TRAINER, ARENA_EXIT].include?(point)
      next false if ArenaRelief.blocked_surface?(surface, x, y)
      occupied[point] = true
    end
  end

  def arena_invite(conn, env)
    room = arena_room(conn)
    return arena_error(conn, 'Open your arena first') unless room && room[:host].equal?(conn)
    return arena_error(conn, 'Your visitor must leave before inviting someone else') if room[:guest]
    target = env[:to].is_a?(Integer) && @online[env[:to]]
    unless target && !target.equal?(conn) && !target.closing && target.data[:arena_cap] && !arena_room(target)
      return arena_error(conn, 'That account is offline, busy, or needs the updated client')
    end
    if (invited = room[:invited]) && invited != target.data[:account_id]
      old = @online[invited]
      reply(old, type: :arena_invitation_cancelled, room: room[:token]) if old
    end
    room[:invited] = target.data[:account_id]
    room[:deadline] = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 60
    reply(target, type: :arena_invitation, room: room[:token], host: conn.data[:account_id])
    reply(conn, type: :arena_notice, text: 'Invitation sent. It expires in 60 seconds. Close your arena to customize it again.')
  end

  def arena_accept(conn, env)
    host = env[:host].is_a?(Integer) && @online[env[:host]]
    room = host && arena_room(host)
    valid = room && room[:host].equal?(host) && room[:token] == env[:room] &&
            room[:invited] == conn.data[:account_id] && !room[:guest] &&
            !arena_room(conn) && room[:deadline] > Process.clock_gettime(Process::CLOCK_MONOTONIC)
    return arena_error(conn, 'That invitation has expired or the arena closed') unless valid
    return arena_error(conn, 'Accept invitations from your entrance room') unless conn.data[:map_id] == 102
    arena_detach_zone(conn)
    conn.data[:arena_room] = room
    conn.data[:arena_arriving] = true
    room[:guest] = conn
    room.delete(:invited)
    arena_state(host)
    arena_state(conn)
  end

  def arena_decline(conn, env)
    host = env[:host].is_a?(Integer) && @online[env[:host]]
    room = host && arena_room(host)
    return unless room && room[:token] == env[:room] && room[:invited] == conn.data[:account_id]
    room.delete(:invited)
    reply(host, type: :arena_notice, text: 'Invitation declined. Close the arena to customize it again.')
    reply(conn, type: :arena_invitation_cancelled, room: room[:token])
  end

  # A visitor is identified by their authenticated socket; no account ID is
  # exposed to either player or typed by hand. Each host with one open arena
  # receives an accept/decline prompt. A single request may be pending per room.
  def arena_visit_request(conn)
    return arena_error(conn, 'Request a visit from your entrance room') unless conn.data[:map_id] == 102
    return arena_error(conn, 'You are already in an arena session') if arena_room(conn) || conn.data[:arena_visit_request]
    rooms = @online.values.uniq.filter_map do |candidate|
      room = arena_room(candidate)
      room if room && room[:host].equal?(candidate) && !candidate.closing
    end.uniq
    return arena_error(conn, 'No one is hosting an arena right now') if rooms.empty?
    return arena_error(conn, 'More than one arena is open on this host. Ask one host to close theirs.') unless rooms.length == 1
    room = rooms.first
    return arena_error(conn, 'The host already has a visitor or pending request') if room[:guest] || room[:visit_request]
    request = {
      :token => SecureRandom.hex(12), :room => room, :guest => conn,
      :deadline => Process.clock_gettime(Process::CLOCK_MONOTONIC) + 60
    }
    room[:visit_request] = request
    conn.data[:arena_visit_request] = request
    reply(room[:host], type: :arena_visit_request, request: request[:token])
    reply(conn, type: :arena_visit_pending)
  end

  def arena_visit_decision(host, env, accept)
    room = arena_room(host)
    request = room && room[:visit_request]
    valid = room && room[:host].equal?(host) && request &&
            env[:request].is_a?(String) && env[:request] == request[:token] &&
            request[:deadline] > Process.clock_gettime(Process::CLOCK_MONOTONIC)
    return arena_error(host, 'That visit request expired or was cancelled') unless valid
    guest = request[:guest]
    valid_guest = !guest.closing && @online[guest.data[:account_id]].equal?(guest) &&
                  guest.data[:map_id] == 102 && !arena_room(guest)
    unless valid_guest
      room.delete(:visit_request)
      guest.data.delete(:arena_visit_request)
      return arena_error(host, 'The visitor is no longer available')
    end
    room.delete(:visit_request)
    guest.data.delete(:arena_visit_request)
    unless accept
      reply(guest, type: :arena_visit_declined)
      reply(host, type: :arena_notice, text: 'Visit request declined.')
      return
    end
    room[:guest] = guest
    guest.data[:arena_room] = room
    guest.data[:arena_arriving] = true
    arena_state(host)
    arena_state(guest)
  end

  def arena_cancel_visit_request(conn)
    request = conn.data.delete(:arena_visit_request)
    return unless request
    room = request[:room]
    return unless room && room[:visit_request].equal?(request)
    room.delete(:visit_request)
    host = room[:host]
    reply(host, type: :arena_visit_cancelled) if host && !host.closing
  end

  def arena_cancel_pending_visit(room, reason)
    request = room.delete(:visit_request)
    return unless request
    guest = request[:guest]
    guest.data.delete(:arena_visit_request)
    reply(guest, type: reason) if guest && !guest.closing
  end

  def expire_visit_requests
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @online.values.uniq.each do |host|
      room = arena_room(host)
      next unless room && room[:host].equal?(host)
      request = room[:visit_request]
      next unless request && request[:deadline] <= now
      room.delete(:visit_request)
      guest = request[:guest]
      guest.data.delete(:arena_visit_request)
      reply(guest, type: :arena_visit_expired) if guest && !guest.closing
      reply(host, type: :arena_visit_expired) unless host.closing
    end
  end

  def arena_close(conn)
    room = arena_room(conn)
    return arena_state(conn) unless room
    if room[:host].equal?(conn)
      arena_cancel_pending_visit(room, :arena_visit_cancelled)
      if (invited = @online[room[:invited]])
        reply(invited, type: :arena_invitation_cancelled, room: room[:token])
      end
      members = [conn, room[:guest]].compact
      peers_gone(conn.data[:account_id]) if @config.relay_guard
      members.each { |member| arena_detach_zone(member) }
      members.each do |member|
        member.data.delete(:arena_room)
        member.data.delete(:arena_arriving)
        arena_state(member) unless member.closing
      end
    else
      peers_gone(conn.data[:account_id]) if @config.relay_guard
      arena_detach_zone(conn)
      conn.data.delete(:arena_room)
      conn.data.delete(:arena_arriving)
      room[:guest] = nil
      arena_reset_field_if_empty(room)
      arena_state(conn) unless conn.closing
      arena_state(room[:host]) unless room[:host].closing
    end
  end

  def arena_detach_zone(conn)
    zone_leave(conn, conn.data[:zone], conn.data[:account_id]) if conn.data[:zone]
    %i[presence_content presence_body sync_at].each { |key| conn.data.delete(key) }
  end

  def arena_scope(conn, map)
    return :legacy unless [100, 101, 102].include?(map) && conn.data[:arena_cap]
    arena_room(conn)&.fetch(:token) || conn.data[:account_id]
  end

  def broadcast_zone(map, sender, frame)
    return super unless [100, 101, 102].include?(map)
    @zones.fetch(map, []).each do |peer|
      @reactor.send_frame(peer, frame) if !peer.equal?(sender) && arena_scope(peer, map) == arena_scope(sender, map)
    end
  end

  def broadcast_legacy(map, sender, frame)
    return super unless [100, 101, 102].include?(map)
    (@zone_legacy[map] || []).each do |peer|
      @reactor.send_frame(peer, frame) if !peer.equal?(sender) && arena_scope(peer, map) == arena_scope(sender, map)
    end
  end

  def send_snapshot(conn, map)
    return super unless [100, 101, 102].include?(map)
    frames = @zones.fetch(map, []).filter_map do |peer|
      peer.data[:presence_body] if !peer.equal?(conn) && !peer.closing && arena_scope(conn, map) == arena_scope(peer, map)
    end
    @reactor.send_frame(conn, frames.join) unless frames.empty?
  end

  def presence_frame(env, account, map)
    frame = super.merge(arena_room: arena_scope(@online.fetch(account), map))
    return frame unless [100, 101, 102].include?(map)
    species = env[:follower_species]
    species = "" unless species.is_a?(String) && species.match?(/\A[A-Z0-9_]{1,32}\z/)
    form = env[:follower_form].is_a?(Integer) ? env[:follower_form] : 0
    gender = env[:follower_gender].is_a?(Integer) ? env[:follower_gender] : 0
    form = 0 unless form.between?(0, 255)
    gender = 0 unless gender.between?(0, 2)
    frame.merge(
      follower_species: species,
      follower_form: form,
      follower_gender: gender,
      follower_shiny: env[:follower_shiny] == true,
      follower_shadow: env[:follower_shadow] == true
    )
  end

  def handle_addressed(sender, env, body, account)
    target = @online[env[:to]]
    if target && (sender.data[:arena_cap] || target.data[:arena_cap]) &&
       (MAPS.include?(sender.data[:map_id]) || MAPS.include?(target.data[:map_id]) || arena_room(sender) || arena_room(target))
      room = arena_room(sender)
      return unless room && room.equal?(arena_room(target))
    end
    super
  end

  def handle_presence(conn, env, account)
    room = arena_room(conn)
    return super unless room
    map, x, y = env.values_at(:map, :x, :y)
    valid = MAPS.include?(map) && x.is_a?(Integer) && y.is_a?(Integer)
    valid &&= if map == 100
                x.between?(0, ARENA_MAP_WIDTH - 1) && y.between?(0, ARENA_MAP_HEIGHT - 1) &&
                  ArenaMaterials.traversable?(room[:surface], x, y, env[:mode]) &&
                  ![ARENA_GUIDE, ARENA_TRAINER, ARENA_EXIT].include?([x, y]) &&
                  ArenaFieldState.effective(room[:placements], room[:field_states]).none? { |_kind, _item, px, py| [px, py] == [x, y] }
              else
                (1..13).include?(x) && (1..11).include?(y) &&
                  ![[7, 2], [10, 3], [10, 4], [4, 5]].include?([x, y])
              end
    if conn.data[:arena_arriving]
      valid &&= [map, x, y] == [102, 8, 10]
    elsif (previous = conn.data[:last_pos]) && previous[0] == map
      trapped = map == 100 && ArenaMaterials.ground_at(room[:surface], previous[1], previous[2]) == 'quicksand'
      if trapped
        valid &&= [x, y] == ARENA_START || [x, y] == previous[1, 2]
      else
        valid &&= (previous[1] - x).abs + (previous[2] - y).abs <= 1
        valid &&= ArenaRelief.step?(room[:relief], previous[1], previous[2], x, y) if map == 100
      end
    elsif previous && MAPS.include?(previous[0])
      valid &&= (map == 100 && [x, y] == ARENA_START) || (map == 102 && [x, y] == [7, 3])
    end
    unless valid
      point = conn.data[:last_pos]
      point = [102, 8, 10] if conn.data[:arena_arriving] || !point || !MAPS.include?(point[0])
      return reply(conn, type: :pos_correct, map: point[0], x: point[1], y: point[2])
    end
    # Dynamic room collisions replace the upstream static-map position audit.
    # All unrelated maps continue through the upstream audit.
    conn.data.delete(:arena_arriving)
    conn.data[:last_pos] = [map, x, y]
    conn.data[:map_id] = map
    arena_reset_field_if_empty(room)
    conn.data[:presence_seen] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    zone_leave(conn, conn.data[:zone], account) if conn.data[:zone] && conn.data[:zone] != map
    joined = conn.data[:zone] != map
    zone_join(conn, map) if joined
    frame = PEMK::Wire.encode_split(presence_frame(env, account, map))
    conn.data[:presence_body] = frame
    broadcast_zone(map, conn, frame)
    send_snapshot(conn, map) if joined || env[:sync] == true
    arena_field_state(conn, room) if map == 100 && (joined || env[:sync] == true)
  end

  def bind(conn, account)
    old = @online[account]
    arena_close(old) if old && !old.equal?(conn) && arena_room(old)
    super
  end

  def on_close(conn)
    arena_cancel_visit_request(conn)
    arena_close(conn) if arena_room(conn)
    super
  end

  def on_tick
    super
    expire_visit_requests
    return unless ENV['ARENA_MANAGED_SERVICE'] == '1'
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    if @online.empty?
      @arena_service_idle ||= now
      @reactor.stop if now - @arena_service_idle > 600
    else
      @arena_service_idle = nil
    end
  end
end

PEMK::Server.prepend(ArenaVisitsServer)
