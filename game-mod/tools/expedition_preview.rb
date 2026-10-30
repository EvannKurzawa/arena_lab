# Offline visual QA of the production generator/renderer using local native art.
# ruby game-mod/tools/expedition_preview.rb PRIVATE_GAME OUTPUT_DIRECTORY [SEED] [BIOMES...]
# Does not change game files or saves; PNG inputs/outputs must remain private.
require 'zlib'
require 'fileutils'
require 'json'

class Color
  attr_reader :red, :green, :blue, :alpha
  def initialize(r, g, b, a = 255); @red, @green, @blue, @alpha = r.to_i, g.to_i, b.to_i, a.to_i; end
  def bytes; [@red, @green, @blue, @alpha].pack('C4'); end
end
Rect = Struct.new(:x, :y, :width, :height)

class Bitmap
  attr_reader :width, :height, :pixels
  def initialize(width, height = nil)
    @rects = {}
    if height
      @width, @height = width, height
      @pixels = "\0".b * (width * height * 4)
    else
      cache = self.class.instance_variable_get(:@decoded_sources) || {}
      self.class.instance_variable_set(:@decoded_sources, cache)
      if cache[width]
        @width, @height, pixels = cache[width]
        @pixels = pixels.dup
      else
        load_png(width)
        cache[width] = [@width, @height, @pixels.dup]
      end
    end
  end

  def load_png(path)
    bytes = File.binread(path)
    chunks, cursor = [], 8
    while cursor < bytes.bytesize
      length = bytes.byteslice(cursor, 4).unpack1('N')
      chunks << [bytes.byteslice(cursor + 4, 4), bytes.byteslice(cursor + 8, length)]
      cursor += length + 12
    end
    @width, @height, depth, type, _, _, interlace = chunks.assoc('IHDR')[1].unpack('NNC5')
    raise "Unsupported PNG #{path}: depth=#{depth}, type=#{type}, interlace=#{interlace}" unless interlace == 0 && ((depth == 8 && [2, 6].include?(type)) || (type == 3 && [1, 2, 4, 8].include?(depth)))
    channels = { 2 => 3, 3 => 1, 6 => 4 }.fetch(type)
    raw = Zlib::Inflate.inflate(chunks.select { |name, _| name == 'IDAT' }.map(&:last).join)
    palette = chunks.assoc('PLTE')&.last&.bytes&.each_slice(3)&.to_a
    alpha = chunks.assoc('tRNS')&.last&.bytes || []
    stride = (@width * channels * depth + 7) / 8
    filter_channels = [(channels * depth + 7) / 8, 1].max
    previous, cursor = Array.new(stride, 0), 0
    @pixels = ''.b
    @height.times do
      filter = raw.getbyte(cursor)
      row = raw.byteslice(cursor + 1, stride).bytes
      cursor += stride + 1
      row.each_index do |i|
        a = i >= filter_channels ? row[i - filter_channels] : 0
        b = previous[i]
        c = i >= filter_channels ? previous[i - filter_channels] : 0
        predictor = case filter
                    when 0 then 0
                    when 1 then a
                    when 2 then b
                    when 3 then (a + b) / 2
                    when 4
                      p = a + b - c
                      distances = [(p - a).abs, (p - b).abs, (p - c).abs]
                      [a, b, c][distances.index(distances.min)]
                    else raise 'Unsupported PNG filter'
                    end
        row[i] = (row[i] + predictor) & 255
      end
      case type
      when 6 then @pixels << row.pack('C*')
      when 2 then row.each_slice(3) { |rgb| @pixels << (rgb + [255]).pack('C4') }
      when 3
        indexes = depth == 8 ? row : row.flat_map { |byte| (8 / depth - 1).downto(0).map { |n| (byte >> (n * depth)) & ((1 << depth) - 1) } }.first(@width)
        indexes.each { |index| @pixels << (palette.fetch(index) + [alpha[index] || 255]).pack('C4') }
      end
      previous = row
    end
  end

  def rect_rows(rect)
    @rects[[rect.x, rect.y, rect.width, rect.height]] ||= Array.new(rect.height) do |dy|
      row = @pixels.byteslice(((rect.y + dy) * @width + rect.x) * 4, rect.width * 4)
      raise "Source rectangle outside native image: #{rect.inspect} / #{@width}x#{@height}" unless row && row.bytesize == rect.width * 4
      [row, row.bytes.each_slice(4).all? { |rgba| rgba[3] == 255 }]
    end
  end

  def blt(x, y, source, rect)
    source.rect_rows(rect).each_with_index do |(row, opaque), dy|
      dest_y = y + dy
      next if dest_y < 0 || dest_y >= @height
      offset = (dest_y * @width + x) * 4
      if opaque && x >= 0 && x + rect.width <= @width
        @pixels[offset, row.bytesize] = row
      else
        rect.width.times do |dx|
          next if x + dx < 0 || x + dx >= @width
          alpha = row.getbyte(dx * 4 + 3)
          next if alpha == 0
          target = offset + dx * 4
          if alpha == 255
            @pixels[target, 4] = row.byteslice(dx * 4, 4)
          else
            3.times { |c| @pixels.setbyte(target + c, (row.getbyte(dx * 4 + c) * alpha + @pixels.getbyte(target + c) * (255 - alpha)) / 255) }
            @pixels.setbyte(target + 3, 255)
          end
        end
      end
    end
    @rects.clear
  end
  def get_pixel(x, y); Color.new(*@pixels.byteslice((y * @width + x) * 4, 4).bytes); end
  def set_pixel(x, y, color); @pixels[(y * @width + x) * 4, 4] = color.bytes; @rects.clear; end
  def dispose; @disposed = true; end
  def disposed?; !!@disposed; end

  def save(path, scale = 1)
    w, h = @width / scale, @height / scale
    raw = ''.b
    h.times do |y|
      raw << "\0"
      if scale == 1
        raw << @pixels.byteslice(y * @width * 4, w * 4)
      else
        w.times { |x| raw << @pixels.byteslice((y * scale * @width + x * scale) * 4, 4) }
      end
    end
    png = "\x89PNG\r\n\x1a\n".b
    [['IHDR', [w, h, 8, 6, 0, 0, 0].pack('NNC5')], ['IDAT', Zlib::Deflate.deflate(raw)], ['IEND', '']].each do |name, data|
      png << [data.bytesize].pack('N') << name << data << [Zlib.crc32(name + data)].pack('N')
    end
    File.binwrite(path, png)
  end
