# frozen_string_literal: true
require 'minitest/autorun'
require 'socket'
require 'timeout'
require 'securerandom'
require 'uri'

# Real PEMK protocol clients, not GUI game windows. Never run against play data.
database = URI(ENV.fetch('DATABASE_URL'))
abort 'This test requires the isolated pemk_test database' unless database.path == '/pemk_test'
server = File.expand_path('../../tools/runtime/pemk-workspace/server', __dir__)
$LOAD_PATH.unshift(File.join(server, 'lib'), File.expand_path('../protocol', server))
ENV['PEMK_BIND'] = '127.0.0.1'
ENV['PEMK_PORT'] = '0'
require 'pemk'

class MultiplayerArenaTest < Minitest::Test
  def send_frame(socket, frame)
    socket.write(PEMK::Wire.encode_split(frame))
  end

  def receive_frame(socket)
    Timeout.timeout(5) do
      header = socket.read(4)
      raise 'Connection closed' unless header
      PEMK::Wire.decode_envelope(socket.read(header.unpack1('N')), false).fetch(:env)
    end
  end

  def test_two_authenticated_players_enter_move_and_leave_arena_100
    db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    ids = []
    sockets = []
    backend = PEMK::Server.new(logger: ->(_message) {})
    backend.start
    clients = 2.times.map do |index|
      socket = TCPSocket.new('127.0.0.1', backend.port)
      sockets << socket
      email = "arena-#{SecureRandom.hex(8)}-#{index}@example.test"
      password = SecureRandom.hex(16)
      send_frame(socket, type: :register, email: email, password: password)
      registered = receive_frame(socket)
      assert_equal :register_ok, registered[:type]
      ids << registered.fetch(:account_id)
      send_frame(socket, type: :login, email: email, password: password, caps: ['presence_v2'])
      authenticated = receive_frame(socket)
      assert_equal :login_ok, authenticated[:type]
      assert_equal ids.last, authenticated[:account_id]
      [socket, ids.last]
    end
    a, a_id = clients[0]
    b, b_id = clients[1]
    send_frame(a, type: :pos, map: 100, x: 12, y: 16)
    send_frame(b, type: :pos, map: 100, x: 13, y: 16)
    assert_equal [b_id, 100, 13, 16], receive_frame(a).values_at(:id, :map, :x, :y)
    assert_equal [a_id, 100, 12, 16], receive_frame(b).values_at(:id, :map, :x, :y)
    send_frame(a, type: :step, map: 100, x: 12, y: 15)
    assert_equal [a_id, 100, 12, 15], receive_frame(b).values_at(:id, :map, :x, :y)
    send_frame(a, type: :challenge, to: b_id, name: 'Alice')
    assert_equal [:challenge, a_id, b_id], receive_frame(b).values_at(:type, :from, :to)
    send_frame(b, type: :challenge_decline, to: a_id, name: 'Bob')
    assert_equal [:challenge_decline, b_id, a_id], receive_frame(a).values_at(:type, :from, :to)
    send_frame(a, type: :challenge, to: b_id, name: 'Alice')
    assert_equal :challenge, receive_frame(b)[:type]
    send_frame(b, type: :challenge_accept, to: a_id, name: 'Bob')
    assert_equal [:challenge_accept, b_id, a_id], receive_frame(a).values_at(:type, :from, :to)
    # Exercise the existing relay after consent; do not simulate a completed game.
    send_frame(a, type: :battle_choice, to: b_id, round: 1, idxBattler: 1, cmd: [0, 0])
    assert_equal [:battle_choice, a_id, b_id], receive_frame(b).values_at(:type, :from, :to)
    a.close
    ended = receive_frame(b)
    assert_equal :battle_end, ended[:type]
    assert_equal a_id, ended[:from]
    left = receive_frame(b)
    assert_equal :leave, left[:type]
    assert_equal a_id, left[:id]
  ensure
    sockets&.each { |socket| socket.close unless socket.closed? }
    backend&.stop
    db[:accounts].where(id: ids).delete if db && ids && !ids.empty?
    db&.disconnect
  end
end
