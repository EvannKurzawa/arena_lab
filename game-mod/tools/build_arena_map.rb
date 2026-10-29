# frozen_string_literal: true

# Add the Arena Lab maps to a private Essentials v21.1 project without needing
# RPG Maker XP. The village is newly composed; only its tile set is reused.
# No upstream map/art assets are written to this source tree.
require "fileutils"
require_relative '../Plugins/ArenaDemo/000_ArenaMusicSelection'

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
GROUND_FILE = File.join(DATA_DIR, "ArenaDemoGround.txt")
ARENA_FACADE_SOURCE = File.expand_path("../Graphics/Characters/$ArenaFacade.png", __dir__)
ARENA_FACADE_DEST = File.join(PROJECT, "Graphics", "Characters", "$ArenaFacade.png")
VILLAGE_HOUSE_SOURCE = File.expand_path("../Graphics/Characters/$VillageHouse.png", __dir__)
VILLAGE_HOUSE_DEST = File.join(PROJECT, "Graphics", "Characters", "$VillageHouse.png")

abort "Expected a complete Essentials project (missing #{SOURCE_MAP})" unless File.file?(SOURCE_MAP)
abort "Missing map registry #{MAP_INFOS}" unless File.file?(MAP_INFOS)
abort "Missing intro map #{INTRO_MAP}" unless File.file?(INTRO_MAP)
abort "Missing original Arena Village facade #{ARENA_FACADE_SOURCE}" unless File.file?(ARENA_FACADE_SOURCE)
abort "Missing matching Arena Village house sprite #{VILLAGE_HOUSE_SOURCE}" unless File.file?(VILLAGE_HOUSE_SOURCE)
FileUtils.mkdir_p(File.dirname(ARENA_FACADE_DEST))
FileUtils.copy_file(ARENA_FACADE_SOURCE, ARENA_FACADE_DEST)
abort "Missing matching Arena Village house sprite #{VILLAGE_HOUSE_SOURCE}" unless File.file?(VILLAGE_HOUSE_SOURCE)
FileUtils.copy_file(VILLAGE_HOUSE_SOURCE, VILLAGE_HOUSE_DEST)
FileUtils.copy_file(VILLAGE_HOUSE_SOURCE, VILLAGE_HOUSE_DEST)

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

def follower_anchor
  anchor = event(900, "Arena follower anchor", 0, 0, "")
  anchor.instance_variable_get(:@pages).first.instance_variable_set(:@through, true)
  anchor
end

def resolve_arena_sign_graphic(source_map)
  # Essentials signposts are commonly tiles, not an "Object sign" charset.
  source_map.instance_variable_get(:@events).each_value do |candidate|
    next unless candidate.instance_variable_get(:@name).to_s.match?(/sign/i)
    x, y = candidate.instance_variable_get(:@x), candidate.instance_variable_get(:@y)
    data = source_map.instance_variable_get(:@data)
    tile = [2, 1].map { |layer| data[x, y, layer] }.find { |id| id.to_i >= 384 }
    return ['', tile] if tile
  end
  sign = Dir.glob(File.join(PROJECT, 'Graphics', 'Characters', '*')).sort.find do |path|
    File.file?(path) && File.basename(path).match?(/sign.*\.(png|bmp)\z/i)
  end
  return [File.basename(sign, File.extname(sign)), 0] if sign
  # A readable stone marker uses the same installed asset as arena boundaries.
  ['Object boulder', 0]
end

def arena_sign_event(id, x, y, source_map)
  character, tile = resolve_arena_sign_graphic(source_map)
  sign = event(id, 'Arena sign', x, y, character, 'ArenaDemo.arena_sign')
  sign.instance_variable_get(:@pages).first.instance_variable_get(:@graphic).instance_variable_set(:@tile_id, tile)
  sign
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

field_x = (100 - 25) / 2
field_y = (100 - 25) / 2
start = [field_x + 12, field_y + 16, 8]
File.binwrite(START_FILE, start.join(","))

map = Marshal.load(File.binread(SOURCE_MAP))
# These maps are generated from Essentials map templates. Preserve each
# template's BGM and explicitly enable map autoplay so transfers start it.
def enable_map_music(map)
  bgm = map.instance_variable_get(:@bgm)
  # Indoor templates may intentionally have no music. Give generated maps an
  # installed exploration track instead of silently inheriting that blank.
  files = Dir.glob(File.join(PROJECT, 'Audio', 'BGM', '*')).select do |path|
    File.file?(path) && path.match?(/\.(ogg|wav|mp3|flac|opus|midi?|wma)\z/i)
  end
  name = bgm && bgm.instance_variable_get(:@name).to_s
  track = ArenaDemo::MusicSelection.select(files, name)
  bgm = RPG::AudioFile.allocate
  bgm.instance_variable_set(:@name, track ? File.basename(track, File.extname(track)) : '')
  bgm.instance_variable_set(:@volume, 80)
  bgm.instance_variable_set(:@pitch, 100)
  map.instance_variable_set(:@bgm, bgm)
  map.instance_variable_set(:@autoplay_bgm, !!track)
