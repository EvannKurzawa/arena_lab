# Disposable native-engine test; the runner removes this plugin after boot.
if defined?(Game) && ENV['ARENA_RELIEF_PROBE']
module ArenaDemo::NativeReliefProbe
  def set_up_system
    path = ENV.fetch('ARENA_RELIEF_PROBE')
    lines = []
    fixture = 'Data/arena-relief-probe-save.rxdata'
    begin
      check = proc do |condition, label|
        raise "FAIL: #{label}" unless condition
        lines << "PASS: #{label}"
      end
      # Fresh disposable world; never read or write the player's save.
      SaveData.initialize_bootup_values
      SaveData.load_new_game_values
      $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
      $map_factory = PokemonMapFactory.new(100)
      $game_player.moveto(49, 53)
      ArenaDemo.ensure_custom_inventory
      records = ArenaDemo.tile_edit_records
      placements = ArenaDemo.custom_placements
      Object.send(:define_method, :pbMessage) { |*| -1 }
      edit = proc { |x, y, code| ArenaDemo.editor_apply_relief(records, placements, x, y, code) }
      (43..47).each do |y|
        (43..47).each { |x| check.call(edit.call(x, y, 1), "platform #{x},#{y}") }
      end
      [[45, 42, 2], [48, 45, 4], [45, 48, 8], [46, 48, 8], [42, 45, 6]].each do |x, y, d|
        check.call(edit.call(x, y, d), "stair #{d}")
        dx, dy = ArenaRelief::DIRECTIONS.fetch(d)
        check.call($game_player.passable?(x - dx, y - dy, d), "native ascent #{d}")
        check.call($game_player.passable?(x + dx, y + dy, 10 - d), "native descent #{d}")
      end
      check.call(!$game_player.passable?(43, 44, 4), 'native platform edge blocks')
      $game_player.moveto(44, 47)
      $game_player.move_down
      check.call([$game_player.x, $game_player.y] == [44, 47], 'actual movement stops on summit before south face')
      check.call(!$game_player.passable?(44, 49, 8) && !$game_player.passable?(43, 48, 6),
        'south face blocks ground approach and side approach')
      check.call(!$game_map.passableStrict?(44, 48, 0), 'wall is not a standing position')
      $game_player.moveto(44, 48)
      ArenaDemo.recover_player_from_void($game_map)
      check.call(!ArenaDemo.relief_wall?(records, $game_player.x, $game_player.y),
        'player saved on newly reserved face recovers to a standing position')
      $game_player.moveto(49, 53)
      check.call($game_player.passable?(45, 48, 6), 'wide stair seam passable')
      check.call(!edit.call(45, 47, 0), 'stair support removal refused')
      $bag.add(:ARENA_TRAINER_ROOKIE, 1)
      [['furniture', :ARENA_FURNITURE_ROCK, 44, 44], ['trainer', :ARENA_TRAINER_ROOKIE, 46, 44]].each do |kind, item, x, y|
        ArenaDemo.editor_apply_placement(placements, records, kind, { item: item }, x, y)
        check.call(placements.any? { |p| p['kind'] == kind && p['x'] == x && p['y'] == y }, "native #{kind} on platform")
      end
      original = Marshal.dump(records)
      draft = ArenaDemo.copy_tile_edits(records)
      check.call(ArenaDemo.editor_apply_platform_style(draft, 44, 43, 'grass'), 'native whole-platform grass tool')
      check.call(Marshal.dump(records) == original, 'style draft leaves saved records unchanged before validation')
      ArenaDemo.apply_tile_edits($game_map, records)
      check.call(ArenaDemo.editor_apply_platform_style(records, 44, 43, 'snow'), 'native whole-platform snow tool')
      check.call(records.values.all? { |r| r['ground'] == 'snow' && r['platform_style'] == 'snow' },
        'whole platform includes every summit and stair')
      check.call(ArenaDemo.editor_apply_ground(records, placements, 44, 44, floor: 'field', ground: 'grass'),
        'native individual summit floor painting with furniture retained')
      check.call(records['44,44']['platform_style'] == 'snow' && records['44,44']['ground'] == 'grass',
        'individual grass paint retains snow wall material')
      check.call(ArenaDemo.editor_apply_ground(records, placements, 43, 50, floor: 'field', ground: 'lava'),
        'native editor paints visible lava')
      $game_player.moveto(43, 49)
      $game_player.move_down
      check.call([$game_player.x, $game_player.y] == [43, 49], 'actual movement cannot enter lava')
      check.call(!$game_map.passableStrict?(43, 50, 0), 'native lava is not a standing position')
      check.call(ArenaDemo.editor_apply_ground(records, placements, 44, 50, floor: 'field', ground: 'volcanic') &&
                 $game_player.passable?(44, 49, 2), 'native volcanic ground remains walkable')
      volcano_draft = ArenaDemo.copy_tile_edits(records)
      check.call(ArenaDemo.editor_apply_platform_style(volcano_draft, 44, 43, 'volcano') &&
                 volcano_draft['44,43']['ground'] == 'volcanic' && volcano_draft['44,43']['platform_style'] == 'volcano',
        'native whole-platform volcanic tool')
      ArenaDemo.apply_tile_edits($game_map, records)
      $game_player.moveto(49, 53)
      check.call(ArenaMaterials::FLOORS.length == 43 && ArenaDemo::PLATFORM_STYLES.length == 12,
        'complete catalogue: 43 floors and 12 platform styles')
      ArenaMaterials::FLOORS.each_key do |ground|
        art = ArenaDemo.platform_floor_bitmap(ground)
        check.call(art.get_pixel(16, 16).alpha > 0, "native floor artwork: #{ground}")
        check.call(ArenaDemo.editor_apply_ground(records, placements, 40, 40, floor: 'field', ground: ground),
          "native floor tool: #{ground}")
        check.call($game_player.passable?(39, 40, 6) == !ArenaMaterials::BLOCKED_GROUNDS.include?(ground),
          "native floor collision: #{ground}")
      end
      check.call(ArenaDemo.editor_apply_ground(records, placements, 40, 40, floor: 'field', ground: 'water'),
        'native editor paints water with a dedicated saved identity')
      toxic_base = ArenaDemo.platform_floor_bitmap('toxic').get_pixel(16, 16)
      check.call(toxic_base.red > 190 && toxic_base.green > 210 && toxic_base.blue < 50,
        'toxic liquid itself is fluorescent yellow, not only its bubble highlights')
      $PokemonGlobal.surfing = true
      check.call($game_player.passable?(39, 40, 6), 'native Surf traverses water')
      $PokemonGlobal.surfing = false
      %w[toxic marsh_water].each do |ground|
        ArenaDemo.editor_apply_ground(records, placements, 40, 40, floor: 'field', ground: ground)
        check.call(!$game_player.passable?(39, 40, 6), "#{ground}: cannot walk in liquid")
        $PokemonGlobal.surfing = true
        check.call($game_player.passable?(39, 40, 6) == (ground == 'marsh_water'), "#{ground}: Surf respects liquid identity")
        $PokemonGlobal.surfing = false
      end
      # Exercise actual Surf entry/exit, the party-menu gate and shore prompt.
      ArenaDemo.editor_apply_ground(records, placements, 40, 40, floor: 'field', ground: 'marsh_water')
      $game_player.moveto(39, 40)
      $game_player.direction = 6
      check.call($game_player.pbFacingTerrainTag.can_surf_freely, 'marsh exposes the native freely surfable terrain tag')
      debug_before_surf = $DEBUG
      $DEBUG = false
      check.call(HiddenMoveHandlers.triggerCanUseMove(:SURF, nil, false), 'native party-menu Surf access accepts marsh bank')
      check.call(!$PokemonGlobal.surfing && !ArenaDemo.surf_probe?, 'Surf access probe restores state and never starts surfing')
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup(100)
      # EX's recall animation needs a real map spriteset and miniupdate loop.
      surf_previous_scene = $scene
      surf_scene = Scene_Map.new
      $scene = surf_scene
      surf_scene.createSpritesets
      if defined?(FollowingPkmn)
        $player.party = [Pokemon.new(:SQUIRTLE, 10)]
        FollowingPkmn.start_following(900, false) unless FollowingPkmn.get
        FollowingPkmn.toggle(true, false)
        check.call(FollowingPkmn.active?, 'water-type follower visible on bank')
      end
      original_confirm = Object.instance_method(:pbConfirmMessage)
      $native_surf_requests = 0
      Object.send(:define_method, :pbConfirmMessage) { |*| $native_surf_requests += 1; true }
      ArenaDemo.try_arena_surf
      Object.send(:define_method, :pbConfirmMessage, original_confirm)
      check.call($native_surf_requests == 1, 'shore Surf actually starts without debug, badges or a Surf Pokemon')
      check.call($PokemonGlobal.surfing && [$game_player.x, $game_player.y] == [40, 40], 'native Surf jump enters marsh water')
      if defined?(FollowingPkmn)
        check.call(!FollowingPkmn.active? && FollowingPkmn.get_event.character_name.empty?, 'Surf hides even a water-type sole party follower')
        check.call(ArenaDemo::FollowingIntegration.descriptor[:follower_species].empty?, 'Surf hides transmitted follower descriptor')
        check.call($PokemonGlobal.follower_toggled, 'Surf preserves follower preference')
      end
      $game_player.moveto(40, 40)
      $game_player.direction = 4
      check.call(pbEndSurf(-1, 0) && [$game_player.x, $game_player.y] == [39, 40], 'native dismount returns from marsh water to bank')
      pbCancelVehicles
      $game_temp.ending_surf = false
      $game_temp.surf_base_coords = nil
      if defined?(FollowingPkmn)
        FollowingPkmn.refresh(false)
        check.call(FollowingPkmn.active? && !FollowingPkmn.get_event.character_name.empty?, 'follower returns on bank after Surf')
        FollowingPkmn.toggle(false, false)
        $PokemonGlobal.surfing = true
        FollowingPkmn.refresh(false)
        $PokemonGlobal.surfing = false
        FollowingPkmn.refresh(false)
        check.call(!FollowingPkmn.active? && !$PokemonGlobal.follower_toggled, 'manual follower disable survives Surf')
        # Keep the fixture follower off for subsequent scene-less floor probes.
      end
      $DEBUG = debug_before_surf
      surf_scene.dispose
      $scene = surf_previous_scene
      $game_player.moveto(49, 53)
      ArenaDemo.editor_apply_ground(records, placements, 40, 40, floor: 'field', ground: 'water')
      ArenaDemo::PLATFORM_STYLES.each_key do |style|
        check.call(ArenaDemo.editor_apply_platform_style(records, 44, 43, style) &&
          records['44,43']['platform_style'] == style, "native complete platform tool: #{style}")
      end
      ArenaDemo.editor_apply_platform_style(records, 44, 43, 'snow')
      ArenaDemo.editor_apply_ground(records, placements, 44, 44, floor: 'field', ground: 'grass')
      new_grounds = %w[toxic marsh_water steel_blue holo_hex quicksand]
      new_grounds.each_with_index do |ground, i|
        check.call(ArenaDemo.editor_apply_ground(records, placements, 37 + i, 38, floor: 'field', ground: ground), "native persistent fixture: #{ground}")
      end
      payload = ArenaDemo.visit_snapshot_payload
      decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
      check.call(decoded && ArenaDemo.relief_grid(decoded[:tile_edits]) == payload[:relief], 'native visit round trip')
      check.call(decoded[:tile_edits]['44,43']['platform_style'] == 'snow', 'native visit preserves wall style')
      check.call(Game.save(fixture), 'native save to disposable path')
      saved = SaveData.read_from_file(fixture)
      check.call(saved[:global_metadata].arena_demo_tile_edits == records, 'native disk relief persistence')
      Game.load(saved)
      records = ArenaDemo.tile_edit_records
      placements = ArenaDemo.custom_placements
      new_grounds.each_with_index do |ground, i|
        check.call(records["#{37 + i},38"]['ground'] == ground, "native disk save/load preserves #{ground}")
      end
      check.call(ArenaDemo.visit_snapshot_payload == payload, 'native load and map reconstruction')
      check.call(!$game_player.passable?(43, 44, 4), 'native collision after reload')
      $game_map.display_x = 40 * 32 * Game_Map::X_SUBPIXELS
      $game_map.display_y = 40 * 32 * Game_Map::Y_SUBPIXELS
      renderer = TilemapRenderer.new(nil)
      renderer.add_tileset($game_map.tileset_name)
      $game_map.autotile_names.each { |name| renderer.add_autotile(name) unless name.empty? }
      renderer.add_extra_autotiles($game_map.tileset_id)
      renderer.update
      tile = renderer.instance_variable_get(:@tiles)[3][4][1]
      expected = ArenaDemo.relief_bitmap(ArenaDemo.tile_edit_records, 43, 44)
      check.call(tile.bitmap.equal?(expected), 'real tilemap renderer uses relief artwork')
      ground_tile = renderer.instance_variable_get(:@tiles)[3][4][0]
      check.call(ground_tile.visible && !ground_tile.bitmap.equal?(expected) && tile.z > ground_tile.z,
        'native ground remains underneath transparent cliff overlay')
      ground_corner = ground_tile.bitmap.get_pixel(ground_tile.src_rect.x, ground_tile.src_rect.y)
      check.call(ground_corner.alpha > 0, 'native ground provides opaque pixels behind corner alpha')
      $game_player.moveto(44, 47)
      $game_player.character_name = 'trainer_POKEMONTRAINER_Red'
      $game_map.display_x = 40 * 32 * Game_Map::X_SUBPIXELS
      $game_map.display_y = 40 * 32 * Game_Map::Y_SUBPIXELS
      renderer.update
      character_sprite = Sprite_Character.new(nil, $game_player)
      check.call(character_sprite.y <= (48 - 40) * 32, 'actual player sprite feet stop before wall tile')
      Graphics.update
      screenshot = Graphics.snap_to_bitmap
      water_pixel = screenshot.get_pixel(16, 16)
      expected_water = ArenaDemo.platform_floor_bitmap('water').get_pixel(16, 16)
      check.call([water_pixel.red, water_pixel.green, water_pixel.blue] ==
                 [expected_water.red, expected_water.green, expected_water.blue], 'actual frame displays the reserved water surface')
      expected_lava = ArenaDemo.platform_floor_bitmap('lava').get_pixel(16, 16)
      rendered_lava = screenshot.get_pixel(112, 336)
      check.call([rendered_lava.red, rendered_lava.green, rendered_lava.blue] ==
                 [expected_lava.red, expected_lava.green, expected_lava.blue], 'actual frame renders lava instead of an invisible blocker')
      base_corner = renderer.instance_variable_get(:@tiles)[3][8][0]
      underlying = base_corner.bitmap.get_pixel(base_corner.src_rect.x, base_corner.src_rect.y)
      rendered_corner = screenshot.get_pixel(96, 256)
      check.call([rendered_corner.red, rendered_corner.green, rendered_corner.blue] ==
                 [underlying.red, underlying.green, underlying.blue], 'actual wall top corner reveals lower field')
      painted = ArenaDemo.relief_bitmap(records, 44, 44)
      expected_pixel = painted.get_pixel(16, 16)
      actual_pixel = screenshot.get_pixel(144, 144)
      check.call([actual_pixel.red, actual_pixel.green, actual_pixel.blue] ==
                 [expected_pixel.red, expected_pixel.green, expected_pixel.blue],
        'actual frame displays individual grass painting over snow platform')
      character_sprite.dispose
      renderer.arena_demo_set_zoom(0.5)
      renderer.update
      check.call(tile.zoom_x == TilemapRenderer::ZOOM_X * 0.5, 'real relief tile follows editor zoom')
      old = tile.bitmap
      check.call(edit.call(43, 44, 0), 'native removal after reload')
      renderer.refresh
      renderer.update
      check.call(!tile.bitmap.equal?(old), 'real renderer updates wall/summit after removal')
      renderer.dispose
      ArenaDemo.instance_variable_set(:@editor_zoom_scale, 1.0)
      # Run the real timed trap animation and engine step callback. Capture the
      # actual character sprite at three stages without touching a private save.
      ArenaDemo.editor_apply_ground(records, placements, 40, 42, floor: 'field', ground: 'quicksand')
      $game_player.moveto(40, 42)
      $game_map.display_x = 31 * 32 * Game_Map::X_SUBPIXELS
      $game_map.display_y = 36 * 32 * Game_Map::Y_SUBPIXELS
      sink_renderer = TilemapRenderer.new(nil)
      sink_renderer.add_tileset($game_map.tileset_name)
      $game_map.autotile_names.each { |name| sink_renderer.add_autotile(name) unless name.empty? }
      sink_renderer.add_extra_autotiles($game_map.tileset_id)
      sink_renderer.arena_demo_set_zoom(1.0)
      sink_renderer.update
      sink_tile = sink_renderer.instance_variable_get(:@tiles)[9][6][0]
      check.call(sink_tile.bitmap.equal?(ArenaDemo.platform_floor_bitmap('quicksand')), 'native renderer shows quicksand underneath the sinking player')
      $native_sink_sprite = Sprite_Character.new(nil, $game_player)
      $native_sink_shots, $native_sink_directions = [], []
      ArenaDemo.singleton_class.prepend(Module.new do
        def quicksand_tick(player, progress)
          super
          $native_sink_directions << player.direction
          $native_sink_sprite.update
          if $native_sink_shots.length < 3 && progress >= [0.1, 0.5, 0.85][$native_sink_shots.length]
            Graphics.update
            $native_sink_shots << [Graphics.snap_to_bitmap, ENV.fetch('ARENA_RELIEF_PROBE').sub(/\.log$/, "-sink-#{$native_sink_shots.length}.png")]
          end
        end
      end)
      $PokemonGlobal.ice_sliding = true
      $game_player.walk_anime = false
      sink_scene = $scene
      $scene = nil  # Boot probe has no initialized Scene_Map spritesets yet.
      EventHandlers.trigger(:on_step_taken, $game_player)
      $scene = sink_scene
      check.call([$game_player.x, $game_player.y] == ArenaDemo.map_start.first(2), 'native quicksand step returns to arena entrance')
      check.call($native_sink_directions.uniq.sort == [2, 4, 6, 8], 'native timed quicksand animation turns through all four directions')
      check.call($native_sink_shots.length == 3 && $game_player.opacity == 255 && $game_player.instance_variable_get(:@y_offset) == 0,
        'native sink animation fades/lowers player and restores sprite')
      check.call(!$PokemonGlobal.ice_sliding && $game_player.walk_anime && !$game_temp.in_menu,
        'quicksand reached from ice restores movement and input')
      $native_sink_sprite.dispose
      sink_renderer.dispose
      ice = ArenaDemo.ice_surface_bitmap
      check.call(ice.get_pixel(8, 18).red == 142 && ice.get_pixel(20, 14).red == 142,
        'ice no longer has the central branching crack')
      sand = ArenaDemo.platform_floor_bitmap('desert')
      trap = ArenaDemo.platform_floor_bitmap('quicksand')
      check.call(32.times.all? { |y| 32.times.all? { |x|
        a, b = sand.get_pixel(x, y), trap.get_pixel(x, y)
        (b.red - a.red * 0.96).abs <= 1 && (b.green - a.green * 0.96).abs <= 1 &&
          (b.blue - a.blue * 0.96).abs <= 1 && b.alpha == a.alpha
      } }, 'quicksand is the exact sand texture darkened by only four percent')
      ArenaDemo::LIQUID_GROUNDS.each do |ground|
        frames = (0..3).map do |frame|
          ArenaDemo.instance_variable_set(:@liquid_art_frame, frame)
          image = Bitmap.new(32, 32)
          ArenaDemo.draw_platform_floor(image, ground)
          pixels = 32.times.flat_map { |y| 32.times.map { |x|
            c = image.get_pixel(x, y); [c.red, c.green, c.blue, c.alpha]
          } }
          image.dispose
          pixels
        end
        check.call(frames.uniq.length > 1, "#{ground} has distinct native liquid animation frames")
      end
      ArenaDemo.instance_variable_set(:@liquid_art_frame, 0)
      ArenaDemo.update_liquid_animation
      water_bitmap = ArenaDemo.platform_floor_bitmap('water')
      water_samples = []
      5.times do
        started = System.uptime
        while System.uptime - started < 0.22
          Graphics.update
          ArenaDemo.update_liquid_animation
        end
        water_samples << 32.times.flat_map { |y| 32.times.map { |x|
          c = water_bitmap.get_pixel(x, y); [c.red, c.green, c.blue]
        } }
      end
      check.call(water_samples.uniq.length > 1 && water_bitmap.equal?(ArenaDemo.platform_floor_bitmap('water')),
        'liquid clock animates shared render bitmap while player stands still')
      check.call(32.times.all? { |i| [ice.get_pixel(0, i), ice.get_pixel(31, i), ice.get_pixel(i, 0), ice.get_pixel(i, 31)].all? { |c| c.red == 142 && c.green == 210 && c.blue == 234 } },
        'ice has identical continuous fill on all four tile edges, without border')
      opaque_black = 0
      256.times do |mask|
        sample = { '50,45' => { 'floor' => 'field', 'height' => 1 } }
        ArenaDemo::ExpeditionTerrain::OFFSETS.each_with_index do |(dx, dy), i|
          sample["#{50 + dx},#{45 + dy}"] = { 'floor' => 'field', 'height' => 1 } if mask & (1 << i) != 0
        end
        bitmap = ArenaDemo.relief_bitmap(sample, 50, 45)
        32.times do |y|
          32.times do |x|
            c = bitmap.get_pixel(x, y)
            opaque_black += 1 if c.alpha > 0 && c.red == 0 && c.green == 0 && c.blue == 0
          end
        end
      end
      check.call(opaque_black == 0, 'all 256 neighbor masks contain no opaque black background')
      isolated = Bitmap.new(32, 32)
      ArenaDemo.draw_relief_cliff(isolated, 0)
      check.call(isolated.get_pixel(0, 0).alpha == 0 && isolated.get_pixel(31, 0).alpha == 0 &&
                 isolated.get_pixel(16, 31).alpha > 0 && isolated.get_pixel(16, 16).alpha > 0,
        'small rounded outer corners preserve summit center and foot position')
      [128, 2, 32, 8].each do |diagonal|
        full = Bitmap.new(32, 32)
        inner = Bitmap.new(32, 32)
        ArenaDemo.draw_relief_cliff(full, 255)
        ArenaDemo.draw_relief_cliff(inner, 255 ^ diagonal)
        x, y = { 128 => [0, 0], 2 => [31, 0], 32 => [0, 31], 8 => [31, 31] }.fetch(diagonal)
        check.call(full.get_pixel(x, y).alpha > 0 && inner.get_pixel(x, y).alpha > 0,
          "missing diagonal #{diagonal} keeps full summit without cut-outs")
        full.dispose
        inner.dispose
      end
      isolated.dispose
      wall = Bitmap.new(32, 32)
      ArenaDemo.draw_relief_wall(wall, false, false)
      wall_alpha = 0
      32.times { |y| 32.times { |x| wall_alpha += 1 if wall.get_pixel(x, y).alpha == 0 } }
      check.call(wall_alpha > 0 && wall_alpha < 1024, 'separate native wall has transparent outer silhouette')
      wall.dispose
      floor_colors, wall_colors = [], []
      ArenaDemo::PLATFORM_STYLES.each do |style, (_label, ground)|
        top = Bitmap.new(32, 32)
        face = Bitmap.new(32, 32)
        ArenaDemo.draw_relief_cliff(top, 0, ground, style)
        ArenaDemo.draw_relief_wall(face, true, true, style, ground)
        [top, face].each_with_index do |bitmap, kind|
          pixels = String.new
          32.times { |y| 32.times { |x| c = bitmap.get_pixel(x, y); pixels << [c.red, c.green, c.blue, c.alpha].map(&:to_i).pack('C4') } }
          (kind == 0 ? floor_colors : wall_colors) << Zlib.crc32(pixels)
        end
        check.call(top.get_pixel(0, 0).alpha == 0 && top.get_pixel(16, 31).alpha > 0,
          "#{style}: rounded corner keeps the standing position")
        cap = Bitmap.new(32, 32)
        ArenaDemo.draw_relief_wall(cap, false, false, style, ground)
        check.call(cap.get_pixel(0, 0).alpha == 0 && cap.get_pixel(31, 0).alpha == 0 && face.get_pixel(16, 0).alpha > 0,
          "#{style}: wall ends are rounded while middle stays connected")
        cap.dispose
        top.dispose
        face.dispose
      end
      check.call(floor_colors.uniq.length == 12, 'twelve platform styles have distinct floor artwork')
      check.call(wall_colors.uniq.length == 12, 'twelve platform styles have distinct wall artwork')
      lava = ArenaDemo.platform_floor_bitmap('lava').get_pixel(16, 16)
      check.call(lava.red > lava.blue && lava.alpha > 0, 'lava artwork is opaque and molten orange')
      ArenaDemo.singleton_class.prepend(Module.new do
        def draw_material_motif(*args)
          $native_floor_motifs << args[1] if $native_floor_motifs
          super
        end
      end)
      %w[mud type_poison type_dark type_psychic].each do |ground|
        $native_floor_motifs = []
        bare = Bitmap.new(32, 32)
        ArenaDemo.draw_platform_floor(bare, ground)
        check.call($native_floor_motifs.empty?, "#{ground}: foreground motifs removed, including base overlays")
        bare.dispose
      end
      $native_floor_motifs = nil
      $native_floor_motifs = []
      tatami = Bitmap.new(32, 32)
      ArenaDemo.draw_platform_floor(tatami, 'type_fighting')
      check.call($native_floor_motifs == [:tatami], 'tatami has no inherited parquet diagonal overlay')
      tatami.dispose
      $native_floor_motifs = []
      deck = Bitmap.new(32, 32)
      ArenaDemo.draw_platform_floor(deck, 'wood')
      check.call($native_floor_motifs.empty?, 'bridge deck has no staggered parquet/brick motif')
      seams = [7, 15, 23, 31]
      check.call(seams.all? { |y| 32.times.all? { |x| c = deck.get_pixel(x, y); c.red == 81 && c.green == 59 && c.blue == 40 && c.alpha == 255 } },
        'bridge deck has four continuous full-width board gaps, including tile boundary')
      check.call(32.times.all? { |y| 32.times.all? { |x| deck.get_pixel(x, y).alpha == 255 } }, 'bridge deck is fully opaque and walkable across tile seams')
      deck.dispose
      $native_floor_motifs = []
      specks = Bitmap.new(32, 32)
      ArenaDemo.draw_platform_floor(specks, 'crystal')
      bright = 0
      32.times { |y| 32.times { |x| c = specks.get_pixel(x, y); bright += 1 if c.blue > 200 && c.blue > c.red * 1.5 } }
      check.call($native_floor_motifs == [:blue_specks] && bright == 3, 'crystal floor has three discreet cyan cores, no large crystal motif')
      specks.dispose
      $native_floor_motifs = nil
      %w[industrial wood].each do |style|
        ground = ArenaDemo::PLATFORM_STYLES[style][1]
        face = Bitmap.new(32, 32)
        ArenaDemo.draw_relief_wall(face, true, true, style, ground)
        floor = ArenaDemo.platform_floor_bitmap(ground)
        top_light = wall_light = 0
        (8..27).each do |y|
          32.times do |x|
            a, b = floor.get_pixel(x, y), face.get_pixel(x, y)
            top_light += a.red + a.green + a.blue
            wall_light += b.red + b.green + b.blue
          end
        end
        check.call(top_light - wall_light > 32 * 20 * 30, "#{style}: front wall has strong contrast against the walking floor")
        face.dispose
      end
      # Export local artwork composition for visual review, without distributing assets.
      preview_records = {}
      (43..46).each do |y|
        (43..(y < 45 ? 45 : 46)).each do |x|
          preview_records["#{x},#{y}"] = { 'floor' => 'field', 'height' => 1 }
        end
      end
      preview_records['44,42'] = { 'floor' => 'field', 'height' => 1, 'stair' => 2 }
      preview_records['42,45'] = { 'floor' => 'field', 'height' => 1, 'stair' => 6 }
      width, height = 1280, 960
      canvas = Bitmap.new(width, height)
      ground = ArenaDemo::ExpeditionTerrain.source('Tilesets/Outside')
      ArenaDemo::PLATFORM_STYLES.keys.select { |key| ArenaMaterials::VISIBLE_STYLES.include?(key) }.each_with_index do |style, index|
        styled = preview_records.transform_values { |r| r.merge('platform_style' => style, 'ground' => ArenaDemo::PLATFORM_STYLES[style][1]) }
        (40..49).each do |y|
          (40..49).each do |x|
            dx, dy = index % 4 * 320 + (x - 40) * 32, index / 4 * 320 + (y - 40) * 32
            canvas.blt(dx, dy, ground, Rect.new(32, 64, 32, 32))
            bmp = ArenaDemo.relief_bitmap(styled, x, y)
            bmp = ArenaDemo.platform_floor_bitmap('lava') if style == 'volcano' && y == 48 && x.between?(43, 46)
            canvas.blt(dx, dy, bmp, Rect.new(0, 0, 32, 32)) if bmp
          end
        end
      end
      atlas = Bitmap.new(768, 384)
      ArenaMaterials::VISIBLE_FLOORS.each_with_index do |key, index|
        tile = ArenaDemo.platform_floor_bitmap(key)
        3.times do |y|
          3.times { |x| atlas.blt(index % 8 * 96 + x * 32, index / 8 * 96 + y * 32, tile, Rect.new(0, 0, 32, 32)) }
        end
      end
      File.write(path.sub(/\.log$/, '-floors.txt'), ArenaMaterials::VISIBLE_FLOORS.map.with_index { |key, i| "#{i + 1}: #{key} — #{ArenaMaterials::FLOORS[key][0]}" }.join("\n"))
      # Exercise the actual picker/window lifecycle, injecting only confirm or
      # cancel input. No map frame/event runs in this disposable UI check.
      picker_scene = $scene
      $scene = nil
      Input.singleton_class.prepend(Module.new do
        def trigger?(button)
          return super unless $native_picker_action
          confirm = $native_picker_action == :confirm && button == Input::USE
          if confirm && $native_picker_capture
            $native_picker_shot = Graphics.snap_to_bitmap
            $native_picker_capture = false
          end
          confirm || ($native_picker_action == :cancel && button == Input::BACK)
        end
      end)
      ArenaMaterialCatalogWindow.prepend(Module.new do
        def initialize(*args)
          super
          ($native_picker_windows ||= []) << self
        end
      end)
      entries = ArenaDemo.material_floor_entries
      check.call(entries.length == 28 && (entries.map { |e| e[:ground] } & ArenaMaterials::RETIRED_FLOORS).empty?,
        'flat visual list contains the 27 offered floors and void')
      entries.concat(ArenaDemo.material_style_entries)
      check.call(ArenaDemo.material_style_entries.length == 11 && ArenaDemo.material_style_entries.none? { |e| e[:platform_style] == 'arena' },
        'combat arena platform retired from the visible selector without changing old style IDs')
      entries.each do |entry|
        art = ArenaDemo.material_catalog_preview(entry)
        check.call(art.width == 96 && art.height == 96 && !art.disposed?, "picker preview: #{entry[:ground] || entry[:platform_style]}")
      end
      picker_state = Marshal.dump($PokemonGlobal)
      picker_shots = []
      all_floors = ArenaDemo.material_floor_entries
      style_options = ArenaDemo.material_style_entries
      [[all_floors, all_floors.index { |e| e[:ground] == 'type_poison' }, 'Améthyste', '-picker-ground.png'],
       [ArenaDemo.material_style_entries, 2, 'Plateforme Neige', '-picker-style.png'],
       [style_options, style_options.index { |e| e[:platform_style] == 'industrial' }, 'Industrielle', '-picker-industrial.png'],
       [style_options, style_options.index { |e| e[:platform_style] == 'wood' }, 'Bois', '-picker-wood.png'],
       [style_options, style_options.index { |e| e[:platform_style] == 'crystal' }, 'Cristal', '-picker-crystal.png'],
       [all_floors, all_floors.index { |e| e[:ground] == 'water' }, 'Eau', '-picker-water.png'],
       [all_floors, all_floors.index { |e| e[:ground] == 'holo_hex' }, 'Hexagones holographiques', '-picker-holo.png'],
       [all_floors, all_floors.index { |e| e[:ground] == 'quicksand' }, 'Sables mouvants', '-picker-quicksand.png']].each do |options, index, title, suffix|
        $native_picker_action = :confirm
        $native_picker_capture = true
        selected = ArenaDemo.choose_material_catalog(options, "Choisissez : #{title}", index)
        check.call(selected == options[index], "actual picker confirms #{title} after scrolling")
        check.call($native_picker_windows.last.disposed?, "actual picker disposes window: #{title}")
        window = $native_picker_windows.last
        check.call(window.width <= Graphics.width - 216 && (window.height - window.borderY) % 64 == 0,
          "picker has separate preview space and complete rows: #{title}")
        check.call(!ArenaDemo.material_catalog_preview(selected).disposed?, "picker keeps shared preview alive: #{title}")
        picker_shots << [$native_picker_shot, path.sub(/\.log$/, suffix)]
      end
      $native_picker_action = :cancel
      check.call(ArenaDemo.choose_material_catalog(ArenaDemo.material_floor_entries(:hazard), 'Retour').nil?, 'actual picker cancels without a selection')
      if Graphics.respond_to?(:resize_screen)
        old_width, old_height = Graphics.width, Graphics.height
        Graphics.resize_screen(512, 384)
        $native_picker_action = :confirm
        $native_picker_capture = true
        options = ArenaDemo.material_floor_entries
        selected = ArenaDemo.choose_material_catalog(options, 'Choisissez le sol à appliquer.', options.index { |e| e[:ground] == 'type_dark' })
        check.call(selected[:ground] == 'type_dark', 'compact 512x384 picker keeps long monotype names selectable')
        picker_shots << [$native_picker_shot, path.sub(/\.log$/, '-picker-compact.png')]
        Graphics.resize_screen(old_width, old_height)
      end
      check.call(Marshal.dump($PokemonGlobal) == picker_state, 'preview browsing never edits or saves the arena')
      $native_picker_action = nil
      $scene = picker_scene
      # Water keeps its summit and only exposed south faces become waterfalls.
      records = ArenaDemo.tile_edit_records
      [[45, 46], [43, 47]].each do |x, y|
        check.call(ArenaDemo.editor_apply_ground(records, [], x, y, floor: 'field', ground: 'water'), 'paint water without removing platform')
        check.call(records["#{x},#{y}"]['height'] == 1, 'water retains summit height')
      end
      check.call(!ArenaDemo.relief_wall?(records, 45, 47) && ArenaDemo.relief_wall?(records, 43, 48),
        'interior water has no waterfall; exposed south water keeps blocked wall')
      wall = ArenaDemo.relief_bitmap(records, 43, 48)
      wall_sample = wall.get_pixel(16, 16)
      check.call(wall_sample.blue > wall_sample.red, 'south face displays blue falling water over retained wall')
      $game_player.moveto(44, 47)
      $game_player.direction = 4
      $PokemonGlobal.surfing = false
      old_confirm = Object.instance_method(:pbConfirmMessage)
      Object.send(:define_method, :pbConfirmMessage) { |*| true }
      ArenaDemo.try_arena_surf
      Object.send(:define_method, :pbConfirmMessage, old_confirm)
      check.call($PokemonGlobal.surfing && [$game_player.x, $game_player.y] == [43, 47], 'native Surf enters water at platform height')
      check.call(!$game_player.passable?(43, 47, 2), 'Surf cannot descend waterfall face')
      payload = ArenaDemo.visit_snapshot_payload
      decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
      check.call(decoded && decoded[:tile_edits]['43,47']['height'] == 1, 'raised water survives visit decode')
      check.call(Game.save(fixture), 'raised water saved to disposable slot')
      Game.load(SaveData.read_from_file(fixture))
      check.call(ArenaDemo.tile_edit_records['43,47']['height'] == 1, 'raised water survives disk save reload')
      cascade_canvas = Bitmap.new(192, 96)
      (42..47).each do |x|
        (46..48).each do |y|
          cascade_canvas.blt((x - 42) * 32, (y - 46) * 32, ArenaDemo.platform_floor_bitmap('plain'), Rect.new(0, 0, 32, 32))
          art = ArenaDemo.relief_bitmap(ArenaDemo.tile_edit_records, x, y)
          cascade_canvas.blt((x - 42) * 32, (y - 46) * 32, art, Rect.new(0, 0, 32, 32)) if art
        end
      end
      picker_shots << [cascade_canvas, path.sub(/\.log$/, '-waterfall.png')]
      # Execute the actual Scene_Map transfer with a step still interpolating.
      extension_records = { '40,42' => { 'floor' => 'field', 'height' => 1, 'ground' => 'desert', 'platform_style' => 'desert' } }
      check.call(ArenaDemo.editor_apply_relief(extension_records, [], 40, 44, 1) && extension_records['40,44']['platform_style'] == 'desert',
        'native extension inherits style across the visible wall cell')
      check.call(ArenaDemo.editor_apply_relief(extension_records, [], 40, 43, 1) && extension_records['40,43']['ground'] == 'desert',
        'native platform over a wall inherits its owning summit theme')
      Input.singleton_class.prepend(Module.new do
        def pressex?(key)
          return $native_hold_enter if key == :RETURN && !$native_hold_enter.nil?
          super
        end
      end)
      message = Window_AdvancedTextPokemon.newWithSize('', 0, 0, 480, 96)
      message.letterbyletter = true
      message.textspeed = 0.05
      message.text = 'abcdefghijklmnopqrstuvwxyz'
      message.instance_variable_set(:@display_timer, 0.0)
      message.instance_variable_set(:@display_last_updated, System.uptime - 0.11)
      $native_hold_enter = false
      message.updateInternal
      normal_chars = message.instance_variable_get(:@curchar)
      message.text = 'abcdefghijklmnopqrstuvwxyz'
      message.instance_variable_set(:@display_timer, 0.0)
      message.instance_variable_set(:@display_last_updated, System.uptime - 0.11)
      $native_hold_enter = true
      message.updateInternal
      fast_chars = message.instance_variable_get(:@curchar)
      check.call(fast_chars > normal_chars * 2, 'holding Enter accelerates actual native letter reveal')
      check.call(message.textspeed == 0.05, 'holding Enter preserves configured text speed')
      $native_hold_enter = false
      message.instance_variable_set(:@display_timer, 0.0)
      message.instance_variable_set(:@display_last_updated, System.uptime - 0.11)
      message.updateInternal
      check.call(message.instance_variable_get(:@curchar) - fast_chars <= normal_chars + 1, 'releasing Enter immediately restores normal dialogue pace')
      message.text = "AB\1CD"
      $native_hold_enter = true
      3.times do
        message.instance_variable_set(:@display_last_updated, System.uptime - 0.2)
        message.updateInternal
      end
      check.call(message.pausing?, 'holding Enter does not dismiss an explicit message pause')
      message.dispose
      $native_hold_enter = nil
      # Reproduce connected liquid tiles and the lower summit beside a wall.
      seams = {}
      (43..46).each { |y| (43..49).each { |x| seams["#{x},#{y}"] = { 'floor' => 'field', 'height' => 1, 'ground' => 'desert', 'platform_style' => 'desert' } } }
      (43..46).each { |y| seams["47,#{y}"]['ground'] = 'water' }
      seams['48,47'] = { 'floor' => 'field', 'height' => 1, 'ground' => 'desert', 'platform_style' => 'desert' }
      seams['49,47'] = seams['48,47'].dup
      middle = ArenaDemo.relief_bitmap(seams, 47, 44)
      floor = ArenaDemo.platform_floor_bitmap('water')
      check.call((8..23).all? { |x| [0, 31].all? { |y|
        a, b = middle.get_pixel(x, y), floor.get_pixel(x, y)
        [a.red, a.green, a.blue, a.alpha] == [b.red, b.green, b.blue, b.alpha]
      } }, 'liquid-to-liquid seams have no stone lips or repeated rounded borders')
      beside_wall = ArenaDemo.relief_bitmap(seams, 48, 47)
      check.call(beside_wall.get_pixel(0, 31).alpha == 255, 'summit beside south wall has no rounded notch at the join')
      join_preview = Bitmap.new(288, 192)
      (42..50).each do |x|
        (42..47).each do |y|
          join_preview.blt((x - 42) * 32, (y - 42) * 32, ArenaDemo.platform_floor_bitmap('plain'), Rect.new(0, 0, 32, 32))
          art = ArenaDemo.relief_bitmap(seams, x, y)
          join_preview.blt((x - 42) * 32, (y - 42) * 32, art, Rect.new(0, 0, 32, 32)) if art
        end
      end
      picker_shots << [join_preview, path.sub(/\.log$/, '-liquid-joins.png')]
      flow_preview = Bitmap.new(160, 96)
      ArenaMaterials::CASCADE_GROUNDS.each_with_index do |ground, i|
        isolated = { '40,40' => { 'floor' => 'field', 'height' => 1, 'ground' => ground } }
        check.call(ArenaDemo.relief_code(isolated, 40, 40) == 1 && ArenaDemo.relief_wall?(isolated, 40, 41), "#{ground}: elevated surface keeps waterfall face")
        top = ArenaDemo.relief_bitmap(isolated, 40, 40)
        face = ArenaDemo.relief_bitmap(isolated, 40, 41)
        flow_preview.blt(i * 32, 0, top, Rect.new(0, 0, 32, 32))
        flow_preview.blt(i * 32, 32, face, Rect.new(0, 0, 32, 32))
        versions = (0..3).map do |frame|
          ArenaDemo.instance_variable_set(:@liquid_art_frame, frame)
          image = Bitmap.new(32, 32)
          ArenaDemo.draw_relief_wall(image, true, true, 'mountain', ground)
          values = (4..31).flat_map { |y| (4..27).map { |x| c = image.get_pixel(x, y); [c.red, c.green, c.blue] } }
          image.dispose
          values
        end
        check.call(versions.uniq.length > 1, "#{ground}: cascade has downward moving animation frames")
      end
      ArenaDemo.instance_variable_set(:@liquid_art_frame, 0)
      picker_shots << [flow_preview, path.sub(/\.log$/, '-all-cascades.png')]
      File.write(path, lines.join("\n") + "\nPreparing real transfer scene\n")
      transfer_scene = Scene_Map.new
      $scene = transfer_scene
      transfer_scene.createSpritesets
      File.write(path, lines.join("\n") + "\nReal transfer scene ready\n")
      2.times do
        $game_player.moveto(49, 55)
        $game_player.instance_variable_set(:@move_timer, 0.01)
        $game_player.instance_variable_set(:@move_initial_x, 49)
        $game_player.instance_variable_set(:@move_initial_y, 54)
        $PokemonGlobal.ice_sliding = true
        $game_temp.player_new_map_id = ArenaDemo::ENTRANCE_MAP_ID
        $game_temp.player_new_x, $game_temp.player_new_y, $game_temp.player_new_direction = 7, 3, 2
        transfer_scene.transfer_player
        File.write(path, lines.join("\n") + "\nTransferred to foyer\n")
        3.times { Graphics.update; $game_player.update }
        check.call($game_map.map_id == ArenaDemo::ENTRANCE_MAP_ID && [$game_player.x, $game_player.y] == [7, 3], 'actual return transfer remains on foyer landing')
        check.call($game_player.real_x == 7 * Game_Map::REAL_RES_X && $game_player.real_y == 3 * Game_Map::REAL_RES_Y,
          'return transfer never interpolates through void from previous-map coordinates')
        check.call(!$PokemonGlobal.ice_sliding && !$game_player.move_route_forcing, 'return clears forced movement')
        $game_temp.player_new_map_id = ArenaDemo::MAP_ID
        $game_temp.player_new_x, $game_temp.player_new_y, $game_temp.player_new_direction = *ArenaDemo.map_start
        transfer_scene.transfer_player
      end
      transfer_scene.dispose
      $scene = picker_scene
      # Export both a tile composition and the real renderer/player frame.
      [[canvas, path.sub(/\.log$/, '.png')], [screenshot, path.sub(/\.log$/, '-player.png')],
       [atlas, path.sub(/\.log$/, '-floors.png')], *picker_shots, *$native_sink_shots].each do |output, filename|
        width, height = output.width, output.height
        rows = String.new
        height.times do |y|
          rows << 0.chr
          width.times do |x|
            c = output.get_pixel(x, y)
            rows << [c.red, c.green, c.blue, c.alpha].map(&:to_i).pack('C4')
          end
        end
        chunk = proc { |type, data| [data.bytesize].pack('N') + type + data + [Zlib.crc32(type + data)].pack('N') }
        png = "\x89PNG\r\n\x1a\n".b + chunk.call('IHDR', [width, height, 8, 6, 0, 0, 0].pack('NNCCCCC')) +
          chunk.call('IDAT', Zlib::Deflate.deflate(rows)) + chunk.call('IEND', ''.b)
        File.binwrite(filename, png)
        output.dispose
      end
      lines << "#{lines.length} native relief checks passed. Only disposable save used."
      File.write(path, lines.join("\n"))
      File.delete(fixture) if File.file?(fixture)
      exit! 0
    rescue Exception => error
      lines << [error.class, error.message, error.backtrace&.first(8)].inspect
      File.write(path, lines.join("\n"))
      File.delete(fixture) if File.file?(fixture)
      exit! 1
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::NativeReliefProbe)
end
