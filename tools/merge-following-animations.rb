# Merge only the Following Pokemon EX animation entries into the user's local
# Essentials animation table, retaining every upstream animation and remapping
# the plugin's configured IDs. Never replace the user's compiled animation data.
require "fileutils"
require "digest"

class Table
  def self._load(payload); obj = allocate; obj.instance_variable_set(:@payload, payload); obj; end
  def _dump(_depth); @payload; end
end
class Tone
  def self._load(payload); obj = allocate; obj.instance_variable_set(:@payload, payload); obj; end
  def _dump(_depth); @payload; end
end
class Color < Tone; end
module RPG
  class Animation
    class Frame; end
    class Timing; end
  end
  class AudioFile; end
end

game_root, source_path, plugin_path = ARGV
abort "Usage: merge-following-animations.rb GAME_ROOT SOURCE_RXDATA PLUGIN_DIR" unless plugin_path
target = File.join(game_root, "Data", "Animations.rxdata")
backup = File.join(game_root, "Data", "ArenaLab-Animations-before-FollowingEX.rxdata")
merge_marker = File.join(game_root, "Data", "ArenaLab-FollowingEX-animations.txt")
abort "Missing local Essentials animation data: #{target}" unless File.file?(target)
FileUtils.copy_file(target, backup) unless File.file?(backup)

following = Marshal.load(File.binread(source_path))
source_hash = Digest::SHA256.file(source_path).hexdigest
if File.file?(merge_marker) && File.read(merge_marker).strip.start_with?("#{source_hash} ")
  base = File.read(merge_marker).split.last.to_i
else
  original = Marshal.load(File.binread(target))
  abort "Unexpected animation table format" unless original.is_a?(Array) && following.is_a?(Array)
  base = original.length
  merged = original + following.drop(1)
  File.binwrite(target + ".arena-tmp", Marshal.dump(merged))
  FileUtils.mv(target + ".arena-tmp", target, force: true)
  File.write(merge_marker, "#{source_hash} #{base}\n")
end

config = File.join(plugin_path, "Configuration", "000_Config.rb")
text = File.read(config)
text.gsub!(/(ANIMATION_(?:COME_OUT|COME_IN|EMOTE_HEART|EMOTE_MUSIC|EMOTE_HAPPY|EMOTE_ELIPSES|EMOTE_ANGRY|EMOTE_POISON)\s*=\s*)(\d+)/) do
  "#{$1}#{base + $2.to_i - 1}"
end
# Arena Lab always follows the lead able Pokémon; configurable hotkeys could
# make the remote sprite disagree with the local saved party ordering.
text.gsub!(/TOGGLE_FOLLOWER_KEY\s*=\s*Input::\w+/, "TOGGLE_FOLLOWER_KEY       = nil")
text.gsub!(/SHOW_TOGGLE_IN_OPTIONS\s*=\s*true/, "SHOW_TOGGLE_IN_OPTIONS    = false")
text.gsub!(/CYCLE_PARTY_FORWARD_KEY\s*=\s*Input::\w+/, "CYCLE_PARTY_FORWARD_KEY  = nil")
text.gsub!(/CYCLE_PARTY_BACKWARD_KEY\s*=\s*Input::\w+/, "CYCLE_PARTY_BACKWARD_KEY = nil")
File.write(config, text)
puts "Following Pokemon EX animations are mapped from #{base}..#{base + following.length - 2}; original animation data backed up."
