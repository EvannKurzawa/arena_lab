# Includes the existing world regressions, using a fresh per-test profile ledger.
class Scene_Map
  def update; end
end
require_relative 'expedition_world_test'
class Scene_Map
  alias __followingpkmn__update update
  def update(*args); __followingpkmn__update(*args); end
end
def pbMapInterpreterRunning?; !!$outing_interpreter; end
def pbMessage(*args); ($outing_messages ||= []) << [$game_map&.map_id, args]; end

class OutingLedgerTest < Minitest::Test
  Ledger = ArenaDemo::OutingLedger
  def setup
    @directory = Dir.mktmpdir('arena-outing-ledger-', File.expand_path('../..', __dir__))
    @path = File.join(@directory, 'primary.dat')
    @ledger = Ledger.new(@path)
  end
  def teardown; FileUtils.remove_entry(@directory); end

  def test_three_free_departures_in_a_rolling_day_and_exact_boundary
    3.times { |i| @ledger.start("visit#{i}", 1000 + i * 60) }
    assert_equal 0, @ledger.free_remaining(2000)
    assert_raises(Ledger::LimitReached) { @ledger.start('fourth', 2000) }
    assert_equal 87400, @ledger.next_free_at(2000)
    assert_equal 0, @ledger.free_remaining(87399)
    assert_equal 1, @ledger.free_remaining(87400)
    assert_equal 3, @ledger.free_remaining(90000)
  end

  def test_reload_and_finish_do_not_replenish_the_allowance
    @ledger.start('visit', 1000)
    @ledger.finish('visit')
    loaded = Ledger.new(@path)
    assert_equal 2, loaded.free_remaining(1100)
    assert_equal 2200, loaded.session('visit')['deadline']
    assert loaded.session('visit')['ended']
    assert_equal 3, Ledger.new(File.join(@directory, 'guest.dat')).free_remaining(1100)
  end

  def test_failed_departure_refunds_free_or_future_bonus_slot
    @ledger.start('failed', 1000)
    @ledger.cancel('failed')
    assert_equal 3, @ledger.free_remaining(1000)
    3.times { |i| @ledger.start("free#{i}", 1000) }
    @ledger.credit(2)
    @ledger.start('extra', 1000)
    assert_equal 1, @ledger.bonus
    assert_equal 0, @ledger.free_remaining(1000)
    @ledger.cancel('extra')
    assert_equal 2, Ledger.new(@path).bonus
    assert_raises(ArgumentError) { @ledger.credit(-1) }
  end

  def test_corrupt_record_does_not_silently_reset_to_three_free_outings
    File.write(@path, 'broken record')
    assert_raises(IOError) { Ledger.new(@path).free_remaining(1000) }
    assert_equal 'broken record', File.read(@path)
  end

  def test_failed_record_write_does_not_consume_a_slot_in_memory
    obstruction = File.join(@directory, 'not-a-directory')
    File.write(obstruction, 'preserve')
    ledger = Ledger.new(File.join(obstruction, 'ledger.dat'))
    assert_raises(SystemCallError) { ledger.start('failed', 1000) }
    assert_equal 3, ledger.free_remaining(1000)
    assert_equal 'preserve', File.read(obstruction)
  end
end

