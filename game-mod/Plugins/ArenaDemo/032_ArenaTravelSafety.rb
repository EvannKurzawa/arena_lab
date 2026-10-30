# A touch transfer can happen before the final interpolated walking frame.
# Drop its old-map origins so it cannot drag the sprite across the new map.
module ArenaDemo
  module_function

  def settle_player_after_transfer
    return unless $game_player
    reset_saved_player_movement
    player = $game_player
    { :jump_timer => nil, :move_initial_x => player.x, :move_initial_y => player.y,
      :jump_initial_x => player.x, :jump_initial_y => player.y,
      :moved_last_frame => false, :stopped_last_frame => true }.each do |key, value|
      player.instance_variable_set("@#{key}", value)
    end
    player.moveto(player.x, player.y)
    player.instance_variable_set(:@last_terrain_tag, player.pbTerrainTag)
  end

  module SafeMapTransfer
    def transfer_player(*args)
      project_maps = [ArenaDemo::MAP_ID, ArenaDemo::ENTRANCE_MAP_ID, ArenaDemo::TOWN_MAP_ID]
      guarded = project_maps.include?($game_map.map_id) || project_maps.include?($game_temp.player_new_map_id)
      ArenaDemo.settle_player_after_transfer if guarded
      result = super
      ArenaDemo.settle_player_after_transfer if guarded
      result
    end
  end
end
Scene_Map.prepend(ArenaDemo::SafeMapTransfer) if defined?(Scene_Map)
