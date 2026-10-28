# frozen_string_literal: true
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'

BUILDER = File.expand_path('../tools/build_arena_map.rb', __dir__)
# Load only Marshal type definitions, without running the generator.
eval(File.read(BUILDER).split('MAP_ID = 100').first, TOPLEVEL_BINDING, BUILDER)

class WorldMapsTest < Minitest::Test
  def fields(klass, **values)
    object = klass.allocate
    values.each { |key, value| object.instance_variable_set("@#{key}", value) }
    object
  end

  def entry(script = nil, transfer = nil)
    fields(RPG::EventCommand, code: transfer ? 201 : 355,
           parameters: transfer || [script], indent: 0)
  end

  def fixture_map(events = {})
    fields(RPG::Map, width: 25, height: 19, tileset_id: 1, events: events,
           data: Table.build(25, 19, 3) { |x, y, z| z == 0 ? (x < 4 && y < 4 ? 2 : 1) : 0 })
  end

  def fixture_event(id, x, y, commands)
    fields(RPG::Event, id: id, name: 'Fixture', x: x, y: y, pages: [
      fields(RPG::Event::Page, list: commands,
             graphic: fields(RPG::Event::Page::Graphic, character_name: 'door', tile_id: 0))
    ])
  end

  def write(name, value)
    File.binwrite(File.join(@data, name), Marshal.dump(value))
  end

  def read(name)
    Marshal.load(File.binread(File.join(@data, name)))
  end

  def setup
    @project = Dir.mktmpdir('arena-world-')
    @data = File.join(@project, 'Data')
    FileUtils.mkdir_p(@data)
    write('Map002.rxdata', fixture_map(1 => fixture_event(1, 12, 5, [entry(nil, [0, 3, 5, 5, 2]) ])))
    write('Map003.rxdata', fixture_map(1 => fixture_event(1, 5, 6, [entry(nil, [0, 2, 12, 6, 2]) ])))
    write('Map009.rxdata', fixture_map(1 => fixture_event(1, 10, 4, [entry('pbPokeCenterPC') ])))
    tone = Tone._load([1.0, 2.0, 3.0, 4.0].pack('d4'))
    fade = fields(RPG::EventCommand, code: 223, parameters: [tone, 6], indent: 0)
    write('Map001.rxdata', fixture_map(1 => fixture_event(1, 0, 0, [entry('original_intro'), fade, fields(RPG::EventCommand, code: 0, parameters: [], indent: 0)])))
    write('MapInfos.rxdata', {})
    table = Table.build(4, 1, 1) { |_x, _y, _z| 0 }
    terrain = Table.build(4, 1, 1) { |x, _y, _z| x == 2 ? 2 : 0 }
    write('Tilesets.rxdata', [nil, fields(RPG::Tileset, passages: table, priorities: table, terrain_tags: terrain)])
  end

  def teardown
    FileUtils.remove_entry(@project)
  end

  def generate
    Open3.capture3(RbConfig.ruby, '--disable-gems', '-e',
      'path = ARGV.shift; eval(File.read(path), TOPLEVEL_BINDING, path)', BUILDER, @project)
  end

  def scripts(map)
    map.instance_variable_get(:@events).values.flat_map do |event|
      event.instance_variable_get(:@pages).flat_map do |page|
        page.instance_variable_get(:@list).select { |command| command.instance_variable_get(:@code) == 355 }
            .map { |command| command.instance_variable_get(:@parameters).first }
      end
    end
  end

  def test_generation_connects_world_and_preserves_original_maps_on_rerun
    original = File.binread(File.join(@data, 'Map002.rxdata'))
    2.times do
      output, error, status = generate
      assert status.success?, output + error
    end
    assert_equal original, File.binread(File.join(@data, 'Map002.rxdata'))
    intro = read('Map001.rxdata')
    assert_equal 1, scripts(intro).count('ArenaDemo.quick_start')
    commands = intro.instance_variable_get(:@events)[1].instance_variable_get(:@pages).first.instance_variable_get(:@list)
    tone = commands.find { |entry| entry.instance_variable_get(:@code) == 223 }.instance_variable_get(:@parameters).first
    assert_equal [1.0, 2.0, 3.0, 4.0].pack('d4'), tone._dump(0), 'Preserve native RGSS tone payloads in the original intro'
    assert_equal '12,6,2', File.read(File.join(@data, 'ArenaDemoTownStart.txt'))
    assert_includes scripts(read('Map101.rxdata')), 'ArenaDemo.enter_entrance'
    assert_includes scripts(read('Map101.rxdata')), 'ArenaDemo.trail_scout'
    assert_includes scripts(read('Map101.rxdata')), 'ArenaDemo.town_guide'
    foyer = read('Map102.rxdata')
    %w[ArenaDemo.enter_town ArenaDemo.enter_training_room ArenaDemo.storage_pc ArenaDemo.multiplayer_attendant].each do |script|
      assert_includes scripts(foyer), script
    end
    arena = read('Map100.rxdata')
    assert_includes scripts(arena), 'ArenaDemo.exit_training_room'
    # The south exit is open; every object keeps its existing event ID.
    events = arena.instance_variable_get(:@events)
    assert_equal 1, events.values.count { |event| [event.instance_variable_get(:@x), event.instance_variable_get(:@y)] == [12, 18] }
    assert_equal (3..8).to_a, events.keys.select { |id| (3..8).include?(id) }.sort
    assert_equal 'Arena Entrance', read('MapInfos.rxdata')[102].instance_variable_get(:@name)
    assert_includes scripts(read('Map103.rxdata')), 'ArenaDemo.return_from_route'
    trail = read('Map103.rxdata').instance_variable_get(:@data)
    assert_equal 2, trail[5, 7, 0], 'Grass must retain the local encounter terrain'
    assert_equal 1, trail[12, 7, 0], 'The central trail stays clear of encounters'
  end

  def test_existing_map_id_is_not_overwritten
    write('MapInfos.rxdata', { 102 => fields(RPG::MapInfo, name: 'User map') })
    write('Map102.rxdata', :user_data)
    _output, error, status = generate
    refute status.success?
    assert_includes error, 'refusing to overwrite'
    assert_equal :user_data, read('Map102.rxdata')
  end
end
