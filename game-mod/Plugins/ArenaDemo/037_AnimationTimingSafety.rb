# Seed transition state when a pack starts by fading an unset background.
# Matches the native timing player's expected [x, y, opacity, color] state.
# The pack author's v21.1 note flags nil opacity in these fade sequences.
module ArenaDemo::AnimationTimingSafety
  def playTiming(frame, bg_graphic, bg_color, fo_graphic, fo_color, old_bg = [], old_fo = [], user = nil)
    [[bg_graphic, bg_color, old_bg], [fo_graphic, fo_color, old_fo]].each do |graphic, plane, state|
      visual = graphic.bitmap.nil? ? plane : graphic
      values = [graphic.ox, graphic.oy, visual.opacity, visual.color.clone]
      values.each_with_index { |value, i| state[i] = value if state[i].nil? }
    end
    super
  end
end
PBAnimation.prepend(ArenaDemo::AnimationTimingSafety)
