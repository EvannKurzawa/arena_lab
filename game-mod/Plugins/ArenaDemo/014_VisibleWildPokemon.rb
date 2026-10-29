# Small, local-only village ecosystem using Essentials sprites and WildBattle.
module ArenaDemo
  module VisibleWild
    TILES_PER_POKEMON = 24
    MAX_ACTIVE = 4
    RESPAWN_SECONDS = 8.0
    LIFETIME_SECONDS = 60.0
    DIRECTIONS = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }.freeze
    module_function

    def enabled?
      $game_map && $game_map.map_id == ArenaDemo::TOWN_MAP_ID && !ArenaDemo.multiplayer?
    end

    def target_count(tile_count)
      return 0 if tile_count <= 0
      [[(tile_count.to_f / TILES_PER_POKEMON).ceil, 1].max, MAX_ACTIVE].min
    end

    def entries; @entries ||= []; end
    def now; ArenaDemo::Visits.now; end

    def clear
      entries.each { |entry| entry[:sprite].dispose unless entry[:sprite].disposed? }
      entries.clear
      @pending = nil
    end

    def context(spriteset, viewport)
      return unless spriteset.map == $game_map
      clear
      @spriteset, @viewport, @map = spriteset, viewport, $game_map
      @tiles = []
      return unless enabled?
      @map.height.times do |y|
        @map.width.times do |x|
          tag = @map.terrain_tag(x, y)
          @tiles << [x, y] if tag.land_wild_encounters && @map.passableStrict?(x, y, 2, $game_player)
        end
      end
      @next_spawn = now
    end

    def available?(x, y)
      return false unless (@tiles || []).include?([x, y])
      return false if [$game_player.x, $game_player.y] == [x, y]
      return false if entries.any? { |entry| [entry[:character].x, entry[:character].y] == [x, y] }
      !@map.events.values.any? { |event| !event.through && event.x == x && event.y == y }
    end

    def roll_encounter
      table = ArenaDemo::VILLAGE_ENCOUNTERS
      roll = rand(table.sum { |row| row[0] })
      row = table.find { |candidate| roll -= candidate[0]; roll < 0 }
      [row[1], rand(row[2]..row[3])]
    end

    def spawn
      tile = (@tiles || []).shuffle.find do |x, y|
        available?(x, y) && (x - $game_player.x).abs + (y - $game_player.y).abs >= 2
      end
      return unless tile
      species, level = roll_encounter
      pokemon = pbGenerateWildPokemon(species, level)
      descriptor = ArenaDemo::FollowingIntegration.descriptor(pokemon)
      charset = ArenaDemo::FollowingIntegration.charset_for(descriptor)
      charset = '' unless !charset.empty? && pbResolveBitmap("Graphics/Characters/#{charset}")
      character = ArenaVisibleWildCharacter.new(tile[0], tile[1], charset)
      sprite = if charset.empty?
                 ArenaVisibleWildIcon.new(pokemon, character, @viewport)
               else
                 Sprite_Character.new(@viewport, character)
               end
      @spriteset.addUserSprite(sprite)
      entries << { :pokemon => pokemon, :character => character, :sprite => sprite,
                   :born => now, :move_at => now + 1 + rand * 2 }
    end

    def safe_frame?
      return false unless $scene.is_a?(Scene_Map) && $game_temp && $game_player && $player
      return false if $game_temp.in_battle || $game_temp.in_menu || @busy
      return false if defined?(pbMapInterpreterRunning?) && pbMapInterpreterRunning?
      true
    end

    def update
      unless enabled? && @map.equal?($game_map)
        clear unless entries.empty?
        return
      end
      return unless @spriteset && @viewport && safe_frame?
      entries.each { |entry| entry[:character].update }
      contact = entries.find { |entry| [entry[:character].x, entry[:character].y] == [$game_player.x, $game_player.y] }
      selected = @pending || contact
      @pending = nil
      if selected && entries.include?(selected) && !$game_player.moving? && $player.able_pokemon_count > 0
        entries.delete(selected)
        selected[:sprite].dispose unless selected[:sprite].disposed?
        @next_spawn = now + RESPAWN_SECONDS
        @busy = true
        begin
          WildBattle.start(selected[:pokemon])
        ensure
          @busy = false
          @next_spawn = now + RESPAWN_SECONDS
        end
        return
      end
      entries.dup.each do |entry|
        if now - entry[:born] >= LIFETIME_SECONDS
          entries.delete(entry)
          entry[:sprite].dispose unless entry[:sprite].disposed?
          @next_spawn = now + RESPAWN_SECONDS
          next
        end
        character = entry[:character]
        next if character.moving? || now < entry[:move_at]
        direction = DIRECTIONS.keys.sample
        dx, dy = DIRECTIONS[direction]
        character.move_generic(direction) if available?(character.x + dx, character.y + dy) &&
          @map.passableStrict?(character.x + dx, character.y + dy, direction, character)
        entry[:move_at] = now + 1.5 + rand * 2
      end
      if entries.length < target_count((@tiles || []).length) && now >= (@next_spawn || 0)
        spawn
        @next_spawn = now + 1.0
      end
    end

    def interact
      return unless enabled? && $game_player
      dx, dy = DIRECTIONS[$game_player.direction]
      @pending = entries.find do |entry|
        [entry[:character].x, entry[:character].y] == [$game_player.x + dx, $game_player.y + dy]
      end
    end
  end

  module VisibleWildStepEncounters
    def encounter_triggered?(*args)
      return false if ArenaDemo::VisibleWild.enabled?
      super
    end
  end
end

class ArenaVisibleWildCharacter < ArenaRemotePokemon
  def initialize(x, y, charset)
    super(nil, charset)
    self.move_speed = 3
    moveto(x, y)
  end
  def name; 'Village wild Pokemon'; end
end

if defined?(PokemonIconSprite)
  class ArenaVisibleWildIcon < PokemonIconSprite
    def initialize(pokemon, character, viewport)
      @wild_character = character
      super(pokemon, viewport)
      setOffset(PictureOrigin::CENTER) if defined?(PictureOrigin::CENTER) && respond_to?(:setOffset)
    end
    def update
      super
      return unless @wild_character
      self.x = @wild_character.screen_x
      self.y = @wild_character.screen_y - 16
      self.z = @wild_character.screen_z
    end
  end
end

PokemonEncounters.prepend(ArenaDemo::VisibleWildStepEncounters) if defined?(PokemonEncounters)
EventHandlers.add(:on_new_spriteset_map, :arena_visible_wild_context,
  proc { |spriteset, viewport| ArenaDemo::VisibleWild.context(spriteset, viewport) })
EventHandlers.add(:on_frame_update, :arena_visible_wild_update, proc { ArenaDemo::VisibleWild.update })
EventHandlers.add(:on_player_interact, :arena_visible_wild_interact, proc { ArenaDemo::VisibleWild.interact })
