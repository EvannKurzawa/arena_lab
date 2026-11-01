# Native Essentials/mkxp-z GIF playback, confined to battle battler sprites.
# Local assets are installed by tools/install-animated-battlers.ps1.
module ArenaDemo::AnimatedBattlers
  ROOT = "Graphics/Pokemon/ArenaAnimated"
  # Explicit Essentials v21.1 form numbers, limited to the Black 2/White 2 era.
  # In particular Kyurem uses 3/4 for its glowing White/Black battle forms.
  FORMS = {
    :UNOWN => (1..27).to_a, :CASTFORM => [1, 2, 3], :DEOXYS => [1, 2, 3],
    :BURMY => [1, 2], :WORMADAM => [1, 2], :CHERRIM => [1],
    :SHELLOS => [1], :GASTRODON => [1], :ROTOM => [1, 2, 3, 4, 5],
    :GIRATINA => [1], :SHAYMIN => [1],
    :ARCEUS => [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17],
    :BASCULIN => [1], :DARMANITAN => [1], :DEERLING => [1, 2, 3],
    :SAWSBUCK => [1, 2, 3], :TORNADUS => [1], :THUNDURUS => [1],
    :LANDORUS => [1], :KYUREM => [1, 2, 3, 4], :KELDEO => [1],
    :MELOETTA => [1], :GENESECT => [1, 2, 3, 4]
  }.transform_values { |forms| forms.freeze }.freeze

  def self.filename(pkmn, back)
    return nil if pkmn.egg? || pkmn.shadowPokemon?
    form = pkmn.form
    if pkmn.species == :LUGIA && form == 1
      gif = "#{ROOT}/#{back ? 'back' : 'front'}/LUGIA_1.gif"
      return gif if File.file?(gif)
      path = "#{ROOT}/#{back ? 'back/[2,8]' : 'front/[4,4]'}LUGIA_1.png"
      return File.file?(path) ? path : nil
    end
    return nil if form != 0 && !FORMS.fetch(pkmn.species, []).include?(form)
    return nil if MultipleForms.getFunction(pkmn.species, "alterBitmap")
    folder = "#{ROOT}/#{back ? 'back' : 'front'}#{pkmn.shiny? ? '-shiny' : ''}"
    base = "#{folder}/#{pkmn.species}"
    base += "_#{form}" if form != 0
    female = "#{base}_female.gif"
    return female if pkmn.gender == 1 && File.file?(female)
    path = "#{base}.gif"
    return File.file?(path) ? path : nil
  end

  # Keep the bottom anchor and native padding while allowing the canvas to grow
  # around full-scale artwork. Species metrics and battle effects use that anchor.
  class Canvas
    attr_reader :bitmap, :width, :height
    def initialize(path, original)
      @source = AnimatedBitmap.new(path)
      bottom = original.height - 1
      bottom -= 1 while bottom > 0 && (0...original.width).all? { |x| original.get_pixel(x, bottom).alpha == 0 }
      padding = original.height - bottom - 1
      # BW GIFs use native pixels; the imported XD001 PNG strips are already 2x.
      # Grow the transparent canvas instead of shrinking large wings/back poses.
      scale = File.extname(path).downcase == '.gif' ? 2.0 : 1.0
      w, h = [(@source.width * scale).round, 1].max, [(@source.height * scale).round, 1].max
      @width, @height = [original.width, w].max, [original.height, h + padding].max
      @bitmap = Bitmap.new(@width, @height)
      @target = Rect.new((@width - w) / 2, @height - padding - h, w, h)
      @frame = nil
      update
    rescue Exception
      @source&.dispose
      @bitmap&.dispose
      raise
    end

    def update
      @source.update
      frame = @source.currentIndex
      return if @frame == frame
      @frame = frame
      @bitmap.clear
      @bitmap.stretch_blt(@target, @source.bitmap, Rect.new(0, 0, @source.width, @source.height))
    end

    def dispose
      @source.dispose
      @bitmap.dispose unless @bitmap.disposed?
    end
    def disposed?; @bitmap.disposed?; end
    def currentIndex; @source.currentIndex; end
    def length; @source.length; end
  end

  module Sprite
    def setPokemonBitmap(pkmn, back = false)
      super
      path = ArenaDemo::AnimatedBattlers.filename(pkmn, back)
      return unless path && @_iconBitmap
      replacement = ArenaDemo::AnimatedBattlers::Canvas.new(path, @_iconBitmap.bitmap)
      old = @_iconBitmap
      @_iconBitmap = replacement
      self.bitmap = replacement.bitmap
      old.dispose
      pbSetPosition
    end
  end
end
Battle::Scene::BattlerSprite.prepend(ArenaDemo::AnimatedBattlers::Sprite)
