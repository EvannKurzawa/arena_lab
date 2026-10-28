# Keep local arena extensions separate from the upstream PEMK overlay.
module ArenaDemo
  module PeerCollision
    def passable?(x, y, direction, strict = false)
      delta = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }[direction]
      if delta && ArenaDemo.connected? && $game_map.map_id == ArenaDemo::MAP_ID && !@through
        nx, ny = x + delta[0], y + delta[1]
        return false if ArenaDemo.arena_peers.any? { |peer| peer.x == nx && peer.y == ny }
      end
      super
    end
  end
end
Game_Player.prepend(ArenaDemo::PeerCollision) if defined?(Game_Player)

if defined?(PEMK::BattleNet)
  module ArenaDemo
    module PeerBattleResult
      def take_end
        packet = super
        return packet unless packet && !host?
        decision = packet[:decision]
        return packet.merge(:decision => 3 - decision) if decision == 1 || decision == 2
        packet
      end
    end

    module BattleStreamFix
      # Essentials' single-battle shuffle draws once for slots [0,1]. The same
      # physical Pokemon occupies the opposite slot on the replaying client.
      # Invert only that shuffle draw; damage/accuracy rolls stay untouched.
      def pbCalculatePriority(fullCalc = false, indexArray = nil)
        @arena_mirror_priority_draw = fullCalc && !PEMK::BattleNet.host? && maxBattlerIndex == 1
        super
      ensure
        @arena_mirror_priority_draw = false
      end

      def pbRandom(limit = 65_536)
        mirror = @arena_mirror_priority_draw
        @arena_mirror_priority_draw = false
        value = super
        mirror && limit == 2 ? 1 - value : value
      end

      # A replacement menu may block before the end-of-round flush. Deliver the
      # rolls that caused the faint before either side waits for a replacement.
      def pbSwitchInBetween(*args)
        pokemmo_flush_rng
        super
      end

      # The core loop calls pbEndOfBattle before returning to PEMK's final flush.
      # Flush here so the replay can animate the final hit while the host reads
      # the victory message, rather than waiting for that message to close.
      def pbEndOfBattle(*args)
        pokemmo_flush_rng
        super
      end
    end
  end
  PEMK::BattleNet.singleton_class.prepend(ArenaDemo::PeerBattleResult)
  [PEMK::HostBattle, PEMK::ClientBattle].each { |klass| klass.prepend(ArenaDemo::BattleStreamFix) }
end
