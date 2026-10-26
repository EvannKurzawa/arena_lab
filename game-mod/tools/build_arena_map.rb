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
end

class Tone
  def self._load(_payload)
    allocate
  end

  def _dump(_depth)
    ""
  end
end

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

home_map = Marshal.load(File.binread(HOME_MAP))
start = transfer_point(home_map, 2)
abort "Could not find the Player's House exit transfer to Lappet Town (map 2)" unless start
File.binwrite(START_FILE, start.join(","))

map = Marshal.load(File.binread(SOURCE_MAP))
map_width = map.instance_variable_get(:@width).to_i
map_height = map.instance_variable_get(:@height).to_i
sx, sy, = start
near = lambda do |dx, dy|
  [[sx + dx, 0].max.clamp(0, [map_width - 1, 0].max),
   [sy + dy, 0].max.clamp(0, [map_height - 1, 0].max)]
end
manager_x, manager_y = near.call(-2, 0)
trainer_x, trainer_y = near.call(2, 0)
boulder_x, boulder_y = near.call(-2, 2)
rock_x, rock_y = near.call(0, 2)
tree_x, tree_y = near.call(2, 2)
map.instance_variable_set(:@events, {
  1 => event(1, "Arena manager", manager_x, manager_y, "trainer_SUPERNERD", "ArenaDemo.manage_objects"),
  2 => event(2, "Arena trainer", trainer_x, trainer_y, "trainer_YOUNGSTER", "ArenaDemo.challenge_trainer"),
  3 => event(3, "Boulder obstacle", boulder_x, boulder_y, "Object boulder"),
  4 => event(4, "Rock obstacle", rock_x, rock_y, "Object rock"),
  5 => event(5, "Tree decoration", tree_x, tree_y, "Object tree 1")
})

map_infos = Marshal.load(File.binread(MAP_INFOS))
if map_infos.key?(MAP_ID) && map_infos[MAP_ID].instance_variable_get(:@name) != "Arena Demo"
  abort "Map ID #{MAP_ID} is already used. Change MAP_ID in both ArenaDemo and this generator."
end
info = set_fields(RPG::MapInfo.allocate,
                  :@name => "Arena Demo", :@parent_id => 0, :@order => 100,
                  :@expanded => false, :@scroll_x => 320, :@scroll_y => 240)
map_infos[MAP_ID] = info

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
File.binwrite(MAP_INFOS, Marshal.dump(map_infos))
puts "Built #{DEST_MAP} from walkable Lappet Town map 2; registered map #{MAP_ID}."
puts "Arena start: #{start[0]},#{start[1]},#{start[2]} (copied from the Player's House exit)."
puts "Added an intro skip choice to #{INTRO_MAP} (or kept the existing choice)."
