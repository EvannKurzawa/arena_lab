# Private artwork QA, without launching or changing the installed game.
# ruby furniture_preview.rb PRIVATE_GAME OUTPUT.png
$stdout.sync = true
require_relative 'expedition_preview'
require_relative '../Plugins/ArenaDemo/000_ReliefRules'
class Window_CommandPokemon; end unless defined?(Window_CommandPokemon)
module ArenaDemo
  MAP_ID = 100 unless const_defined?(:MAP_ID)
end
require_relative '../Plugins/ArenaDemo/009_ArenaCustomMode'
require_relative '../Plugins/ArenaDemo/091_ArenaFurnitureCatalog'

class Bitmap
  def fill_rect(x, y, w, h, color)
    h.times { |dy| w.times { |dx| set_pixel(x + dx, y + dy, color) } }
  end
  def stretch_blt(target, source, rect)
    target.height.times do |y|
      target.width.times do |x|
        color = source.get_pixel(rect.x + x * rect.width / target.width, rect.y + y * rect.height / target.height)
        set_pixel(target.x + x, target.y + y, color) if color.alpha > 0
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  game, output = ARGV.map { |path| File.expand_path(path) }
  abort 'Usage: furniture_preview.rb PRIVATE_GAME OUTPUT.png' unless game && output
  Object.send(:define_method, :pbResolveBitmap) do |path|
    candidate = File.join(game, path + '.png')
    File.file?(candidate) ? candidate : nil
  end
  canvas = Bitmap.new(480, 512)
  entries = ArenaDemo::BASIC_FURNITURE.keys
  entries.each_with_index do |item, i|
    x, y = i % 5 * 96, i / 5 * 128
    canvas.fill_rect(x, y, 96, 128, Color.new(32, 42, 52))
    art = ArenaDemo.furniture_catalog_preview(:item => item)
    canvas.blt(x, y + 16, art, Rect.new(0, 0, 96, 96))
    puts "#{i + 1}: #{ArenaDemo::BASIC_FURNITURE.fetch(item)[0]}"
  end
  FileUtils.mkdir_p(File.dirname(output))
  canvas.save(output)
  puts "Private furniture preview: #{output}"
end
