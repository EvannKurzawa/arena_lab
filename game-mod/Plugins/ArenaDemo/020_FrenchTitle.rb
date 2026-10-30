# The repository's title_screen.png is installed into the local game by
# Prepare-Clients so source updates deliver the same title art to all players.
if defined?(IntroEventScene)
  class IntroEventScene
    TITLE_ART_WIDTH = 3712
    TITLE_ART_HEIGHT = 2475

    # Enter the custom screen directly instead of playing the stock splashes.
    alias arena_title_base_splash open_splash
    def open_splash(scene, *args)
      return open_title_screen(scene, *args) if FileTest.exist?('Graphics/Titles/arena_title.png')
      arena_title_base_splash(scene, *args)
    end

    alias arena_title_base_open open_title_screen
    def open_title_screen(_scene, *args)
      return arena_title_base_open(_scene, *args) unless FileTest.exist?('Graphics/Titles/arena_title.png')
      onUpdate.clear
      onCTrigger.clear
      @pic.name = 'Graphics/Titles/arena_title'
      scale = [Graphics.width.to_f / TITLE_ART_WIDTH, Graphics.height.to_f / TITLE_ART_HEIGHT].min
      @pic.setZoom(0, scale * 100)
      @pic.setXY(0, (Graphics.width - TITLE_ART_WIDTH * scale).round / 2,
                    (Graphics.height - TITLE_ART_HEIGHT * scale).round / 2)
      @pic.moveOpacity(0, FADE_TICKS, 255)
      @pic2.setVisible(0, false)
      @arena_prompt_bitmap = Bitmap.new(Graphics.width, 48)
      @arena_prompt_bitmap.fill_rect(64, 0, Graphics.width - 128, 44, Color.new(0, 0, 0, 170))
      pbSetSystemFont(@arena_prompt_bitmap)
      @arena_prompt_bitmap.font.size = 22
      # mkxp-z reports rendered glyph height; account for the system font's
      # baseline offset so the visible text is centered in the 44px panel.
      prompt_height = 44
      prompt_y = (@arena_prompt_bitmap.respond_to?(:text_offset_y) ? @arena_prompt_bitmap.text_offset_y : 0) || 0
      @arena_prompt_bitmap.draw_text(0, prompt_y, Graphics.width, prompt_height, 'APPUYEZ SUR ENTRÉE OU ESPACE', 1)
      @arena_prompt = addBitmap(0, Graphics.height - 56, @arena_prompt_bitmap)
      @arena_prompt.setOpacity(0, 0, 0)
      @arena_prompt.moveOpacity(0, FADE_TICKS, 255)
      pictureWait
      if FileTest.exist?('Audio/BGM/Arena Title.mp3')
        pbBGMPlay('Arena Title')
      else
        pbBGMPlay($data_system.title_bgm)
      end
      onUpdate.set(method(:title_screen_update))
      onCTrigger.set(method(:close_title_screen))
    end

    alias arena_title_base_fade fade_out_title_screen
    def fade_out_title_screen(scene)
      return arena_title_base_fade(scene) unless @arena_prompt
      onUpdate.clear
      onCTrigger.clear
      @arena_prompt.clearProcesses
      @arena_prompt.moveOpacity(0, FADE_TICKS, 0)
      @pic.moveOpacity(0, FADE_TICKS, 0)
      pbBGMStop(1.0)
      pictureWait
      scene.dispose
    end

    alias arena_title_base_update title_screen_update
    def title_screen_update(scene, args)
      if @arena_prompt && !@arena_prompt.running?
        @arena_prompt.moveOpacity(TICKS_PER_ENTER_FLASH * 2 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 0)
        @arena_prompt.moveOpacity(TICKS_PER_ENTER_FLASH * 6 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 255)
      end
      arena_title_base_update(scene, args)
    end

    alias arena_title_base_dispose dispose
    def dispose
      arena_title_base_dispose
      @arena_prompt_bitmap.dispose if @arena_prompt_bitmap && !@arena_prompt_bitmap.disposed?
    end
  end
end

# Debug compilation stays enabled, but the desktop game still shows its title.
module ArenaDemo::TitleEntry
  def pbCallTitle
    return Scene_Intro.new if FileTest.exist?('Graphics/Titles/arena_title.png')
    super
  end
end
Object.prepend(ArenaDemo::TitleEntry)
Kernel.singleton_class.prepend(ArenaDemo::TitleEntry)