class OutingRuntimeTest < Minitest::Test
  World = ArenaDemo::Expeditions
  Rules = ArenaDemo::Outings
  Ledger = ArenaDemo::OutingLedger
  Player = Struct.new(:moving) do
    def moving?; !!moving; end
  end
  def setup
    @directory = Dir.mktmpdir('arena-outing-runtime-', File.expand_path('../..', __dir__))
    SaveData.send(:remove_const, :FILE_PATH)
    SaveData.const_set(:FILE_PATH, File.join(@directory, 'Game.rxdata'))
    @original_clock = Rules.method(:now)
    @clock = 1000.0
    owner = self
    Rules.define_singleton_method(:now) { owner.instance_variable_get(:@clock) }
    $PokemonGlobal = PokemonGlobalMetadata.new
    @plan = { 'seed' => 123, 'regions' => Array.new(16) { { 'biome' => 'grassland', 'cells' => 'b' * 4096, 'decorations' => [] } } }
    $PokemonGlobal.arena_expedition = @plan
    Rules.start(@plan)
    $game_map = Struct.new(:map_id).new(123)
    $game_temp = Struct.new(:in_battle, :in_menu, :message_window_showing, :player_transferring).new(false, false, false, false)
    $game_player = Player.new(false)
    $scene = Scene_Map.new
    $transfers = []
    $fail_transfer = false
    $confirm = true
    $online = false
    $outing_interpreter = false
    $outing_messages = []
    GameData::Species.entries = []
    World.instance_variable_set(:@pools, nil)
  end
  def teardown
    Rules.define_singleton_method(:now, @original_clock)
    FileUtils.remove_entry(@directory)
  end

  def test_following_pokemon_update_alias_returns_after_expiry
    @clock = 2201
    $scene.update
    assert_equal [[101, 16, 20, 8]], $transfers
    assert Rules.ledger.session(@plan['outing_id'])['ended']
  end

  def test_real_timer_counts_menus_and_survives_reloading_the_save
    snapshot = Marshal.dump(@plan)
    @clock = 1600
    $game_temp.in_menu = true
    assert_equal 600, Rules.remaining
    assert_equal '10:00', Rules.time_text
    Rules.tick
    assert_empty $transfers
    $PokemonGlobal.arena_expedition = Marshal.load(snapshot)
    assert_equal 600, Rules.remaining
    @clock = 2300
    assert Rules.expired?
    Rules.tick
    assert_empty $transfers
    $game_temp.in_menu = false
    Rules.tick
    assert_equal [[101, 16, 20, 8]], $transfers
    assert_equal 101, $outing_messages.last[0], 'Return happens automatically, before any acknowledgement dialog'
  end

  def test_expired_wild_or_trainer_battle_finishes_before_return
    @clock = 2201
    $game_temp.in_battle = true
    3.times { Rules.tick }
    assert_empty $transfers
    $game_temp.in_battle = false
    $outing_interpreter = true # Post-battle dialog/evolution/interpreter.
    Rules.tick
    assert_empty $transfers
    $outing_interpreter = false
    Rules.tick
    assert_equal [[101, 16, 20, 8]], $transfers
    assert Rules.ledger.session(@plan['outing_id'])['ended']
    Rules.tick
    assert_equal 1, $transfers.length
  end

  def test_expiry_waits_for_a_step_or_message_and_blocks_sector_crossings
    @clock = 2200
    $game_player.moving = true
    Rules.tick
    assert_empty $transfers
    World.portal(8)
    assert_empty $transfers
    $game_player.moving = false
    $game_temp.message_window_showing = true
    Rules.tick
    assert_empty $transfers
    $game_temp.message_window_showing = false
    Rules.tick
    assert_equal [101, 16, 20, 8], $transfers.last
  end

  def test_reloading_a_closed_outing_cannot_resume_it
    snapshot = Marshal.dump(@plan)
    Rules.close_current
    $PokemonGlobal.arena_expedition = Marshal.load(snapshot)
    assert Rules.expired?
    Rules.tick
    assert_equal [101, 16, 20, 8], $transfers.last
  end

  def test_old_save_gets_one_recorded_migration_not_a_fresh_timer_on_each_load
    old = { 'seed' => 999, 'regions' => @plan['regions'] }
    $PokemonGlobal.arena_expedition = Marshal.load(Marshal.dump(old))
    assert_equal 1200, Rules.remaining
    @clock = 1300
    $PokemonGlobal.arena_expedition = Marshal.load(Marshal.dump(old))
    assert_equal 900, Rules.remaining
    assert_equal 1, Rules.ledger.free_remaining(@clock) # Original outing plus migrated outing.
  end

  def test_unreadable_record_fails_closed_instead_of_granting_a_new_outing
    Rules.ledger.instance_variable_set(:@data, nil)
    File.write(Rules.ledger.path, 'invalid')
    assert Rules.expired?
    refute Rules.departure_allowed?
  end

  def test_zone_selection_is_unique_capped_and_frozen_for_the_whole_expedition
    species = ExpeditionWorldTest::Species
    GameData::Species.entries = 18.times.map { |i| species.new("MON#{i}".to_sym, 0, 1 + i % 5, [:NORMAL], :Grassland, 300 + i * 10, []) }
    World.assign_species(@plan)
    lists = @plan['regions'].map { |region| region['encounters'] }
    assert lists.all? { |list| list.length == 5 && list.map(&:last).uniq.length == 5 }
    assert lists.uniq.length > 1
    original = Marshal.dump(lists)
    map = Object.new
    map.instance_variable_set(:@map, Object.new)
    map.instance_variable_get(:@map).instance_variable_set(:@arena_expedition_region, @plan['regions'][13])
    def map.map_id; 123; end
    allowed = lists[13].map(&:last)
    100.times { assert_includes allowed, World.encounter(map)[0] }
    @clock += 500
    World.assign_species(@plan)
    assert_equal original, Marshal.dump(@plan['regions'].map { |region| region['encounters'] })
    restored = Marshal.load(Marshal.dump(@plan))
    assert_equal lists, World.assign_species(restored)['regions'].map { |region| region['encounters'] }
    legacy = { 'seed' => 123, 'regions' => Array.new(16) { { 'biome' => 'grassland' } } }
    assert_equal lists, World.assign_species(legacy)['regions'].map { |region| region['encounters'] }
  end

  def test_daily_limit_blocks_before_generating_another_world
    Rules.ledger.start('second', @clock)
    Rules.ledger.start('third', @clock)
    $game_map.map_id = 101
    $player = Struct.new(:able_pokemon_count).new(1)
    World.stub(:generate, ->(*) { flunk('An unavailable outing must not generate a world') }) { World.depart }
    assert_empty $transfers
    assert_equal 0, Rules.ledger.free_remaining(@clock)
  end

  def test_declining_departure_does_not_spend_an_outing
    $game_map.map_id = 101
    $player = Struct.new(:able_pokemon_count).new(1)
    $confirm = false
    World.stub(:generate, ->(*) { flunk('A declined outing must not generate a world') }) { World.depart }
    assert_empty $transfers
    assert_equal 2, Rules.ledger.free_remaining(@clock)
  end
end
