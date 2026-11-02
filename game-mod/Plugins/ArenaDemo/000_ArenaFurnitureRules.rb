# Collision rules shared by the native game and the multiplayer service.
module ArenaFurnitureRules
  RAISED = %w[ARENA_FURNITURE_RSE_STAND ARENA_FURNITURE_RSE_SOLID_BOARD].freeze
  WALKABLE = (RAISED + %w[ARENA_FURNITURE_HGSS_RED_CARPET]).freeze
  def self.raised?(item); RAISED.include?(item.to_s); end
  def self.walkable?(item); WALKABLE.include?(item.to_s); end
end
