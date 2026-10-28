# Disabled prototype retained temporarily while switching to actual walking
# sprites from a licensed, version-compatible follower pack.
if false
module ArenaDemo
  module FollowingPokemon
    module_function

    def species_id(pokemon)
      return "" if !pokemon || pokemon.egg?
      value = pokemon.species.to_s.upcase
      return value if value.match?(/\A[A-Z0-9_]{1,32}\z/) && GameData::Species.try_get(value.to_sym)
      ""
    rescue StandardError
      ""
    end

    def local_pokemon
      return nil if !$player || !$player.party || $player.party.empty?
      pokemon = $player.party.find { |member| member && !member.egg? }
      return nil if species_id(pokemon).empty?
      pokemon
    end

    def pokemon_for(species)
      data = GameData::Species.try_get(species.to_sym)
      return nil if !data
      Pokemon.new(data.id, 1)
    rescue StandardError
      nil
    end

    def local_sprite
      @local_sprite
    end

    def current_spriteset; @spriteset; end
    def current_viewport; @viewport; end

    def remote_sprites
      @remote_sprites ||= {}
    end

    def set_remote_species(player_id, species)
      @remote_species ||= {}
      value = species.to_s
      value = "" unless value.empty? || value.match?(/\A[A-Z0-9_]{1,32}\z/)
      @remote_species[player_id] = value
    end

    def remote_species(player_id)
      (@remote_species || {})[player_id].to_s
    end

    def refresh_remote_sprite(player_id, spriteset, viewport)
      remote = PEMK::Remotes.players[player_id]
      species = remote_species(player_id)
      unless remote && !species.empty?
        old = remote_sprites.delete(player_id)
        old.dispose if old && !old.disposed?
        return
      end
      sprite = remote_sprites[player_id]
      if sprite && sprite.species_id != species
        sprite.dispose unless sprite.disposed?
        sprite = nil
      end
      unless sprite
        pokemon = pokemon_for(species)
        return if !pokemon
        sprite = ArenaFollowingPokemonSprite.new(pokemon, remote, viewport, species)
        remote_sprites[player_id] = sprite
        spriteset.addUserSprite(sprite)
      end
    end

    def attach_all(spriteset, viewport)
      return unless spriteset && viewport && $scene.is_a?(Scene_Map)
      @spriteset = spriteset
      @viewport = viewport
      if local_pokemon
        if !@local_sprite || @local_sprite.disposed? || @local_sprite.viewport != viewport
          @local_sprite.dispose if @local_sprite && !@local_sprite.disposed?
          @local_sprite = ArenaFollowingPokemonSprite.new(local_pokemon, $game_player, viewport,
                                                          species_id(local_pokemon))
          spriteset.addUserSprite(@local_sprite)
        end
      else
        @local_sprite.dispose if @local_sprite && !@local_sprite.disposed?
        @local_sprite = nil
      end
      return unless defined?(PEMK::Remotes)
      PEMK::Remotes.players.each_key do |player_id|
        refresh_remote_sprite(player_id, spriteset, viewport)
      end
    end
  end
end

class ArenaFollowingPokemonSprite < PokemonIconSprite
  attr_reader :species_id

  def initialize(pokemon, leader, viewport, species_id)
    super(pokemon, viewport)
    @leader = leader
    @species_id = species_id.to_s
    self.zoom_x = 1.35
    self.zoom_y = 1.35
    self.ox = self.bitmap.width / 2 if self.bitmap
    self.oy = self.bitmap.height if self.bitmap
    self.z = 1
  end

  def update
    super
    return if !@leader || !@leader.respond_to?(:screen_x)
    direction = @leader.direction
    dx = (direction == 6) ? -1 : (direction == 4) ? 1 : 0
    dy = (direction == 2) ? -1 : (direction == 8) ? 1 : 0
    self.x = @leader.screen_x + dx * Game_Map::TILE_WIDTH
    self.y = @leader.screen_y + dy * Game_Map::TILE_HEIGHT - 2
    self.z = [@leader.screen_z - 1, 0].max
    self.visible = !@leader.transparent
  end
end

if defined?(PEMK::Presence)
  module ArenaDemo::FollowingPresence
    def build(type)
      super.merge(:follower => ArenaDemo::FollowingPokemon.species_id(ArenaDemo::FollowingPokemon.local_pokemon))
    end

    def key_of(frame)
      super + [frame[:follower]]
    end
  end
  PEMK::Presence.singleton_class.prepend(ArenaDemo::FollowingPresence)
end

if defined?(PEMK::Remotes)
  module ArenaDemo::FollowingRemotes
    def apply_pos(message)
      result = super
      ArenaDemo::FollowingPokemon.set_remote_species(message[:id], message[:follower]) if message[:id]
      spriteset = ArenaDemo::FollowingPokemon.current_spriteset
      viewport = ArenaDemo::FollowingPokemon.current_viewport
      if spriteset && viewport && message[:id]
        ArenaDemo::FollowingPokemon.refresh_remote_sprite(message[:id], spriteset, viewport)
      end
      result
    end

    def remove(player_id)
      sprite = ArenaDemo::FollowingPokemon.remote_sprites.delete(player_id)
      sprite.dispose if sprite && !sprite.disposed?
      (ArenaDemo::FollowingPokemon.instance_variable_get(:@remote_species) || {}).delete(player_id)
      super
    end

    def clear_all
      ArenaDemo::FollowingPokemon.remote_sprites.each_value do |sprite|
        sprite.dispose if sprite && !sprite.disposed?
      end
      ArenaDemo::FollowingPokemon.remote_sprites.clear
      ArenaDemo::FollowingPokemon.instance_variable_set(:@remote_species, {})
      super
    end
  end
  PEMK::Remotes.singleton_class.prepend(ArenaDemo::FollowingRemotes)
end

EventHandlers.add(:on_new_spriteset_map, :arena_following_pokemon,
  proc { |spriteset, viewport| ArenaDemo::FollowingPokemon.attach_all(spriteset, viewport) })
EventHandlers.add(:on_frame_update, :arena_following_pokemon_refresh,
  proc do
    spriteset = ArenaDemo::FollowingPokemon.current_spriteset
    viewport = ArenaDemo::FollowingPokemon.current_viewport
    if $scene.is_a?(Scene_Map) && spriteset && viewport
      ArenaDemo::FollowingPokemon.attach_all(spriteset, viewport)
      sprite = ArenaDemo::FollowingPokemon.local_sprite
      if sprite && !sprite.disposed? && ArenaDemo::FollowingPokemon.local_pokemon
        pokemon = ArenaDemo::FollowingPokemon.local_pokemon
        if sprite.pokemon != pokemon
          sprite.pokemon = pokemon
          sprite.instance_variable_set(:@species_id, ArenaDemo::FollowingPokemon.species_id(pokemon))
        end
      end
    end
  end)
end
