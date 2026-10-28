# Lightweight LAN-only discovery for the current private-host model. The host
# server replies to UDP broadcasts on 9997; the game still authenticates over
# the existing PEMK TCP connection on 9998.
require 'socket'

module ArenaDemo
  module LanDiscovery
    PORT = 9997
    PROBE = 'ARENA_LAB_DISCOVER_V1'.freeze
    PREFIX = 'ARENA_LAB_HOST_V1'.freeze

    module_function

    def start_responder(logger = nil)
      Thread.new do
        socket = UDPSocket.new(Socket::AF_INET)
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
        socket.bind('0.0.0.0', PORT)
        name = Socket.gethostname.to_s.gsub(/[^A-Za-z0-9_.-]/, '_')[0, 80]
        loop do
          data, sender = socket.recvfrom(256)
          next unless data == PROBE
          socket.send("#{PREFIX}\t#{name}", 0, sender[3], sender[1])
        end
      rescue Exception => error
        logger.call("LAN discovery stopped: #{error.class}: #{error.message}") if logger
      ensure
        socket&.close
      end
    end

    def discover(timeout = 2.5)
      socket = UDPSocket.new(Socket::AF_INET)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
      socket.bind('0.0.0.0', 0)
      targets = ['127.0.0.1', '255.255.255.255']
      begin
        Socket.getifaddrs.each do |interface|
          next unless interface.addr && interface.addr.afamily == Socket::AF_INET
          next unless interface.broadaddr && interface.broadaddr.afamily == Socket::AF_INET
          targets << interface.broadaddr.ip_address
        end
      rescue StandardError
        # The limited broadcast above remains available if interface enumeration
        # isn't implemented by this Ruby build.
      end
      targets.uniq.each { |address| socket.send(PROBE, 0, address, PORT) }
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      hosts = {}
      local_name = Socket.gethostname.to_s.gsub(/[^A-Za-z0-9_.-]/, '_')[0, 80]
      while (remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)) > 0
        readable = IO.select([socket], nil, nil, remaining)
        break unless readable
        data, sender = socket.recvfrom(256)
        prefix, name = data.split("\t", 2)
        next unless prefix == PREFIX && name && name.match?(/\A[A-Za-z0-9_.-]{1,80}\z/)
        address = name == local_name ? '127.0.0.1' : sender[3]
        hosts[name] ||= { :name => name, :address => address }
        hosts[name][:address] = address if address == '127.0.0.1'
      end
      hosts.values.sort_by { |host| host[:name].downcase }
    ensure
      socket&.close
    end
  end
end
