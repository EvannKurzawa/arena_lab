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

    def configure_socket(socket)
      # Winsock reports ICMP port-unreachable for an earlier UDP probe as a
      # reset on a later recvfrom. Suppress that notification at its source.
      return unless RUBY_PLATFORM =~ /mswin|mingw/
      require 'fiddle'
      # Ruby IO#ioctl is not implemented on Windows. Use Winsock's WSAIoctl
      # with the CRT descriptor-to-native-socket conversion.
      runtime = Fiddle.dlopen(RUBY_PLATFORM.include?('ucrt') ? 'ucrtbase.dll' : 'msvcrt.dll')
      native_handle = Fiddle::Function.new(
        runtime['_get_osfhandle'],
        [Fiddle::TYPE_INT], Fiddle::TYPE_INTPTR_T
      ).call(socket.fileno)
      winsock = Fiddle.dlopen('ws2_32.dll')
      control = Fiddle::Function.new(winsock['WSAIoctl'],
        [Fiddle::TYPE_INTPTR_T, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP,
         Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT,
         Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
      result = control.call(native_handle, 0x9800000C - 0x100000000,
                            [0].pack('L'), 4, 0, 0, [0].pack('L'), 0, 0)
      raise IOError, 'Could not disable Windows UDP connection resets' unless result == 0
    end

    def start_responder(logger = nil)
      Thread.new do
        socket = UDPSocket.new(Socket::AF_INET)
        configure_socket(socket)
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
        socket.bind('0.0.0.0', PORT)
        name = Socket.gethostname.to_s.gsub(/[^A-Za-z0-9_.-]/, '_')[0, 80]
        loop do
          begin
            data, sender = socket.recvfrom(256)
            next unless data == PROBE
            socket.send("#{PREFIX}\t#{name}", 0, sender[3], sender[1])
          rescue Errno::ECONNRESET, Errno::ECONNREFUSED
            next
          end
        end
      rescue Exception => error
        logger.call("LAN discovery stopped: #{error.class}: #{error.message}") if logger
      ensure
        socket&.close
      end
    end

    def discover(timeout = 5.0)
      socket = UDPSocket.new(Socket::AF_INET)
      configure_socket(socket)
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
      targets.uniq!
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      next_probe = 0
      hosts = {}
      local_addresses = Socket.ip_address_list.select(&:ipv4?).map(&:ip_address)
      while (remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)) > 0
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        if now >= next_probe
          targets.each do |address|
            begin
              socket.send(PROBE, 0, address, PORT)
            rescue SystemCallError
              # A disconnected/VPN interface must not prevent other probes.
            end
          end
          next_probe = now + 0.5
        end
        readable = IO.select([socket], nil, nil, [remaining, next_probe - now].min)
        next unless readable
        begin
          data, sender = socket.recvfrom(256)
        rescue Errno::ECONNRESET, Errno::ECONNREFUSED
          # On Windows, probing loopback when no responder is bound there can
          # deliver an ICMP port-unreachable as WSAECONNRESET. That reply says
          # only that this address has no host; keep listening for LAN replies.
          next
        end
        prefix, name = data.split("\t", 2)
        next unless prefix == PREFIX && name && name.match?(/\A[A-Za-z0-9_.-]{1,80}\z/)
        # Hostnames are labels, not identities: two computers can share one.
        address = local_addresses.include?(sender[3]) ? '127.0.0.1' : sender[3]
        hosts[address] ||= { :name => name, :address => address }
      end
      hosts.values.sort_by { |host| host[:name].downcase }
    ensure
      socket&.close
    end
  end
end
