require 'minitest/autorun'
require 'tmpdir'
require 'digest'
require_relative '../tools/install_dark_lugia'

class DarkLugiaAssetsTest < Minitest::Test
  SOURCE = File.expand_path('../../xd001.png', __dir__)

  def test_gif_recolor_keeps_frames_timing_and_transparency_unchanged
    %w[front back].each do |side|
      path = File.expand_path("../../tools/runtime/essentials-v21.1-base/Graphics/Pokemon/ArenaAnimated/#{side}/LUGIA.gif", __dir__)
      skip 'Local pinned Lugia GIF is unavailable.' unless File.file?(path)
      source = File.binread(path)
      output = DarkLugiaAssets.recolor_gif(source)
      refute_equal source, output
      assert_equal source.bytesize, output.bytesize
      DarkLugiaAssets.gif_palette_ranges(source).each do |range|
        output[range] = source[range]
      end
      assert_equal source, output, 'only palette bytes change, never animation blocks or transparency'
    end
  end

  def test_rejects_unverified_sheet_before_writing
    Dir.mktmpdir do |dir|
      bad = File.join(dir, 'bad.png')
      File.binwrite(bad, 'not the credited sheet')
      assert_raises(RuntimeError) { DarkLugiaAssets.install(File.join(dir, 'game'), bad) }
      refute File.exist?(File.join(dir, 'game'))
    end
  end

  def test_missing_optional_sheet_leaves_game_untouched
    Dir.mktmpdir do |dir|
      game = File.join(dir, 'game')
      DarkLugiaAssets.install(game, File.join(dir, 'missing.png'))
      refute File.exist?(game)
    end
  end

  def test_imports_expected_pngs_and_reuses_verified_private_source
    skip 'Private source sheet is unavailable in this checkout.' unless File.file?(SOURCE)
    Dir.mktmpdir do |dir|
      game = File.join(dir, 'game')
      DarkLugiaAssets.install(game, SOURCE)
      expected = {
        'Graphics/Pokemon/Front/LUGIA_1.png' => [192, 192],
        'Graphics/Pokemon/Back/LUGIA_1.png' => [208, 208],
        'Graphics/Pokemon/Icons/LUGIA_1.png' => [128, 64],
        'Graphics/Characters/Followers/LUGIA_1.png' => [512, 512],
        'Graphics/Pokemon/ArenaAnimated/front/[4,4]LUGIA_1.png' => [896, 224],
        'Graphics/Pokemon/ArenaAnimated/back/[2,8]LUGIA_1.png' => [448, 224]
      }
      expected.each do |relative, dimensions|
        path = File.join(game, relative)
        assert File.file?(path), "Missing #{relative}"
        bytes = File.binread(path)
        assert_equal dimensions, bytes[16, 8].unpack('N2')
        assert_equal [8, 6], bytes[24, 2].unpack('C2')
      end
      # Unfiltered RGBA rows emitted by the importer: compare actual pixels.
      decode = lambda do |relative|
        bytes = File.binread(File.join(game, relative))
        width, height = bytes[16, 8].unpack('N2')
        offset, compressed = 8, ''.b
        while offset < bytes.bytesize
          size = bytes[offset, 4].unpack1('N')
          compressed << bytes[offset + 8, size] if bytes[offset + 4, 4] == 'IDAT'
          offset += size + 12
        end
        rows = Zlib::Inflate.inflate(compressed)
        Array.new(height) { |y| rows[y * (width * 4 + 1) + 1, width * 4] }
      end
      rows = decode.call('Graphics/Characters/Followers/LUGIA_1.png')
      areas = [[688, 518], [699, 564], [699, 564], [782, 620]]
      4.times do |direction|
        frames = 4.times.map { |frame| rows[direction * 128, 128].map { |row| row[frame * 128 * 4, 128 * 4] }.join }
        assert_equal frames[0], frames[1], 'first wing pose held for two frames'
        assert_equal frames[2], frames[3], 'second wing pose held for two frames'
        refute_equal frames[0], frames[2], 'wing poses are actually different'
        [0, 2].each_with_index do |frame, pose|
          actual = frames[frame].bytes.each_slice(4).count { |pixel| pixel[3] > 0 }
          assert_equal areas[direction][pose] * 4, actual, 'complete follower silhouette, including every wing-tip pixel'
        end
      end
      DarkLugiaAssets::OUTPUTS.first(4).each do |relative|
        legacy = File.join(game, relative)
        independent = File.join(game, relative.sub('LUGIA_1', 'DARKLUGIA'))
        assert_equal Digest::SHA256.file(legacy).hexdigest, Digest::SHA256.file(independent).hexdigest,
          'independent species retains the exact reviewed sprite artwork'
      end
      # Icons use the native Lugia 2x scale even when a wing reaches the edge.
      source_rows = DarkLugiaAssets.read_sheet(SOURCE)
      icon_rows = decode.call('Graphics/Pokemon/Icons/LUGIA_1.png')
      [[100, 349, 35, 27], [137, 349, 43, 27]].each_with_index do |(x, y, w, h), frame|
        area = source_rows[y, h].sum { |row| row[x, w].count { |pixel| pixel.getbyte(3) > 0 } }
        actual = icon_rows.sum { |row| row[frame * 64 * 4, 64 * 4].bytes.each_slice(4).count { |pixel| pixel[3] > 0 } }
        assert_equal area * 4, actual, 'both party icon poses retain the native double scale'
      end
      back_rows = decode.call('Graphics/Pokemon/ArenaAnimated/back/[2,8]LUGIA_1.png')
      first = back_rows.map { |row| row[0, 224 * 4] }
      assert_equal 3179 * 4, first.join.bytes.each_slice(4).count { |pixel| pixel[3] > 0 }, 'full back silhouette including left wing'
      second = back_rows.map { |row| row[224 * 4, 224 * 4] }
      assert_equal first[2..], second[0...-2], 'back animation is the same complete pose hovering two pixels'
      assert second[-2..].all? { |row| row.bytes.all?(&:zero?) }, 'hover preserves transparent lower margin'
      installed = expected.keys.to_h do |relative|
        path = File.join(game, relative)
        [relative, [Digest::SHA256.file(path).hexdigest, File.mtime(path)]]
      end
      DarkLugiaAssets.install(game, File.join(dir, 'missing.png'))
      expected.each_key do |relative|
        path = File.join(game, relative)
        assert_equal installed.fetch(relative), [Digest::SHA256.file(path).hexdigest, File.mtime(path)]
      end
      assert_equal DarkLugiaAssets::SHA256, Digest::SHA256.file(SOURCE).hexdigest
    end
  end
end
