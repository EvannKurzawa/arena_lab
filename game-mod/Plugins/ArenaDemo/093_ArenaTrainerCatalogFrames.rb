# Character sheets contain four complete poses per direction, including wide
# trainers such as Biker and Cueball. Fit the whole pose into the menu icon slot.
module ArenaDemo::TrainerCatalogFrames
  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    entry = @entries[index]
    path = entry[:sprite] && "Graphics/Characters/#{entry[:sprite]}"
    if path && pbResolveBitmap(path)
      @arena_trainer_bitmaps ||= {}
      bitmap = @arena_trainer_bitmaps[entry[:sprite]]
      if !bitmap || bitmap.disposed?
        bitmap = RPG::Cache.load_bitmap("Graphics/Characters/", entry[:sprite])
        @arena_trainer_bitmaps[entry[:sprite]] = bitmap
      end
      width, height = bitmap.width / 4, bitmap.height / 4
      scale = [44.0 / width, 48.0 / height, 1.0].min
      w, h = [(width * scale).floor, 1].max, [(height * scale).floor, 1].max
      target = Rect.new(rect.x + 4 + (44 - w) / 2, rect.y + (56 - h) / 2, w, h)
      contents.stretch_blt(target, bitmap, Rect.new(width, 0, width, height))
    end
    pbDrawShadowText(contents, rect.x + 54,
                     rect.y + (contents.text_offset_y || 0),
                     rect.width - 54, rect.height,
                     @commands[index], baseColor, shadowColor)
  end

  def dispose
    @arena_trainer_bitmaps&.each_value { |bitmap| bitmap.dispose unless bitmap.disposed? }
    @arena_trainer_bitmaps = nil
    super
  end
end
ArenaCatalogWindow.prepend(ArenaDemo::TrainerCatalogFrames)
