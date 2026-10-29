require 'minitest/autorun'
require_relative '../Plugins/ArenaDemo/008_LanDiscovery'

class LanDiscoveryRetryTest < Minitest::Test
  def test_discovery_recovers_from_lost_first_probe
    socket = UDPSocket.new
    socket.bind('127.0.0.1', 0)
    discovery = ArenaDemo::LanDiscovery
    original_port = discovery::PORT
    discovery.send(:remove_const, :PORT)
    discovery.const_set(:PORT, socket.addr[1])
    responder = Thread.new do
      socket.recvfrom(256) # Simulate a lost request/response on the first attempt.
      data, sender = socket.recvfrom(256)
      socket.send("#{discovery::PREFIX}\tRetryHost", 0, sender[3], sender[1]) if data == discovery::PROBE
    end
    hosts = discovery.discover(1.2)
    assert_equal [{ name: 'RetryHost', address: '127.0.0.1' }], hosts
  ensure
    responder&.kill
    responder&.join
    socket&.close
    discovery.send(:remove_const, :PORT)
    discovery.const_set(:PORT, original_port)
  end
end
