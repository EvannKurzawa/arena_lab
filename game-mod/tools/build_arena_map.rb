# frozen_string_literal: true

# Add the Arena Demo map to a private Essentials v21.1 project without needing
# RPG Maker XP. The map is derived locally from walkable Lappet Town (map 2).
# No upstream map/art assets are written to this source tree.

class Table
  attr_reader :payload

  def self._load(payload)
    object = allocate
    object.instance_variable_set(:@payload, payload)
    object
  end

  def _dump(_depth)
    @payload
  end

  def [](x, y = 0, z = 0)
    _, width, height, = @payload.unpack("V5")
    @payload.byteslice(20 + 2 * (x + y * width + z * width * height), 2).unpack1("v")
  end

  def self.build(width, height, layers)
    table = allocate
    values = []
    layers.times do |z|
      height.times do |y|
        width.times { |x| values << yield(x, y, z) }
      end
    end
    table.instance_variable_set(:@payload, [3, width, height, layers, values.length].pack("V5") + values.pack("v*"))
    table
  end
end

class Tone
  def self._load(payload)
    object = allocate
    object.instance_variable_set(:@payload, payload)
    object
  end

  def _dump(_depth)
    @payload
  end
end

class Color < Tone; end

module RPG
  class Map; end
  class MapInfo; end
  class Event; end
  class Event::Page; end
  class Event::Page::Condition; end
  class Event::Page::Graphic; end
  class EventCommand; end
  class MoveRoute; end
  class MoveCommand; end
  class AudioFile; end
  class Tileset; end
end

MAP_ID = 100
PROJECT = File.expand_path(ARGV.fetch(0, "."))
DATA_DIR = File.join(PROJECT, "Data")
SOURCE_MAP = File.join(DATA_DIR, "Map002.rxdata")
HOME_MAP = File.join(DATA_DIR, "Map003.rxdata")
DEST_MAP = File.join(DATA_DIR, format("Map%03d.rxdata", MAP_ID))
MAP_INFOS = File.join(DATA_DIR, "MapInfos.rxdata")
INTRO_MAP = File.join(DATA_DIR, "Map001.rxdata")
START_FILE = File.join(DATA_DIR, "ArenaDemoStart.txt")

abort "Expected a complete Essentials project (missing #{SOURCE_MAP})" unless File.file?(SOURCE_MAP)
abort "Missing map registry #{MAP_INFOS}" unless File.file?(MAP_INFOS)
abort "Missing intro map #{INTRO_MAP}" unless File.file?(INTRO_MAP)

def set_fields(object, values)
  values.each { |name, value| object.instance_variable_set(name, value) }
  object
end

def command(code, parameters = [], indent = 0)
  set_fields(RPG::EventCommand.allocate,
             :@code => code, :@parameters => parameters, :@indent => indent)
end

def event(id, name, x, y, character, script = nil)
  condition = set_fields(RPG::Event::Page::Condition.allocate,
                         :@switch1_valid => false, :@switch1_id => 1,
                         :@switch2_valid => false, :@switch2_id => 1,
                         :@variable_valid => false, :@variable_id => 1,
                         :@variable_value => 0, :@self_switch_valid => false,
                         :@self_switch_ch => "A")
  graphic = set_fields(RPG::Event::Page::Graphic.allocate,
                        :@tile_id => 0, :@character_name => character,
                        :@character_hue => 0, :@direction => 2, :@pattern => 1,
                        :@opacity => 255, :@blend_type => 0)
  move_command = set_fields(RPG::MoveCommand.allocate,
                            :@code => 0, :@parameters => [])
  move_route = set_fields(RPG::MoveRoute.allocate,
                          :@list => [move_command], :@repeat => true,
                          :@skippable => false)
  list = []
  list << command(355, [script]) if script
  list << command(0)
  page = set_fields(RPG::Event::Page.allocate,
                    :@condition => condition, :@graphic => graphic,
                    :@move_type => 0, :@move_speed => 3, :@move_frequency => 3,
                    :@move_route => move_route, :@walk_anime => character.start_with?("trainer_"),
                    :@step_anime => false, :@direction_fix => !character.start_with?("trainer_"),
                    :@through => false, :@always_on_top => false,
                    :@trigger => 0, :@list => list)
  set_fields(RPG::Event.allocate,
             :@id => id, :@name => name, :@x => x, :@y => y, :@pages => [page])
