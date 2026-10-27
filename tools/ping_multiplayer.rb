# frozen_string_literal: true
require 'socket'
require 'timeout'
require_relative '../upstream/pokemon-essentials-mmo-kit/protocol/pemk_wire'

# This checks the actual PEMK protocol, not just an open TCP port. No account or
# credential is needed. A single bounded retry window allows server startup.
wait_seconds = Integer(ARGV.fetch(0, '15'))
deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + wait_seconds
last_error = nil
loop do
  socket = nil
  begin
    Timeout.timeout(2) do
      socket = TCPSocket.new('127.0.0.1', 9998)
      socket.write(PEMK::Wire.encode_split(type: :ping, t: 123))
      header = socket.read(4)
      raise 'Server closed the connection' unless header && header.bytesize == 4
      length = header.unpack1('N')
      raise 'Unexpected server frame size' unless length.between?(1, 65_536)
      payload = socket.read(length)
      raise 'Incomplete server reply' unless payload && payload.bytesize == length
      reply = PEMK::Wire.decode_envelope(payload, false).fetch(:env)
      raise 'Server did not answer the PEMK ping' unless reply[:type] == :pong && reply[:t] == 123
    end
    puts 'PEMK server READY at 127.0.0.1:9998.'
    exit 0
  rescue StandardError => error
    last_error = error.class.to_s
  ensure
    socket&.close
  end
  break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
  sleep 0.25
end
warn "PEMK server is not responding at 127.0.0.1:9998 (#{last_error})."
warn 'Start Launch-Multiplayer-Server.bat from this same project folder and leave its window open.'
exit 1
