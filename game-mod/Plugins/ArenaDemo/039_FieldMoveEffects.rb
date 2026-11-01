# Overworld object effects reuse the object's existing character artwork.
# No battle animation assets or copied game effects are required.
module ArenaDemo
  module FieldMoveEffects
    module_function

    def play(event)
      return unless event && !event.character_name.empty?
      cut = !!event.name[/cuttree/i]
      return unless cut || event.name[/smashrock/i]
      pieces, bitmaps = [], []
      original_transparency = event.transparent
      source = AnimatedBitmap.new("Graphics/Characters/#{event.character_name}")
      sheet = source.bitmap
      width, height = sheet.width / 4, sheet.height / 4
      frame_x = event.pattern * width
      frame_y = ((event.direction - 2) / 2) * height
      columns, rows = cut ? [2, 1] : [3, 2]
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      viewport.z = 999
      rows.times do |row|
        columns.times do |column|
          left, top = width * column / columns, height * row / rows
          right, bottom = width * (column + 1) / columns, height * (row + 1) / rows
          bitmap = Bitmap.new(right - left, bottom - top)
          bitmaps << bitmap
          bitmap.blt(0, 0, sheet, Rect.new(frame_x + left, frame_y + top, right - left, bottom - top))
          sprite = Sprite.new(viewport)
          sprite.bitmap = bitmap
          sprite.ox, sprite.oy = bitmap.width / 2, bitmap.height / 2
          sprite.x = event.screen_x - width / 2 + left + sprite.ox
          sprite.y = event.screen_y - height + top + sprite.oy
          pieces << [sprite, sprite.x, sprite.y, column, row]
        end
      end
      if cut
        bitmap = Bitmap.new(width + 12, height + 12)
        bitmaps << bitmap
        [bitmap.width, bitmap.height].min.times do |i|
          bitmap.fill_rect(i, bitmap.height - i - 1, 5, 3, Color.new(255, 255, 255))
        end
        slash = Sprite.new(viewport)
        slash.bitmap = bitmap
        slash.x, slash.y = event.screen_x - width / 2 - 6, event.screen_y - height - 6
      end
      event.transparent = true
      pbSEPlay(cut ? 'Cut' : 'Rock Smash')
      pbWait(0.5) do |elapsed|
        t = [elapsed / 0.5, 1.0].min
        slash.opacity = 255 * [1 - t * 3, 0].max if slash
        pieces.each do |sprite, x, y, column, row|
          side = column - (columns - 1) / 2.0
          sprite.x = x + side * (cut ? 32 : 30) * t
          sprite.y = y - Math.sin(t * Math::PI) * (cut ? 6 : 20 + row * 8) + 16 * t * t
          sprite.angle = side * (cut ? 32 : 180) * t
          sprite.opacity = 255 * [1 - t * t, 0].max
        end
      end
    ensure
      event.transparent = original_transparency if event && !original_transparency.nil?
      pieces&.each { |part| part[0].dispose }
      slash&.dispose
      bitmaps&.each(&:dispose)
      source&.dispose
      viewport&.dispose
    end
  end

  module FieldSmashPresentation
    def pbSmashEvent(event)
      return super unless event && event.name[/cuttree|smashrock/i]
      FieldMoveEffects.play(event)
      event.erase
      $PokemonMap&.addErasedEvent(event.id)
    end
  end
end
Object.prepend(ArenaDemo::FieldSmashPresentation)
