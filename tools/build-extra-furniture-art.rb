# Deterministic packing of native pixel art, with nearest-neighbour sampling.
require_relative '../game-mod/tools/expedition_preview'
require 'digest'
ROOT = File.expand_path('..', __dir__)
source_root = File.expand_path(ARGV.fetch(0, 'tools/runtime/furniture-sources')).tr('\\', '/')
output = File.join(ROOT, 'game-mod/SharedAssets/Graphics/ArenaFurniture')
FileUtils.mkdir_p(output)
paint_rect = proc do |bitmap,x,y,width,height,color|
  height.times { |dy| width.times { |dx| bitmap.set_pixel(x+dx,y+dy,color) } }
end
entries = JSON.parse(File.read(File.join(source_root, 'sources.json'), encoding: 'bom|utf-8'))
entries.reject! { |entry| entry['name'] == 'hgss-blackthorn' }
entries.each { |entry| entry['source'] = File.join(source_root, entry['name'] + '.png'); entry['mask'] = 'alpha' }
outside = File.join(ROOT,'tools/runtime/essentials-v21.1-base/Graphics/Tilesets/Outside.png')
individual_tree = File.join(ROOT,'game-mod/AssetSources/tree-leafy-master.png')
[
  ['tree-leafy', individual_tree, [0,0,64,64], 'alpha', 'single rounded tree isolated from Essentials v21.1 Outside.png crop [96,1952,96,96]'],
  ['tree-pine', outside, [128,1664,64,96], 'alpha', 'local Essentials v21.1: Outside.png'],
  ['hgss-red-carpet', File.join(source_root,'hgss-blackthorn.png'), [186,1118,28,18], 'red', 'https://www.pokepedia.fr/images/1/16/Int%C3%A9rieur_Ar%C3%A8ne_%C3%89b%C3%A8nelle_HGSS.png'],
  ['hgss-spikes', File.join(source_root,'hgss-blackthorn.png'), [96,1016,16,32], 'pixel-spikes', 'https://www.pokepedia.fr/images/1/16/Int%C3%A9rieur_Ar%C3%A8ne_%C3%89b%C3%A8nelle_HGSS.png'],
  ['snowball', File.join(source_root,'dppt-snowpoint.png'), [164,158,17,17], 'snow', 'https://www.pokepedia.fr/images/1/1a/Ar%C3%A8ne_Frimapic_DP.png']
].each do |name,source,rect,mask,url|
  entries << { 'name'=>name, 'source'=>source, 'rect'=>rect, 'mask'=>mask, 'url'=>url, 'sha256'=>Digest::SHA256.file(source).hexdigest }
