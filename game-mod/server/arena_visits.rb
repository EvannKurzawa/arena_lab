# frozen_string_literal: true
require 'securerandom'

# Reactor-owned, temporary rooms. Loaded after PEMK by our launcher.
module ArenaVisitsServer
  MAPS = [100, 102].freeze
  POSITIONS = [
    [[5, 6], [5, 9], [5, 12], [19, 6], [19, 9], [19, 12]],
    [[8, 6], [16, 8], [8, 10], [16, 12], [8, 14], [16, 14]],
    [[9, 7], [12, 7], [15, 7], [9, 11], [12, 11], [15, 11]]
  ].freeze
  TYPES = %i[arena_hello arena_open arena_invite arena_accept arena_decline arena_close].freeze

  def dispatch_frame(conn, env, type, authed, body)
    return reply(conn, type: :pong, t: ping_t(env[:t]), arena_visits: 1, arena_bind: @config.bind) if type == :ping
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
      return reply(conn, type: :arena_ready, version: 1)
    end
    return arena_error(conn, 'Restart the updated client') unless conn.data[:arena_cap]
    case type
    when :arena_open then arena_open(conn, env)
    when :arena_invite then arena_invite(conn, env)
    when :arena_accept then arena_accept(conn, env)
    when :arena_decline then arena_decline(conn, env)
    when :arena_close then arena_close(conn)
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
    objects, layout, difficulty = env.values_at(:objects, :layout, :difficulty)
    valid = objects.is_a?(Array) && objects.length <= 6 && objects.uniq == objects &&
            objects.all? { |id| id.is_a?(Integer) && id.between?(0, 5) } &&
            layout.is_a?(Integer) && layout.between?(0, 2) &&
            difficulty.is_a?(Integer) && difficulty.between?(0, 2)
    return arena_error(conn, 'Invalid arena layout') unless valid
    room = { token: SecureRandom.hex(12), host: conn, guest: nil,
             objects: objects.dup.freeze, layout: layout, difficulty: difficulty }
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
          objects: room[:objects], layout: room[:layout], difficulty: room[:difficulty])
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

  def arena_close(conn)
    room = arena_room(conn)
    return arena_state(conn) unless room
    if room[:host].equal?(conn)
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
      arena_state(conn) unless conn.closing
      arena_state(room[:host]) unless room[:host].closing
    end
  end

  def arena_detach_zone(conn)
    zone_leave(conn, conn.data[:zone], conn.data[:account_id]) if conn.data[:zone]
    %i[presence_content presence_body sync_at].each { |key| conn.data.delete(key) }
  end

  def arena_scope(conn, map)
    return :legacy unless [100, 101, 102, 103].include?(map) && conn.data[:arena_cap]
    arena_room(conn)&.fetch(:token) || conn.data[:account_id]
  end

  def broadcast_zone(map, sender, frame)
    return super unless [100, 101, 102, 103].include?(map)
    @zones.fetch(map, []).each do |peer|
      @reactor.send_frame(peer, frame) if !peer.equal?(sender) && arena_scope(peer, map) == arena_scope(sender, map)
    end
  end

  def broadcast_legacy(map, sender, frame)
    return super unless [100, 101, 102, 103].include?(map)
    (@zone_legacy[map] || []).each do |peer|
      @reactor.send_frame(peer, frame) if !peer.equal?(sender) && arena_scope(peer, map) == arena_scope(sender, map)
    end
  end

  def send_snapshot(conn, map)
    return super unless [100, 101, 102, 103].include?(map)
    frames = @zones.fetch(map, []).filter_map do |peer|
      peer.data[:presence_body] if !peer.equal?(conn) && !peer.closing && arena_scope(conn, map) == arena_scope(peer, map)
    end
    @reactor.send_frame(conn, frames.join) unless frames.empty?
  end

  def presence_frame(env, account, map)
    super.merge(arena_room: arena_scope(@online.fetch(account), map))
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
                (((1..23).include?(x) && (1..17).include?(y)) || [x, y] == [12, 18]) &&
                  ![[10, 16], [12, 4]].include?([x, y]) &&
                  room[:objects].none? { |id| POSITIONS[room[:layout]][id] == [x, y] }
              else
                (1..13).include?(x) && (1..11).include?(y) &&
                  ![[7, 2], [10, 3], [10, 4], [4, 5]].include?([x, y])
              end
    if conn.data[:arena_arriving]
      valid &&= [map, x, y] == [102, 8, 10]
    elsif (previous = conn.data[:last_pos]) && previous[0] == map
      valid &&= (previous[1] - x).abs + (previous[2] - y).abs <= 1
    elsif previous && MAPS.include?(previous[0])
      valid &&= (map == 100 && [x, y] == [12, 16]) || (map == 102 && [x, y] == [7, 3])
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
    conn.data[:presence_seen] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    zone_leave(conn, conn.data[:zone], account) if conn.data[:zone] && conn.data[:zone] != map
    joined = conn.data[:zone] != map
    zone_join(conn, map) if joined
    frame = PEMK::Wire.encode_split(presence_frame(env, account, map))
    conn.data[:presence_body] = frame
    broadcast_zone(map, conn, frame)
    send_snapshot(conn, map) if joined || env[:sync] == true
  end

  def bind(conn, account)
    old = @online[account]
    arena_close(old) if old && !old.equal?(conn) && arena_room(old)
    super
  end

  def on_close(conn)
    arena_close(conn) if arena_room(conn)
    super
  end

  def on_tick
    super
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
