# frozen_string_literal: true
require 'minitest/autorun'
require 'socket'
require 'securerandom'
require 'timeout'
require 'uri'

abort 'Use the isolated pemk_test database' unless URI(ENV.fetch('DATABASE_URL')).path == '/pemk_test'
root = File.expand_path('../..', __dir__)
backend = File.join(root, 'tools/runtime/pemk-workspace/server')
$LOAD_PATH.unshift(File.join(backend, 'lib'), File.expand_path('../protocol', backend))
ENV['PEMK_BIND'] = '127.0.0.1'
ENV['PEMK_PORT'] = '0'
require 'pemk'

# Load the actual client networking/auth code alongside an isolated real server.
# Only the configuration and log facade normally supplied by RGSS are stubbed.
{ HOST: '127.0.0.1', PORT: 9998, LOGIN_TIMEOUT: 5, LENGTH_BYTES: 4, ENVELOPE_MAX: 65_536,
  PRIM_MAX_ELEMS: 4096, MAX_MESSAGE_BYTES: 16 * 1024 * 1024 }.each do |key, value|
  PEMK::Config.const_set(key, value) unless PEMK::Config.const_defined?(key)
end
def PEMK.log(_message); end
plugin = File.join(root, 'upstream/pokemon-essentials-mmo-kit/Plugins/PEMK')
require File.join(plugin, '001_Net/002_MessageCodec')
require File.join(plugin, '001_Net/003_NetClient')
require File.join(plugin, '004_Persist/001_Auth')

class LoginConnectionTest < Minitest::Test
  def expire_preauth(server)
    reactor = server.instance_variable_get(:@reactor)
    done = Queue.new
    reactor.post do
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      reactor.instance_variable_get(:@conns).each_value do |connection|
        connection.data[:opened_at] = now - 60 if connection.data[:account_id].nil?
      end
      reactor.send(:sweep_idle, now)
      done << true
    end
    Timeout.timeout(5) { done.pop }
  end

  def test_registration_after_the_form_socket_expires
    db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    server = PEMK::Server.new(logger: ->(_message) {})
    server.start
    client = PEMK::NetClient.new('127.0.0.1', server.port)
    assert client.connect
    # A ping ensures the reactor has accepted this socket before aging it.
    assert_equal :pong, PEMK::Auth.send_and_wait(client, { type: :ping }, [:pong])[:type]
    expire_preauth(server)
    email = "form-#{SecureRandom.hex(8)}@example.test"
    password = SecureRandom.hex(16)
    request = { type: :register, email: email, password: password }
    assert_nil PEMK::Auth.send_and_wait(client, request, [:register_ok, :register_err]),
               'Unpatched upstream should reproduce no response on the expired socket'

    # Reproduce the same expiry, then install our extension and submit the form.
    assert client.connect
    assert_equal :pong, PEMK::Auth.send_and_wait(client, { type: :ping }, [:pong])[:type]
    expire_preauth(server)
    require_relative '../Plugins/ArenaDemo/002_PEMKLoginFix'
    registered = PEMK::Auth.send_and_wait(client, request, [:register_ok, :register_err])
    assert_equal :register_ok, registered[:type]
    account_id = registered.fetch(:account_id)
    logged_in = PEMK::Auth.send_and_wait(client, { type: :login, email: email, password: password }, [:login_ok, :login_err])
    assert_equal :login_ok, logged_in[:type]
    assert_equal account_id, logged_in[:account_id]

    PEMK::Auth.instance_variable_set(:@logged_in, true)
    socket = client.instance_variable_get(:@socket)
    assert_equal :pong, PEMK::Auth.send_and_wait(client, { type: :ping }, [:pong])[:type]
    assert_same socket, client.instance_variable_get(:@socket)
  ensure
    PEMK::Auth.instance_variable_set(:@logged_in, false)
    client&.close
    server&.stop
    db[:accounts].where(email: email).delete if db && email
    db&.disconnect
  end
end
