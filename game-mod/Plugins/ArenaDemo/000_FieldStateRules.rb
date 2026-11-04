# Primitive, temporary overlay. Placement order/coordinates remain canonical.
module ArenaFieldState
  ITEMS = { 'ARENA_FURNITURE_TREE' => :CUT, 'ARENA_FURNITURE_ROCK' => :ROCKSMASH,
            'ARENA_FURNITURE_BOULDER' => :STRENGTH }.freeze
  DIRECTIONS = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }.freeze
  module_function

  def furniture(placements); placements.select { |p| p[0] == 0 }; end

  def effective(placements, states)
    slot = -1
    placements.filter_map do |entry|
      next entry.dup unless entry[0] == 0
      slot += 1
      point = states.fetch(slot, entry[2, 2])
      point && [entry[0], entry[1], *point]
    end
  end

  def valid?(states, placements, surface, relief)
    return false unless states.is_a?(Hash) && states.length <= 64
    objects = furniture(placements)
    return false unless states.all? do |slot, point|
      next false unless slot.is_a?(Integer) && slot.between?(0, objects.length - 1)
      move = ITEMS[objects[slot][1]]
      if point.nil?
        [:CUT, :ROCKSMASH].include?(move)
      else
        move == :STRENGTH && point.is_a?(Array) && point.length == 2 &&
          point.all? { |v| v.is_a?(Integer) && v.between?(0, 199) } &&
          !ArenaRelief.blocked_surface?(surface, *point) &&
          !ArenaRelief.wall?(relief, *point) && ArenaRelief.at(relief, *point) <= 1
      end
    end
    objects = effective(placements, states)
    points = defined?(ArenaFurnitureRules) ? ArenaFurnitureRules.positions(objects) : objects.map { |p| p[2,2] }
    points.uniq.length == points.length
  end

  def proposal(placements, states, slot, move, direction, surface, relief, reserved = [], players = [])
    return nil unless slot.is_a?(Integer) && slot >= 0 && DIRECTIONS.key?(direction)
    object = furniture(placements)[slot]
    return nil unless object && ITEMS[object[1]] == move
    point = states.fetch(slot, object[2, 2])
    return nil unless point
    result = states.transform_values { |p| p&.dup }
    if move == :STRENGTH
      dx, dy = DIRECTIONS.fetch(direction)
      target = [point[0] + dx, point[1] + dy]
      return nil if reserved.include?(target) || players.include?(target)
      return nil unless ArenaRelief.step?(relief, *point, *target)
      result[slot] = target
    else
      result[slot] = nil
    end
    valid?(result, placements, surface, relief) ? result : nil
  end
end