end

# Find the same Lappet Town tile used by the house's exit door, rather than
# guessing a coordinate or using the house map as the arena base.
def transfer_point(map, target_map_id)
  events = map.instance_variable_get(:@events) || {}
  events.each_value do |event_data|
    pages = event_data.instance_variable_get(:@pages) || []
    pages.each do |page|
      commands = page.instance_variable_get(:@list) || []
      commands.each do |entry|
        next if entry.instance_variable_get(:@code) != 201
        parameters = entry.instance_variable_get(:@parameters) || []
        next if parameters[0] != 0 || parameters[1].to_i != target_map_id
        direction = parameters[4].to_i
        direction = 2 unless [2, 4, 6, 8].include?(direction)
        return [parameters[2].to_i, parameters[3].to_i, direction]
      end
    end
  end
  return nil
end

start = [12, 16, 8]
File.binwrite(START_FILE, start.join(","))

map = Marshal.load(File.binread(SOURCE_MAP))
# Reuse a real, fully passable ground stack from the installed tileset, but
# construct a new arena rather than copying buildings or village events.
tilesets = Marshal.load(File.binread(File.join(DATA_DIR, "Tilesets.rxdata")))
tileset = tilesets[map.instance_variable_get(:@tileset_id)]
passages = tileset.instance_variable_get(:@passages)
priorities = tileset.instance_variable_get(:@priorities)
terrain = tileset.instance_variable_get(:@terrain_tags)
source = map.instance_variable_get(:@data)
grounds = Hash.new(0)
map.instance_variable_get(:@height).times do |y|
  map.instance_variable_get(:@width).times do |x|
    stack = 3.times.map { |z| source[x, y, z] }
    next if stack[0] == 0
    next unless stack.all? { |tile| tile == 0 || (passages[tile] & 15 == 0 && priorities[tile] == 0 && terrain[tile] == 0) }
    grounds[stack] += 1
  end
end
ground = grounds.max_by { |_stack, count| count }&.first
abort "No ordinary passable ground found in the local town tileset" unless ground
map.instance_variable_set(:@width, 25)
map.instance_variable_set(:@height, 19)
map.instance_variable_set(:@data, Table.build(25, 19, 3) { |_x, _y, z| ground[z] })
map.instance_variable_set(:@events, {
  1 => event(1, "Arena guide", 10, 16, "trainer_SUPERNERD", "ArenaDemo.arena_reception"),
  2 => event(2, "Arena trainer", 12, 4, "trainer_YOUNGSTER", "ArenaDemo.challenge_trainer"),
  3 => event(3, "Boulder obstacle", 5, 6, "Object boulder"),
  4 => event(4, "Rock obstacle", 5, 9, "Object rock"),
  5 => event(5, "Tree decoration", 5, 12, "Object tree 1"),
  6 => event(6, "Boulder obstacle 2", 19, 6, "Object boulder"),
  7 => event(7, "Rock obstacle 2", 19, 9, "Object rock"),
  8 => event(8, "Tree decoration 2", 19, 12, "Object tree 1")
})
events = map.instance_variable_get(:@events)
# A visible solid perimeter leaves the interior and entrance lane walkable.
25.times do |x|
  [0, 18].each do |y|
    next if x == 12 && y == 18
    id = events.keys.max + 1
    events[id] = event(id, "Arena boundary", x, y, "Object boulder")
  end
end
(1...18).each do |y|
  [0, 24].each do |x|
    id = events.keys.max + 1
    events[id] = event(id, "Arena boundary", x, y, "Object boulder")
  end
end

# The arena keeps map 100 and its object IDs for existing saves/multiplayer.
# A touch exit connects its south entrance to the new offline foyer.
def touch_portal(id, name, x, y, script)
  portal = event(id, name, x, y, "", script)
  page = portal.instance_variable_get(:@pages).first
  page.instance_variable_set(:@trigger, 1)
  page.instance_variable_set(:@through, true)
  portal
end
exit_id = events.keys.max + 1
events[exit_id] = touch_portal(exit_id, "Arena exit", 12, 18, "ArenaDemo.exit_training_room")

# Reusable runtime placement slots. The editor saves only inventory item IDs
# and tile coordinates; these blank events provide render/collision slots
# without writing user layouts into map binaries or game scripts.
80.times do |index|
  id = 200 + index
  events[id] = event(id, "Arena furniture slot", 1, 1, "")
