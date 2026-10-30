require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'
BUILDER = File.expand_path('../tools/build_arena_map.rb', __dir__)
eval(File.read(BUILDER).split('MAP_ID = 100').first, TOPLEVEL_BINDING, BUILDER)

class ExpeditionMapBuildTest < Minitest::Test
  def fields(type, **values)
    object = type.allocate
    values.each { |key, value| object.instance_variable_set("@#{key}", value) }
    object
  end
  def command(code, parameters = [])
    fields(RPG::EventCommand, code: code, parameters: parameters, indent: 0)
  end
  def event(commands)
    fields(RPG::Event, id: 1, name: 'Fixture', x: 12, y: 5, pages: [
      fields(RPG::Event::Page, list: commands,
             graphic: fields(RPG::Event::Page::Graphic, character_name: 'door', tile_id: 0))
    ])
  end
  def map(events)
    fields(RPG::Map, width: 25, height: 19, tileset_id: 1, events: events,
      data: Table.build(25, 19, 3) { |x, y, z| z != 0 ? 0 : (x < 4 && y < 4 ? 402 : (y == 10 ? 403 : 401)) })
  end
  def write(name, value); File.binwrite(File.join(@data, name), Marshal.dump(value)); end
  def read(name); Marshal.load(File.binread(File.join(@data, name))); end
  def setup
    @project = Dir.mktmpdir('arena-expedition-build-', File.expand_path('../..', __dir__))
    @data = File.join(@project, 'Data')
    FileUtils.mkdir_p(@data)
    FileUtils.mkdir_p(File.join(@project, 'Graphics/Tilesets'))
    File.write(File.join(@project, 'Graphics/Tilesets/Fixture.png'), '')
    write('Map002.rxdata', map(1 => event([command(201, [0, 3, 5, 5, 2]), command(0)])))
    write('Map003.rxdata', map(1 => event([command(201, [0, 2, 12, 6, 2]), command(0)])))
    write('Map009.rxdata', map(1 => event([command(355, ['pbPokeCenterPC']), command(0)])))
    write('Map001.rxdata', map(1 => event([command(355, ['original_intro']), command(0)])))
    write('MapInfos.rxdata', {})
    zeros = Table.build(405, 1, 1) { 0 }
    terrain = Table.build(405, 1, 1) { |x| x == 402 ? 2 : 0 }
    write('Tilesets.rxdata', [nil, fields(RPG::Tileset, tileset_name: 'Fixture',
      passages: zeros, priorities: zeros, terrain_tags: terrain)])
  end
  def teardown; FileUtils.remove_entry(@project); end
  def generate
    assert File.file?(File.join(@project, 'Graphics/Tilesets/Fixture.png')), @project
    assert_equal 1, Dir.glob(File.join(File.expand_path(@project), 'Graphics', 'Tilesets', 'Fixture.*')).length, @project
    Open3.capture3(RbConfig.ruby, BUILDER, @project)
  end
  def scripts(map)
    map.instance_variable_get(:@events).values.flat_map do |event|
      event.instance_variable_get(:@pages).flat_map do |page|
        page.instance_variable_get(:@list).select { |cmd| cmd.instance_variable_get(:@code) == 355 }
          .map { |cmd| cmd.instance_variable_get(:@parameters)[0] }
      end
    end
  end
  def test_builds_repeatable_source_templates_and_village_gate_without_changing_upstream
    source = File.binread(File.join(@data, 'Map002.rxdata'))
    2.times do
      out, err, status = generate
      assert status.success?, out + err
    end
    assert_equal source, File.binread(File.join(@data, 'Map002.rxdata'))
    assert_includes scripts(read('Map101.rxdata')), 'ArenaDemo::Expeditions.depart'
    assert_includes scripts(read('Map101.rxdata')), 'ArenaDemo::Expeditions.guide'
    assert_equal '16,12,8', File.read(File.join(@data, 'ArenaDemoTownStart.txt'))
    assert_equal({ 'ground' => [401, 0, 0], 'grass' => [402, 0, 0], 'path' => [403, 0, 0] }, read('ArenaExpeditionPalette.rxdata'))
    infos = read('MapInfos.rxdata')
    (110..125).each do |id|
      template = read(format('Map%03d.rxdata', id))
      assert_equal [64, 64], [template.instance_variable_get(:@width), template.instance_variable_get(:@height)]
      assert_empty template.instance_variable_get(:@events)
      assert_nil template.instance_variable_get(:@arena_expedition_region)
      assert_equal "Expedition Sector #{id - 109}", infos[id].instance_variable_get(:@name)
    end
    refute infos.key?(103)
  end
  def test_refuses_to_overwrite_an_unrelated_map_in_the_new_id_range
    write('MapInfos.rxdata', { 117 => fields(RPG::MapInfo, name: 'My custom route') })
    write('Map117.rxdata', :private_map)
    _, err, status = generate
    refute status.success?
    assert_includes err, 'refusing to overwrite'
    assert_equal :private_map, read('Map117.rxdata')
  end
end
