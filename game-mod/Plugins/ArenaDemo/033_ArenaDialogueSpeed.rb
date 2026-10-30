# Hold physical Enter to reveal dialogue four times faster. Native pauses,
# confirmation edges and choice handling are left to the message system.
module ArenaDemo::DialogueSpeed
  def updateInternal
    original_delay = @text_delay
    held = Input.respond_to?(:pressex?) ? Input.pressex?(:RETURN) : Input.press?(Input::USE)
    if @letterbyletter && !@pausing && held && original_delay && original_delay > 0
      @text_delay = original_delay / 4.0
    end
    super
  ensure
    @text_delay = original_delay
  end
end
Window_AdvancedTextPokemon.prepend(ArenaDemo::DialogueSpeed) if defined?(Window_AdvancedTextPokemon)
