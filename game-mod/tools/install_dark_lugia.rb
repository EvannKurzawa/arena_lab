# Exact crops of the user-supplied indexed PNG. Uses portable Ruby's stdlib only.
require 'zlib'
require 'digest'
require 'fileutils'

module DarkLugiaAssets
  SHA256 = 'c86232a4d11d709d2606d8ad15e258253402496c6964d6383963a9715e670864'
  GIF_HASHES = {
    'front' => '12a4de409d7f51a4ad6bd3106f00f5a74551d81c4a662ab4ad0fa48b7b54ba20',
    'back' => 'f59defb372e9c888b22874124e46b7b9cbf898921b1989bfe925edff263919bc'
  }.freeze
  # BW Lugia whites become XD001 purples; blue markings become its pale armor.
  GIF_COLORS = {
    [255,255,255] => [88,88,147], [214,231,247] => [79,79,135],
    [181,198,247] => [70,70,122], [156,173,231] => [62,62,109],
    [132,132,198] => [54,54,96], [41,49,140] => [39,39,73],
    [82,90,173] => [137,155,188], [90,115,255] => [182,197,225],
    [123,165,247] => [205,218,242], [0,99,189] => [161,177,209],
    [0,66,132] => [86,104,137], [16,16,16] => [11,11,11],
    [239,74,57] => [247,43,39], [156,57,74] => [198,24,21]
  }.freeze
  OUTPUTS = ['Graphics/Pokemon/Front/LUGIA_1.png', 'Graphics/Pokemon/Back/LUGIA_1.png',
    'Graphics/Pokemon/Icons/LUGIA_1.png', 'Graphics/Characters/Followers/LUGIA_1.png',
    'Graphics/Pokemon/ArenaAnimated/front/[4,4]LUGIA_1.png',
    'Graphics/Pokemon/ArenaAnimated/back/[2,8]LUGIA_1.png'].freeze
  module_function

  # Change only color tables, keeping frame data, durations, disposal and
  # transparency indices byte-for-byte identical to the pinned source GIF.
  def gif_palette_ranges(bytes)
    raise 'Invalid GIF header.' unless ['GIF87a', 'GIF89a'].include?(bytes[0, 6])
    ranges = []
    offset = 13
    if bytes.getbyte(10) & 128 != 0
      size = 3 * (2 ** ((bytes.getbyte(10) & 7) + 1))
      ranges << (offset...offset + size)
      offset += size
    end
    skip_blocks = lambda do
      loop do
        size = bytes.getbyte(offset)
        raise 'Truncated GIF blocks.' unless size
        offset += 1
        break if size == 0
        offset += size
        raise 'Truncated GIF payload.' if offset > bytes.bytesize
      end
    end
    loop do
      case bytes.getbyte(offset)
      when 0x3b then break
      when 0x21
        offset += 2
        skip_blocks.call
      when 0x2c
        flags = bytes.getbyte(offset + 9)
        raise 'Truncated GIF image descriptor.' unless flags
        offset += 10
        if flags & 128 != 0
          size = 3 * (2 ** ((flags & 7) + 1))
          ranges << (offset...offset + size)
          offset += size
        end
        offset += 1 # LZW minimum code size
        skip_blocks.call
      else raise 'Unexpected GIF block.'
      end
    end
    ranges
  end

  def recolor_gif(bytes)
    output = bytes.dup
    gif_palette_ranges(bytes).each do |range|
      range.step(3) do |offset|
        color = bytes[offset, 3].bytes
        output[offset, 3] = GIF_COLORS.fetch(color, color).pack('C3')
      end
    end
    output
  end

  def read_sheet(path)
    bytes = File.binread(path)
    raise 'XD001 sheet differs from the reviewed original.' unless Digest::SHA256.hexdigest(bytes) == SHA256
    chunks, offset = Hash.new { |h, k| h[k] = ''.b }, 8
    while offset < bytes.bytesize
      length = bytes[offset, 4].unpack1('N')
      type = bytes[offset + 4, 4]
      chunks[type] << bytes[offset + 8, length]
      offset += length + 12
    end
    width, height, depth, type, compression, filtering, interlace = chunks['IHDR'].unpack('NNCCCCC')
    raise 'Expected the original indexed 270x376 PNG.' unless [width, height, depth, type, compression, filtering, interlace] == [270, 376, 8, 3, 0, 0, 0]
    palette = chunks['PLTE'].bytes.each_slice(3).with_index.map { |rgb, i| (rgb + [chunks['tRNS'].getbyte(i) || 255]).pack('C4') }
    raw = Zlib::Inflate.inflate(chunks['IDAT'])
    raise 'Unexpected PNG length.' unless raw.bytesize == (width + 1) * height
    rows, previous = [], Array.new(width, 0)
    height.times do |y|
      filter = raw.getbyte(y * (width + 1))
      row = raw[y * (width + 1) + 1, width].bytes
      width.times do |x|
        left, up, corner = x > 0 ? row[x - 1] : 0, previous[x], x > 0 ? previous[x - 1] : 0
        prediction = case filter
        when 0 then 0
        when 1 then left
        when 2 then up
        when 3 then (left + up) / 2
        when 4
          p = left + up - corner
          a, b, c = (p - left).abs, (p - up).abs, (p - corner).abs
          a <= b && a <= c ? left : b <= c ? up : corner
        else raise 'Unsupported PNG filter.'
        end
        row[x] = (row[x] + prediction) & 255
      end
      rows << row.map { |index| palette.fetch(index) }
      previous = row
    end
    rows
  end

  def canvas(width, height)
    [width, height, Array.new(width * height, "\0\0\0\0".b)]
  end

  def pose(sheet, target, box, x, y, width, height, margin = 0, max_scale = 2, fixed_scale: nil)
    points = []
    (box[1]...(box[1] + box[3])).each do |py|
      (box[0]...(box[0] + box[2])).each { |px| points << [px, py] if sheet[py][px].getbyte(3) > 0 }
    end
    raise 'Empty sprite crop.' if points.empty?
    left, right = points.map(&:first).minmax
    top, bottom = points.map(&:last).minmax
    sw, sh = right - left + 1, bottom - top + 1
    scale = [max_scale, (width - margin * 2) / sw, (height - margin * 2) / sh].min
    scale = fixed_scale if fixed_scale
    raise 'Sprite does not fit its native frame.' if scale < 1
    raise 'Fixed-scale sprite does not fit.' if sw * scale > width - margin * 2 || sh * scale > height - margin * 2
    tx, ty = x + (width - sw * scale) / 2, y + height - margin - sh * scale
    sh.times do |sy|
      sw.times do |sx|
        color = sheet[top + sy][left + sx]
        scale.times { |dy| scale.times { |dx| target[2][(ty + sy * scale + dy) * target[0] + tx + sx * scale + dx] = color } }
      end
    end
    [left, top, sw, sh, scale]
  end

  def save(image, path)
    width, height, pixels = image
    raw = (0...height).map { |y| "\0".b + pixels[y * width, width].join }.join
    chunk = ->(type, data) { [data.bytesize].pack('N') + type + data + [Zlib.crc32(type + data)].pack('N') }
    png = "\x89PNG\r\n\x1a\n".b + chunk.call('IHDR', [width, height, 8, 6, 0, 0, 0].pack('NNCCCCC')) +
      chunk.call('IDAT', Zlib::Deflate.deflate(raw)) + chunk.call('IEND', ''.b)
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, png)
  end

  def install(game, source)
    private_root = File.join(game, 'Data/ArenaDarkLugia')
    stored = File.join(private_root, 'xd001.png')
    source = stored unless File.file?(source)
    unless File.file?(source)
      puts 'Optional XD001 sheet not present; Dark Lugia remains disabled.'
      return
    end
    sheet = read_sheet(source)
    gif_sources = GIF_HASHES.keys.to_h do |side|
      [side, File.join(game, "Graphics/Pokemon/ArenaAnimated/#{side}/LUGIA.gif")]
    end
    has_gifs = gif_sources.values.all? { |path| File.file?(path) }
    gif_outputs = GIF_HASHES.keys.map { |side| "Graphics/Pokemon/ArenaAnimated/#{side}/LUGIA_1.gif" }
    if has_gifs
      gif_sources.each do |side, path|
        raise 'Unexpected source Lugia GIF.' unless Digest::SHA256.file(path).hexdigest == GIF_HASHES.fetch(side)
      end
    end
    marker = File.join(private_root, 'installed.txt')
    signature = "layout=8; source=#{SHA256}; gif=#{has_gifs}"
    aliases = OUTPUTS.first(4).map { |path| path.sub('LUGIA_1', 'DARKLUGIA') }
    required = OUTPUTS + aliases + (has_gifs ? gif_outputs : [])
    if File.file?(marker) && File.read(marker).start_with?(signature) && required.all? { |p| File.file?(File.join(game, p)) }
      puts 'Dark Lugia local sprites already installed.'
      return
    end
    raise 'Form 1 artwork already exists; inspect it before importing.' if !File.file?(marker) && OUTPUTS.any? { |p| File.exist?(File.join(game, p)) }
    front, back, icons, follower = canvas(192, 192), canvas(208, 208), canvas(128, 64), canvas(512, 512)
    crops = []
    crops << pose(sheet, front, [0, 0, 85, 89], 0, 0, 192, 192, 4, fixed_scale: 2)
    crops << pose(sheet, back, [128, 90, 98, 90], 0, 0, 208, 208, 4, fixed_scale: 2)
    crops << pose(sheet, icons, [100, 349, 35, 27], 0, 0, 64, 64, 0, fixed_scale: 2)
    crops << pose(sheet, icons, [137, 349, 43, 27], 64, 0, 64, 64, 0, fixed_scale: 2)
    # Complete connected silhouettes, with a transparent pixel of padding.
    # The old shared row bounds sliced pixels off the lower/right wing tips.
    follower_boxes = [
      [[95, 224, 46, 36], [144, 226, 32, 39]],
      [[88, 265, 46, 37], [137, 268, 46, 39]],
      [[88, 307, 46, 37], [137, 310, 46, 39]],
      [[94, 182, 46, 42], [143, 182, 34, 42]]
    ]
    follower_boxes.each_with_index do |boxes, row|
      4.times do |column|
        crops << pose(sheet, follower, boxes[column / 2], column * 128, row * 128, 128, 128, 4, fixed_scale: 2)
      end
    end
    front_strip, back_strip = canvas(224 * 4, 224), canvas(224 * 2, 224)
    [[0, 0, 85, 89], [85, 0, 85, 89], [170, 0, 100, 89], [85, 0, 85, 89]].each_with_index do |box, i|
      crops << pose(sheet, front_strip, box, i * 224, 0, 224, 224, 4, fixed_scale: 2)
    end
    # The other back drawing is a neck close-up, not a second wing pose.
    # Animate one consistent full-body view with a two-pixel hover instead.
    2.times do |i|
      crops << pose(sheet, back_strip, [128, 90, 98, 90], i * 224, -i * 2, 224, 224, 4, fixed_scale: 2)
    end
    [front, back, icons, follower, front_strip, back_strip].zip(OUTPUTS).each { |image, path| save(image, File.join(game, path)) }
    OUTPUTS.first(4).zip(aliases).each { |from, to| FileUtils.cp(File.join(game, from), File.join(game, to)) }
    if has_gifs
      gif_sources.each do |side, path|
        File.binwrite(File.join(game, "Graphics/Pokemon/ArenaAnimated/#{side}/LUGIA_1.gif"), recolor_gif(File.binread(path)))
      end
    end
    preview = canvas(768, 512)
    [[front, 0, 0], [back, 0, 192], [icons, 0, 400], [follower, 256, 0]].each do |image, x, y|
      image[1].times { |py| image[0].times { |px| preview[2][(y + py) * preview[0] + x + px] = image[2][py * image[0] + px] } }
    end
    save(preview, File.join(private_root, 'preview.png'))
    FileUtils.cp(source, stored) unless File.expand_path(source) == File.expand_path(stored)
    File.write(marker, "#{signature}\nArtist: ShadowGate31\nSource: https://www.deviantart.com/shadowgate31/art/Shadow-Lugia-sprites-for-fangames-410361664\nLocal import only; redistribution terms not verified.\nCrops: #{crops.inspect}\n")
    puts 'Dark Lugia: front/back animations, stable icons and slower follower installed locally.'
  end
end

if $PROGRAM_NAME == __FILE__
  project = File.expand_path('../..', __dir__)
  DarkLugiaAssets.install(File.expand_path(ARGV.fetch(0)), File.expand_path(ARGV[1] || File.join(project, 'game-mod/AssetSources/xd001.png')))
end