end
enable_map_music(map)
# Reuse a real, fully passable ground stack from the installed tileset, but
# construct a new arena rather than copying buildings or village events.
tilesets = Marshal.load(File.binread(File.join(DATA_DIR, "Tilesets.rxdata")))
tileset = tilesets[map.instance_variable_get(:@tileset_id)]
abort "Map 2 references a missing tileset" unless tileset
tileset_name = tileset.instance_variable_get(:@tileset_name).to_s
tileset_images = Dir.glob(File.join(PROJECT, "Graphics", "Tilesets", "#{tileset_name}.*"))
abort "Arena tileset image is missing: Graphics/Tilesets/#{tileset_name}.*" if tileset_images.empty?
passages = tileset.instance_variable_get(:@passages)
priorities = tileset.instance_variable_get(:@priorities)
terrain = tileset.instance_variable_get(:@terrain_tags)
source = map.instance_variable_get(:@data)
grounds = Hash.new(0)
map.instance_variable_get(:@height).times do |y|
  map.instance_variable_get(:@width).times do |x|
    stack = 3.times.map { |z| source[x, y, z] }
    next if stack[0] < 48   # Essentials renders tile IDs 0..47 as blank
    next unless stack.all? { |tile| tile == 0 || (tile >= 48 && passages[tile] & 15 == 0 && priorities[tile] == 0 && terrain[tile] == 0) }
    grounds[stack] += 1
  end
end
ground = grounds.max_by { |_stack, count| count }&.first
abort "No ordinary passable ground found in the local town tileset" unless ground
abort "Selected ground tile is not renderable by Essentials: #{ground.inspect}" if ground[0] < 48
File.binwrite(GROUND_FILE, ground.join(","))
map.instance_variable_set(:@width, 100)
map.instance_variable_set(:@height, 100)
map.instance_variable_set(:@data, Table.build(100, 100, 3) do |x, y, z|
  (x >= field_x && x < field_x + 25 && y >= field_y && y < field_y + 25) ? ground[z] : 0
end)
map.instance_variable_set(:@events, {
  1 => event(1, "Arena guide", field_x + 10, field_y + 16, "trainer_SUPERNERD", "ArenaDemo.arena_reception"),
  2 => event(2, "Arena trainer", field_x + 12, field_y + 4, "trainer_YOUNGSTER", "ArenaDemo.challenge_trainer"),
  3 => event(3, "Boulder obstacle", field_x + 5, field_y + 6, "Object boulder"),
  4 => event(4, "Rock obstacle", field_x + 5, field_y + 9, "Object rock"),
  5 => event(5, "Tree decoration", field_x + 5, field_y + 12, "Object tree 1"),
  6 => event(6, "Boulder obstacle 2", field_x + 19, field_y + 6, "Object boulder"),
  7 => event(7, "Rock obstacle 2", field_x + 19, field_y + 9, "Object rock"),
  8 => event(8, "Tree decoration 2", field_x + 19, field_y + 12, "Object tree 1")
})
events = map.instance_variable_get(:@events)
# Following Pokemon EX turns this invisible map event into the Essentials-native
# walking follower. Keep it as a dedicated anchor on all four Arena Lab maps.
events[900] = follower_anchor

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
arena_return_door = touch_portal(exit_id, "Arena return door", field_x + 12, field_y + 18, "ArenaDemo.exit_training_room")
events[exit_id] = arena_return_door

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
enable_map_music(town)
home = Marshal.load(File.binread(HOME_MAP))
town_start = transfer_point(home, 2)
abort "Cannot locate the house's town exit" unless town_start
door = town.instance_variable_get(:@events).values.find do |candidate|
  probe = set_fields(RPG::Map.allocate, :@events => { 1 => candidate })
  transfer_point(probe, 3)
end
abort "Cannot locate the town's house entrance" unless door
door.instance_variable_set(:@id, 1)
door.instance_variable_set(:@name, "Village house entrance")
# Keep this original home door and its transfer intact. The arena gets a new
# entrance event in the village center instead of taking over the upper-left house.
door_page = door.instance_variable_get(:@pages).first
foyer_door_graphic = Marshal.load(Marshal.dump(door_page.instance_variable_get(:@graphic)))
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
center_target = [town_width / 2.0, town_height / 2.0 + 1.5]
arena_candidates = sites.select do |x, y|
  next false if [guide_site, scout_site, town_start.first(2)].include?([x, y])
  next false if (x - town_start[0]).abs + (y - town_start[1]).abs < 5
  # Reserve an unobstructed 5x4-tile footprint, not just an open doorway tile.
  (x - 2..x + 2).all? do |fx|
    (y - 3..y).all? { |fy| walkable.call(fx, fy) }
  end
