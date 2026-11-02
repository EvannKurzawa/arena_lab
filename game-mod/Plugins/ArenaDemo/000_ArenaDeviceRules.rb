# Shared primitive rules: the existing ordered placement wire format stays intact.
module ArenaDevices
  DIRECTIONS = { 'D' => [2, 0, 1], 'L' => [4, -1, 0], 'R' => [6, 1, 0], 'U' => [8, 0, -1] }.freeze
  CONVEYORS = DIRECTIONS.keys.map { |d| "ARENA_CONVEYOR_#{d}" }.freeze
  MAGNETS = DIRECTIONS.keys.map { |d| "ARENA_MAGNET_#{d}" }.freeze
  TELEPORT = 'ARENA_TELEPORTER'
  COIL = 'ARENA_TESLA'
  COILS = ([COIL] + DIRECTIONS.keys.map { |d| "ARENA_TESLA_#{d}" }).freeze
  BUTTON = 'ARENA_TESLA_BUTTON'
  WEB = 'ARENA_WEB'
  RUNE = 'ARENA_BLIND_RUNE'
  FLOOR = (CONVEYORS + [TELEPORT, BUTTON, WEB, RUNE]).freeze
  ITEMS = (FLOOR + MAGNETS + COILS).freeze
  module_function

  def item?(item); ITEMS.include?(item.to_s); end
  def direction(item); DIRECTIONS[item.to_s.split('_').last]; end
  def floor?(item); FLOOR.include?(item.to_s); end
  def coil?(item); COILS.include?(item.to_s); end
  def furniture(placements); placements.select { |p| p[0] == 0 }; end

  # Pairs are inserted/removed atomically. Their order is preserved in saves/wire.
  def partner(placements, slot)
    objects = furniture(placements)
    object = objects[slot] if slot.is_a?(Integer) && slot >= 0
    return nil unless object
    if object[1] == TELEPORT
      slots = objects.each_index.select { |i| objects[i][1] == TELEPORT }
      index = slots.index(slot)
      slots[index.even? ? index + 1 : index - 1]
    elsif coil?(object[1]) || object[1] == BUTTON
      own = objects.each_index.select { |i| coil?(object[1]) ? coil?(objects[i][1]) : objects[i][1] == BUTTON }
      other = objects.each_index.select { |i| coil?(object[1]) ? objects[i][1] == BUTTON : coil?(objects[i][1]) }
      other[own.index(slot)]
    end
  end

  def valid_pairs?(placements)
    return false unless placements.is_a?(Array) && placements.all? { |p| p.is_a?(Array) && p.length == 4 }
    objects = furniture(placements)
    objects.count { |p| p[1] == TELEPORT }.even? &&
      objects.count { |p| coil?(p[1]) } == objects.count { |p| p[1] == BUTTON }
  end

  def valid_disabled?(disabled, placements)
    objects = furniture(placements)
    disabled.is_a?(Array) && disabled.uniq == disabled && disabled.length <= 40 &&
      disabled.all? { |slot| slot.is_a?(Integer) && slot >= 0 && objects[slot] && coil?(objects[slot][1]) }
  end

  def blocked?(item, slot, disabled)
    return false if floor?(item)
    return false if defined?(ArenaFurnitureRules) && ArenaFurnitureRules.walkable?(item)
    true
  end

  def spark_target(placements, slot)
    object = furniture(placements)[slot]
    return nil unless object && coil?(object[1])
    directions = object[1] == COIL ? %w[R D L U] : [object[1].split('_').last]
    occupied = defined?(ArenaFurnitureRules) ? ArenaFurnitureRules.positions(placements) : placements.map { |p| p[2,2] }
    directions.each do |key|
      _direction, dx, dy = DIRECTIONS.fetch(key)
      point = [object[2] + dx, object[3] + dy]
      next unless point.all? { |v| v.between?(0, 99) }
      next if object[1] == COIL && occupied.include?(point)
      return point
    end
    nil
  end

  def sparks(placements, disabled = [])
    furniture(placements).each_with_index.filter_map do |p, slot|
      next unless coil?(p[1]) && !disabled.include?(slot)
      point = spark_target(placements, slot)
      [slot, point] if point
    end.to_h
  end

  def valid_sparks?(placements, surface, relief, reserved = [])
    occupied = defined?(ArenaFurnitureRules) ? ArenaFurnitureRules.positions(placements) : placements.map { |p| p[2,2] }
    furniture(placements).each_with_index.all? do |p, slot|
      next true unless coil?(p[1]) && p[1] != COIL
      point = spark_target(placements, slot)
      point && !occupied.include?(point) && !reserved.include?(point) &&
        !ArenaRelief.blocked_surface?(surface, *point) && ArenaRelief.step?(relief, *p[2, 2], *point)
    end
  end

  def teleport_target(placements, x, y)
    objects = furniture(placements)
    slot = objects.index { |p| p[1] == TELEPORT && p[2, 2] == [x, y] }
    target = partner(placements, slot) if slot
    target && objects[target][2, 2]
  end

  def attraction(placements, x, y)
    furniture(placements).filter_map do |p|
      next unless MAGNETS.include?(p[1])
      direction, dx, dy = direction(p[1])
      distance = dx == 0 ? (y - p[3]) * dy : (x - p[2]) * dx
      aligned = dx == 0 ? x == p[2] : y == p[3]
      next unless aligned && distance > 1
      [distance, { 2 => 8, 4 => 6, 6 => 4, 8 => 2 }[direction]]
    end.min_by { |distance, dir| [distance, dir] }&.last
  end
end
