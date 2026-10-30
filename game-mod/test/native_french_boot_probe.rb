if defined?(Game) && ENV['ARENA_LOCALE_PROBE']
module ArenaDemo::NativeLocaleProbe
  def set_up_system
    result = super
    path = ENV['ARENA_LOCALE_PROBE']
    return result unless path
    lines = []
    begin
      check = proc do |condition, name|
        raise "FAIL: #{name}" unless condition
        lines << "PASS: #{name}"
      end
      check.call(ArenaDemo::French::TEXT.length > 700, 'native catalog populated after PluginManager normalization')
      [Object.new, Kernel, ArenaDemo, FollowingPkmn].each do |receiver|
        value = receiver.send(:_INTL, '{1} started spinning around in circles.', 'Zekrom')
        check.call(value == 'Zekrom se met à tourner en rond.', "#{receiver.class}: actual _INTL translation")
      end
      check.call(_INTL("{1}'s", 'Zekrom') == 'Talent de Zekrom', 'native ability popup possessive')
      check.call(GameData::Ability.get(:TERAVOLT).name == 'Téra-Voltage', 'native ability name')
      check.call(_INTL('You got away safely!') == 'Vous avez pris la fuite !', 'native successful escape wording')
      inventory = _INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.", 'Poké Balls', 3, 'Poké Balls')
      check.call(inventory.start_with?('Vous rangez Poké Balls') && !inventory.include?("Sac's"), 'native actual inventory template')
      expected = Marshal.load(File.binread('../french_messages_audit.dat'))
      mismatched = expected.reject { |key, value| _INTL(key) == value }
      check.call(expected.length >= 3310 && mismatched.empty?, "#{expected.length} Essentials templates identical in native engine")
      $probe_ability_rows = []
      Object.send(:define_method, :pbDrawTextPositions) do |bitmap, rows|
        $probe_ability_rows = rows
      end
      bar = Battle::Scene::AbilitySplashBar.new(0)
      bar.battler = Struct.new(:abilityName).new('Téra-Voltage')
      check.call($probe_ability_rows.map(&:first) == ['Téra-Voltage'], 'actual ability bar draws only the ability name')
      bar.dispose
      ['Following Pokemon EX', 'PEMK'].each do |plugin|
        keys = Dir.glob("Plugins/#{plugin}/**/*.rb").flat_map { |p| File.read(p).scan(/_INTL\("((?:\\.|[^"\\])*)"/).flatten }.map { |key| key.gsub('\\\\') { '\\' }.gsub('\\"', '"') }.uniq
        missing = keys.select { |key| _INTL(key) == key }
        check.call(keys.length > 100 && missing.empty?, "native #{plugin}: #{keys.length} texts, untranslated=#{missing.inspect}")
      end
      # Keep the real translation wrappers and replace only the final UI sink.
      # Cancel all choices; no battles, save loads or save writes occur.
      $probe_dialogs = []
      Object.send(:define_method, :pbMessage) do |message, commands = nil, *args|
        $probe_dialogs << [message, commands]
        -1
      end
      Object.send(:define_method, :pbReceiveItem) { |*| false }
      ArenaDemo.singleton_class.send(:define_method, :ensure_custom_inventory) {}
      $PokemonGlobal = Struct.new(:arena_trail_supplies, :arena_trail_complete).new(true, false)
      $player = Object.new
      $probe_owned = false
      def $player.owned?(*); $probe_owned; end
      $game_map = Struct.new(:map_id).new(ArenaDemo::ENTRANCE_MAP_ID)
      ArenaDemo::ConnectionMode.attendant
      check.call($probe_dialogs.last[0].start_with?('État : hors ligne'), 'actual entrance attendant text')
      check.call($probe_dialogs.last[1] == ['Héberger en ligne', 'Trouver une arène à visiter', 'Retour'], 'actual entrance choices')
      ArenaDemo.arena_reception
      check.call($probe_dialogs.last[0] == 'Bienvenue dans votre arène. Que souhaitez-vous faire ?', 'actual inside guide')
      ArenaDemo.trail_scout
      check.call($probe_dialogs.last[0].start_with?('Des Pokémon sauvages'), 'actual outside scout')
      ArenaDemo.village_house
      check.call($probe_dialogs.last[0].start_with?('Une maison accueillante.'), 'actual house NPC')
      ArenaDemo.village_resident
      check.call($probe_dialogs.last[0].start_with?('Bienvenue au Village Arène !'), 'actual outside resident')
      $PokemonGlobal.arena_trail_supplies = false
      ArenaDemo.town_guide
      check.call($probe_dialogs.last[0].start_with?('Notre arène était'), 'actual village guide introduction')
      $PokemonGlobal.arena_trail_supplies = true
      ArenaDemo.town_guide
      check.call($probe_dialogs[-2][0].start_with?("Parlez à l'éclaireur"), 'actual village guide quest reminder')
      $probe_owned = true
      ArenaDemo.town_guide
      check.call($probe_dialogs[-2][0].start_with?('Un nouveau partenaire'), 'actual village guide reward')
      $PokemonGlobal.arena_trail_complete = true
      ArenaDemo.town_guide
      check.call($probe_dialogs[-2][0].start_with?('Votre arène perpétue'), 'actual village guide completed quest')
      lines << "#{lines.length} native engine checks passed. No save loaded or written."
      File.write(path, lines.join("\n"))
      exit! 0
    rescue Exception => error
      lines << [error.class, error.message, error.backtrace&.first(5)].inspect
      File.write(path, lines.join("\n"))
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeLocaleProbe)
end
