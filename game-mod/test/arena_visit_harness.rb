# frozen_string_literal: true
require 'minitest/autorun'
require 'socket'
require 'timeout'
require_relative '../../upstream/pokemon-essentials-mmo-kit/protocol/pemk_wire'
require_relative '../../upstream/pokemon-essentials-mmo-kit/server/lib/pemk/reactor'
require_relative '../../upstream/pokemon-essentials-mmo-kit/server/lib/pemk/plain_text'
require_relative '../../upstream/pokemon-essentials-mmo-kit/server/lib/pemk/peer_sessions'
require_relative '../../upstream/pokemon-essentials-mmo-kit/server/lib/pemk/rate_limiter'
require_relative '../../upstream/pokemon-essentials-mmo-kit/server/lib/pemk/server'
require_relative '../server/arena_visits'

# Real upstream reactor, wire codec, frame gate, zones and relay methods.
# Authentication is injected by the harness; no accounts or DB are touched.
class ArenaVisitHarness < PEMK::Server
  attr_reader :reactor, :errors
  def initialize
    @config = Struct.new(:flood_guard, :relay_guard, :presence_dedup, :bind).new(false, true, true, '0.0.0.0')
    @peers = PEMK::PeerSessions.new
    @invite_limiter = PEMK::RateLimiter.new(max: 5, per: 25)
    @pending_trades = {}
    @zones = Hash.new { |hash, key| hash[key] = Set.new }
    @zone_legacy, @online = {}, {}
    @errors = []
    @log = ->(message) { @errors << message }
    @pos_audit = Object.new
    def @pos_audit.check(_id, env, data); data[:last_pos] = env.values_at(:map, :x, :y); end
    @next_id = 0
    @reactor = PEMK::Reactor.new(host: '0.0.0.0', port: 0, on_frame: ->(conn, payload) {
      unless conn.data[:account_id]
        @next_id += 1
        conn.data[:account_id] = @next_id
        conn.data[:presence_v2] = true
        @online[@next_id] = conn
      end
      on_frame(conn, payload)
    }, on_close: ->(conn) {
      arena_close(conn) if arena_room(conn)
      arena_detach_zone(conn)
      @online.delete(conn.data[:account_id])
    })
  end
  def mode_refused?(*); false; end
  def field_audit(*); end
end

module ArenaVisitTestSupport
  def setup
    @backend = ArenaVisitHarness.new
    @backend.reactor.start
    @thread = Thread.new { @backend.reactor.run_loop }
    @clients = []
  end
  def teardown
    @clients.each { |socket| socket.close unless socket.closed? }
    @backend.reactor.stop
    @thread.join(2)
    assert_empty @backend.errors.grep(/handler error|tick error/)
  end
  def send_frame(socket, frame)
    socket.write(PEMK::Wire.encode_split(frame))
  end
  def receive(socket)
    Timeout.timeout(3) do
      length = socket.read(4)
      raise 'Closed socket' unless length
      PEMK::Wire.decode_envelope(socket.read(length.unpack1('N')), false).fetch(:env)
    end
  end
  def until_type(socket, type)
    15.times do
      frame = receive(socket)
      return frame if frame[:type] == type
    end
    flunk "Missing #{type}"
  end
  def connect
    socket = TCPSocket.new('127.0.0.1', @backend.reactor.port)
    @clients << socket
    send_frame(socket, type: :arena_hello)
    assert_equal :arena_ready, receive(socket)[:type]
    send_frame(socket, type: :pos, map: 102, x: 4, y: 6)
    # Round trip ensures presence was processed before open/accept.
    send_frame(socket, type: :ping, t: 1)
    pong = receive(socket)
    assert_equal :pong, pong[:type]
assert_equal 12, pong[:arena_visits]
    assert_equal '0.0.0.0', pong[:arena_bind]
    socket
  end
  def open_room(host, objects = [0, 2], layout = 1)
    surface = '0' * 10000
    (37..61).each { |y| (37..61).each { |x| surface.setbyte(y * 100 + x, 49) } }
    send_frame(host, type: :arena_open, objects: objects, layout: layout, difficulty: 2,
      surface: surface, relief: '0' * 10000, styles: '0' * 10000, placements: [])
    frame = until_type(host, :arena_state)
    assert_equal :host, frame[:role]
    send_frame(host, type: :pos, map: 102, x: 4, y: 6)
    frame
  end
  def join(host, guest, room)
    send_frame(host, type: :arena_invite, to: 2)
    invitation = until_type(guest, :arena_invitation)
    assert_equal room[:room], invitation[:room]
    until_type(host, :arena_notice)
    send_frame(guest, type: :arena_accept, room: invitation[:room], host: 1)
    joined = until_type(guest, :arena_state)
    assert_equal :guest, joined[:role]
    assert_equal room.values_at(:objects, :layout, :difficulty), joined.values_at(:objects, :layout, :difficulty)
    until_type(host, :arena_state)
    send_frame(guest, type: :pos, map: 102, x: 8, y: 10)
    joined
  end

end
