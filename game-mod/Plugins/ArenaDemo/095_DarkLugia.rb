# Optional local XD001 sprites; no external artwork is bundled with this plugin.
module ArenaDemo::PokedexRoster
  module_function
  def supported?(species)
    data = GameData::Species.try_get(species)
    data && (data.species == :DARKLUGIA || data.generation.between?(1, 5))
  end
end

module ArenaDemo::DarkLugia
  FORM = 1
  ID = :LUGIA_1
  SPECIES = :DARKLUGIA
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
    # Register data on every client, even when optional local artwork is absent.
    # Saved/received custom Pokemon must remain loadable independently of assets.
    return false unless GameData::Species.exists?(:LUGIA)
    if GameData::Species.exists?(ID)
      raise 'Lugia form 1 already belongs to another plugin.' unless GameData::Species.get(ID).real_form_name == 'Dark Lugia (XD001)'
      GameData::Species::DATA.delete(ID)
    end
    return true if GameData::Species.exists?(SPECIES)
    base = Marshal.load(Marshal.dump(GameData::Species.get(:LUGIA)))
    data = base.instance_variables.to_h { |key| [key.to_s.delete_prefix('@').to_sym, base.instance_variable_get(key)] }
    data.merge!(:id => SPECIES, :species => SPECIES, :form => 0, :pokedex_form => 0,
      :real_name => 'Dark Lugia', :real_form_name => nil,
      :types => [:DARK, :FLYING], :moves => LEVEL_MOVES.map(&:dup),
      :real_pokedex_entry => 'Cette forme obscure de Lugia porte le nom de code XD001.')
    GameData::Species.register(data)
    true
  end

  def register_dex
    return unless GameData::Species.exists?(SPECIES) && $player && $player.pokedex
    dex = $player.pokedex
    gender, previous_form, shiny = dex.last_form_seen(:LUGIA)
    dex.set_last_form_seen(:LUGIA, gender, 0, shiny) if previous_form == FORM
    return if dex.seen_form?(SPECIES, 0, 0, false) && $player.has_pokedex
    $player.has_pokedex = true
    dex.unlock(-1)
    dex.register(SPECIES, 0, 0, false)
  end

  def make(level = 100)
    raise 'Dark Lugia assets are not installed.' unless available? && register
    pokemon = Pokemon.new(SPECIES, level)
    pokemon.name = 'Dark Lugia'
    update_moves(pokemon)
    pokemon.calc_stats
    pokemon.heal
    pokemon
  end

  # One-time conversion also covers existing saved XD001 when it joins the party.
  # Persist the marker on the Pokemon so later manual move choices are respected.
  def update_moves(pokemon)
    legacy = pokemon.species == :LUGIA && pokemon.form == FORM
    return false unless (legacy || pokemon.species == SPECIES) && !pokemon.egg?
    if legacy
      pokemon.species = SPECIES
      pokemon.form = 0
    end
    return legacy if pokemon.instance_variable_get(:@arena_xd001_moveset_version) == MOVESET_VERSION
    pokemon.reset_moves
    if pokemon.level == 100
      pokemon.moves.clear
      DEBUG_MOVES.each { |move| pokemon.learn_move(move) }
    end
    pokemon.instance_variable_set(:@arena_xd001_moveset_version, MOVESET_VERSION)
    true
  end

  def update_owned
    return unless $player
    $player.party.each do |pokemon|
      update_moves(pokemon)
      $player.pokedex.set_owned(SPECIES) if pokemon.species == SPECIES && !pokemon.egg? && !$player.pokedex.owned?(SPECIES)
    end
    return unless defined?($PokemonStorage) && $PokemonStorage
    key = [$player.object_id, $PokemonStorage.object_id]
    return if @migrated_storage == key
    $PokemonStorage.maxBoxes.times do |box|
      $PokemonStorage.maxPokemon(box).times do |index|
        pokemon = $PokemonStorage[box, index]
        update_moves(pokemon) if pokemon
        $player.pokedex.set_owned(SPECIES) if pokemon && pokemon.species == SPECIES && !pokemon.egg?
      end
    end
    @migrated_storage = key
  end

  def menu
    register_dex
    case pbMessage('Dark Lugia (XD001)', ['Voir dans le Pokédex', 'Recevoir Dark Lugia', 'Retour'], -1)
    when 0
      $player.pokedex.set_last_form_seen(SPECIES, 0, 0, false)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        PokemonPokedexInfoScreen.new(scene).pbStartSceneSingle(SPECIES)
      end
    when 1
      pbAddPokemon(make(100)) if pbConfirmMessage('Recevoir Dark Lugia niveau 100 ?')
    end
  end

  module SpeciesLoader
    def each_species
      return enum_for(:each_species) unless block_given?
      # Compiler exports must retain the complete dependency graph (including
      # evolutions and regional forms). The playable national roster stays 1–5.
      return super { |entry| yield entry } if Thread.current[:arena_compiling_species]
      entries = []
      super { |entry| entries << entry if ArenaDemo::PokedexRoster.supported?(entry) }
      dark = entries.find { |entry| entry.id == ArenaDemo::DarkLugia::SPECIES }
      if dark
        entries.delete(dark)
        entries.insert([649, entries.length].min, dark)
      end
      entries.each { |entry| yield entry }
    end

    def load(*args)
      result = super
      ArenaDemo::DarkLugia.register
      result
    end
    def cry_filename(species, form = 0, suffix = '')
      super(species == ArenaDemo::DarkLugia::SPECIES ? :LUGIA : species, form, suffix)
    end
    def sprite_filename(species, *args)
      result = super
      return result if result || species != ArenaDemo::DarkLugia::SPECIES
      super(:LUGIA, *args)
    end
    def icon_filename(species, *args)
      result = super
      return result if result || species != ArenaDemo::DarkLugia::SPECIES
      super(:LUGIA, *args)
    end
  end

  def register_metrics
    return unless GameData::Species.exists?(SPECIES) && GameData::SpeciesMetrics.exists?(:LUGIA)
    base = Marshal.load(Marshal.dump(GameData::SpeciesMetrics.get(:LUGIA)))
    values = base.instance_variables.to_h { |key| [key.to_s.delete_prefix('@').to_sym, base.instance_variable_get(key)] }
    GameData::SpeciesMetrics.register(values.merge(:id => SPECIES, :species => SPECIES, :form => 0))
  end
  module MetricsLoader
    def load(*args)
      result = super
      ArenaDemo::DarkLugia.register_metrics
      result
    end
  end
