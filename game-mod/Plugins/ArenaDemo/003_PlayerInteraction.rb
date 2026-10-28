module ArenaDemo
  module_function

  def connected?
    multiplayer? && defined?(PEMK::Remotes) && PEMK.client && PEMK.client.connected?
  end

  def arena_peers
    return [] unless connected? && $game_map.map_id == MAP_ID
    PEMK::Remotes.players.values.select do |peer|
      peer.player_id != PEMK.self_id && peer.map.map_id == MAP_ID
    end.sort_by { |peer| peer.player_id }
  end

  def room_peers
    return [] unless connected? && [MAP_ID, ENTRANCE_MAP_ID].include?($game_map.map_id)
    PEMK::Remotes.players.values.select do |peer|
      peer.player_id != PEMK.self_id && peer.map.map_id == $game_map.map_id
    end
  end

  def peer_label(peer)
    name = PEMK.plain_name(peer.player_name)
    name = "Player" if !name || name.empty?
    "#{name} (##{peer.player_id})"
  end

  # Blocking interaction dialogs must not launch a pending battle or incoming
  # challenge UI inside themselves. The network pump continues while in_menu.
  def with_player_dialog
    return if @in_player_dialog || !$game_temp || $game_temp.in_battle
    previous = $game_temp.in_menu
    @in_player_dialog = true
    $game_temp.in_menu = true
    begin
      yield
    ensure
      $game_temp.in_menu = previous
      @in_player_dialog = false
    end
  end

  def players_menu
    with_player_dialog do
      peers = arena_peers
      if !connected?
        pbMessage("Log in to the local server to interact with another player.")
      elsif peers.empty?
        pbMessage("No other players are in this arena yet.")
      else
        choice = pbMessage("Players in this arena", peers.map { |peer| peer_label(peer) } + ["Cancel"], -1)
        player_dialog(peers[choice]) if choice >= 0 && choice < peers.length
      end
    end
  end

  def player_dialog(peer)
    choice = pbMessage(peer_label(peer), ["Challenge to battle", "Cancel"], -1)
    PEMK::Challenge.request_from_arena(peer.player_id) if choice == 0
  end

  def interact_with_facing_player
    return unless connected? && $game_map.map_id == MAP_ID && $game_player
    return if !$game_temp || $game_temp.in_menu || $game_temp.in_battle
    dx, dy = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }[$game_player.direction]
    return unless dx
    peers = arena_peers
    peer = peers.find { |other| other.x == $game_player.x + dx && other.y == $game_player.y + dy }
    # PEMK's remote characters are passable, including a shared spawn tile.
    peer ||= peers.find { |other| other.x == $game_player.x && other.y == $game_player.y }
    with_player_dialog { player_dialog(peer) } if peer
  end
end

EventHandlers.add(:on_player_interact, :arena_demo_player_interaction,
                  proc { ArenaDemo.interact_with_facing_player })

if defined?(PEMK::Challenge)
  module ArenaDemo
    module PlayerChallengeEntry
      def pbChallengeFromMenu
        return ArenaDemo.players_menu if $game_map && $game_map.map_id == ArenaDemo::MAP_ID
        super
      end

      def request_from_arena(player_id)
        if !ArenaDemo.connected?
          pbMessage("The connection was lost. Reconnect before sending a battle request.")
          return false
        end
        peer = ArenaDemo.arena_peers.find { |other| other.player_id == player_id }
        if !peer
          pbMessage("That player has left the arena.")
          return false
        end
        if !$player || $player.able_pokemon_count == 0
          pbMessage("You need a Pokemon able to battle first.")
          return false
        end
        return false if $game_temp.in_battle || PEMK::BattleSetup.launch_pending?
        # Use PEMK's existing challenge state and consent gate. Only this peer's
        # acceptance can start its normal team exchange and battle launch.
        @outgoing = player_id
        sent = PEMK.send_message(:type => :challenge, :from => PEMK.self_id,
                                 :name => own_name, :to => player_id)
        if !sent
          @outgoing = nil
          pbMessage("The battle request could not be sent. Check the server connection.")
          return false
        end
        pbMessage("Battle request sent to #{ArenaDemo.peer_label(peer)}. They must accept in their game window.")
        return true
      end
    end
  end
  unless PEMK::Challenge.singleton_class.ancestors.include?(ArenaDemo::PlayerChallengeEntry)
    PEMK::Challenge.singleton_class.prepend(ArenaDemo::PlayerChallengeEntry)
  end
end
