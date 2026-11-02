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
entries.reject! { |entry| %w[hgss-blackthorn rse-breakable-door].include?(entry['name']) }
entries.each { |entry| entry['source'] = File.join(source_root, entry['name'] + '.png'); entry['mask'] = 'alpha' }
stand_entry = entries.find { |entry| entry['name'] == 'rse-stand' }
stand_entry['source'] = File.join(ROOT,'game-mod/AssetSources/estrade-rse-reference.png')
stand_entry['rect'] = [0,0,64,32]
stand_entry['url'] = 'https://www.pokepedia.fr/images/5/56/Estrade_RSE.png'
stand_entry['sha256'] = Digest::SHA256.file(stand_entry['source']).hexdigest
outside = File.join(ROOT,'tools/runtime/essentials-v21.1-base/Graphics/Tilesets/Outside.png')
[
  ['tree-leafy', outside, [96,1952,96,96], 'alpha', 'single rounded tree from Essentials v21.1 Outside.png, isolated individual at [96,1952,96,96]'],
  ['tree-pine', outside, [128,1664,64,96], 'alpha', 'local Essentials v21.1: Outside.png'],
  ['hgss-red-carpet', File.join(source_root,'hgss-blackthorn.png'), [186,1118,28,18], 'red', 'https://www.pokepedia.fr/images/1/16/Int%C3%A9rieur_Ar%C3%A8ne_%C3%89b%C3%A8nelle_HGSS.png'],
  ['snowball', File.join(source_root,'dppt-snowpoint.png'), [164,158,17,17], 'snow', 'https://www.pokepedia.fr/images/1/1a/Ar%C3%A8ne_Frimapic_DP.png']
].each do |name,source,rect,mask,url|
  entries << { 'name'=>name, 'source'=>source, 'rect'=>rect, 'mask'=>mask, 'url'=>url, 'sha256'=>Digest::SHA256.file(source).hexdigest }
end
sizes = {
  'tree-leafy'=>[96,96], 'tree-pine'=>[64,96],
  'dppt-labmachine'=>[64,76], 'dppt-bigoildrum'=>[64,76],
  'dppt-oildrum'=>[16,28], 'dppt-trashcan'=>[20,24], 'lampe'=>[18,36],
  'chandelier'=>[24,40], 'snowball'=>[30,30], 'hgss-red-carpet'=>[32,24],
  'rse-stand'=>[64,96], 'rse-solid-board'=>[64,64]
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
  if %w[rse-stand rse-solid-board].include?(name)
    if name == 'rse-stand'
      # Estrade_RSE.png is the upper platform itself. Keep it intact, then
      # draw its built-in two-cell stair run directly beneath it.
      crop = Bitmap.new(64,96)
      crop.blt(0,0,source,Rect.new(*rect))
      step_edge, step_mid, step_light = Color.new(52,58,72),Color.new(130,139,151),Color.new(205,211,216)
      paint_rect.call(crop,4,32,56,31,step_edge)
      paint_rect.call(crop,6,33,52,28,step_mid)
      [36,43,50,57].each do |y|
        paint_rect.call(crop,6,y,52,2,step_light)
        paint_rect.call(crop,6,y+2,52,2,step_edge)
        paint_rect.call(crop,8,y+1,48,1,step_mid)
      end
      paint_rect.call(crop,4,32,56,1,Color.new(235,239,242))
    else
      # Two-cell wooden board top, with its vertical face from native relief.
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
  canvas_w = [32,((limit[0]+31)/32)*32].max
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
%w[hgss-spikes rse-breakable-door].each do |retired|
  obsolete_asset = File.join(output,retired+'.png')
  File.delete(obsolete_asset) if File.file?(obsolete_asset)
end
File.write(File.join(ROOT,'game-mod/AssetSources/furniture-sources.json'),JSON.pretty_generate(entries)+"\n")
puts "Packed #{entries.length} furniture sprites with individual native sizes."
