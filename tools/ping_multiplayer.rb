# frozen_string_literal: true
require 'socket'
require 'timeout'
require_relative '../upstream/pokemon-essentials-mmo-kit/protocol/pemk_wire'

# This checks the actual PEMK protocol, not just an open TCP port. No account or
# credential is needed. A single bounded retry window allows server startup.
wait_seconds = Integer(ARGV.fetch(0, '15'))
deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + wait_seconds
last_error = nil
stage = 'connect'
loop do
  socket = nil
  begin
    stage = 'connect'
    Timeout.timeout(5) do
      socket = Socket.tcp('127.0.0.1', 9998, connect_timeout: 2)
      stage = 'send ping'
      socket.write(PEMK::Wire.encode_split(type: :ping, t: 123))
      stage = 'wait for pong header'
      header = socket.read(4)
      raise 'Server closed the connection' unless header && header.bytesize == 4
      length = header.unpack1('N')
      raise 'Unexpected server frame size' unless length.between?(1, 65_536)
      stage = 'read pong body'
      payload = socket.read(length)
      raise 'Incomplete server reply' unless payload && payload.bytesize == length
      reply = PEMK::Wire.decode_envelope(payload, false).fetch(:env)
      raise 'Server did not answer the PEMK ping' unless reply[:type] == :pong && reply[:t] == 123
if ARGV.include?('arena') && (reply[:arena_visits] != 14 || reply[:arena_follower_pose] != true || reply[:arena_furniture_size] != 2)
        warn 'An older PEMK service is running. Host online will verify whether it can safely replace it.'
        exit 2
      end
      if ARGV.include?('lan') && reply[:arena_bind] != '0.0.0.0'
        warn 'A loopback-only PEMK service is running. Host online will verify whether it can safely replace it.'
        exit 3
      end
    end
    puts 'PEMK server READY at 127.0.0.1:9998.'
    exit 0
  rescue StandardError => error
    last_error = "#{stage}: #{error.class}"
  ensure
    socket&.close
  end
  break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
  sleep 0.25
end
unless ARGV[1] == 'quiet'
  warn "PEMK server is not responding at 127.0.0.1:9998 (#{last_error})."
  warn 'Start Play-Arena.bat and choose Host online at the arena attendant.'
  if stage != 'connect'
    warn 'TCP connected, but the PEMK exchange failed. If the server console has selected text, press Esc there and retry.'
  end
end
exit 1