end
16.times do |index|
  id = 300 + index
  events[id] = event(id, "Arena trainer slot", 1, 1, "")
end

# Reuse the local town's artwork, replacing tutorial/story events with a
# deliberately small offline hub. Locate its real house door and exit spawn.
town = Marshal.load(File.binread(SOURCE_MAP))
home = Marshal.load(File.binread(HOME_MAP))
town_start = transfer_point(home, 2)
abort "Cannot locate the house's town exit" unless town_start
door = town.instance_variable_get(:@events).values.find do |candidate|
  probe = set_fields(RPG::Map.allocate, :@events => { 1 => candidate })
  transfer_point(probe, 3)
end
abort "Cannot locate the town's house entrance" unless door
door.instance_variable_set(:@id, 1)
door.instance_variable_set(:@name, "Arena building entrance")
# Keep the original door artwork, but remove intro/switch conditions and the
# upstream movement route/transfer sequence.
door_page = door.instance_variable_get(:@pages).first
door_page.instance_variable_set(:@condition,
  event(1, "", 0, 0, "").instance_variable_get(:@pages).first.instance_variable_get(:@condition))
door_page.instance_variable_set(:@list, [command(355, ["ArenaDemo.enter_entrance"]), command(0)])
door.instance_variable_set(:@pages, [door_page])
town.instance_variable_set(:@events, { 1 => door })
# Pick reachable, open ground for the guide and trail scout, rather than guessing
# coordinates that might be inside a local building or blocking its doorway.
town_tiles = town.instance_variable_get(:@data)
town_width, town_height = town.instance_variable_get(:@width), town.instance_variable_get(:@height)
walkable = lambda do |x, y|
  next false unless x.between?(0, town_width - 1) && y.between?(0, town_height - 1)
  stack = 3.times.map { |z| town_tiles[x, y, z] }
  stack[0] != 0 && stack.all? { |tile| tile == 0 || passages[tile] & 15 == 0 }
end
queue = [town_start.first(2)]
seen = { queue.first => true }
sites = []
until queue.empty?
  x, y = queue.shift
  neighbors = [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]].select { |nx, ny| walkable.call(nx, ny) }
  distance = (x - town_start[0]).abs + (y - town_start[1]).abs
  door_distance = (x - door.instance_variable_get(:@x)).abs + (y - door.instance_variable_get(:@y)).abs
  sites << [x, y] if distance >= 2 && door_distance >= 2 && neighbors.length >= 3
  neighbors.each do |point|
    next if seen[point]
    seen[point] = true
    queue << point
  end
end
guide_site = sites.first
scout_site = sites.find { |point| guide_site && (point[0] - guide_site[0]).abs + (point[1] - guide_site[1]).abs >= 3 }
abort "Cannot find reachable town guide/scout positions" unless guide_site && scout_site
town.instance_variable_get(:@events)[2] = event(2, "Town keeper", *guide_site, "trainer_SUPERNERD", "ArenaDemo.town_guide")
town.instance_variable_get(:@events)[3] = event(3, "Trail scout", *scout_site, "trainer_YOUNGSTER", "ArenaDemo.trail_scout")
File.binwrite(File.join(DATA_DIR, "ArenaDemoTownStart.txt"), town_start.join(","))

# Reuse an actual local grass stack with Essentials' grass terrain tag.
grass = nil
town_height.times do |y|
  town_width.times do |x|
    stack = 3.times.map { |z| town_tiles[x, y, z] }
    if stack.any? { |tile| tile != 0 && terrain[tile] == 2 } &&
       stack.all? { |tile| tile == 0 || passages[tile] & 15 == 0 }
      grass = stack
      break
    end
  end
  break if grass
end
unless grass
  # Some private towns contain no grass. Find a matching stack in another
  # installed map using the same tileset, rather than inventing tile IDs.
  Dir.glob(File.join(DATA_DIR, "Map[0-9][0-9][0-9].rxdata")).each do |path|
    next if File.basename(path).match?(/Map10[0-3]\.rxdata/)
    candidate = Marshal.load(File.binread(path))
    next unless candidate.instance_variable_get(:@tileset_id) == town.instance_variable_get(:@tileset_id)
    data = candidate.instance_variable_get(:@data)
    candidate.instance_variable_get(:@height).times do |y|
      candidate.instance_variable_get(:@width).times do |x|
        stack = 3.times.map { |z| data[x, y, z] }
        if stack.any? { |tile| tile != 0 && terrain[tile] == 2 } &&
           stack.all? { |tile| tile == 0 || passages[tile] & 15 == 0 }
          grass = stack
          break
        end
      end
      break if grass
    end
    break if grass
  end