end
module ArenaDemo::FullSpeciesCompilation
  def with_arena_species_dependencies
    previous = Thread.current[:arena_compiling_species]
    Thread.current[:arena_compiling_species] = true
    yield
  ensure
    Thread.current[:arena_compiling_species] = previous
  end
  def write_all(*args)
    with_arena_species_dependencies { super }
  end
  def compile_all(*args)
    with_arena_species_dependencies { super }
  end
  def write_pokemon(*args)
    with_arena_species_dependencies { super }
  end
  def compile_pokemon(*args)
    with_arena_species_dependencies { super }
  end
end
Compiler.singleton_class.prepend(ArenaDemo::FullSpeciesCompilation) if defined?(Compiler)
GameData::Species.singleton_class.prepend(ArenaDemo::DarkLugia::SpeciesLoader)
GameData::SpeciesMetrics.singleton_class.prepend(ArenaDemo::DarkLugia::MetricsLoader)
ArenaDemo::DarkLugia.register
ArenaDemo::DarkLugia.register_metrics
EventHandlers.add(:on_frame_update, :arena_xd001_dex, proc do
  next unless $scene.is_a?(Scene_Map) && $game_temp && !$game_temp.in_battle && !$game_temp.in_menu
  ArenaDemo::DarkLugia.register_dex
  ArenaDemo::DarkLugia.update_owned
end)

module ArenaDemo::GenFiveEvolution
  def check_evolution_internal(&condition)
    super do |pokemon, target, method, parameter|
      next nil unless ArenaDemo::PokedexRoster.supported?(target)
      condition.call(pokemon, target, method, parameter)
    end
  end
end
Pokemon.prepend(ArenaDemo::GenFiveEvolution)
MenuHandlers.add(:pause_menu, :arena_dark_lugia, {
  'name' => 'Dark Lugia', 'order' => 66,
  'condition' => proc { ArenaDemo::DarkLugia.available? && GameData::Species.exists?(ArenaDemo::DarkLugia::SPECIES) },
  'effect' => proc { |menu| menu.pbEndScene; ArenaDemo::DarkLugia.menu; true }
})
