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

class ArenaVisitsServerTest < Minitest::Test
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
    assert_equal 2, pong[:arena_visits]
    assert_equal '0.0.0.0', pong[:arena_bind]
    socket
  end
  def open_room(host, objects = [0, 2], layout = 1)
    send_frame(host, type: :arena_open, objects: objects, layout: layout, difficulty: 2)
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

  def test_private_visit_layout_presence_restrictions_and_close
    host, guest, stranger = connect, connect, connect
    room = open_room(host)
    join(host, guest, room)
    guest_presence = until_type(host, :pos)
    assert_equal [2, room[:room], 8, 10], guest_presence.values_at(:id, :arena_room, :x, :y)
    assert_equal 1, until_type(guest, :pos)[:id]
    refute IO.select([stranger], nil, nil, 0.05), 'Private presence leaked'
    send_frame(guest, type: :pos, map: 101, x: 12, y: 6)
    assert_equal [102, 8, 10], until_type(guest, :pos_correct).values_at(:map, :x, :y)
    send_frame(host, type: :pos, map: 100, x: 12, y: 16)
    send_frame(guest, type: :pos, map: 100, x: 12, y: 16)
    until_type(host, :pos)
    until_type(guest, :pos)
    send_frame(guest, type: :pos, map: 100, x: 8, y: 6) # Host's slalom boulder
    assert_equal [100, 12, 16], until_type(guest, :pos_correct).values_at(:map, :x, :y)
    send_frame(host, type: :challenge, to: 2, name: 'Host')
    assert_equal 1, until_type(guest, :challenge)[:from]
    send_frame(guest, type: :challenge_accept, to: 1)
    assert_equal 2, until_type(host, :challenge_accept)[:from]
    send_frame(host, type: :battle_choice, to: 2, cmd: [0, 0])
    assert_equal [0, 0], until_type(guest, :battle_choice)[:cmd]
    send_frame(stranger, type: :challenge, to: 2, name: 'Stranger')
    refute IO.select([guest], nil, nil, 0.05), 'Stranger reached the private room'
    send_frame(host, type: :arena_close)
    assert_equal :closed, until_type(guest, :arena_state)[:phase]
    assert_equal :closed, until_type(host, :arena_state)[:phase]
  end

  def test_consent_replay_invalid_layout_and_host_disconnect
    host, guest = connect, connect
    send_frame(host, type: :arena_open, objects: [7], layout: 0, difficulty: 1)
    assert_equal :arena_error, receive(host)[:type]
    room = open_room(host)
    send_frame(guest, type: :arena_accept, room: room[:room], host: 1)
    assert_equal :arena_error, receive(guest)[:type], 'No invitation means no entry'
    join(host, guest, room)
    host.close
    assert_equal :closed, until_type(guest, :arena_state)[:phase]
    send_frame(guest, type: :arena_accept, room: room[:room], host: 1)
    assert_equal :arena_error, until_type(guest, :arena_error)[:type]
  end

  def test_guest_disconnect_keeps_host_open_and_second_host_is_isolated
    host, guest, other = connect, connect, connect
    room = open_room(host)
    second = open_room(other, [1, 4], 2)
    refute_equal room[:room], second[:room]
    join(host, guest, room)
    until_type(host, :pos)
    until_type(guest, :pos)
    guest.close
    state = until_type(host, :arena_state)
    assert_equal :open, state[:phase]
    assert_nil state[:guest]
    refute IO.select([other], nil, nil, 0.05)
  end

  def test_declining_and_expiring_an_invitation_never_opens_a_visit
    host, guest = connect, connect
    room = open_room(host)
    send_frame(host, type: :arena_invite, to: 2)
    until_type(guest, :arena_invitation)
    until_type(host, :arena_notice)
    send_frame(guest, type: :arena_decline, room: room[:room], host: 1)
    assert_equal room[:room], until_type(guest, :arena_invitation_cancelled)[:room]
    until_type(host, :arena_notice)
    send_frame(guest, type: :arena_accept, room: room[:room], host: 1)
    assert_equal :arena_error, until_type(guest, :arena_error)[:type]
    send_frame(host, type: :arena_invite, to: 2)
    until_type(guest, :arena_invitation)
    until_type(host, :arena_notice)
    # Expire on the reactor thread, without a minute-long test wait.
    @backend.reactor.post do
      online = @backend.instance_variable_get(:@online)
      online.fetch(1).data[:arena_room][:deadline] = -1
    end
    send_frame(guest, type: :ping, t: 2)
    until_type(guest, :pong)
    send_frame(guest, type: :arena_accept, room: room[:room], host: 1)
    assert_equal :arena_error, until_type(guest, :arena_error)[:type]
    send_frame(host, type: :arena_close)
    assert_equal :closed, until_type(host, :arena_state)[:phase]
  end

  def test_local_world_connection_cannot_overwrite_the_historical_account_save
    client = connect
    send_frame(client, type: :arena_hello, local_world: true)
    assert_equal :arena_ready, receive(client)[:type]
    client.write(PEMK::Wire.encode_split({ type: :save, seq: 42 }, 'local world bytes'))
    reply = receive(client)
    assert_equal [:save_err, 42, 'local_world'], reply.values_at(:type, :seq, :reason)
  end

  def test_managed_service_idle_stop_preserves_connected_players
    base = Class.new do
      def on_tick; end
    end
    base.prepend(ArenaVisitsServer)
    worker = base.new
    reactor = Struct.new(:stopped).new(false)
    def reactor.stop; self.stopped = true; end
    worker.instance_variable_set(:@reactor, reactor)
    worker.instance_variable_set(:@online, {})
    worker.instance_variable_set(:@arena_service_idle, 0.0)
    previous = ENV['ARENA_MANAGED_SERVICE']
    ENV['ARENA_MANAGED_SERVICE'] = '1'
    Process.stub(:clock_gettime, 601.0) { worker.on_tick }
    assert reactor.stopped
    reactor.stopped = false
    worker.instance_variable_set(:@online, { 1 => :connected })
    Process.stub(:clock_gettime, 1000.0) { worker.on_tick }
    refute reactor.stopped
    assert_nil worker.instance_variable_get(:@arena_service_idle)
  ensure
    ENV['ARENA_MANAGED_SERVICE'] = previous
  end
end
