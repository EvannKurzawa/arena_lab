# One private host + one invited guest, using the existing PEMK connection.
# State is deliberately NOT saved: reconnecting closes the previous visit.
module ArenaDemo
  module Visits
    module_function

    def ready?; @ready == true; end
    def locked?; !!(@return_home || @arrival || (@phase && @phase != :closed)); end
    def guest?; @role == :guest; end
    def hosting?; @role == :host && locked?; end
    def request_pending?; @request_pending == true || @phase == :requesting; end
    def snapshot; @snapshot; end
    def scope; @room || (defined?(PEMK) && PEMK.self_id); end
    def transfer_pending?; !!@arrival; end

    def reset
      @return_home = true if guest? || @arrival
      @ready = false
      @hello_at = nil
      @phase = :closed
      @role = @room = @snapshot = @invitation = @arrival = nil
      @visit_request = @request_pending = nil
      @notice = nil
      @refresh = true
    end

    def now
      return System.uptime if defined?(System) && System.respond_to?(:uptime)
      Time.now.to_f
    end

    def pump
      if !ArenaDemo.connected?
        reset if ready? || locked?
        return
      end
      if !ready? && (!@hello_at || now - @hello_at >= 5)
        @hello_at = now
        PEMK.send_message(:type => :arena_hello, :local_world => defined?(ArenaDemo::ConnectionMode) && ArenaDemo::ConnectionMode.local_world?)
      end
    end

    def send_request(type, fields = {})
      return false unless ready? && ArenaDemo.connected?
      PEMK.send_message(fields.merge(:type => type))
    end

    def open_arena
      return false if locked? || $game_map.map_id != ENTRANCE_MAP_ID
      # Lock BEFORE submitting anything, including while the reply is pending.
      @phase = :opening
      snapshot = {
        :objects => ArenaDemo.objects.map { |name| OBJECTS.index(name) }.compact,
        :layout => LAYOUTS.keys.index($PokemonGlobal.arena_demo_layout) || 0,
        :difficulty => $PokemonGlobal.arena_demo_difficulty || 1
      }.merge(ArenaDemo.visit_snapshot_payload)
      unless send_request(:arena_open, snapshot)
        @phase = :closed
        pbMessage("The arena could not be opened. Check your connection.")
        return false
      end
      true
    end

    def close_arena
      previous = @phase
      @phase = :closing
      unless send_request(:arena_close)
        @phase = previous
        pbMessage("The close request could not be sent. The arena stays locked until the connection closes or the server confirms.")
        return false
      end
      true
    end

    def request_visit
      return false if locked? || !ready? || $game_map.map_id != ENTRANCE_MAP_ID
      @phase = :requesting
      @request_pending = true
      unless send_request(:arena_visit_request)
        @phase = :closed
        @request_pending = nil
        pbMessage("The visit request could not be sent. Check your connection.")
        return false
      end
      true
    end

    def accept_visit_request
      return false unless @visit_request && @phase == :hosting
      unless send_request(:arena_visit_accept, :request => @visit_request)
        pbMessage("The accept action could not be sent. Check your connection.")
        return false
      end
      @visit_request = nil
      true
    end

    def decline_visit_request
      return false unless @visit_request && @phase == :hosting
      unless send_request(:arena_visit_decline, :request => @visit_request)
        pbMessage("The decline action could not be sent. Check your connection.")
        return false
      end
      @visit_request = nil
      true
    end

    def accept_invitation
      return false if locked? || !@invitation || $game_map.map_id != ENTRANCE_MAP_ID
      @phase = :joining
      unless send_request(:arena_accept, :host => @invitation[:host], :room => @invitation[:room])
        @phase = :closed
        return false
      end
      true
    end

    def receive(message)
      case message[:type]
      when :arena_ready
        return unless message[:version] == 8
        @ready = true
        @phase ||= :closed
        @refresh = true
        clear_remotes(true)
      when :arena_state
        if message[:phase] == :closed
          @return_home = true if guest? || @arrival
          @phase = :closed
          @role = @room = @snapshot = @arrival = nil
          @visit_request = nil
        elsif message[:phase] == :open
          ids, layout, difficulty = message.values_at(:objects, :layout, :difficulty)
          decoded_snapshot = ArenaDemo.decode_visit_snapshot(message[:surface], message[:placements], message[:relief], message[:styles])
          return unless [:host, :guest].include?(message[:role]) &&
                        message[:room].is_a?(String) && message[:room].length <= 32 &&
                        ids.is_a?(Array) && ids.length <= 6 && ids.uniq == ids &&
                        ids.all? { |id| id.is_a?(Integer) && id.between?(0, 5) } &&
                        layout.is_a?(Integer) && layout.between?(0, 2) &&
                        difficulty.is_a?(Integer) && difficulty.between?(0, 2) && decoded_snapshot
          joining = message[:role] == :guest && @room != message[:room]
          @room, @role = message.values_at(:room, :role)
          @phase = @role == :guest ? :visiting : :hosting
          @snapshot = { :objects => ids.map { |id| OBJECTS[id] }.freeze,
                        :layout => LAYOUTS.keys[layout], :difficulty => difficulty,
                        :tile_edits => decoded_snapshot[:tile_edits],
                        :placements => decoded_snapshot[:placements] }.freeze
          @arrival = true if joining
          @invitation = nil
          @request_pending = nil
          @visit_request = nil if @role == :guest
        end
        @refresh = true
        clear_remotes(true)
      when :arena_invitation
        return unless message[:room].is_a?(String) && message[:room].length <= 32 && message[:host].is_a?(Integer)
        @invitation = { :host => message[:host], :room => message[:room], :expires => now + 60 }
        @notice = "Account ##{message[:host]} invited you to their arena. Talk to the entrance-room attendant within 60 seconds to accept."
      when :arena_invitation_cancelled
        @invitation = nil if @invitation && @invitation[:room] == message[:room]
      when :arena_visit_request
        token = message[:request]
        return unless token.is_a?(String) && token.match?(/\A[0-9a-f]{24}\z/)
        @visit_request = token
        @notice = "Someone is requesting to visit your arena. Talk to the attendant to accept or decline."
      when :arena_visit_pending
        @request_pending = true
        @notice = "Visit request sent. Waiting for the host to accept."
      when :arena_visit_declined, :arena_visit_expired
        if @visit_request
          @visit_request = nil
          @notice = "The visit request expired."
        else
          @request_pending = nil
          @phase = :closed if @phase == :requesting
          @notice = message[:type] == :arena_visit_declined ? "The host declined the visit request." : "The visit request expired."
        end
      when :arena_visit_cancelled
        if @visit_request
          @visit_request = nil
          @notice = "The visit request was cancelled."
        elsif @request_pending
          @request_pending = nil
          @phase = :closed if @phase == :requesting
          @notice = "The host is no longer available."
        end
      when :arena_error
        if [:opening, :joining, :requesting].include?(@phase)
          @phase = :closed
          @request_pending = nil
        end
        @notice = PEMK.plain_text(message[:reason], 200) || "Arena request refused."
      when :arena_notice
        @notice = PEMK.plain_text(message[:text], 200)
      end
    end

    def clear_remotes(clear_corrections = false)
      PEMK::PosCorrect.reset if clear_corrections && defined?(PEMK::PosCorrect)
      PEMK::Remotes.clear_all if defined?(PEMK::Remotes) && PEMK::Remotes.respond_to?(:clear_all)
      PEMK::Presence.announce_soon if defined?(PEMK::Presence)
    end

    # Apply transfers only on safe overworld frames, never inside the network
    # pump, another message, PC screen, event interpreter, or battle.
    def update_world
      return unless $game_map && $scene.is_a?(Scene_Map) && $game_temp
      return if $game_temp.in_menu || $game_temp.in_battle
      return if defined?(pbMapInterpreterRunning?) && pbMapInterpreterRunning?
      if @return_home
        @return_home = nil
        ArenaDemo.transfer_to(ENTRANCE_MAP_ID, 7, 10, 8)
      elsif @arrival
        @arrival = nil
        ArenaDemo.transfer_to(ENTRANCE_MAP_ID, 8, 10, 8)
      end
      if @refresh
        @refresh = nil
        ArenaDemo.refresh_objects
        clear_remotes
      end
      if @notice
        notice, @notice = @notice, nil
        pbMessage(notice)
      end
    end

    def allow_travel?(map_id)
      !locked? || [MAP_ID, ENTRANCE_MAP_ID].include?(map_id)
    end

    def attendant
      if !ArenaDemo.connected?
        pbMessage("Use Play-Arena.bat, then ask the entrance attendant to Host online or Find an arena to visit. Each player signs in with their own account.")
        return
      end
      unless ready?
        pbMessage("Waiting for the current arena service. Restart the host game and both clients with the latest Arena Lab files.")
        return
      end
      @invitation = nil if @invitation && now > @invitation[:expires]
      actions = []
      if guest?
        actions << ["Leave this visit", proc { close_arena }]
      elsif @role == :host && @phase == :hosting
        actions << ["Close arena to visitors", proc { close_arena }]
        if @visit_request
          actions << ["Accept visit request", proc { accept_visit_request }]
          actions << ["Decline visit request", proc { decline_visit_request }]
        end
      elsif !locked?
        if !defined?(ConnectionMode) || ConnectionMode.host_mode?
          actions << ["Open arena to visitors", proc { open_arena }]
        else
          actions << ["Request to visit", proc { request_visit }]
        end
      end
      labels = actions.map(&:first) + ["Back"]
      status = if defined?(ConnectionMode)
                 ConnectionMode.status
               else
                 locked? ? "Hosting or visiting" : "Connected"
               end
      detail = if @request_pending
                 "Visit request pending. Waiting for the host."
               elsif locked?
                 "Arena customization is locked until the visit closes."
               else
                 "Your arena is closed to visitors."
               end
      choice = pbMessage("Status: #{status}\n#{detail}", labels, -1)
      actions[choice][1].call if choice && choice >= 0 && choice < actions.length
    end
  end

  module_function

  def multiplayer_attendant
    return ConnectionMode.attendant if defined?(ConnectionMode)
    with_player_dialog { Visits.attendant }
  end

  def customization_locked?
    Visits.locked? || (multiplayer? && !Visits.ready?)
  end

  def customization_allowed?
    return true if $game_map && $game_map.map_id == MAP_ID && !customization_locked?
    pbMessage("Customize from the arena's pause menu after closing it to visitors.")
    false
  end

  def effective_layout
    return Visits.snapshot if Visits.snapshot
    return { :objects => OBJECTS, :layout => "Sidelines", :difficulty => 1 } if multiplayer? && !Visits.ready?
    { :objects => objects, :layout => $PokemonGlobal.arena_demo_layout || "Sidelines",
      :difficulty => $PokemonGlobal.arena_demo_difficulty || 1 }
  end

  def arena_reception
    pbMessage("Talk to the Arena Guide offline to open Custom mode. The entrance-room attendant handles visits.")
    heal_team if pbConfirmMessage("Would you like me to heal your team?")
  end
