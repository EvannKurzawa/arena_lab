# Essentials' supplied animation library is partial. Keep authored animations
# whenever present; give these otherwise generic attacks a readable native effect.
module ArenaDemo
  module BattleAnimationFallbacks
    RELATED = {
      :MUDSLAP => [:MUDSHOT, :SANDATTACK],
      :FUSIONBOLT => [:BOLTSTRIKE, :THUNDERBOLT, :THUNDERSHOCK]
    }.freeze

    def pbFindMoveAnimation(move_id, user_index, hit_num)
      move = GameData::Move.get(move_id)
      candidates = RELATED[move.id]
      return super unless candidates
      mapping = pbLoadMoveToAnim
      # Future installed animation packs take precedence, including OppMove
      # and multi-phase variants selected by the native resolver.
      return super if pbFindMoveAnimDetails(mapping, move.id, user_index, hit_num)
      candidates.each do |candidate|
        next unless GameData::Move.exists?(candidate)
        result = pbFindMoveAnimDetails(mapping, candidate, user_index)
        next unless result
        animation = pbLoadBattleAnimations&.[](result[0])
        next unless animation && animation.length > 1
        next unless pbResolveBitmap("Graphics/Animations/#{animation.graphic}")
        return result
      end
      super
    end
  end
end
Battle::Scene.prepend(ArenaDemo::BattleAnimationFallbacks)
