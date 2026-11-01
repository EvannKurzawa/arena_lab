# Activated only in the disposable native test game.
if defined?(Game) && ENV['ARENA_BATTLERS_PROBE']
module ArenaDemo::NativeBattlersProbe
  def set_up_system
    path = ENV.fetch('ARENA_BATTLERS_PROBE')
    lines = []
    sprites = []
    begin
      check = proc { |ok, label| raise("FAIL: #{label}") unless ok; lines << "PASS: #{label}" }
      SaveData.initialize_bootup_values
      SaveData.load_new_game_values
      $map_factory = PokemonMapFactory.new(100)
      $game_player.moveto(49, 53)
      entries = %w[BIKER CUEBALL YOUNGSTER].map { |name| { sprite: "trainer_#{name}" } }
      window = ArenaCatalogWindow.new(entries, ['Motard', 'Loubard', 'Gamin'])
      window.contents.singleton_class.prepend(Module.new do
        def stretch_blt(destination, bitmap, source, *rest)
          ($trainer_rects ||= []) << [source.x, source.y, source.width, source.height, destination.width, destination.height]
          super
        end
      end)
      window.refresh
      check.call($trainer_rects[0][0, 4] == [48, 0, 48, 48], 'Motard: one complete 48px pose')
      check.call($trainer_rects[1][0, 4] == [48, 0, 48, 48], 'Loubard: one complete 48px pose')
      check.call($trainer_rects[2][0, 4] == [32, 0, 32, 48], 'normal trainers retain their complete pose')
      check.call($trainer_rects.all? { |r| r[4] <= 44 && r[5] <= 48 }, 'all trainer previews fit their row')
      window.dispose
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      [[:ZEKROM, false, false], [:DIALGA, true, false], [:PIKACHU, false, true], [:BULBASAUR, true, true]].each do |species, back, shiny|
        pokemon = Pokemon.new(species, 50)
        pokemon.shiny = shiny
        original = GameData::Species.sprite_bitmap_from_pokemon(pokemon, back)
        sprite = Battle::Scene::BattlerSprite.new(viewport, 1, back ? 0 : 1, [])
        sprites << sprite
        sprite.setPokemonBitmap(pokemon, back)
        icon = sprite.instance_variable_get(:@_iconBitmap)
        check.call(icon.is_a?(ArenaDemo::AnimatedBattlers::Canvas), "native animated battler: #{species}, back=#{back}, shiny=#{shiny}")
        check.call(sprite.width >= original.width && sprite.height >= original.height, 'canvas grows to preserve full-scale battle artwork')
        check.call(icon.length > 1, 'GIF contains multiple actual frames')
        first = icon.currentIndex
        signature = proc do |bitmap|
          step_x = [bitmap.width / 24, 1].max
          step_y = [bitmap.height / 24, 1].max
          (0...bitmap.height).step(step_y).map do |y|
            (0...bitmap.width).step(step_x).map do |x|
              c = bitmap.get_pixel(x, y)
              [c.red, c.green, c.blue, c.alpha].map(&:to_i).pack('C4')
            end.join
          end.join
        end
        initial_pixels = signature.call(sprite.bitmap)
        changed = false
        start = System.uptime
        while System.uptime - start < 1.0
          Graphics.update
          sprite.update
          if icon.currentIndex != first && signature.call(sprite.bitmap) != initial_pixels
            changed = true
            break
          end
        end
        check.call(changed, 'native update visibly advances the sprite pixels')
        pokemon.form = 1
        check.call(ArenaDemo::AnimatedBattlers.filename(pokemon, back).nil?, 'unsupported form keeps native art') if pokemon.form != 0
        original.dispose
      end
      $game_temp.in_battle = true
      ArenaDemo::AnimatedBattlers::FORMS.each do |species, forms|
        forms.each do |form|
          pokemon = Pokemon.new(species, 50)
          pokemon.forced_form = form
          check.call(GameData::Species.exists?("#{species}_#{form}".to_sym), "native form exists: #{species} #{form}")
          [false, true].each do |back|
            [false, true].each do |shiny|
              pokemon.shiny = shiny
              path = ArenaDemo::AnimatedBattlers.filename(pokemon, back)
              expected = "#{species}_#{form}.gif"
              check.call(path && File.basename(path) == expected, "exact form asset: #{species} #{form} back=#{back} shiny=#{shiny}")
              check.call(File.file?(path), 'form animation asset exists')
            end
          end
        end
      end
      # Exercise engine-driven Kyurem entry and in-battle shape changes on the
      # same sprite; this also covers retiring/replacing the previous bitmap.
      signatures = proc do |bitmap|
        step_x = [bitmap.width / 24, 1].max
        step_y = [bitmap.height / 24, 1].max
        (0...bitmap.height).step(step_y).map do |y|
          (0...bitmap.width).step(step_x).map do |x|
            c = bitmap.get_pixel(x, y)
            [c.red, c.green, c.blue, c.alpha].map(&:to_i).pack('C4')
          end.join
        end.join
      end
      [[:KYUREM, 1], [:KYUREM, 2], [:GIRATINA, 1], [:CASTFORM, 1],
       [:CASTFORM, 2], [:CASTFORM, 3], [:MELOETTA, 1], [:ROTOM, 5]].each do |species, form|
        pokemon = Pokemon.new(species, 50)
        pokemon.form = form
        if species == :KYUREM
          entered = MultipleForms.call('getFormOnEnteringBattle', pokemon, false)
          check.call(entered == form + 2, 'native Kyurem entry activates glowing form')
          pokemon.form = entered
        end
        [false, true].each do |back|
          sprite = sprites.first
          old = sprite.instance_variable_get(:@_iconBitmap)
          sprite.setPokemonBitmap(pokemon, back)
          icon = sprite.instance_variable_get(:@_iconBitmap)
          check.call(old.disposed?, 'previous sprite canvas disposed on shape change')
          check.call(icon.is_a?(ArenaDemo::AnimatedBattlers::Canvas), "shape change stays animated: #{species} #{pokemon.form} back=#{back}")
          initial = signatures.call(sprite.bitmap)
          start = System.uptime
          changed = false
          while System.uptime - start < 1.0
            Graphics.update
            sprite.update
            if signatures.call(sprite.bitmap) != initial
              changed = true
              break
            end
          end
          check.call(changed, 'alternative form pixels visibly animate')
        end
      end
      [[:CHARIZARD, 1], [:RAICHU, 1], [:ARCEUS, 18], [:DARMANITAN, 3],
       [:BASCULIN, 2], [:LUGIA, 1], [:PICHU, 2]].each do |species, form|
        pokemon = Pokemon.new(species, 50)
        pokemon.forced_form = form
        check.call(ArenaDemo::AnimatedBattlers.filename(pokemon, false).nil?, "unsupported form is never replaced with base species: #{species} #{form}")
      end
      pokemon = Pokemon.new(:FROAKIE, 5)
      sprite = sprites.first
      sprite.setPokemonBitmap(pokemon, false)
      check.call(!sprite.instance_variable_get(:@_iconBitmap).is_a?(ArenaDemo::AnimatedBattlers::Canvas), 'later generations retain correct native sprite')
      pokemon = Pokemon.new(:SPINDA, 5)
      check.call(ArenaDemo::AnimatedBattlers.filename(pokemon, false).nil?, 'Spinda markings preserved by native fallback')
      sprites.each(&:dispose)
      viewport.dispose
      lines << "#{lines.length} native battlers checks passed. Disposable game only."
      File.write(path, lines.join("\n"))
      exit! 0
    rescue Exception => error
      lines << [error.class, error.message, error.backtrace&.first(8)].inspect
      File.write(path, lines.join("\n"))
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeBattlersProbe)
end
