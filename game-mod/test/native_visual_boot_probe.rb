# Runs only in the disposable native process started by test-native-visuals.py.
if defined?(Game) && ENV['ARENA_VISUAL_PROBE']
  module ArenaDemo::NativeVisualProbe
    def check_field_obstacles(check)
      records = ArenaDemo.tile_edit_records
      placements = ArenaDemo.custom_placements
      old_scene, old_debug = $scene, $DEBUG
      old_message = Object.instance_method(:pbMessage)
      old_confirm = Object.instance_method(:pbConfirmMessage)
      old_wait = Object.instance_method(:pbWait)
      $field_effect_frames = 0
      Object.send(:define_method, :pbWait) do |duration, &animation|
        old_wait.bind(self).call(duration) do |elapsed|
          animation.call(elapsed) if animation
          $field_effect_frames += 1 if duration == 0.5 && animation
        end
      end
      Object.send(:define_method, :pbMessage) { |*| -1 }
      $field_probe_confirm = true
      Object.send(:define_method, :pbConfirmMessage) { |*| $field_probe_confirm }
      $DEBUG = false
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup(100)
      $scene = Scene_Map.new
      $scene.createSpritesets
      begin
        [[:ARENA_FURNITURE_TREE, 45], [:ARENA_FURNITURE_ROCK, 47], [:ARENA_FURNITURE_BOULDER, 49]].each do |item, x|
          ArenaDemo.editor_apply_placement(placements, records, 'furniture', { item: item }, x, 42)
        end
        find = proc { |x| $game_map.events.values.find { |e| e.x == x && e.y == 42 && !e.transparent } }
        $player.party = [Pokemon.new(:PIKACHU, 15)]
        $player.party.first.moves.clear
        tree = find.call(45)
        check.call(tree && tree.name.include?('CutTree') && tree.list.length == 2, 'Cut object has a native-named interactive event')
        check.call(!ArenaDemo::FieldObstacles.interact(tree.id), 'Cut refuses a party without the move even in debug launch')
        check.call([:HM01, :HM04, :HM06].all? { |item| $bag.has?(item) }, 'three field HMs supplied once in the Bag')
        [:CUT, :ROCKSMASH, :STRENGTH].each { |move| $player.party.first.learn_move(move) }
        $game_player.moveto(44, 42)
        $game_player.direction = 6
        $field_probe_confirm = false
        before = placements.length
        check.call(!ArenaDemo::FieldObstacles.interact(tree.id) && placements.length == before, 'cancelled Cut preserves furniture')
        $field_probe_confirm = true
        count = $bag.quantity(:ARENA_FURNITURE_TREE)
        check.call(ArenaDemo::FieldObstacles.interact(tree.id), 'Cut plays natively without story badges')
        check.call(placements.length == before && $bag.quantity(:ARENA_FURNITURE_TREE) == count && tree.through && tree.transparent,
          'Cut hides the tree without changing layout or inventory')
        rock = find.call(47)
        $game_player.moveto(46, 42)
        rock_count = $bag.quantity(:ARENA_FURNITURE_ROCK)
        check.call(rock.name.include?('SmashRock') && ArenaDemo::FieldObstacles.interact(rock.id), 'Rock Smash uses its stable slot')
        check.call(rock.transparent && rock.through && placements.length == before && $bag.quantity(:ARENA_FURNITURE_ROCK) == rock_count,
          'Rock Smash hides the rock without changing inventory or layout')
        check.call($stats.cut_count == 1 && $stats.rock_smash_count == 1, 'native Cut and Rock Smash statistics increment once')
        check.call($field_effect_frames > 4, 'Cut slash and Rock Smash fragments render across real native frames')
        boulder = find.call(49)
        $game_player.moveto(48, 42)
        check.call(boulder.name.include?('StrengthBoulder') && boulder.trigger == 0, 'boulder requires Action key interaction')
        check.call($game_player.check_event_trigger_there([0, 2]), 'Action key starts the Strength boulder event')
        boulder.clear_starting
        $game_player.check_event_trigger_touch(6)
        check.call(!boulder.starting, 'walking into the boulder does not start its event')
        boulder.clear_starting
        ArenaDemo.editor_apply_ground(records, placements, 50, 42, floor: 'field', ground: 'lava')
        check.call(!ArenaDemo::FieldObstacles.interact(boulder.id) && boulder.x == 49, 'Strength cannot push onto lava')
        ArenaDemo.editor_apply_ground(records, placements, 50, 42, floor: 'field', ground: 'plain')
        check.call(ArenaDemo::FieldObstacles.interact(boulder.id) && boulder.x == 50, 'native Strength pushes exactly one tile')
        check.call($stats.strength_push_count == 1, 'native Strength push counter increments once')
        $game_player.moveto(49, 42)
        ArenaDemo.editor_apply_relief(records, placements, 51, 42, 1)
        check.call(!ArenaDemo::FieldObstacles.interact(boulder.id) && boulder.x == 50, 'Strength cannot push across a raised edge')
        ArenaDemo.editor_apply_relief(records, placements, 51, 42, 0)
        ArenaDemo.refresh_custom_placements
        record = placements.find { |p| p['item'] == 'ARENA_FURNITURE_BOULDER' }
        check.call(record && record['x'] == 49 && find.call(50), 'push survives refresh but does not edit the canonical placement')
        saved = Marshal.load(Marshal.dump($PokemonGlobal))
        check.call(saved.arena_demo_placements.any? { |p| p['item'] == 'ARENA_FURNITURE_BOULDER' && p['x'] == 49 }, 'native save metadata retains original boulder position')
        check.call(!ArenaDemo::FieldObstacles.using?, 'temporary native badge access is restored')
        online_method = ArenaDemo.method(:multiplayer?)
        ArenaDemo.define_singleton_method(:multiplayer?) { true }
        begin
          check.call(!ArenaDemo::FieldObstacles.interact(boulder.id) && boulder.x == 50, 'online layout cannot be changed by field moves')
        ensure
          ArenaDemo.define_singleton_method(:multiplayer?, online_method)
        end
        # A cancelled editor still resets field actions before making its draft.
        cancel_input = Module.new do
          def trigger?(button)
            return button == Input::BACK if @native_editor_cancel
            super
          end
        end
        Input.singleton_class.prepend(cancel_input)
        Input.instance_variable_set(:@native_editor_cancel, true)
        Object.send(:define_method, :pbMessage) { |*args| args[1].is_a?(Array) ? 1 : -1 }
        begin
          ArenaDemo.custom_mode
        ensure
          Input.instance_variable_set(:@native_editor_cancel, false)
          Object.send(:define_method, :pbMessage) { |*| -1 }
        end
        check.call(find.call(45) && find.call(47) && find.call(49) && !find.call(50), 'entering custom mode restores all temporary changes')
        tree = find.call(45)
        $game_player.moveto(44, 42)
        $game_player.direction = 6
        check.call(ArenaDemo::FieldObstacles.interact(tree.id), 'cut again before a real room transfer')
        $game_temp.player_new_map_id = ArenaDemo::ENTRANCE_MAP_ID
        $game_temp.player_new_x, $game_temp.player_new_y, $game_temp.player_new_direction = 7, 3, 2
        $scene.transfer_player
        $game_temp.player_new_map_id = ArenaDemo::MAP_ID
        $game_temp.player_new_x, $game_temp.player_new_y, $game_temp.player_new_direction = *ArenaDemo.map_start
        $scene.transfer_player
        check.call(find.call(45) && find.call(47) && find.call(49), 'leaving and returning to the main room restores all objects')
        check_network_fields(check)
      ensure
        $scene.dispose if $scene.is_a?(Scene_Map)
        $scene, $DEBUG = old_scene, old_debug
        $PokemonMap.strengthUsed = false
        Object.send(:define_method, :pbMessage, old_message)
        Object.send(:define_method, :pbConfirmMessage, old_confirm)
        Object.send(:define_method, :pbWait, old_wait)
      end
    end

    def check_network_fields(check)
      visits = ArenaDemo::Visits
      field = ArenaDemo::FieldObstacles
      saved = visits.instance_variables.to_h { |key| [key, visits.instance_variable_get(key)] }
      send_request = visits.method(:send_request)
      payload = ArenaDemo.visit_snapshot_payload
      token = 'a' * 24
      begin
        visits.instance_variable_set(:@ready, true)
        visits.instance_variable_set(:@phase, :hosting)
        visits.instance_variable_set(:@room, token)
        visits.instance_variable_set(:@snapshot, { placements: ArenaDemo.custom_placements.map(&:dup), tile_edits: ArenaDemo.tile_edit_records })
        field.clear
        message = { type: :arena_field_state, room: token, field_revision: 1, field_states: {0 => nil, 1 => nil, 2 => [50, 42]} }
        field.receive(message)
        field.update
        events = $game_map.events
        base = ArenaDemo::FURNITURE_SLOT_BASE
        check.call(events[base].transparent && events[base + 1].transparent && events[base + 2].x == 50, 'authoritative network overlay updates both hidden objects and pushed boulder')
        visits.define_singleton_method(:send_request) { |type, data| $native_field_request = data.merge(type: type); true }
        $game_player.moveto(49, 42)
        $game_player.direction = 6
        $PokemonMap.strengthUsed = true
        check.call(field.interact(base + 2), 'online Strength submits a request')
        check.call($native_field_request.values_at(:type, :slot, :move, :field_revision) == [:arena_field_request, 2, :STRENGTH, 1], 'request identifies canonical slot and server revision')
        check.call(events[base + 2].x == 50, 'online Strength waits for server approval before moving')
        # Coalescing a later peer action must also release an older pending request.
        field.receive(message.merge(field_revision: 2, field_states: {0 => nil, 1 => nil, 2 => [51, 42]}, actor: 999))
        field.update
        check.call(events[base + 2].x == 51 && field.instance_variable_get(:@pending).nil?, 'newer room state releases pending action and applies movement')
        field.clear
        field.receive(message.merge(field_revision: 2, field_states: {0 => nil, 1 => nil, 2 => [51, 42]}))
        field.update
        check.call(events[base].transparent && events[base + 2].x == 51, 'fresh client cache receives existing shared room effects')
        field.receive(message.merge(field_revision: 1, field_states: {}))
        field.receive(message.merge(room: 'b' * 24, field_revision: 8, field_states: {}))
        field.update
        check.call(events[base].transparent && events[base + 2].x == 51, 'stale and foreign-room messages do not reset effects')
        field.receive(message.merge(field_revision: 3, field_states: {}))
        field.update
        check.call(!events[base].transparent && !events[base + 1].transparent && events[base + 2].x == 49, 'empty-room server reset restores canonical objects')
        frames = $field_effect_frames
        field.receive(message.merge(field_revision: 4, field_states: {0 => nil, 1 => nil}, actor: 999))
        field.update
        check.call($field_effect_frames > frames && events[base].transparent && events[base + 1].transparent,
          'live peer Cut and Rock Smash animate before applying the authoritative hidden state')
        frames = $field_effect_frames
        field.receive(message.merge(field_revision: 4, field_states: {0 => nil, 1 => nil}, actor: 999))
        field.update
        check.call($field_effect_frames == frames, 'duplicate network state does not replay object effects')
        check.call(ArenaDemo.visit_snapshot_payload[:placements] == payload[:placements], 'network effects never alter canonical snapshot')
      ensure
        visits.define_singleton_method(:send_request, send_request)
        (visits.instance_variables - saved.keys).each { |key| visits.remove_instance_variable(key) }
        saved.each { |key, value| visits.instance_variable_set(key, value) }
        field.reset(true)
      end
    end

    def set_up_system
      path = ENV.fetch('ARENA_VISUAL_PROBE')
      lines = []
      begin
        check = proc do |condition, label|
          raise "FAIL: #{label}" unless condition
          lines << "PASS: #{label}"
        end
        SaveData.initialize_bootup_values
        SaveData.load_new_game_values
        $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
        $map_factory = PokemonMapFactory.new(100)
        $game_player.moveto(39, 40)
        ArenaDemo.ensure_custom_inventory
        records = ArenaDemo.tile_edit_records
        placements = ArenaDemo.custom_placements
        check_field_obstacles(check)
        [100, 101, 102].each do |id|
          map = id == 100 ? $game_map : Game_Map.new
          map.setup(id) unless id == 100
          npcs = map.events.values.select { |e| e.character_name.start_with?('trainer_') }
          check.call(!npcs.empty?, "map #{id} contains NPCs")
          npcs.each do |npc|
            check.call(npc.pattern == 0 && npc.instance_variable_get(:@original_pattern) == 0,
                       "#{id}/#{npc.id}: standing and resting pose are frame zero")
            check.call(!npc.instance_variable_get(:@step_anime) && npc.walk_anime, "#{id}/#{npc.id}: stationary NPC does not step on the spot")
            npc.direction = 4
            npc.straighten
            npc.refresh
            check.call(npc.pattern == 0 && npc.direction == 4, "#{id}/#{npc.id}: turning and refresh keep idle pose")
          end
        end
        $bag.add(:ARENA_TRAINER_ROOKIE, 1)
        ArenaDemo.editor_apply_placement(placements, records, 'trainer', { item: :ARENA_TRAINER_ROOKIE }, 44, 40)
        ArenaDemo.refresh_custom_placements
        trainer = $game_map.events[ArenaDemo::TRAINER_SLOT_BASE]
        check.call(trainer.pattern == 0 && !trainer.instance_variable_get(:@step_anime) && trainer.walk_anime, 'placed trainer starts idle')
        trainer.pattern = 2
        trainer.instance_variable_set(:@moved_last_frame, true)
        trainer.instance_variable_set(:@moved_this_frame, false)
        trainer.update_pattern
        check.call(trainer.pattern == 0, 'placed trainer returns to idle after a scripted step')
        ArenaDemo.refresh_custom_placements
        check.call(trainer.pattern == 0 && trainer.instance_variable_get(:@original_pattern) == 0, 'placed trainer stays idle after editor rebuild')
        $player.party = [Pokemon.new(:SQUIRTLE, 10)]
        FollowingPkmn.start_following(900, false) unless FollowingPkmn.get
        FollowingPkmn.toggle(true, false)
        check.call(FollowingPkmn.active?, 'follower starts visible on land')
        check.call(FollowingPkmn.singleton_class.ancestors.include?(ArenaDemo::SurfFollowerSprite), 'sprite writer guard installed after EX loads')
        ArenaDemo.editor_apply_ground(records, placements, 40, 40, floor: 'field', ground: 'water')
        $PokemonGlobal.surfing = true
        FollowingPkmn.refresh(false)
        follower = FollowingPkmn.get_event
        [2, 4, 6, 8].each do |direction|
          $game_player.moveto(39, 40)
          $game_player.direction = direction
          follower.moveto(40, 40)
          follower.instance_variable_set(:@move_route_forcing, false)
          follower.instance_variable_set(:@last_leader_x, nil)
          follower.follow_leader($game_player, true)
          check.call(!follower.terrain_tag.can_surf, "corner #{direction}: follower crossed water to land")
          check.call(follower.character_name.empty? && FollowingPkmn.get_data.character_name.empty?, "corner #{direction}: live and saved sprites stay hidden")
          FollowingPkmn.change_sprite($player.party.first)
          FollowingPkmn.refresh(false)
          check.call(follower.character_name.empty?, "corner #{direction}: direct sprite and queued refresh stay hidden")
        end
        $PokemonGlobal.surfing = false
        FollowingPkmn.refresh(false)
        check.call(FollowingPkmn.active? && !follower.character_name.empty?, 'follower returns on dismount')
        FollowingPkmn.toggle(false, false)
        check.call(!FollowingPkmn.active?, 'manual follower preference is preserved')
        scene = Battle::Scene.new
        animations = pbLoadBattleAnimations
        mapping = pbLoadMoveToAnim
        [:MUDSLAP, :FUSIONBOLT].each do |move|
          expected = move == :MUDSLAP ? :SANDATTACK : :THUNDERBOLT
          2.times do |side|
            [0, 1].each do |phase|
              result = scene.pbFindMoveAnimation(move, side, phase)
              wanted = scene.pbFindMoveAnimDetails(mapping, move, side, phase) || scene.pbFindMoveAnimDetails(mapping, expected, side)
              check.call(result == wanted, "#{move}/#{side}/#{phase}: dedicated animation takes precedence")
            end
          end
        end
        move_count = 0
        fallbacks = []
        GameData::Move.each do |move|
          move_count += 1
          fallbacks << move.id unless mapping[0].key?(move.id)
          2.times do |side|
            result = scene.pbFindMoveAnimation(move.id, side, 0)
            animation = animations[result[0]] if result
            check.call(animation && animation.length > 1 && (animation.graphic.to_s.empty? || pbResolveBitmap("Graphics/Animations/#{animation.graphic}")),
                       "#{move.id}/#{side}: playable animation and bitmap")
            native = scene.pbFindMoveAnimDetails(mapping, move.id, side)
            check.call(native == result, "#{move.id}/#{side}: authored animation preserved") if native
          end
        end
        check.call(move_count - fallbacks.length >= 700, 'complete animation pack supplies at least 700 dedicated move animations')
        lines << "Dedicated coverage: #{move_count - fallbacks.length}/#{move_count}; fallback moves: #{fallbacks.inspect}"
        File.write(path, lines.join("\n") + "\nPreparing battle playback\n")
        battle = Battle.new(scene, [Pokemon.new(:PIKACHU, 15)], [Pokemon.new(:SQUIRTLE, 15)], $player, nil)
        battle.backdrop = 'field'
        2.times do |i|
          battler = Battle::Battler.new(battle, i)
          battle.battlers[i] = battler
          battler.pbInitialize(battle.pbParty(i).first, 0)
        end
        scene.pbStartBattle(battle)
        2.times do |i|
          scene.pbChangePokemon(i, battle.battlers[i].pokemon)
          scene.sprites["pokemon_#{i}"].visible = true
          scene.sprites["pokemon_#{i}"].tone = Tone.new(0, 0, 0)
        end
        [:MUDSLAP, :FUSIONBOLT].each do |move|
          2.times do |side|
            scene.pbAnimation(move, battle.battlers[side], [battle.battlers[1 - side]], 0)
            check.call(scene.sprites.values.none? { |s| s.disposed? }, "#{move}/#{side}: native playback completes")
          end
        end
        [:MEMENTO, :SWORDSDANCE, :EARTHQUAKE, :SURF, :FLAMETHROWER].each do |move|
          targets = move == :SWORDSDANCE ? [battle.battlers[0]] : [battle.battlers[1]]
          scene.pbAnimation(move, battle.battlers[0], targets, 0)
          check.call(scene.sprites.values.none? { |s| s.disposed? }, "#{move}: full-pack native playback completes")
        end
        scene.pbAnimation(:FUSIONBOLT, battle.battlers[0], [battle.battlers[1]], 1)
        check.call(scene.sprites.values.none? { |s| s.disposed? }, 'boosted Fusion Bolt phase plays natively')
        scene.pbDisposeSprites
        scene.viewport.dispose
        original_party = $player.party.dup
        check.call(ArenaDemo::DebugParty.apply(false), 'debug party migration applies in native engine')
        check.call($player.party.length == 1 && $player.party.first.species == :MEW && $player.party.first.level == 100,
          'debug party contains exactly one level 100 Mew')
        check.call($player.party.first.moves.map(&:id) == [:CUT, :SURF, :ROCKSMASH, :STRENGTH], 'debug Mew has exactly the four requested field moves')
        check.call($PokemonGlobal.arena_debug_party_backup == original_party && !ArenaDemo::DebugParty.apply(false), 'previous native party is backed up and migration is one-time')
        lines << "#{lines.length} native visual checks passed; #{move_count} moves audited. No save read or written."
        File.write(path, lines.join("\n"))
        exit! 0
      rescue Exception => error
        lines << [error.class, error.message, error.backtrace&.first(10)].inspect
        File.write(path, lines.join("\n"))
        exit! 1
      end
    end
  end
  Game.singleton_class.prepend(ArenaDemo::NativeVisualProbe)
end
