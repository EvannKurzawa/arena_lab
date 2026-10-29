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
      return if @pvp_active || ($game_temp && $game_temp.in_battle)
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
      return if spriteset && spriteset.map != $game_map
      # A battle/map rebuild owns new sprites. Never reuse an old attachment.
      sprites.each_value { |sprite| sprite.dispose unless sprite.disposed? }
      sprites.clear
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
      (sprites.keys | followers.keys | (@last_descriptors || {}).keys).each { |id| dispose_remote(id) }
    end

    def sync_remote(id, leader, descriptor, attach = false)
      return dispose_remote(id) if defined?(PEMK) && id == PEMK.self_id
      return dispose_remote(id) unless leader && descriptor && !descriptor[:follower_species].to_s.empty?
      charset = charset_for(descriptor)
      return dispose_remote(id) if charset.empty?
      @last_descriptors ||= {}
      prior = @last_descriptors[id]
      if prior != descriptor || !followers[id]
        character = ArenaRemotePokemon.new(leader, charset)
        character.bind_owner(id)
        followers[id] = character
        @last_descriptors[id] = descriptor.dup
        old = sprites.delete(id)
        old.dispose if old && !old.disposed?
      end
      return unless attach || (@spriteset && @viewport)
      return unless @spriteset && @viewport && $scene.is_a?(Scene_Map)
      old = sprites[id]
      return if old && !old.disposed?
      sprite = ArenaRemotePokemonSprite.new(@viewport, followers[id])
      sprites[id] = sprite
      @spriteset.addUserSprite(sprite)
    end

    def remote_position(id, message)
      return dispose_remote(id) if id == PEMK.self_id
      return unless ARENA_MAPS.include?(message[:map])
      return dispose_remote(id) if $game_map && message[:map] != $game_map.map_id
      @last_descriptors ||= {}
      if message[:follower_species].to_s.empty?
        dispose_remote(id)
        return
      end
      descriptor = message.slice(
        :follower_species, :follower_form, :follower_gender,
        :follower_shiny, :follower_shadow
      )
      leader = PEMK::Remotes.players[id]
      sync_remote(id, leader, descriptor) if leader
    end

    def update_remote_followers
      return unless $scene.is_a?(Scene_Map)
      return if @pvp_active || ($game_temp && $game_temp.in_battle)
      followers.dup.each do |id, follower|
        leader = PEMK::Remotes.players[id] if defined?(PEMK::Remotes)
        unless leader
          dispose_remote(id)
          next
        end
        follower.follow_remote(leader)
        follower.update
      end
    end

    def rebuild_after_battle
      sprites.each_value { |sprite| sprite.dispose unless sprite.disposed? }
      sprites.clear
      followers.clear
      sprite_context(@spriteset, @viewport)
      PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
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

if defined?(Sprite_Character)
  class ArenaRemotePokemonSprite < Sprite_Character
    def initialize(viewport, character)
      @arena_owner_character = character
      super
    end

    def update
      # Following plugins can alter generic character sprite updates. Keep this
      # visual bound to the exact network-owned character on every frame.
      @character = @arena_owner_character
      super
      @character = @arena_owner_character
      self.x = @arena_owner_character.screen_x
      self.y = @arena_owner_character.screen_y
      self.z = @arena_owner_character.screen_z
    end
  end
end

if defined?(PEMK::BattleLauncher)
  module ArenaDemo::FollowingBattleCleanup
    def run_battle(*args)
      ArenaDemo::FollowingIntegration.instance_variable_set(:@pvp_active, true)
      super
    ensure
      ArenaDemo::FollowingIntegration.instance_variable_set(:@pvp_active, false)
      ArenaDemo::FollowingIntegration.rebuild_after_battle
    end
  end
  PEMK::BattleLauncher.singleton_class.prepend(ArenaDemo::FollowingBattleCleanup)
end

class ArenaRemotePokemon < Game_Character
  # Essentials' grass step callbacks use map_id as well as map.map_id.
  def map_id; map.map_id; end
  attr_reader :owner_id
  def bind_owner(id); @owner_id = id; @id = -id; end
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
    return if @owner_id && leader.respond_to?(:player_id) && leader.player_id != @owner_id
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
  def check_event_trigger_touch(*_args); false; end
  # Released Essentials 21.1 runtimes can still use the camelCase hooks.
  def pbCheckEventTriggerAfterTurning(*_args); false; end
  def pbCheckEventTriggerTouch(*_args); false; end
  def pbCheckEventTriggerAfterMoving(*_args); false; end
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
    return if message[:id] == PEMK.self_id
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