end

if defined?(PEMK::Dispatch)
  module ArenaDemo::VisitDispatch
    def handle(message)
      if message.is_a?(Hash)
        if [:arena_ready, :arena_state, :arena_invitation, :arena_invitation_cancelled,
            :arena_visit_request, :arena_visit_pending, :arena_visit_declined,
            :arena_visit_expired, :arena_visit_cancelled, :arena_error, :arena_notice].include?(message[:type])
          return ArenaDemo::Visits.receive(message)
        end
        if [:pos, :step, :spawn, :dir].include?(message[:type]) && ArenaDemo::Visits.ready? &&
           [100, 101, 102].include?(message[:map])
          return unless message[:arena_room] == ArenaDemo::Visits.scope
        end
        ArenaDemo::Visits.reset if message[:type] == PEMK::NetClient::DISCONNECTED
      end
      super
    end
  end
  PEMK::Dispatch.singleton_class.prepend(ArenaDemo::VisitDispatch)
end

if defined?(PEMK::Pump)
  module ArenaDemo::VisitPump
    def tick
      super
      ArenaDemo::Visits.pump
    end
  end
  PEMK::Pump.singleton_class.prepend(ArenaDemo::VisitPump)
end

if defined?(PEMK::Presence)
  module ArenaDemo::VisitPresence
    def can_emit?
      super && ArenaDemo::Visits.ready? && !ArenaDemo::Visits.transfer_pending?
    end
  end
  PEMK::Presence.singleton_class.prepend(ArenaDemo::VisitPresence)
end

if defined?(PEMK::Auth)
  module ArenaDemo::VisitLogin
    def apply_login(reply)
      ArenaDemo::Visits.reset
      super
    end
  end
  PEMK::Auth.singleton_class.prepend(ArenaDemo::VisitLogin)
end

# Cover engine transfers as well as our own menu/door helpers.
module ArenaDemo::VisitTransfer
  def transfer_player(*args)
    unless ArenaDemo::Visits.allow_travel?($game_temp.player_new_map_id)
      $game_temp.player_new_map_id = ArenaDemo::ENTRANCE_MAP_ID
      $game_temp.player_new_x, $game_temp.player_new_y = 7, 10
      $game_temp.player_new_direction = 8
    end
    super
  end
end
Scene_Map.prepend(ArenaDemo::VisitTransfer)

EventHandlers.add(:on_frame_update, :arena_visits_world, proc { ArenaDemo::Visits.update_world })
