require 'minitest/autorun'
require 'socket'
require 'timeout'
require_relative '../upstream/pokemon-essentials-mmo-kit/protocol/pemk_wire'
require_relative '../upstream/pokemon-essentials-mmo-kit/server/lib/pemk/reactor'

class ReadinessTest < Minitest::Test
  def test_upstream_reactor_answers_split_ping
    socket = nil
    reactor = nil
    reactor = PEMK::Reactor.new(host: '127.0.0.1', port: 0,
      on_frame: lambda { |connection, payload|
        env = PEMK::Wire.decode_envelope(payload, false).fetch(:env)
        reactor.send_frame(connection, PEMK::Wire.encode_split(type: :pong, t: env[:t]))
      })
    reactor.start
    thread = Thread.new { reactor.run_loop }
    Timeout.timeout(5) do
      socket = TCPSocket.new('127.0.0.1', reactor.port)
      socket.write(PEMK::Wire.encode_split(type: :ping, t: 123))
      length = socket.read(4).unpack1('N')
      assert_equal({ type: :pong, t: 123 }, PEMK::Wire.decode_envelope(socket.read(length), false).fetch(:env))
    end
  ensure
    socket&.close
    reactor&.stop
    thread&.join(2)
  end
end
