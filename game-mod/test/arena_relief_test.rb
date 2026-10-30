require 'minitest/autorun'
require_relative '../Plugins/ArenaDemo/000_ReliefRules'
module EventHandlers
  def self.add(*); end
end
class Window_CommandPokemon; end
class Game_Map
  attr_accessor :map_id, :events
  def initialize; @map_id = 100; @events = {}; end
  def passable?(*); true; end
  def passableStrict?(*); true; end
  def setup(*); end
end
module ArenaDemo
  MAP_ID = 100
  def self.refresh_objects; end
end
require_relative '../Plugins/ArenaDemo/009_ArenaCustomMode'
require_relative '../Plugins/ArenaDemo/027_ArenaRelief'
require_relative '../Plugins/ArenaDemo/029_ArenaMaterialPicker'
class Scene_Map; end
module ArenaDemo
  OBJECTS = []
  LAYOUTS = { 'Sidelines' => [] }
end
require_relative '../Plugins/ArenaDemo/005_ArenaVisits'
def pbMessage(message, choices = nil, *)
  $relief_choices = choices if choices
  return $relief_choice_queue.shift if $relief_choice_queue
  $relief_choice
end

class ArenaReliefTest < Minitest::Test
  def setup
    $relief_choice = nil
    $relief_choice_queue = nil
    ArenaDemo::Visits.instance_variables.each { |v| ArenaDemo::Visits.remove_instance_variable(v) }
    ArenaDemo::Visits.reset
    $PokemonGlobal = PokemonGlobalMetadata.new
    $PokemonGlobal.arena_demo_void_recovery_version = 1
    $game_player = Struct.new(:x, :y).new(49, 53)
    $game_map = Game_Map.new
    $bag = nil
    ArenaDemo.singleton_class.send(:define_method, :apply_tile_surface) { |*| }
    @records = ArenaDemo.tile_edit_records
    @placements = []
  end
  def teardown
    ArenaDemo::Visits.reset
  end
  def edit(x, y, code)
    ArenaDemo.editor_apply_relief(@records, @placements, x, y, code)
  end
  def test_stair_labels_use_screen_directions_and_keep_direction_codes
    { 2 => [2, 'bas'], 4 => [4, 'gauche'], 6 => [6, 'droite'], 8 => [8, 'haut'] }.each do |code, (_, label)|
      assert_includes ArenaDemo.relief_tool_name(code), label
    end
    [8, 6, 2, 4].each_with_index do |code, i|
      $relief_choice = i + 2
      assert_equal({ relief: code }, ArenaDemo.editor_choose_relief)
    end
    assert_equal ['Escalier vers le haut ↑', 'Escalier vers la droite →',
                  'Escalier vers le bas ↓', 'Escalier vers la gauche ←'], $relief_choices[2, 4]
  end
  def test_four_ascent_directions_descent_and_side_collisions
    ArenaRelief::DIRECTIONS.each do |d, (dx, dy)|
      @records.clear
      assert edit(44 + dx, 44 + dy, 1)
      assert edit(44, 44, d)
      assert ArenaDemo.relief_step?(@records, 44 - dx, 44 - dy, d)
      assert ArenaDemo.relief_step?(@records, 44, 44, d)
      assert ArenaDemo.relief_step?(@records, 44 + dx, 44 + dy, 10 - d)
      assert ArenaDemo.relief_step?(@records, 44, 44, 10 - d)
      side = ArenaRelief::DIRECTIONS.keys.find { |k| k != d && k != 10 - d }
      refute ArenaDemo.relief_step?(@records, 44, 44, side)
      grid = ArenaDemo.relief_grid(@records)
      (42..46).each do |x|
        (42..46).each do |y|
          ArenaRelief::DIRECTIONS.each do |direction, (ox, oy)|
            assert_equal ArenaDemo.relief_step?(@records, x, y, direction),
                         ArenaRelief.step?(grid, x, y, x + ox, y + oy)
          end
        end
      end
    end
  end
  def test_wall_below_summit_is_blocked_from_both_sides_and_cannot_hold_objects
    assert edit(44, 43, 1)
    assert edit(45, 43, 1)
    assert ArenaDemo.relief_step?(@records, 44, 43, 6), 'Last summit row stays walkable'
    refute $game_map.passable?(44, 43, 2), 'Cannot step from summit onto face'
    refute $game_map.passable?(44, 45, 8), 'Cannot stand in the face from below'
    refute $game_map.passable?(43, 44, 6), 'Cannot enter face sideways'
    refute $game_map.passableStrict?(44, 44, 0)
    assert ArenaDemo.relief_wall?(@records, 44, 44)
    assert ArenaRelief.wall?(ArenaDemo.relief_grid(@records), 44, 44)
    ArenaDemo.editor_apply_placement(@placements, @records, 'furniture', { item: :ARENA_FURNITURE_ROCK }, 44, 44)
    assert_empty @placements
    @placements << { 'kind' => 'furniture', 'item' => 'ARENA_FURNITURE_ROCK', 'x' => 46, 'y' => 44 }
    refute edit(46, 43, 1), 'Cannot build a face over furniture'
    @placements.clear
    $game_player.x, $game_player.y = 46, 44
    refute edit(46, 43, 1), 'Cannot build a face over player'
  end
  def test_platform_edges_and_parallel_stair_connections
    [[44, 43], [45, 43]].each { |x, y| assert edit(x, y, 1) }
    assert edit(44, 44, 8)
    assert edit(45, 44, 8)
    assert $game_map.passable?(44, 44, 6)
    assert $game_map.passable?(45, 44, 4)
    refute $game_map.passable?(44, 43, 8)
    refute $game_map.passable?(44, 43, 4)
    assert $game_map.passable?(44, 43, 6)
    refute edit(44, 43, 0), 'An occupied stair support must remain'
    assert edit(44, 44, 0)
    assert edit(44, 43, 0)
    refute $game_map.passable?(45, 44, 4), 'Rail returns when adjoining stair is removed'
  end
  def test_invalid_edits_are_atomic_and_protect_occupants_spawn_void_and_player
    refute edit(44, 44, 8)
    assert_empty @records
    refute edit(49, 53, 1)
    refute edit(47, 53, 1)
    refute edit(1, 1, 1)
    @placements << { 'kind' => 'furniture', 'item' => 'ARENA_FURNITURE_ROCK', 'x' => 44, 'y' => 44 }
    refute edit(44, 44, 1)
    @placements.clear
    assert edit(44, 43, 1)
    assert edit(44, 44, 8)
    before = Marshal.dump(@records)
    refute ArenaDemo.editor_apply_ground(@records, [], 44, 43, floor: 'void')
    assert_equal before, Marshal.dump(@records)
  end
  def test_save_marshal_and_visit_snapshot_round_trip_preserve_relief_and_objects
    assert edit(44, 43, 1)
    assert edit(44, 44, 8)
    @placements.concat([
      { 'kind' => 'furniture', 'item' => 'ARENA_FURNITURE_ROCK', 'x' => 44, 'y' => 43 },
      { 'kind' => 'trainer', 'item' => 'ARENA_TRAINER_ROOKIE', 'x' => 45, 'y' => 43 }
    ])
    @records['45,43'] = { 'floor' => 'field', 'ground' => 'grass', 'height' => 1 }
    $PokemonGlobal.arena_demo_placements = @placements
    $PokemonGlobal = Marshal.load(Marshal.dump($PokemonGlobal))
    payload = ArenaDemo.visit_snapshot_payload
    decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief])
    refute_nil decoded
    assert_equal payload[:relief], ArenaDemo.relief_grid(decoded[:tile_edits])
    assert_equal @placements, decoded[:placements]
    assert_equal 'grass', decoded[:tile_edits]['45,43']['ground']
    invalid = payload[:relief].dup
    invalid.setbyte(43 * 100 + 44, 48)
    assert_nil ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], invalid)
    assert_nil ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], 'x' * 10000)
    assert_nil ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], nil)
  end
  def test_existing_flat_saves_remain_flat
    payload = ArenaDemo.visit_snapshot_payload
    assert_equal '0' * 10000, payload[:relief]
    refute_nil ArenaDemo.decode_visit_snapshot(payload[:surface], [], payload[:relief])
  end
  def test_material_catalogue_menus_and_water_identity
    assert_equal '8', ArenaMaterials::SURFACE_CODES['lava']
    assert_equal '9', ArenaMaterials::SURFACE_CODES['water']
    assert_equal 18, ArenaMaterials::FLOORS.count { |_key, data| data[1] == :type }
    assert_equal 12, ArenaDemo::PLATFORM_STYLES.length
    chooser = proc { |entries, _title| i = $relief_choice_queue.shift; i && i >= 0 ? entries[i] : nil }
    ArenaDemo.stub(:choose_material_catalog, chooser) do
      entries = ArenaDemo.material_floor_entries
      $relief_choice_queue = [entries.index { |e| e[:ground] == 'type_steel' }]
      assert_equal({ floor: 'field', ground: 'type_steel' }, ArenaDemo.editor_choose_ground)
      assert_empty $relief_choice_queue, 'Direct selection requires no family menu'
      $relief_choice_queue = [entries.index { |e| e[:ground] == 'water' }]
      assert_equal({ floor: 'field', ground: 'water' }, ArenaDemo.editor_choose_ground)
      $relief_choice_queue = [entries.index { |e| e[:ground] == 'void' }]
      assert_equal({ floor: 'void' }, ArenaDemo.editor_choose_ground)
      $relief_choice_queue = [-1]
      assert_nil ArenaDemo.editor_choose_ground
      $relief_choice_queue = [10]
      assert_equal({ platform_style: 'swamp' }, ArenaDemo.editor_choose_platform_style)
    end
    $relief_choice_queue = nil
    assert ArenaDemo.editor_apply_ground(@records, [], 40, 40, floor: 'field', ground: 'water')
    assert ArenaDemo.tile_is_void?(40, 40)
    refute $game_map.passableStrict?(40, 40, 0)
    refute $game_map.passable?(39, 40, 6)
    assert_equal 'water', @records['40,40']['ground'], 'Future Surf identity is separate from void'
    assert ArenaDemo.editor_apply_ground(@records, [], 41, 40, floor: 'field', ground: 'type_water')
    assert $game_map.passable?(42, 40, 4), 'Aquatic ceramic is a walkable decorative floor'
    assert_equal ArenaMaterials::BLOCKED_GROUNDS, %w[lava water]
  end
  def test_visual_catalogue_metadata_matches_materials_and_hazard_behavior
    entries = [:classic, :material, :type, :hazard].flat_map { |family| ArenaDemo.material_floor_entries(family) }
    assert_equal 23, entries.length
    assert_equal ArenaMaterials::VISIBLE_FLOORS.sort, entries.map { |e| e[:ground] }.reject { |g| g == 'void' }.sort
    assert_equal entries.map { |e| e[:ground] }.sort, ArenaDemo.material_floor_entries.map { |e| e[:ground] }.sort
    assert_empty ArenaDemo.material_floor_entries.map { |e| e[:ground] } & ArenaMaterials::RETIRED_FLOORS
    assert_equal 'Tatami', ArenaDemo.material_floor_entries.find { |e| e[:ground] == 'type_fighting' }[:name]
    assert_equal ArenaDemo::PLATFORM_STYLES.keys - ['arena'], ArenaDemo.material_style_entries.map { |e| e[:platform_style] }
    assert_equal 11, ArenaDemo.material_style_entries.length
    assert_equal 'Sol de base', entries.find { |e| e[:ground] == 'plain' }[:name]
    refute entries.any? { |e| e[:ground] == 'metal' }
    assert_equal ['Tatami', 'Améthyste', 'Quartz rose', 'Ardoise mauve', 'Obsidienne', 'Plaques métalliques'],
      ArenaDemo.material_floor_entries.select { |e| e[:ground].start_with?('type_') }.map { |e| e[:name] }
    water = entries.find { |e| e[:ground] == 'water' }
    assert_includes ArenaDemo.material_catalog_description(water), 'Infranchissable'
    assert_includes ArenaDemo.material_catalog_description(water), 'Surf à venir'
    assert_includes ArenaDemo.material_catalog_description(ground: 'type_poison'), 'Praticable'
    ice = entries.find { |e| e[:ground] == 'ice' }
    assert_includes ArenaDemo.material_catalog_description(ice), 'glissant'
  end
  def test_every_material_and_style_round_trips_with_alphanumeric_codes
    assert edit(44, 43, 1)
    assert edit(45, 43, 1)
    assert edit(44, 44, 8)
    ArenaDemo::PLATFORM_STYLES.each_key do |style|
      assert ArenaDemo.editor_apply_platform_style(@records, 44, 43, style)
      payload = ArenaDemo.visit_snapshot_payload
      decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], [], payload[:relief], payload[:styles])
      refute_nil decoded
      assert_equal style, decoded[:tile_edits]['44,43']['platform_style']
      assert_equal payload[:styles], ArenaDemo.platform_style_grid(decoded[:tile_edits])
    end
    ArenaMaterials::FLOORS.each_key do |ground|
      assert ArenaDemo.editor_apply_ground(@records, [], 40, 40, floor: 'field', ground: ground), ground
      payload = ArenaDemo.visit_snapshot_payload
      decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], [], payload[:relief], payload[:styles])
      refute_nil decoded, ground
      assert_equal ground, ArenaDemo.tile_surface_state(decoded[:tile_edits], 40, 40)['ground']
      assert_equal ArenaMaterials::BLOCKED_GROUNDS.include?(ground), ArenaDemo.tile_is_void?(40, 40)
    end
    payload = ArenaDemo.visit_snapshot_payload
    invalid = payload[:surface].dup
    invalid.setbyte(40 * 100 + 40, 95)
    assert_nil ArenaDemo.decode_visit_snapshot(invalid, [], payload[:relief], payload[:styles])
    $PokemonGlobal = Marshal.load(Marshal.dump($PokemonGlobal))
    assert_equal payload, ArenaDemo.visit_snapshot_payload
  end
  def test_lava_is_a_visible_blocking_surface_and_volcanic_ground_is_walkable
    paint = { floor: 'field', ground: 'lava' }
    assert ArenaDemo.editor_apply_ground(@records, @placements, 44, 44, paint)
    assert_equal 'lava', @records['44,44']['ground']
    assert_equal 'field', @records['44,44']['floor'], 'Lava has its own visible surface'
    assert ArenaDemo.tile_is_void?(44, 44, @records)
    ArenaRelief::DIRECTIONS.each do |direction, (dx, dy)|
      refute $game_map.passable?(44 - dx, 44 - dy, direction)
    end
    refute $game_map.passableStrict?(44, 44, 0)
    ArenaDemo.editor_apply_placement(@placements, @records, 'furniture', { item: :ARENA_FURNITURE_ROCK }, 44, 44)
    assert_empty @placements
    refute edit(44, 44, 1)
    refute ArenaDemo.editor_apply_ground(@records, @placements, 47, 53, paint), 'Fixed guide protected'
    assert edit(45, 43, 1)
    assert edit(45, 44, 8)
    refute ArenaDemo.editor_apply_ground(@records, @placements, 45, 45, paint), 'Stair landing protected'
    assert ArenaDemo.editor_apply_ground(@records, @placements, 44, 44, floor: 'field', ground: 'volcanic')
    refute ArenaDemo.tile_is_void?(44, 44, @records)
    assert $game_map.passable?(43, 44, 6)
    assert ArenaDemo.editor_apply_platform_style(@records, 45, 43, 'volcano')
    assert_equal 'volcano', @records['45,44']['platform_style']
    assert_equal 'volcanic', @records['45,43']['ground']
    assert ArenaDemo.editor_apply_ground(@records, @placements, 43, 43, paint)
    payload = ArenaDemo.visit_snapshot_payload
    decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], [], payload[:relief], payload[:styles])
    refute_nil decoded
    assert_equal 'lava', decoded[:tile_edits]['43,43']['ground']
    assert_equal 'volcano', decoded[:tile_edits]['45,43']['platform_style']
    assert_nil ArenaDemo.decode_visit_snapshot(payload[:surface], [[0, 'ARENA_FURNITURE_ROCK', 43, 43]], payload[:relief], payload[:styles])
    $PokemonGlobal = Marshal.load(Marshal.dump($PokemonGlobal))
    assert_equal payload, ArenaDemo.visit_snapshot_payload
  end
  def test_connected_style_paints_whole_platform_and_stairs_but_not_diagonal_or_ground
    [[44, 43], [45, 43], [45, 42], [46, 41]].each { |x, y| assert edit(x, y, 1) }
    assert edit(44, 44, 8)
    occupied = { 'kind' => 'trainer', 'item' => 'ARENA_TRAINER_ROOKIE', 'x' => 45, 'y' => 42 }
    @placements << occupied
    before_grid = ArenaDemo.relief_grid(@records)
    before = ArenaDemo.copy_tile_edits(@records)
    assert ArenaDemo.editor_apply_platform_style(@records, 44, 43, 'snow')
    [[44, 43], [45, 43], [45, 42], [44, 44]].each do |x, y|
      assert_equal 'snow', @records["#{x},#{y}"]['ground']
      assert_equal 'snow', @records["#{x},#{y}"]['platform_style']
    end
    assert_equal before['46,41'], @records['46,41'], 'Diagonal island is independent'
    refute @records.key?('43,43'), 'Ordinary ground is unchanged'
    assert_equal before_grid, ArenaDemo.relief_grid(@records)
    assert_equal [occupied], @placements
    assert ArenaDemo.editor_apply_ground(@records, @placements, 45, 42, floor: 'field', ground: 'grass')
    assert_equal 'snow', @records['45,42']['platform_style'], 'Individual floor paint keeps walls'
    assert_equal 'grass', @records['45,42']['ground']
    $PokemonGlobal.arena_demo_placements = @placements
    $PokemonGlobal = Marshal.load(Marshal.dump($PokemonGlobal))
    payload = ArenaDemo.visit_snapshot_payload
    decoded = ArenaDemo.decode_visit_snapshot(payload[:surface], payload[:placements], payload[:relief], payload[:styles])
    refute_nil decoded
    assert_equal 'snow', decoded[:tile_edits]['44,43']['platform_style']
    assert_equal 'grass', decoded[:tile_edits]['45,42']['ground']
    assert_equal payload[:styles], ArenaDemo.platform_style_grid(decoded[:tile_edits])
    snapshot = Marshal.dump(@records)
    refute ArenaDemo.editor_apply_platform_style(@records, 45, 44, 'grass'), 'Wall is not a platform selection'
    refute ArenaDemo.editor_apply_platform_style(@records, 44, 43, 'invalid')
    assert_equal snapshot, Marshal.dump(@records)
    assert_nil ArenaDemo.decode_visit_snapshot(payload[:surface], [], payload[:relief], 'x' * 10000)
    assert_nil ArenaDemo.decode_visit_snapshot(payload[:surface], [], payload[:relief], '2' * 10000)
    assert_equal 'plain', ArenaDemo.tile_surface_state({}, 50, 50)['ground'], 'Legacy floor remains supported'
  end
  def test_guest_snapshot_is_used_without_overwriting_personal_save
    assert edit(44, 43, 1)
    assert edit(44, 44, 8)
    payload = ArenaDemo.visit_snapshot_payload
    home_records = $PokemonGlobal.arena_demo_tile_edits
    ArenaDemo::Visits.receive(type: :arena_ready, version: 3)
    refute ArenaDemo::Visits.ready?
    ArenaDemo::Visits.receive(type: :arena_ready, version: 4)
    refute ArenaDemo::Visits.ready?
    ArenaDemo::Visits.receive(type: :arena_ready, version: 5)
    refute ArenaDemo::Visits.ready?
    ArenaDemo::Visits.receive(type: :arena_ready, version: 6)
    refute ArenaDemo::Visits.ready?
    ArenaDemo::Visits.receive(type: :arena_ready, version: 7)
    refute ArenaDemo::Visits.ready?
    ArenaDemo::Visits.receive(type: :arena_ready, version: 8)
    assert ArenaDemo::Visits.ready?
    ArenaDemo::Visits.receive(payload.merge(type: :arena_state, phase: :open,
      role: :guest, room: 'room-relief', host: 1, guest: 2,
      objects: [], layout: 0, difficulty: 1))
    assert ArenaDemo::Visits.guest?
    assert ArenaDemo::Visits.locked?
    assert_equal payload[:relief], ArenaDemo.relief_grid(ArenaDemo.tile_edit_records)
    assert ArenaDemo.tile_edit_records['44,44'].frozen?
    assert_same home_records, $PokemonGlobal.arena_demo_tile_edits
    refute_same home_records, ArenaDemo.tile_edit_records
    ArenaDemo::Visits.receive(type: :arena_state, phase: :closed)
    assert_same home_records, ArenaDemo.tile_edit_records
  end
  def test_real_placement_and_removal_accept_platforms_but_keep_stairs_free
    assert edit(44, 43, 1)
    assert edit(44, 44, 8)
    $bag = Object.new
    def $bag.remove(*); true; end
    def $bag.add(*); true; end
    ArenaDemo.singleton_class.send(:define_method, :refresh_custom_placements) { |*| }
    %w[furniture trainer].each do |kind|
      item = kind == 'furniture' ? :ARENA_FURNITURE_ROCK : :ARENA_TRAINER_ROOKIE
      selection = { item: item }
      ArenaDemo.editor_apply_placement(@placements, @records, kind, selection, 44, 44)
      assert_empty @placements
      ArenaDemo.editor_apply_placement(@placements, @records, kind, selection, 44, 43)
      assert_equal kind, @placements.first['kind']
      assert_equal [44, 43], @placements.first.values_at('x', 'y')
      ArenaDemo.editor_apply_placement(@placements, @records, kind, { action: :remove }, 44, 43)
      assert_empty @placements
    end
  end
end