end
arena_site = arena_candidates.min_by do |x, y|
  ((x - center_target[0])**2 + (y - center_target[1])**2)
end
abort "Cannot find a central, reachable Arena Village site" unless arena_site
town_events = town.instance_variable_get(:@events)
town_events[2] = event(2, "Town keeper", *guide_site, "trainer_SUPERNERD", "ArenaDemo.town_guide")
town_events[3] = event(3, "Trail scout", *scout_site, "trainer_YOUNGSTER", "ArenaDemo.trail_scout")
# Put the stadium entrance in the middle of the village. Its facade sprite is
# five tiles wide and four tall, with its bottom-center tile at arena_site.
arena_building = event(5, "Village arena entrance", *arena_site, "$ArenaFacade", "ArenaDemo.enter_entrance")
arena_page = arena_building.instance_variable_get(:@pages).first
arena_page.instance_variable_set(:@always_on_top, true)
sign_site = sites.reject do |point|
  [guide_site, scout_site, town_start.first(2), arena_site].include?(point) ||
    (point[0] - arena_site[0]).abs + (point[1] - arena_site[1]).abs < 4
end.min_by { |x, y| (x - arena_site[0]).abs + (y - arena_site[1]).abs }
town_events[5] = arena_building
if sign_site
  town_events[4] = arena_sign_event(4, *sign_site, Marshal.load(File.binread(SOURCE_MAP)))
end
town_events[900] = follower_anchor
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
# Make a compact foyer from real indoor floor and PC tiles. No asset copies
# enter this repository; all generated maps stay in the private game project.
interior = Marshal.load(File.binread(File.join(DATA_DIR, "Map009.rxdata")))
enable_map_music(interior)
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
foyer_events[4].instance_variable_get(:@pages).first.instance_variable_set(:@always_on_top, true)
# Reuse a real door graphic so the north interaction is visible.
foyer_events[2].instance_variable_get(:@pages).first.instance_variable_set(:@graphic,
  Marshal.load(Marshal.dump(foyer_door_graphic)))
# Reuse this visible door charset for the arena's south exit. The exit remains
# a touch transfer, but now the player can see the doorway they should enter.
arena_return_door.instance_variable_get(:@pages).first.instance_variable_set(:@graphic,
  Marshal.load(Marshal.dump(foyer_events[2].instance_variable_get(:@pages).first.instance_variable_get(:@graphic))))
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
foyer_events[900] = follower_anchor

# Replace the old Lappet Town based layout with a newly composed Arena Village.
# Reuse only local ground/path/grass tile stacks and the source map's tileset ID.
town_source = Marshal.load(File.binread(SOURCE_MAP))
source_data = town_source.instance_variable_get(:@data)
source_width, source_height = town_source.instance_variable_get(:@width), town_source.instance_variable_get(:@height)
path_candidates = Hash.new(0)
source_height.times do |y|
  source_width.times do |x|
    stack = 3.times.map { |z| source_data[x, y, z] }
    next if stack == ground || stack[0] < 48
    next unless stack.all? { |tile| tile == 0 || (passages[tile] & 15 == 0 && priorities[tile] == 0 && terrain[tile] == 0) }
    path_candidates[stack] += 1
  end
end
path = path_candidates.max_by { |_stack, count| count }&.first || ground
town_width, town_height = 32, 24
town.instance_variable_set(:@width, town_width)
town.instance_variable_set(:@height, town_height)
town.instance_variable_set(:@data, Table.build(town_width, town_height, 3) do |x, y, z|
  in_grass = x.between?(23, 29) && y.between?(15, 20)
  road = y.between?(11, 13) || x.between?(14, 17)
  house_walk = ((x.between?(5, 9) || x.between?(22, 26)) && y.between?(5, 13))
  (in_grass ? grass : (road || house_walk ? path : ground))[z]
end)
town_events = {}
town_events[1] = event(1, "Village keeper", 12, 13, "trainer_SUPERNERD", "ArenaDemo.town_guide")
town_events[2] = event(2, "Grassland scout", 25, 14, "trainer_YOUNGSTER", "ArenaDemo.trail_scout")
arena_building = event(3, "Village arena entrance", 16, 11, "$ArenaFacade", "ArenaDemo.enter_entrance")
arena_building.instance_variable_get(:@pages).first.instance_variable_set(:@always_on_top, true)
town_events[3] = arena_building
town_events[4] = arena_sign_event(4, 19, 12, town_source)
town_events[5] = event(5, "West village house", 7, 7, "$VillageHouse", "ArenaDemo.village_house")
town_events[6] = event(6, "East village house", 25, 7, "$VillageHouse", "ArenaDemo.village_house")
town_events[7] = event(7, "South village house", 7, 18, "$VillageHouse", "ArenaDemo.village_house")
[[3, 4], [30, 4], [3, 20], [30, 20], [21, 17], [22, 17], [30, 15], [30, 16],
 [30, 17], [22, 15], [22, 16], [22, 18], [22, 19], [22, 20], [30, 18], [30, 19]].each_with_index do |(x, y), i|
  id = 20 + i
  town_events[id] = event(id, "Village tree", x, y, "Object tree 1")
