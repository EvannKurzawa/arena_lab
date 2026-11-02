# Collision rules shared by the native game and the multiplayer service.
module ArenaFurnitureRules
  RAISED = %w[ARENA_FURNITURE_RSE_STAND ARENA_FURNITURE_RSE_SOLID_BOARD].freeze
  WALKABLE = (RAISED + %w[ARENA_FURNITURE_HGSS_RED_CARPET]).freeze
  WIDE = (%w[ARENA_FURNITURE_DPPT_LABMACHINE ARENA_FURNITURE_DPPT_BIGOILDRUM
             ARENA_FURNITURE_TREE_LEAFY ARENA_FURNITURE_TREE_PINE] + RAISED).freeze
  STAND = 'ARENA_FURNITURE_RSE_STAND'.freeze
  def self.raised?(item); RAISED.include?(item.to_s); end
  def self.walkable?(item); WALKABLE.include?(item.to_s); end
  def self.width(item); return 4 if item.to_s == STAND; WIDE.include?(item.to_s) ? 2 : 1; end
  def self.stand_row(x,y); 4.times.map { |dx| [x+dx,y] }; end
  def self.stand_stairs(x,y); [[x,y],[x+3,y]]; end
  def self.relief_cells(item,x,y)
    return stand_row(x,y-2) + stand_row(x,y-1) if item.to_s == STAND
    width(item).times.map { |dx| [x+dx,y] }
  end
  def self.cells(item, x, y)
    return relief_cells(item,x,y) + stand_row(x,y) if item.to_s == STAND
    width(item).times.map { |dx| [x + dx, y] }
  end
  def self.positions(placements)
    placements.flat_map do |kind,item,x,y|
      next [[x,y]] unless kind == 0
      item.to_s == STAND ? stand_row(x,y-2) + stand_row(x,y) : cells(item,x,y)
    end
  end
  def self.valid_footprints?(placements, surface, relief = nil, reserved = [])
    positions = []
    placements.each do |kind,item,x,y|
      if kind == 0 && item.to_s == STAND
        top = stand_row(x,y-2)
        stairs = stand_stairs(x,y-1)
        facade = [[x+1,y-1],[x+2,y-1]]
        floor = stand_row(x,y)
        return false unless (top+stairs+facade+floor).all? { |px,py| px.between?(0,99) && py.between?(0,99) }
        return false if (top+stairs+facade+floor).any? { |point| reserved.include?(point) || positions.include?(point) }
        if relief
          return false unless top.all? { |px,py| ArenaRelief.at(relief,px,py) == 1 } &&
            stairs.all? { |px,py| ArenaRelief.at(relief,px,py) == 8 } &&
            facade.all? { |px,py| ArenaRelief.at(relief,px,py) == 0 } &&
            floor.all? { |px,py| ArenaRelief.at(relief,px,py) == 0 }
        end
        return false unless (top+stairs+facade+floor).all? { |px,py| !ArenaRelief.blocked_surface?(surface,px,py) }
        positions.concat(top+stairs+facade+floor)
        next
      end
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
