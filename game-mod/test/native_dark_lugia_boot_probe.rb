if defined?(Game) && ENV['ARENA_XD001_PROBE']
module ArenaDemo::NativeDarkLugiaProbe
  def save_xd001_screen(path)
    bitmap = Graphics.snap_to_bitmap
    rows = String.new.b
    bitmap.height.times do |y|
      rows << "\0"
      bitmap.width.times do |x|
        color = bitmap.get_pixel(x, y)
        rows << [color.red, color.green, color.blue, color.alpha].map(&:to_i).pack('C4')
      end
    end
    chunk = proc { |type, data| [data.bytesize].pack('N') + type + data + [Zlib.crc32(type + data)].pack('N') }
    File.binwrite(path, "\x89PNG\r\n\x1a\n".b + chunk.call('IHDR', [bitmap.width, bitmap.height, 8, 6, 0, 0, 0].pack('NNCCCCC')) +
      chunk.call('IDAT', Zlib::Deflate.deflate(rows)) + chunk.call('IEND', ''.b))
    bitmap.dispose
  end

  def set_up_system
    path = ENV.fetch('ARENA_XD001_PROBE')
    lines = []
    begin
      check = proc { |ok, label| raise "FAIL: #{label}" unless ok; lines << "PASS: #{label}" }
      SaveData.initialize_bootup_values
      SaveData.load_new_game_values
      $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
      $map_factory = PokemonMapFactory.new(100)
      $game_player.moveto(50, 55)
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup(100)
      check.call(ArenaDemo::DarkLugia.available?, 'all four XD001 asset files installed')
      check.call(ArenaDemo::DarkLugia.register, 'Lugia form registration works after native data load')
      base, data = GameData::Species.get(:LUGIA), GameData::Species.get(:DARKLUGIA)
      national = []
      GameData::Species.each_species { |entry| national << entry.id }
      check.call(national.length == 650 && GameData::Species.species_count == 650 && national[-2..] == [:GENESECT, :DARKLUGIA], 'national roster has exactly 650 species and ends with Genesect then Dark Lugia')
      check.call(national.all? { |id| ArenaDemo::PokedexRoster.supported?(id) } && !national.include?(:CHESPIN) && !national.include?(:CALYREX), 'generation 6 and later species are excluded from the national list')
      complete_dex = Player::Pokedex.new
      (national + [:CHESPIN, :CALYREX]).each do |id|
        complete_dex.set_seen(id, false)
        complete_dex.set_owned(id, false)
      end
      check.call(complete_dex.seen_count == 650 && complete_dex.owned_count == 650, 'completed national seen/owned counters stop at 650 despite legacy later-generation records')
      national_scene = PokemonPokedex_Scene.new
      national_scene.define_singleton_method(:pbGetPokedexRegion) { -1 }
      actual_list = national_scene.pbGetDexList
      check.call(actual_list.length == 650 && actual_list.last.values_at(:species, :number) == [:DARKLUGIA, 650], 'actual national Pokedex menu has exactly 650 entries')
      eevee = Pokemon.new(:EEVEE, 25)
      check.call(eevee.check_evolution_on_use_item(:WATERSTONE) == :VAPOREON, 'native supported evolutions remain usable')
      sylveon_checked = false
      forbidden = eevee.check_evolution_internal do |_pokemon, target, _method, _parameter|
        next nil unless target == :SYLVEON
        sylveon_checked = true
        target
      end
      check.call(forbidden.nil? && !sylveon_checked, 'later-generation evolution targets are excluded before native condition checks')
      check.call(national.index(:DARKLUGIA) == 649 && national.index(:LUGIA) == 248, "national Pokedex numbers are Dark Lugia 650 and Lugia 249 (actual #{national.index(:DARKLUGIA).to_i + 1}/#{national.index(:LUGIA).to_i + 1}, #{national.length} species)")
      check.call(base.form == 0 && data.form == 0 && data.species == :DARKLUGIA && !GameData::Species.exists?(:LUGIA_1), 'XD001 has its own species entry instead of appearing under Lugia forms')
      check.call(base.types == [:PSYCHIC, :FLYING] && data.types == [:DARK, :FLYING], 'XD001 is Dark/Flying and normal Lugia stays Psychic/Flying')
      check.call(data.moves == ArenaDemo::DarkLugia::LEVEL_MOVES && data.moves.none? { |entry| entry[1] == :DARKVOID }, 'XD001 learns the requested progression without Dark Void')
      check.call(data.moves.all? { |entry| GameData::Move.exists?(entry[1]) }, 'all requested level-up moves exist in the native database')
      [:base_stats, :abilities, :hidden_abilities, :growth_rate].each do |key|
        check.call(data.public_send(key) == base.public_send(key), "inherits Lugia's native #{key}")
      end
      check.call(data.base_stats.object_id != base.base_stats.object_id, 'form data does not share mutable stat tables with base species')
      check.call(GameData::Species.cry_filename(:DARKLUGIA) == GameData::Species.cry_filename(:LUGIA), 'independent Dark Lugia keeps its native Lugia cry')
      availability = ArenaDemo::DarkLugia.method(:available?)
      begin
        ArenaDemo::DarkLugia.define_singleton_method(:available?) { false }
        GameData::Species::DATA.delete(:DARKLUGIA)
        check.call(ArenaDemo::DarkLugia.register && Pokemon.new(:DARKLUGIA, 5).species == :DARKLUGIA, 'custom species data remains loadable when optional local art is absent')
      ensure
        ArenaDemo::DarkLugia.define_singleton_method(:available?, availability)
      end
      pokemon = ArenaDemo::DarkLugia.make(100)
      check.call(pokemon.species == :DARKLUGIA && pokemon.form == 0 && pokemon.level == 100 && pokemon.name == 'Dark Lugia', 'factory builds a usable level 100 Dark Lugia')
      check.call(pokemon.hp == pokemon.totalhp && pokemon.moves.all? { |move| GameData::Move.exists?(move.id) }, 'native moves/stats initialized and healed')
      check.call(pokemon.types == [:DARK, :FLYING] && pokemon.moves.map(&:id) == ArenaDemo::DarkLugia::DEBUG_MOVES, 'level 100 XD001 has Dark/Flying typing and the requested four usable moves')
      ordinary = Pokemon.new(:LUGIA, 100)
      ordinary_moves = ordinary.moves.map(&:id)
      check.call(!ArenaDemo::DarkLugia.update_moves(ordinary) && ordinary.moves.map(&:id) == ordinary_moves, 'normal Lugia moves are preserved')
      existing = Pokemon.new(:LUGIA, 100)
      existing.form = 1
      existing.moves.clear
      existing.learn_move(:SURF)
      existing.hp = 1
      check.call(ArenaDemo::DarkLugia.update_moves(existing) && existing.species == :DARKLUGIA && existing.form == 0 && existing.moves.map(&:id) == ArenaDemo::DarkLugia::DEBUG_MOVES && existing.hp == 1, 'saved Lugia form 1 migrates to Dark Lugia without healing')
      existing.moves.clear
      existing.learn_move(:SURF)
      restored = Marshal.load(Marshal.dump(existing))
      check.call(!ArenaDemo::DarkLugia.update_moves(restored) && restored.moves.map(&:id) == [:SURF], 'saved migration marker preserves subsequent manual move changes')
      young = ArenaDemo::DarkLugia.make(36)
      check.call(young.moves.map(&:id) == [:MIST, :TAUNT, :NASTYPLOT, :DARKPULSE], 'lower-level XD001 uses its own native level-up learnset')
      ArenaDemo::DarkLugia.register_dex
      check.call($player.has_pokedex && $player.pokedex.seen_form?(:DARKLUGIA, 0, 0, false), 'national Pokedex enables and records Dark Lugia as seen')
      check.call(!$player.pokedex.owned?(:DARKLUGIA), 'Pokedex discovery does not mark an unreceived Pokemon as owned')
      $player.pokedex.set_last_form_seen(:DARKLUGIA, 0, 0, false)
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      sprites = []
      [false, true].each_with_index do |back, index|
        filename = GameData::Species.sprite_filename(:DARKLUGIA, 0, 2, false, false, back)
        check.call(filename.include?('DARKLUGIA'), "native #{back ? 'back' : 'front'} graphic resolver chooses XD001")
        sprite = Battle::Scene::BattlerSprite.new(viewport, 1, back ? 0 : 1, [])
        sprites << sprite
        sprite.setPokemonBitmap(pokemon, back)
        sprite.visible = true
        check.call(sprite.bitmap.width >= 192 && sprite.bitmap.height >= 192, 'native battler preserves full-size animated XD001 poses')
        icon = sprite.instance_variable_get(:@_iconBitmap)
        check.call(icon.is_a?(ArenaDemo::AnimatedBattlers::Canvas), 'XD001 uses its own animated battle artwork')
        check.call(icon.length == (back ? 120 : 60), 'native GIF retains all original Lugia animation frames')
        source = icon.instance_variable_get(:@source)
        sample = proc { (0...sprite.height).step(4).map { |y| (0...sprite.width).step(4).map { |x| c = sprite.bitmap.get_pixel(x, y); [c.red, c.green, c.blue, c.alpha] } } }
        before = sample.call
        changed = false
        (1...icon.length).each do |frame|
          source.bitmap.goto_and_stop(frame)
          icon.update
          if sample.call != before
            changed = true
            break
          end
        end
        check.call(changed, 'native GIF frames change Dark Lugia pose pixels')
        sprite.x, sprite.y = 160 + 230 * index, 310
      end
      Graphics.transition(0)
      Graphics.update
      save_xd001_screen(path.sub('.log', '-battle.png'))
      sprites.each(&:dispose)
      [[:LUGIA, 0, true], [:ZEKROM, 0, true], [:KYUREM, 3, true],
       [:GIRATINA, 1, false], [:GIRATINA, 1, true]].each do |species, form, back|
        subject = Pokemon.new(species, 100)
        subject.forced_form = form
        battler = Battle::Scene::BattlerSprite.new(viewport, 1, back ? 0 : 1, [])
        battler.setPokemonBitmap(subject, back)
        canvas = battler.instance_variable_get(:@_iconBitmap)
        check.call(canvas.is_a?(ArenaDemo::AnimatedBattlers::Canvas), "animated size regression: #{species} form #{form} back=#{back}")
        source = canvas.instance_variable_get(:@source)
        target = canvas.instance_variable_get(:@target)
        check.call(target.width == source.width * 2 && target.height == source.height * 2, 'native GIF artwork retains exact double pixel scale')
        check.call(target.x >= 0 && target.y >= 0 && target.x + target.width <= battler.width && target.y + target.height <= battler.height, 'large wings and back poses fit without clipping')
        battler.dispose
      end
      viewport.dispose
      $scene = Scene_Map.new
      $scene.createSpritesets
      $player.party = [pokemon]
      stored = Pokemon.new(:LUGIA, 65)
      stored.form = 1
      stored.name = 'XD sauvegardé'
      stored.item = :LEFTOVERS
      stored.hp = 23
      stored.moves.clear
      stored.learn_move(:SURF)
      stored.instance_variable_set(:@arena_xd001_moveset_version, ArenaDemo::DarkLugia::MOVESET_VERSION)
      original_exp, original_owner = stored.exp, stored.owner.id
      $PokemonStorage[0, 0] = stored
      ArenaDemo::DarkLugia.instance_variable_set(:@migrated_storage, nil)
      ArenaDemo::DarkLugia.update_owned
      check.call($PokemonStorage[0, 0].equal?(stored) && stored.species == :DARKLUGIA && stored.form == 0, 'stored legacy XD001 migrates in place to the independent species')
      check.call([stored.name, stored.item_id, stored.hp, stored.exp, stored.owner.id, stored.moves.map(&:id)] == ['XD sauvegardé', :LEFTOVERS, 23, original_exp, original_owner, [:SURF]], 'storage migration preserves nickname, item, HP, experience, owner and manual moves')
      check.call($player.pokedex.owned?(:DARKLUGIA), 'existing owned XD001 is marked owned under its new Pokedex entry')
      ArenaDemo::DarkLugia.register_dex
      check.call($player.pokedex.last_form_seen(:LUGIA)[1] == 0, 'Lugia 249 no longer remembers the legacy Dark Lugia artwork')
      FollowingPkmn.start_following(900, false) unless FollowingPkmn.get
      FollowingPkmn.toggle(true, false)
      FollowingPkmn.refresh(false)
      follower = FollowingPkmn.get_event
      check.call(FollowingPkmn.active? && follower.character_name.include?('DARKLUGIA'), 'Following EX selects the Dark Lugia species on the overworld')
      follower.direction = 6
      follower.pattern = 1
      $scene.updateSpritesets
      Graphics.update
      save_xd001_screen(path.sub('.log', '-follower.png'))
      dex = PokemonPokedexInfo_Scene.new
      dex.pbStartScene([{:species => :DARKLUGIA, :name => data.name, :height => 0, :weight => 0, :number => 650, :shift => false}], 0, -1)
      check.call(dex.instance_variable_get(:@species) == :DARKLUGIA && dex.instance_variable_get(:@dexlist)[0][:number] == 650, 'actual Pokedex entry opens Dark Lugia number 650')
      forms = dex.pbGetAvailableForms
      check.call(forms.any? { |_name, _gender, form| form == 0 }, 'native Pokedex selector supports the independent Dark Lugia species')
      dex.instance_variable_set(:@page, 3)
      dex.drawPage(3)
      Graphics.update
      save_xd001_screen(path.sub('.log', '-pokedex.png'))
      dex.pbEndScene
      $scene.dispose
      lines << "#{lines.length} native Dark Lugia checks passed. No player save read or written."
      File.write(path, lines.join("\n"))
      exit! 0
    rescue Exception => error
      lines << [error.class, error.message, error.backtrace&.first(10)].inspect
      File.write(path, lines.join("\n"))
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeDarkLugiaProbe)
end