end
abort "No walkable tall-grass stack found in installed maps with the town tileset" unless grass
route = Marshal.load(File.binread(SOURCE_MAP))
route.instance_variable_set(:@width, 25)
route.instance_variable_set(:@height, 19)
route.instance_variable_set(:@data, Table.build(25, 19, 3) do |x, y, z|
  in_grass = ((3..9).include?(x) || (15..21).include?(x)) && (4..13).include?(y)
  (in_grass ? grass : ground)[z]
end)
route_events = { 1 => touch_portal(1, "Return to town", 12, 18, "ArenaDemo.return_from_route") }
25.times do |x|
  [0, 18].each do |y|
    next if [x, y] == [12, 18]
    id = route_events.keys.max + 1
    route_events[id] = event(id, "Trail boundary", x, y, "Object tree 1")
  end
end
(1...18).each do |y|
  [0, 24].each do |x|
    id = route_events.keys.max + 1
    route_events[id] = event(id, "Trail boundary", x, y, "Object tree 1")
  end
end
route.instance_variable_set(:@events, route_events)

# Make a compact foyer from real indoor floor and PC tiles. No asset copies
# enter this repository; all generated maps stay in the private game project.
interior = Marshal.load(File.binread(File.join(DATA_DIR, "Map009.rxdata")))
interior_source = interior.instance_variable_get(:@data)
indoor_tileset = tilesets[interior.instance_variable_get(:@tileset_id)]
indoor_passages = indoor_tileset.instance_variable_get(:@passages)
indoor_priorities = indoor_tileset.instance_variable_get(:@priorities)
floors = Hash.new(0)
interior.instance_variable_get(:@height).times do |y|
  interior.instance_variable_get(:@width).times do |x|
    stack = 3.times.map { |z| interior_source[x, y, z] }
    next if stack[0] == 0
    next unless stack.all? { |tile| tile == 0 || (indoor_passages[tile] & 15 == 0 && indoor_priorities[tile] == 0) }
    floors[stack] += 1
  end
end
floor = floors.max_by { |_stack, count| count }&.first
abort "No passable indoor floor found" unless floor
pc = interior.instance_variable_get(:@events).values.find do |candidate|
  candidate.instance_variable_get(:@pages).any? do |page|
    page.instance_variable_get(:@list).any? do |entry|
      entry.instance_variable_get(:@parameters).any? { |value| value.is_a?(String) && value.include?("pbPokeCenterPC") }
    end
  end
end
abort "Cannot locate the local Pokemon Center PC" unless pc
pc_x, pc_y = pc.instance_variable_get(:@x), pc.instance_variable_get(:@y)
pc_stack = 3.times.map { |z| interior_source[pc_x, pc_y, z] }
pc_top = pc_y > 0 ? 3.times.map { |z| interior_source[pc_x, pc_y - 1, z] } : floor
interior.instance_variable_set(:@width, 15)
interior.instance_variable_set(:@height, 13)
interior.instance_variable_set(:@data, Table.build(15, 13, 3) do |x, y, z|
  stack = if x == 10 && y == 4
            pc_stack
          elsif x == 10 && y == 3
            pc_top
          else
            floor
          end
  stack[z]
end)
foyer_events = {
  1 => touch_portal(1, "To town", 7, 12, "ArenaDemo.enter_town"),
  2 => event(2, "Arena door", 7, 2, "", "ArenaDemo.enter_training_room"),
  3 => event(3, "Pokemon storage PC", 10, 4, "", "ArenaDemo.storage_pc"),
  4 => event(4, "Multiplayer attendant", 4, 5, "trainer_SUPERNERD", "ArenaDemo.multiplayer_attendant"),
  5 => event(5, "PC housing", 10, 3, "")
}
# Reuse a real door graphic so the north interaction is visible.
foyer_events[2].instance_variable_get(:@pages).first.instance_variable_set(:@graphic,
  Marshal.load(Marshal.dump(door_page.instance_variable_get(:@graphic))))
