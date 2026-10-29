# frozen_string_literal: true

# Arena Lab integration for Following Pokemon EX 2.5.1 (Essentials 21.1).
# Local followers use the plugin's real Game_Follower system and charset assets.
# Multiplayer only relays a species/form descriptor; clients resolve the sprite
# locally and never accept asset paths from the network.
module ArenaDemo
  module FollowingIntegration
    ARENA_MAPS = [100, 101, 102].freeze

    module_function

    def local_pokemon
      return nil unless defined?(FollowingPkmn) && FollowingPkmn.can_check?
      pokemon = FollowingPkmn.get_pokemon
      return nil if !pokemon || pokemon.egg?
      pokemon
    rescue StandardError
      nil
    end

    def descriptor(pokemon = local_pokemon)
      empty = {
        :follower_species => "", :follower_form => 0, :follower_gender => 0,
        :follower_shiny => false, :follower_shadow => false
      }
      return empty unless pokemon
      species = pokemon.species.to_s.upcase
      return empty unless species.match?(/\A[A-Z0-9_]{1,32}\z/) && GameData::Species.try_get(species.to_sym)
      {
        :follower_species => species,
        :follower_form => pokemon.form.to_i,
        :follower_gender => pokemon.gender.to_i,
        :follower_shiny => pokemon.shiny? == true,
        :follower_shadow => pokemon.shadow == true
      }
    rescue StandardError
      empty
    end

    def charset_for(message)
      species = message[:follower_species].to_s
      return "" unless species.match?(/\A[A-Z0-9_]{1,32}\z/)
      return "" unless GameData::Species.try_get(species.to_sym)
      path = GameData::Species.ow_sprite_filename(
        species.to_sym, message[:follower_form].to_i,
        message[:follower_gender].to_i, message[:follower_shiny] == true,
        message[:follower_shadow] == true, false
      )
      path.to_s.sub(/\AGraphics\/Characters\//i, "").sub(/\.(png|bmp)\z/i, "")
    rescue StandardError
      ""
    end

    def ensure_local_follower
      return unless defined?(FollowingPkmn) && $game_map && ARENA_MAPS.include?($game_map.map_id)
      return unless local_pokemon && $game_map.events[900]
      return if FollowingPkmn.get
      FollowingPkmn.start_following(900, false)
    rescue StandardError => e
      echoln("[Arena Lab] Could not start following Pokémon: #{e.message}") if defined?(echoln)
    end

    def followers
      @followers ||= {}
    end

    def sprites
      @sprites ||= {}
    end

    def sprite_context(spriteset, viewport)
      @spriteset = spriteset
      @viewport = viewport
      return unless spriteset && viewport && defined?(PEMK::Remotes)
      PEMK::Remotes.players.each do |id, leader|
        sync_remote(id, leader, @last_descriptors && @last_descriptors[id], true)
      end
    end

    def dispose_remote(id)
      sprite = sprites.delete(id)
      sprite.dispose if sprite && !sprite.disposed?
      followers.delete(id)
      (@last_descriptors || {}).delete(id)
    rescue StandardError
      nil
    end

    def clear_remote
      sprites.keys.each { |id| dispose_remote(id) }
    end

    def sync_remote(id, leader, descriptor, attach = false)
      return dispose_remote(id) unless leader && descriptor && !descriptor[:follower_species].to_s.empty?
      charset = charset_for(descriptor)
      return dispose_remote(id) if charset.empty?
      @last_descriptors ||= {}
      prior = @last_descriptors[id]
      if prior != descriptor || !followers[id]
        character = ArenaRemotePokemon.new(leader, charset)
        followers[id] = character
        @last_descriptors[id] = descriptor.dup
        old = sprites.delete(id)
        old.dispose if old && !old.disposed?
      end
      return unless attach || (@spriteset && @viewport)
      return unless @spriteset && @viewport && $scene.is_a?(Scene_Map)
      old = sprites[id]
      return if old && !old.disposed?
      sprite = Sprite_Character.new(@viewport, followers[id])
      sprites[id] = sprite
      @spriteset.addUserSprite(sprite)
    end

    def remote_position(id, message)
      return unless ARENA_MAPS.include?(message[:map])
      @last_descriptors ||= {}
      if message[:follower_species].to_s.empty?
        dispose_remote(id)
        return
      end
      @last_descriptors[id] = message.slice(
        :follower_species, :follower_form, :follower_gender,
        :follower_shiny, :follower_shadow
      )
      leader = PEMK::Remotes.players[id]
      sync_remote(id, leader, @last_descriptors[id]) if leader
    end

    def update_remote_followers
      return unless $scene.is_a?(Scene_Map)
      followers.each do |id, follower|
        leader = PEMK::Remotes.players[id] if defined?(PEMK::Remotes)
        next unless leader
        follower.follow_remote(leader)
        follower.update
      end
    end

    def install_network_hooks
      if defined?(PEMK::Presence) &&
         !PEMK::Presence.singleton_class.ancestors.include?(ArenaDemo::FollowingPresence)
        PEMK::Presence.singleton_class.prepend(ArenaDemo::FollowingPresence)
      end
      if defined?(PEMK::Remotes) &&
         !PEMK::Remotes.singleton_class.ancestors.include?(ArenaDemo::FollowingRemotes)
        PEMK::Remotes.singleton_class.prepend(ArenaDemo::FollowingRemotes)
      end
    end
  end
end

class ArenaRemotePokemon < Game_Character
  def initialize(leader, charset)
    super($game_map)
    @through = true
    @walk_anime = true
    @step_anime = false
    self.move_speed = 4
    self.character_name = charset
    follow_remote(leader, true)
  end

  def follow_remote(leader, snap = false)
    return unless leader
    self.move_speed = leader.move_speed if leader.respond_to?(:move_speed)
    self.direction = leader.direction if [2, 4, 6, 8].include?(leader.direction)
    dx = (leader.direction == 6) ? -1 : (leader.direction == 4) ? 1 : 0
    dy = (leader.direction == 2) ? -1 : (leader.direction == 8) ? 1 : 0
    target_x = leader.x + dx
    target_y = leader.y + dy
    if snap || (self.x - target_x).abs + (self.y - target_y).abs > 3
      moveto(target_x, target_y)
      return
    end
    return if moving? || [self.x, self.y] == [target_x, target_y]
    case [target_x - self.x, target_y - self.y]
    when [1, 0] then move_right(false)
    when [-1, 0] then move_left(false)
    when [0, 1] then move_down(false)
    when [0, -1] then move_up(false)
    else moveto(target_x, target_y)
    end
  end

  def name; "Arena remote follower"; end

  # This character is visual-only; movement must not invoke map event triggers.
  def check_event_trigger_after_turning(*_args); end
end

module ArenaDemo::FollowingPresence
  def build(type)
    frame = super
    frame.merge!(ArenaDemo::FollowingIntegration.descriptor) if ArenaDemo::FollowingIntegration::ARENA_MAPS.include?(frame[:map])
    frame
  end

  def key_of(frame)
    super + ArenaDemo::FollowingIntegration.descriptor.values_at(
      :follower_species, :follower_form, :follower_gender,
      :follower_shiny, :follower_shadow
    )
  end
end

module ArenaDemo::FollowingRemotes
  def apply_pos(message)
    result = super
    ArenaDemo::FollowingIntegration.remote_position(message[:id], message) if message[:id]
    result
  end

  def remove(id)
    ArenaDemo::FollowingIntegration.dispose_remote(id)
    super
  end

  def clear_all
    ArenaDemo::FollowingIntegration.clear_remote
    super
  end
end

EventHandlers.add(:on_new_spriteset_map, :arena_demo_following_sprites,
  proc { |spriteset, viewport| ArenaDemo::FollowingIntegration.sprite_context(spriteset, viewport) })
EventHandlers.add(:on_frame_update, :arena_demo_following_update, proc {
  ArenaDemo::FollowingIntegration.install_network_hooks
  ArenaDemo::FollowingIntegration.ensure_local_follower
  ArenaDemo::FollowingIntegration.update_remote_followers if defined?(PEMK::Remotes)
})
