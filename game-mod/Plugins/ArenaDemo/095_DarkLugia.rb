# Optional local XD001 sprites; no external artwork is bundled with this plugin.
module ArenaDemo::DarkLugia
  FORM = 1
  ID = :LUGIA_1
  MOVESET_VERSION = 1
  LEVEL_MOVES = [
    [1, :ASTONISH], [1, :LEER], [1, :WHIRLWIND], [1, :DRAGONRUSH],
    [9, :MIST], [18, :TAUNT], [27, :NASTYPLOT], [36, :DARKPULSE],
    [45, :RECOVER], [54, :AEROBLAST], [63, :SHADOWBALL],
    [81, :DREAMEATER], [90, :OBLIVIONWING]
  ].map(&:freeze).freeze
  DEBUG_MOVES = [:AEROBLAST, :DARKPULSE, :NASTYPLOT, :OBLIVIONWING].freeze
  module_function

  def available?
    %w[Graphics/Pokemon/Front/LUGIA_1.png Graphics/Pokemon/Back/LUGIA_1.png
       Graphics/Pokemon/Icons/LUGIA_1.png Graphics/Characters/Followers/LUGIA_1.png].all? { |path| File.file?(path) }
  end

  def register
    return false unless available? && GameData::Species.exists?(:LUGIA)
    if GameData::Species.exists?(ID)
      raise 'Lugia form 1 already belongs to another plugin.' unless GameData::Species.get(ID).real_form_name == 'Dark Lugia (XD001)'
      return true
    end
    base = Marshal.load(Marshal.dump(GameData::Species.get(:LUGIA)))
    data = base.instance_variables.to_h { |key| [key.to_s.delete_prefix('@').to_sym, base.instance_variable_get(key)] }
    data.merge!(:id => ID, :species => :LUGIA, :form => FORM, :pokedex_form => FORM,
      :real_form_name => 'Dark Lugia (XD001)',
      :types => [:DARK, :FLYING], :moves => LEVEL_MOVES.map(&:dup),
      :real_pokedex_entry => 'Cette forme obscure de Lugia porte le nom de code XD001.')
    GameData::Species.register(data)
    true
  end

  def register_dex
    return unless GameData::Species.exists?(ID) && $player && $player.pokedex
    dex = $player.pokedex
    return if dex.seen_form?(:LUGIA, 0, FORM, false) && $player.has_pokedex
    $player.has_pokedex = true
    dex.unlock(-1)
    dex.register(:LUGIA, 0, FORM, false)
  end

  def make(level = 100)
    raise 'Dark Lugia assets are not installed.' unless register
    pokemon = Pokemon.new(:LUGIA, level)
    pokemon.form = FORM
    pokemon.name = 'Dark Lugia'
    update_moves(pokemon)
    pokemon.calc_stats
    pokemon.heal
    pokemon
  end

  # One-time conversion also covers existing saved XD001 when it joins the party.
  # Persist the marker on the Pokemon so later manual move choices are respected.
  def update_moves(pokemon)
    return false unless pokemon.species == :LUGIA && pokemon.form == FORM && !pokemon.egg?
    return false if pokemon.instance_variable_get(:@arena_xd001_moveset_version) == MOVESET_VERSION
    pokemon.reset_moves
    if pokemon.level == 100
      pokemon.moves.clear
      DEBUG_MOVES.each { |move| pokemon.learn_move(move) }
    end
    pokemon.instance_variable_set(:@arena_xd001_moveset_version, MOVESET_VERSION)
    true
  end

  def menu
    register_dex
    case pbMessage('Dark Lugia (XD001)', ['Voir dans le Pokédex', 'Recevoir Dark Lugia', 'Retour'], -1)
    when 0
      $player.pokedex.set_last_form_seen(:LUGIA, 0, FORM, false)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        PokemonPokedexInfoScreen.new(scene).pbStartSceneSingle(:LUGIA)
      end
    when 1
      pbAddPokemon(make(100)) if pbConfirmMessage('Recevoir Dark Lugia niveau 100 ?')
    end
  end

  module SpeciesLoader
    def load(*args)
      result = super
      ArenaDemo::DarkLugia.register
      result
    end
  end
end
GameData::Species.singleton_class.prepend(ArenaDemo::DarkLugia::SpeciesLoader)
ArenaDemo::DarkLugia.register
EventHandlers.add(:on_frame_update, :arena_xd001_dex, proc do
  next unless $scene.is_a?(Scene_Map) && $game_temp && !$game_temp.in_battle && !$game_temp.in_menu
  ArenaDemo::DarkLugia.register_dex
  $player.party.each { |pokemon| ArenaDemo::DarkLugia.update_moves(pokemon) } if $player
end)
MenuHandlers.add(:pause_menu, :arena_dark_lugia, {
  'name' => 'Dark Lugia', 'order' => 66,
  'condition' => proc { GameData::Species.exists?(ArenaDemo::DarkLugia::ID) },
  'effect' => proc { |menu| menu.pbEndScene; ArenaDemo::DarkLugia.menu; true }
})