end

module EventHandlers
  def self.add(*); end
end
require_relative '../Plugins/ArenaDemo/015_ExpeditionLayout'
module ArenaDemo::Expeditions
  def self.data_for(map); map; end
end
require_relative '../../upstream/pokemon-essentials/Data/Scripts/006_Map renderer/004_TileDrawingHelper'
require_relative '../Plugins/ArenaDemo/017_ExpeditionTerrain'

if $PROGRAM_NAME == __FILE__
  source_root = File.expand_path(ARGV.fetch(0))
  output_root = File.expand_path(ARGV.fetch(1))
  seed = Integer(ARGV.fetch(2, 42))
  selected = ARGV.drop(3)
  FileUtils.mkdir_p(output_root)
  define_method(:pbResolveBitmap) do |path|
    resolved = File.join(source_root, path + '.png')
    File.file?(resolved) ? resolved : nil
  end
  layout, terrain = ArenaDemo::ExpeditionLayout, ArenaDemo::ExpeditionTerrain
  summaries = []
  layout::BIOMES.each_key.with_index do |biome, i|
    next unless selected.empty? || selected.include?(biome)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    region = layout.build_region(biome, layout::RNG.new(seed + i * 923), 5)
    canvas = Bitmap.new(64 * 32, 64 * 32)
    64.times { |y| 64.times { |x| canvas.blt(x * 32, y * 32, terrain.tile(region, x, y), Rect.new(0, 0, 32, 32)) } }
    region['decorations'].sort_by { |_x, y, _name| y }.each do |x, y, name|
      tree = terrain.scenery_bitmap(name, biome, x, y)
      if tree
        canvas.blt(x * 32 + 16 - tree.width / 2, (y + 1) * 32 - tree.height, tree, Rect.new(0, 0, tree.width, tree.height))
        tree&.dispose
        next
      end
      path = pbResolveBitmap("Graphics/Characters/#{name}")
      next unless path
      charset = Bitmap.new(path)
      width, height = charset.width / 4, charset.height / 4
      canvas.blt(x * 32 + 16 - width / 2, (y + 1) * 32 - height,
                 charset, Rect.new(width, 0, width, height))
    end
    canvas.save(File.join(output_root, "#{biome}.png"), 2)
    viewport = Bitmap.new(640, 480)
    viewport.blt(0, 0, canvas, Rect.new(22 * 32, 24 * 32, 640, 480))
    viewport.save(File.join(output_root, "#{biome}-viewport.png"))
    summaries << { biome: biome, grass: region['cells'].count('g'), water: region['cells'].count('w'),
      lava: region['cells'].count('l'), props: region['decorations'].length,
      seconds: (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(3) }
    terrain.clear
    puts JSON.generate(summaries.last)
  end
  File.write(File.join(output_root, 'summary.json'), JSON.pretty_generate(summaries))
end
