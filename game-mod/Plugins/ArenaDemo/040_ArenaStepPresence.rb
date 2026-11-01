# Ice and other forced moves skip Essentials' ordinary player-step callback.
# Send every occupied tile so arena authority sees adjacent steps, including
# the final ice tile before void, instead of correcting an apparent teleport.
EventHandlers.add(:on_step_taken, :arena_step_presence, proc do |event|
  next unless event && event.equal?($game_player) && $game_map && $game_map.map_id == ArenaDemo::MAP_ID
  PEMK::Presence.emit(:pos) if defined?(PEMK::Presence)
end)
