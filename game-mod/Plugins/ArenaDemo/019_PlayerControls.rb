# Physical keyboard controls for Arena Lab. Menus/dialogs retain their normal
# confirm/cancel bindings; only the map's input polling changes Use/Action.
module ArenaDemo
  module Controls
    module_function
    def enabled?; Input.respond_to?(:triggerex?); end
    def space_trigger?; enabled? && Input.triggerex?(:SPACE); end
    def shift_down?
      return Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT) if Input.respond_to?(:pressex?)
      Input.press?(Input::SHIFT)
    end
    def menu_pending?; !!@menu_pending; end
    def cancel_menu; @menu_pending = false; end
    def cancel_expired_menu?
      return false unless $game_temp && $game_temp.in_menu && !$game_temp.in_battle
      return false if pbMapInterpreterRunning?
      return false if defined?(VisibleWild) && VisibleWild.instance_variable_get(:@busy)
      defined?(Outings) && Outings.expired?
    end
    def map_poll?
      enabled? && (@map_depth || 0) > 0 && $game_temp &&
        !$game_temp.in_menu && !$game_temp.in_battle && !$game_temp.message_window_showing &&
        !pbMapInterpreterRunning?
    end
    def queue_menu
      return unless enabled? && $game_temp && $game_system && $PokemonGlobal
      blocked = $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing ||
                $game_system.menu_disabled || pbMapInterpreterRunning? || $PokemonGlobal.forced_movement?
      if blocked
        cancel_menu
      elsif space_trigger?
        @menu_pending = true
      end
    end
    def with_map_input
      @map_depth = (@map_depth || 0) + 1
      yield
    ensure
      @map_depth -= 1
    end
  end

  module MapKeyboardInput
    def trigger?(button)
      # Let each menu unwind through its own normal cancel/dispose path. Never
      # warp underneath an open bag/party screen or cancel a battle's commands.
      if Controls.cancel_expired_menu?
        return true if button == Input::BACK
        return false if [Input::USE, Input::ACTION].include?(button)
      end
      if Controls.map_poll?
        return Controls.menu_pending? if button == Input::ACTION
        return false if button == Input::USE && (Controls.space_trigger? || Controls.menu_pending? ||
                         (defined?(Outings) && Outings.expired?))
      end
      super
    end
  end

  module PlayerKeyboardMovement
    def can_run?
      return @move_speed > 3 if @move_route_forcing
      return false if @bumping || jumping? || pbTerrainTag.must_walk
      return false if $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing || pbMapInterpreterRunning?
      Controls.shift_down?
    end
    def update_command_new
      scripted = @move_route_forcing || pbMapInterpreterRunning? || $PokemonGlobal&.forced_movement?
      return if !scripted && (Controls.menu_pending? || (defined?(Outings) && Outings.expired?))
      super
    end
  end

  module MapKeyboardControls
    def call_menu
      Controls.cancel_menu
      super
    end
  end
end

Input.singleton_class.prepend(ArenaDemo::MapKeyboardInput) if defined?(Input)
Game_Player.prepend(ArenaDemo::PlayerKeyboardMovement) if defined?(Game_Player)
Scene_Map.prepend(ArenaDemo::MapKeyboardControls) if defined?(Scene_Map)
if defined?(Scene_Map)
  class Scene_Map
    alias arena_controls_base_update update
    def update
      ArenaDemo::Controls.queue_menu
      ArenaDemo::Controls.with_map_input { arena_controls_base_update }
    end
  end
end
MenuHandlers.remove(:options_menu, :movement_style) if defined?(Input) && ArenaDemo::Controls.enabled?
