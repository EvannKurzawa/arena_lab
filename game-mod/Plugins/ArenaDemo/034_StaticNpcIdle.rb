# Essentials charsets use frame 0 for standing; frame 1 has a raised foot.
# Normalize generated human pages before Game_Event applies their graphics,
# including old templates on installations that have not rebuilt maps yet.
EventHandlers.add(:on_game_map_setup, :arena_static_npc_idle, proc { |map_id, map, _tileset|
  next unless [100, 101, 102].include?(map_id) || ArenaDemo::ExpeditionLayout.map?(map_id)
  map.events.each_value do |event|
    event.pages.each do |page|
      next unless page.move_type == 0
      next unless page.graphic.character_name.to_s.start_with?('trainer_') || event.name == 'Arena trainer slot'
      page.graphic.pattern = 0
      page.step_anime = false
    end
  end
})