end
sizes = {
  'tree-leafy'=>[64,64], 'tree-pine'=>[64,96],
  'dppt-labmachine'=>[64,76], 'dppt-bigoildrum'=>[64,76],
  'dppt-oildrum'=>[16,28], 'dppt-trashcan'=>[20,24], 'lampe'=>[18,36],
  'chandelier'=>[24,40], 'snowball'=>[30,30], 'hgss-red-carpet'=>[32,24],
  'rse-stand'=>[64,64], 'rse-solid-board'=>[64,64]
}
entries.each do |entry|
  name = entry.fetch('name')
  if name == 'chandelier'
    entry['source'] = File.join(source_root, 'chandelier-redrawn.png')
    entry['url'] = 'OpenAI imagegen: red-brass three-candle pixel candelabra, 2026-11-02'
    entry['sha256'] = Digest::SHA256.file(entry['source']).hexdigest
  end
  raise "Source changed: #{name}" unless Digest::SHA256.file(entry['source']).hexdigest == entry.fetch('sha256')
  source = Bitmap.new(entry['source'])
  rect = entry['rect'] || [0,0,source.width,source.height]
  crop = Bitmap.new(rect[2],rect[3])
  crop.blt(0,0,source,Rect.new(*rect))
  if name == 'hgss-spikes'
    # Crisp, recognizable two-spike HGSS barrier with no lava/red cap or
    # black platform fragments from the surrounding tiles.
    crop = Bitmap.new(32,64)
    outline = Color.new(63,67,78)
    shadow = Color.new(91,91,92)
    stone = Color.new(148,143,127)
    light = Color.new(196,190,168)
    glint = Color.new(224,219,199)
    [[9,0,21],[23,3,18]].each do |cx,top,height|
      height.times do |dy|
        y = 60-height+dy
        half = [1 + (dy*0.30).floor,5].min
        (-half..half).each do |dx|
          x = cx+dx
          col = if dy == 0 || dx.abs == half then outline
                elsif dx < -1 then light
                elsif dx == -1 then glint
                elsif dx == 1 then shadow
                else stone end
          crop.set_pixel(x,y,col)
        end
      end
    end
    paint_rect.call(crop,4,60,24,2,Color.new(104,91,73))
  end
  if %w[rse-stand rse-solid-board].include?(name)
    # Top view of a compact, two-tile Pokémon-style raised wooden platform.
    # The engine supplies its coherent front wall from the two raised tiles.
    crop = Bitmap.new(64,32)
    edge, dark, wood, pale = Color.new(66,43,36),Color.new(105,65,41),Color.new(164,111,63),Color.new(209,159,95)
    paint_rect.call(crop,0,2,64,30,edge)
    paint_rect.call(crop,2,3,60,27,dark)
    paint_rect.call(crop,3,4,58,24,wood)
    [8,15,22].each do |y|
      paint_rect.call(crop,4,y,56,1,pale)
      paint_rect.call(crop,4,y+1,56,1,dark)
      [12,28,44,58].each { |x| paint_rect.call(crop,x,y,1,2,edge) }
    end
    if name == 'rse-stand'
      paint_rect.call(crop,8,10,48,10,Color.new(119,42,58))
      paint_rect.call(crop,10,11,44,8,Color.new(188,63,72))
      paint_rect.call(crop,12,12,40,1,Color.new(238,158,145))
      paint_rect.call(crop,12,17,40,1,Color.new(126,40,52))
    else
      paint_rect.call(crop,6,8,52,13,Color.new(190,149,91))
      paint_rect.call(crop,7,9,50,1,pale)
      [17,28,39,50].each { |x| paint_rect.call(crop,x,10,1,10,dark) }
      paint_rect.call(crop,7,20,50,1,edge)
    end
  end
  if name == 'chandelier'
    points = []
    crop.height.times { |y| crop.width.times { |x| points << [x,y] if crop.get_pixel(x,y).alpha > 128 } }
    xs,ys = points.transpose
    visible = Bitmap.new(xs.max-xs.min+1,ys.max-ys.min+1)
    visible.blt(0,0,crop,Rect.new(xs.min,ys.min,visible.width,visible.height))
    crop = visible
  end
  crop.height.times do |y|
    crop.width.times do |x|
      pixel = crop.get_pixel(x,y)
      keep = case entry['mask']
             when 'red' then pixel.red > pixel.green * 1.6 && pixel.red > pixel.blue * 1.5
             when 'snow' then ((x-8)/8.5)**2 + ((y-8)/8.5)**2 <= 1 && pixel.red > 160 && pixel.green > 180
             when 'pixel-spikes' then true
             else true
             end
      crop.set_pixel(x,y,Color.new(0,0,0,0)) unless keep
    end
  end
  limit = sizes[name]
  limit ||= if name.match?(/flower/) then [20,30]
            elsif name.match?(/plant/) then [24,32]
            else [32,64]
            end
  scale = [limit[0].to_f/crop.width,limit[1].to_f/crop.height].min
  w,h = (crop.width*scale).round,(crop.height*scale).round
  canvas_w = limit[0] > 32 ? 64 : 32
  canvas_h = [64,((h+31)/32)*32].max
  image = Bitmap.new(canvas_w,canvas_h)
  h.times do |y|
    w.times do |x|
      pixel = crop.get_pixel([((x+0.5)/scale).floor,crop.width-1].min,[((y+0.5)/scale).floor,crop.height-1].min)
      pixel = Color.new(pixel.red,pixel.green,pixel.blue,pixel.alpha > 128 ? 255 : 0) if name == 'chandelier'
      target_y = canvas_h-h+y
      image.set_pixel((canvas_w-w)/2+x,target_y,pixel) if target_y < canvas_h
    end
  end
  target = File.join(output,name+'.png')
  image.save(target)
  entry['size'] = [canvas_w,canvas_h]
  entry['visible_size'] = [w,h]
  entry['packed_sha256'] = Digest::SHA256.file(target).hexdigest
  entry.delete('source')
end
File.write(File.join(ROOT,'game-mod/AssetSources/furniture-sources.json'),JSON.pretty_generate(entries)+"\n")
puts "Packed #{entries.length} furniture sprites with individual native sizes."
