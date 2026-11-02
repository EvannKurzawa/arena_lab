# Collision rules shared by the native game and the multiplayer service.
module ArenaFurnitureRules
  RAISED = %w[ARENA_FURNITURE_RSE_STAND ARENA_FURNITURE_RSE_SOLID_BOARD].freeze
  WALKABLE = (RAISED + %w[ARENA_FURNITURE_HGSS_RED_CARPET]).freeze
  WIDE = %w[ARENA_FURNITURE_DPPT_LABMACHINE ARENA_FURNITURE_DPPT_BIGOILDRUM
            ARENA_FURNITURE_TREE_LEAFY ARENA_FURNITURE_TREE_PINE].freeze
  def self.raised?(item); RAISED.include?(item.to_s); end
  def self.walkable?(item); WALKABLE.include?(item.to_s); end
  def self.width(item); WIDE.include?(item.to_s) ? 2 : 1; end
  def self.cells(item, x, y); width(item).times.map { |dx| [x + dx, y] }; end
  def self.positions(placements)
    placements.flat_map { |kind,item,x,y| kind == 0 ? cells(item,x,y) : [[x,y]] }
  end
  def self.valid_footprints?(placements, surface, relief = nil, reserved = [])
    positions = []
    placements.each do |kind,item,x,y|
      cells = kind == 0 ? self.cells(item,x,y) : [[x,y]]
      return false unless cells.all? do |px,py|
        px.between?(0,99) && py.between?(0,99) && !reserved.include?([px,py]) &&
          !ArenaRelief.blocked_surface?(surface,px,py) &&
          (!relief || (!ArenaRelief.wall?(relief,px,py) &&
           ArenaRelief.at(relief,px,py) == ArenaRelief.at(relief,x,y)))
      end
      positions.concat(cells)
    end
    positions.length == positions.uniq.length
  end
end