end
town_events[8] = event(8, "Village resident", 10, 9, "trainer_LASS", "ArenaDemo.village_resident")
town_events[9] = event(9, "Village resident", 21, 9, "trainer_YOUNGSTER", "ArenaDemo.village_resident")
town_events[900] = follower_anchor
town.instance_variable_set(:@events, town_events)
town_start = [16, 12, 8]
File.binwrite(File.join(DATA_DIR, "ArenaDemoTownStart.txt"), town_start.join(","))

map_infos = Marshal.load(File.binread(MAP_INFOS))
old_route_name = map_infos[103]&.instance_variable_get(:@name)
if old_route_name == "Founders' Path"
  old_route = File.join(DATA_DIR, "Map103.rxdata")
  File.delete(old_route) if File.file?(old_route)
  map_infos.delete(103)
end
if map_infos.key?(MAP_ID) && map_infos[MAP_ID].instance_variable_get(:@name) != "Arena Demo"
  abort "Map ID #{MAP_ID} is already used. Change MAP_ID in both ArenaDemo and this generator."
end
info = set_fields(RPG::MapInfo.allocate,
                  :@name => "Arena Demo", :@parent_id => 0, :@order => 100,
                  :@expanded => false, :@scroll_x => 320, :@scroll_y => 240)
map_infos[MAP_ID] = info
{ 101 => ["Arena Village", town], 102 => ["Arena Entrance", interior] }.each do |id, (name, generated)|
  existing_name = map_infos[id]&.instance_variable_get(:@name)
  previous_generated_name = (id == 101 && existing_name == "Arena Town")
  if map_infos.key?(id) && existing_name != name && !previous_generated_name
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
intro_commands.each_with_index do |entry, index|
  next unless entry.instance_variable_get(:@code) == 201
  parameters = entry.instance_variable_get(:@parameters) || []
  next unless parameters[0] == 0 && parameters[1].to_i == 3
  # Keep the full character/story intro, but finish it in Arena Village rather
  # than sending the player into the old Player's House/Lappet Town map chain.
  parameters[1], parameters[2], parameters[3], parameters[4] = 101, 16, 12, 8
  indent = entry.instance_variable_get(:@indent).to_i
  intro_commands.insert(index, command(355, ["ArenaDemo.prepare_village_return"], indent))
  break
end
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
end
File.binwrite(INTRO_MAP, Marshal.dump(intro_map))

File.binwrite(DEST_MAP, Marshal.dump(map))
written_map = Marshal.load(File.binread(DEST_MAP))
written_data = written_map.instance_variable_get(:@data)
written_center = 3.times.map { |z| written_data[field_x + 12, field_y + 12, z] }
abort "Generated floor did not survive Map 100 serialization: #{written_center.inspect}" unless written_center == ground
File.binwrite(File.join(DATA_DIR, "Map101.rxdata"), Marshal.dump(town))
File.binwrite(File.join(DATA_DIR, "Map102.rxdata"), Marshal.dump(interior))
File.binwrite(MAP_INFOS, Marshal.dump(map_infos))
floor_tiles = written_data.payload.byteslice(20..).unpack("v*").count { |tile_id| tile_id == ground[0] }
puts "Built #{DEST_MAP}: 100x100 arena with centered 25x25 floor; floor tile IDs #{ground.inspect}; center verifies #{written_center.inspect}; base-floor count #{floor_tiles}/625."
puts "Arena tileset: #{map.instance_variable_get(:@tileset_id)} / #{tileset_name}; image: #{File.basename(tileset_images.first)}; base tile index: #{ground[0] - 384}."
puts "Arena start: #{start.join(',')}. Trainer: #{field_x + 12},#{field_y + 4}; guide: #{field_x + 10},#{field_y + 16}; exit: #{field_x + 12},#{field_y + 18}."
puts "Added an intro skip choice to #{INTRO_MAP} (or kept the existing choice)."
puts "Built offline town (101) -> entrance with storage PC (102) -> arena (100)."
puts "Built a fresh 32x24 Arena Village: stadium at (16,11), return/spawn at #{town_start.join(',')}, three houses, two residents, and an offline grass patch."
puts "Map 103 is no longer generated or registered; world transfers stay among Maps 100-102."