foyer_events[3].instance_variable_get(:@pages).first.instance_variable_set(:@graphic,
  Marshal.load(Marshal.dump(pc.instance_variable_get(:@pages).first.instance_variable_get(:@graphic))))
15.times do |x|
  [0, 12].each do |y|
    next if x == 7 && y == 12
    id = foyer_events.keys.max + 1
    foyer_events[id] = event(id, "Foyer boundary", x, y, "Object boulder")
  end
end
(1...12).each do |y|
  [0, 14].each do |x|
    id = foyer_events.keys.max + 1
    foyer_events[id] = event(id, "Foyer boundary", x, y, "Object boulder")
  end
end
interior.instance_variable_set(:@events, foyer_events)

map_infos = Marshal.load(File.binread(MAP_INFOS))
if map_infos.key?(MAP_ID) && map_infos[MAP_ID].instance_variable_get(:@name) != "Arena Demo"
  abort "Map ID #{MAP_ID} is already used. Change MAP_ID in both ArenaDemo and this generator."
end
info = set_fields(RPG::MapInfo.allocate,
                  :@name => "Arena Demo", :@parent_id => 0, :@order => 100,
                  :@expanded => false, :@scroll_x => 320, :@scroll_y => 240)
map_infos[MAP_ID] = info
{ 101 => ["Arena Town", town], 102 => ["Arena Entrance", interior], 103 => ["Founders' Path", route] }.each do |id, (name, generated)|
  if map_infos.key?(id) && map_infos[id].instance_variable_get(:@name) != name
    abort "Map ID #{id} is already used; refusing to overwrite it."
  end
  map_infos[id] = set_fields(RPG::MapInfo.allocate,
    :@name => name, :@parent_id => 0, :@order => id, :@expanded => false,
    :@scroll_x => 320, :@scroll_y => 240)
end

# Put a short, explicit choice at the start of a new game. The full Essentials
# intro remains available; the quick-start branch gives a battle-ready party
# and transfers directly into the arena demo.
intro_map = Marshal.load(File.binread(INTRO_MAP))
intro_events = intro_map.instance_variable_get(:@events)
intro_event = intro_events && intro_events[1]
abort "Map 1 is missing its Intro event (event ID 1)" unless intro_event
intro_pages = intro_event.instance_variable_get(:@pages)
intro_page = intro_pages && intro_pages[0]
abort "Map 1 Intro event has no first page" unless intro_page
intro_commands = intro_page.instance_variable_get(:@list)
unless intro_commands.any? { |entry| entry.instance_variable_get(:@code) == 355 &&
                                      entry.instance_variable_get(:@parameters)&.first == "ArenaDemo.quick_start" }
  old_list = intro_commands
  abort "Map 1 Intro event has no commands" if old_list.empty?
  original_intro = old_list[0...-1]
  original_intro.each do |entry|
    entry.instance_variable_set(:@indent, entry.instance_variable_get(:@indent).to_i + 1)
  end
  intro_page.instance_variable_set(:@list, [
    command(102, [["Skip intro and start Arena Demo", "Play the full intro"], 1, 0]),
    command(402, [0, "Skip intro and start Arena Demo"]),
    command(355, ["ArenaDemo.quick_start"], 1),
    command(402, [1, "Play the full intro"]),
    *original_intro,
    command(404),
    command(0)
  ])
  File.binwrite(INTRO_MAP, Marshal.dump(intro_map))
end

File.binwrite(DEST_MAP, Marshal.dump(map))
File.binwrite(File.join(DATA_DIR, "Map101.rxdata"), Marshal.dump(town))
File.binwrite(File.join(DATA_DIR, "Map102.rxdata"), Marshal.dump(interior))
File.binwrite(File.join(DATA_DIR, "Map103.rxdata"), Marshal.dump(route))
File.binwrite(MAP_INFOS, Marshal.dump(map_infos))
puts "Built #{DEST_MAP}: new 25x19 training yard using local passable ground; registered map #{MAP_ID}."
puts "Arena start: #{start.join(',')}. Trainer: 12,4. Medic: 10,16. Customize from the pause menu."
puts "Added an intro skip choice to #{INTRO_MAP} (or kept the existing choice)."
puts "Built offline town (101) -> entrance with storage PC (102) -> arena (100)."
puts "Built Founders' Path (103); guide at #{guide_site.join(',')}, trail scout at #{scout_site.join(',')}."
