require 'minitest/autorun'
require_relative '../Plugins/ArenaDemo/008_LanDiscovery'

class LanDiscoveryRetryTest < Minitest::Test
  def test_expected_reset_is_quiet_in_debug_mode_and_next_reply_survives
    socket = Object.new
    socket.instance_variable_set(:@attempts, 0)
    def socket.recvfrom_nonblock(*)
      @attempts += 1
      raise Errno::ECONNRESET if @attempts == 1
      ['host reply', ['AF_INET', 9997, 'host', '192.168.1.20']]
    end
    previous_debug = $DEBUG
    $DEBUG = true
    _, errors = capture_io do
      assert_nil ArenaDemo::LanDiscovery.receive_probe(socket)
      assert_equal true, $DEBUG
      assert_equal 'host reply', ArenaDemo::LanDiscovery.receive_probe(socket)[0]
    end
    assert_empty errors
  ensure
    $DEBUG = previous_debug
  end

  def test_unexpected_receive_errors_propagate_and_restore_debug_mode
    socket = Object.new
    def socket.recvfrom_nonblock(*); raise IOError, 'unexpected failure'; end
    previous_debug = $DEBUG
    $DEBUG = true
    assert_raises(IOError) { ArenaDemo::LanDiscovery.receive_probe(socket) }
    assert_equal true, $DEBUG
  ensure
    $DEBUG = previous_debug
  end

  def test_configuration_works_without_fiddle_dlopen
    require 'fiddle'
    socket = UDPSocket.new
    Fiddle.stub(:dlopen, ->(*) { raise 'Game runtime has no dlopen' }) do
      assert_equal true, ArenaDemo::LanDiscovery.configure_socket(socket)
    end
  ensure
    socket&.close
  end

  def test_missing_native_api_is_optional
    require 'fiddle'
    socket = UDPSocket.new
    Fiddle::Handle.stub(:new, ->(*) { raise NotImplementedError }) do
      assert_equal false, ArenaDemo::LanDiscovery.configure_socket(socket)
    end
  ensure
    socket&.close
  end
  def test_windows_unreachable_port_does_not_raise_a_receive_reset
    skip 'Windows-specific Winsock control' unless RUBY_PLATFORM =~ /mswin|mingw/
    closed = UDPSocket.new
    closed.bind('127.0.0.1', 0)
    port = closed.addr[1]
    closed.close
    socket = UDPSocket.new
    ArenaDemo::LanDiscovery.configure_socket(socket)
    socket.send('probe', 0, '127.0.0.1', port)
    refute IO.select([socket], nil, nil, 0.3), 'An unreachable UDP port surfaced as a reset'
  ensure
    socket&.close
    closed&.close unless closed&.closed?
  end

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
