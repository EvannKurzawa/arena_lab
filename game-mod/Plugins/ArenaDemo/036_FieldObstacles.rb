# Temporary, room-scoped field actions; never edit the saved arena or inventory.
module ArenaDemo
  module FieldObstacles
    MOVES = {
      :ARENA_FURNITURE_TREE => [:CUT, 'CutTree'],
      :ARENA_FURNITURE_ROCK => [:ROCKSMASH, 'SmashRock'],
      :ARENA_FURNITURE_BOULDER => [:STRENGTH, 'StrengthBoulder']
    }.freeze
    MACHINES = [:HM01, :HM04, :HM06].freeze
    module_function

    def network?; defined?(Visits) && Visits.field_session?; end
    def scope; network? ? Visits.scope : :solo; end

    def states
      if @scope != scope
        @scope, @states, @revision, @pending = scope, {}, network? ? -1 : 0, nil
        @incoming = nil if @incoming && @incoming[:room] != @scope
      end
      @states ||= {}
    end

    def clear
      @scope = nil
      @states, @revision, @incoming, @pending, @notice = {}, 0, nil, nil, nil
    end

    def clear_native_slots
      return unless $PokemonMap
      ArenaDemo::MAX_ARENA_FURNITURE.times do |slot|
        key = [ArenaDemo::MAP_ID, ArenaDemo::FURNITURE_SLOT_BASE + slot]
        $PokemonMap.erasedEvents.delete(key)
        $PokemonMap.movedEvents.delete(key)
      end
    end

    def reset(refresh = false)
      clear
      clear_native_slots
      $PokemonMap.strengthUsed = false if $PokemonMap && $game_map && $game_map.map_id == ArenaDemo::MAP_ID && !network?
      ArenaDemo.refresh_custom_placements if refresh && $game_map && $game_map.map_id == ArenaDemo::MAP_ID
    end

    def geometry; ArenaDemo.visit_snapshot_payload; end

    def receive(message)
      return unless network? && message[:room] == Visits.scope
      states
      revision = message[:field_revision]
      return unless revision.is_a?(Integer) && revision >= 0 && revision >= @revision
      data = geometry
      return unless ArenaFieldState.valid?(message[:field_states], data[:placements], data[:surface], data[:relief])
      @incoming = message.merge(:field_states => message[:field_states].transform_values { |p| p&.dup }) if !@incoming || revision >= @incoming[:field_revision]
    end

    def update
      return if @animating
      return unless $scene.is_a?(Scene_Map) && $game_temp && !$game_temp.in_battle && !$game_temp.in_menu
      return if pbMapInterpreterRunning? || $game_temp.message_window_showing
      if @incoming
        message, @incoming = @incoming, nil
        if network? && message[:room] == Visits.scope
          if message[:actor] && !message[:rejected] && @revision >= 0 && $game_map.map_id == ArenaDemo::MAP_ID
            begin
              @animating = true
              message[:field_states].each do |slot, point|
                event = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE + slot]
                next unless event && !event.transparent
                if point.nil? && !states.fetch(slot, :visible).nil?
                  FieldMoveEffects.play(event)
                elsif point && event.name[/strengthboulder/i] && point != [event.x, event.y]
                  FieldMoveEffects.push(event, point)
                end
              end
            ensure
              @animating = false
            end
          end
          @states, @revision = message.values_at(:field_states, :field_revision)
          if @pending && (@revision > @pending[:revision] ||
              (message[:actor] == PEMK.self_id && message[:request] == @pending[:request]))
            @notice = 'Cet objet a changé. Son état a été actualisé.' if message[:rejected]
            @pending = nil
          end
          ArenaDemo.refresh_custom_placements if $game_map.map_id == ArenaDemo::MAP_ID
        end
      end
      if @pending && Visits.now - @pending[:sent_at] > 8
        @pending = nil
        enable_strength_contact if $PokemonMap.strengthUsed && $game_map.map_id == ArenaDemo::MAP_ID
        @notice = 'La réponse du serveur tarde. Réessayez après la synchronisation.'
      end
      if @notice
        notice, @notice = @notice, nil
        pbMessage(notice)
      end
    end

    def using?; @using == true; end

    def with_native_access
      previous = @using
      # Following EX's field choreography steps the player backwards and turns
      # them towards the follower. Keep the native Pokemon banner, but preserve
      # the facing tile used for authoritative obstacle requests and pushing.
      follower_temp = $game_temp if $game_temp.respond_to?(:no_follower_field_move)
      previous_follower_move = follower_temp.no_follower_field_move if follower_temp
      follower_temp.no_follower_field_move = true if follower_temp
      @using = true
      yield
    ensure
      @using = previous
      follower_temp.no_follower_field_move = previous_follower_move if follower_temp
    end

    def ensure_machines
      return if !$bag || !$PokemonGlobal || $PokemonGlobal.arena_field_machines_added
      added = MACHINES.all? { |item| $bag.has?(item) || $bag.add(item, 1) }
      $PokemonGlobal.arena_field_machines_added = true if added
    end

    def bind(placements)
      return unless $game_map && $game_map.map_id == ArenaDemo::MAP_ID
      overlay = states
      furniture = ArenaDemo.furniture_placements(placements)
      ArenaDemo::MAX_ARENA_FURNITURE.times do |slot|
        event = $game_map.events[ArenaDemo::FURNITURE_SLOT_BASE + slot]
        next unless event
        placement = furniture[slot]
        spec = placement && MOVES[ArenaDemo.placement_item(placement)]
        point = placement && overlay.fetch(slot, placement.values_at('x', 'y'))
        event.moveto(*point) if point
        if placement && point.nil?
          event.transparent = event.through = true
          event.character_name = ''
        end
        event.instance_variable_get(:@event).name = spec ? "Arena #{spec[1]}" : 'Arena furniture slot'
        # Action activates Strength; afterwards contact can push every boulder.
        event.instance_variable_set(:@trigger, spec && spec[0] == :STRENGTH && $PokemonMap.strengthUsed && !@pending ? 2 : 0)
        script = "ArenaDemo::FieldObstacles.interact(#{event.id}, self)"
        commands = []
        commands << RPG::EventCommand.new(355, 0, [script]) if spec && point
        commands << RPG::EventCommand.new(0, 0, [])
        event.instance_variable_set(:@list, commands)
      end
    end

    def interact(event_id, interpreter = nil)
      return false unless $game_map && $game_map.map_id == ArenaDemo::MAP_ID
      return false if ArenaDemo.multiplayer? && !network?
      return false if ArenaDemo.instance_variable_get(:@editor_surface_edits) || @pending
      event = $game_map.events[event_id]
      return false unless event && !event.transparent && !event.through
      placements = ArenaDemo.custom_placements
      slot = event_id - ArenaDemo::FURNITURE_SLOT_BASE
      return false unless slot.between?(0, ArenaDemo::MAX_ARENA_FURNITURE - 1)
      placement = ArenaDemo.furniture_placements(placements)[slot]
      point = placement && states.fetch(slot, placement.values_at('x', 'y'))
      return false unless placement && point == [event.x, event.y]
      spec = MOVES[ArenaDemo.placement_item(placement)]
      return false unless spec
      move = spec[0]
      ensure_machines
      pokemon = $player.get_pokemon_with_move(move)
      unless pokemon || (move == :STRENGTH && $PokemonMap.strengthUsed)
        pbMessage(_INTL('Un Pokémon de votre équipe doit connaître {1}. Les CS Coupe, Force et Éclate-Roc sont disponibles dans le Sac.', GameData::Move.get(move).name))
        return false
      end
      if move == :STRENGTH
        unless $PokemonMap.strengthUsed
          return false unless with_native_access { pbStrength }
          enable_strength_contact
        end
      else
        return false unless with_native_access { move == :CUT ? pbCut : pbRockSmash }
      end
      # Held movement against a blocked destination must stop locally rather
      # than repeatedly submitting pushes the server will reject.
      data = geometry
      proposed = ArenaFieldState.proposal(data[:placements], states, slot, move, $game_player.direction,
        data[:surface], data[:relief], ArenaDemo.relief_reserved, [[$game_player.x, $game_player.y]])
      return false unless proposed
      if network?
        return false if @revision < 0
        PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
        @request = (@request.to_i % 0x7ffffffe) + 1
        sent = Visits.send_request(:arena_field_request, :room => Visits.scope, :field_revision => @revision,
          :request => @request, :slot => slot, :move => move, :direction => $game_player.direction)
        @pending = { :request => @request, :sent_at => Visits.now, :revision => @revision } if sent
        # Held movement must not keep restarting a contact interpreter while
        # update waits for a safe frame to apply the authoritative reply.
        enable_strength_contact(false) if sent
        return sent
      end
      if move == :STRENGTH
        return false unless push(event, interpreter)
      else
        pbSmashEvent(event)
      end
      @states = proposed
      clear_native_slots
      ArenaDemo.refresh_custom_placements
      true
    end

    def push(event, interpreter)
      direction = $game_player.direction
      return false unless event.can_move_in_direction?(direction, true)
      interpreter ||= Interpreter.new.tap { |i| i.setup([], event.id, $game_map.map_id) }
      before = [event.x, event.y]
      interpreter.pbPushThisEvent(true)
      return false if before == [event.x, event.y]
      true
    end

    def enable_strength_contact(enabled = true)
      $game_map.events.each_value do |event|
        event.instance_variable_set(:@trigger, enabled ? 2 : 0) if event.name[/strengthboulder/i]
      end
    end
  end

  module FieldObstacleRefresh
    def refresh_custom_placements(placements = custom_placements)
      # Slots are reassigned when furniture is removed. Native erased/moved
      # metadata for a previous occupant must not affect the next occupant.
      if $game_map && $game_map.map_id == MAP_ID
        MAX_ARENA_FURNITURE.times do |slot|
          id = FURNITURE_SLOT_BASE + slot
          event = $game_map.events[id]
          if event && event.instance_variable_get(:@erased)
            event.instance_variable_set(:@erased, false)
            event.refresh
          end
        end
        FieldObstacles.clear_native_slots
      end
      result = super
      FieldObstacles.bind(placements)
      result
    end

    def custom_mode
      FieldObstacles.reset(true) if !multiplayer? && $game_map && $game_map.map_id == MAP_ID
      super
    end
  end

  module FieldBadgeAccess
    def pbCheckHiddenMoveBadge(*args)
      return true if FieldObstacles.using?
      super
    end
  end

  module FieldTransfer
    def transfer_player(*args)
      previous_map = $game_map.map_id
      shared = FieldObstacles.network?
      leaving_solo = previous_map == ArenaDemo::MAP_ID && !shared
      result = super
      FieldObstacles.reset if leaving_solo && $game_map.map_id != ArenaDemo::MAP_ID
      if shared && previous_map != $game_map.map_id && [previous_map, $game_map.map_id].include?(ArenaDemo::MAP_ID)
        # Do not let presence throttling skip a very quick trip through the hub.
        PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
      end
      result
    end
  end

  module FieldLoad
    def load_map(*args)
      FieldObstacles.clear
      result = super
      FieldObstacles.reset(true)
      result
    end
  end
end
class PokemonGlobalMetadata
  attr_accessor :arena_field_machines_added
end
ArenaDemo.singleton_class.prepend(ArenaDemo::FieldObstacleRefresh)
Object.prepend(ArenaDemo::FieldBadgeAccess)
Scene_Map.prepend(ArenaDemo::FieldTransfer)
Game.singleton_class.prepend(ArenaDemo::FieldLoad)
EventHandlers.add(:on_frame_update, :arena_field_state, proc { ArenaDemo::FieldObstacles.update })
