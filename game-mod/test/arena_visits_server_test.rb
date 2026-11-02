# frozen_string_literal: true
require_relative 'arena_visit_harness'

class ArenaVisitsServerTest < Minitest::Test
  def test_follower_pose_is_relayed_and_invalid_or_hidden_pose_is_removed
    sender, viewer = connect, connect
    send_frame(sender, type: :ping, t: 99)
    assert_equal true, until_type(sender, :pong)[:arena_follower_pose]
    room = open_room(sender)
    join(sender, viewer, room)
    until_type(sender, :pos)
    until_type(viewer, :pos)
    frame = { type: :pos, map: 102, x: 4, y: 6, follower_species: 'LUGIA',
              follower_x: 3, follower_y: 6, follower_dir: 6 }
    send_frame(sender, frame)
    pose = until_type(viewer, :pos)
    assert_equal [3,6,6], pose.values_at(:follower_x, :follower_y, :follower_dir)
    [[99,6,6], [3,6,5], ['3',6,6], [nil,nil,nil]].each do |x,y,direction|
      send_frame(sender, frame.merge(follower_x: x, follower_y: y, follower_dir: direction))
      rejected = until_type(viewer, :pos)
      refute rejected.key?(:follower_x)
      refute rejected.key?(:follower_dir)
    end
    send_frame(sender, frame.merge(follower_species: ''))
    hidden = until_type(viewer, :pos)
    assert_equal '', hidden[:follower_species]
    refute hidden.key?(:follower_x)
  end
  include ArenaVisitTestSupport

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
    send_frame(host, type: :pos, map: 100, x: 49, y: 53)
    send_frame(guest, type: :pos, map: 100, x: 49, y: 53)
    until_type(host, :pos)
    until_type(guest, :pos)
    send_frame(guest, type: :pos, map: 100, x: 45, y: 43) # Nonadjacent jump
    assert_equal [100, 49, 53], until_type(guest, :pos_correct).values_at(:map, :x, :y)
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
    worker.instance_variable_set(:@online, { 1 => Struct.new(:data).new({}) })
    Process.stub(:clock_gettime, 1000.0) { worker.on_tick }
    refute reactor.stopped
    assert_nil worker.instance_variable_get(:@arena_service_idle)
  ensure
    ENV['ARENA_MANAGED_SERVICE'] = previous
  end
end
