# Only forms introduced by Black 2/White 2 are offered in the playable roster.
# Keep engine data intact: later forms remain compiler dependencies only.
module ArenaDemo::PokedexRoster
  FORMS = ArenaDemo::AnimatedBattlers::FORMS.merge(:PICHU => [1].freeze).freeze
  def self.supported_form?(species, form)
    data = GameData::Species.try_get(species)
    return false unless data && supported?(data.species)
    form == 0 || FORMS.fetch(data.species, []).include?(form)
  end
  def self.runtime_form(species, form)
    # Preserve the old XD001 save representation until DarkLugia.update_owned
    # converts it to the standalone DARKLUGIA species.
    return form if species == :LUGIA && form == ArenaDemo::DarkLugia::FORM
    supported_form?(species, form) ? form : 0
  end
end
module ArenaDemo::GenFiveForms
  def form
    ArenaDemo::PokedexRoster.runtime_form(species, super)
  end
  def form_simple
    ArenaDemo::PokedexRoster.runtime_form(species, super)
  end
  def form=(value)
    super(ArenaDemo::PokedexRoster.runtime_form(species, value))
  end
  def form_simple=(value)
    super(ArenaDemo::PokedexRoster.runtime_form(species, value))
  end
  def forced_form=(value)
    super(value.nil? ? nil : ArenaDemo::PokedexRoster.runtime_form(species, value))
  end
  def setForm(value, &block)
    super(ArenaDemo::PokedexRoster.runtime_form(species, value), &block)
  end
end
Pokemon.prepend(ArenaDemo::GenFiveForms)
module ArenaDemo::GenFiveDexForms
  def pbGetAvailableForms
    super.select { |entry| ArenaDemo::PokedexRoster.supported_form?(@species, entry[2]) }
  end
end
PokemonPokedexInfo_Scene.prepend(ArenaDemo::GenFiveDexForms)
