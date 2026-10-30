# Shared material IDs and collision rules. No engine/graphics dependencies.
module ArenaMaterials
  ALPHABET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.freeze
  FLOORS = {
    'plain' => ['Sol de base', :classic], 'grass' => ['Herbe', :classic],
    'desert' => ['Sable', :classic], 'ice' => ['Glace (glissante)', :classic],
    'rock' => ['Roche', :classic], 'snow' => ['Neige', :classic],
    'volcanic' => ['Sol volcanique', :classic], 'lava' => ['Lave (infranchissable)', :hazard],
    'water' => ['Eau (Surf)', :hazard],
    'pavers' => ['Pavés', :material], 'parquet' => ['Parquet', :material],
    'metal' => ['Métal et grilles', :material], 'dirt' => ['Terre battue', :classic],
    'moss' => ['Mousse', :classic], 'wood' => ['Planches', :material],
    'mud' => ['Boue', :classic], 'roots' => ['Terre et racines', :classic],
    'ruins' => ['Dalles de ruines', :material], 'crystal' => ['Dalles de cristal', :material],
    'arena' => ['Dalles de combat', :material],
    'type_normal' => ['Normal — mosaïque ivoire', :type],
    'type_fire' => ['Feu — braises minérales', :type],
    'type_water' => ['Eau — céramique à vagues (praticable)', :type],
    'type_electric' => ['Électrik — circuits dorés', :type],
    'type_grass' => ['Plante — nervures végétales', :type],
    'type_ice' => ['Glace — cristaux de givre (praticable)', :type],
    'type_fighting' => ['Tatami', :type],
    'type_poison' => ['Améthyste', :type],
    'type_ground' => ['Sol — dunes gravées', :type],
    'type_flying' => ['Vol — mosaïque de nuages', :type],
    'type_psychic' => ['Quartz rose', :type],
    'type_bug' => ['Insecte — alvéoles d’ambre', :type],
    'type_rock' => ['Roche — basalte fissuré', :type],
    'type_ghost' => ['Basalte nocturne', :type],
    'type_dragon' => ['Dragon — écailles minérales', :type],
    'type_dark' => ['Obsidienne', :type],
    'type_steel' => ['Plaques métalliques', :type],
    'type_fairy' => ['Fée — étoiles opalines', :type],
    # Append only: the position of older entries is their saved/wire ID.
    'toxic' => ['Déchets toxiques', :hazard],
    'marsh_water' => ['Eau de marécage (Surf)', :hazard],
    'steel_blue' => ['Acier bleuté', :material],
    'holo_hex' => ['Hexagones holographiques', :material],
    'quicksand' => ['Sables mouvants', :hazard]
  }.transform_values(&:freeze).freeze
  # Keep old save/wire IDs and platform dependencies, but no longer offer these
  # materials in the floor picker. Never renumber SURFACE_CODES when retiring.
  RETIRED_FLOORS = %w[parquet moss arena metal type_normal type_fire type_water
    type_electric type_grass type_ice type_ground type_flying type_bug
    type_rock type_dragon type_fairy].freeze
  VISIBLE_FLOORS = (FLOORS.keys - RETIRED_FLOORS).freeze
  SURFACE_CODES = { 'void' => '0' }.merge(FLOORS.keys.each_with_index.to_h { |key, i| [key, ALPHABET[i + 1]] }).freeze
  SURFACE_BYTES = SURFACE_CODES.values.map(&:ord).freeze
  SURF_GROUNDS = %w[water marsh_water].freeze
  CASCADE_GROUNDS = %w[water lava marsh_water toxic mud].freeze
  BLOCKED_GROUNDS = %w[lava water toxic marsh_water].freeze
  # Quicksand is enterable, but cannot support occupants, relief or fixed exits.
  UNSAFE_GROUNDS = (BLOCKED_GROUNDS + ['quicksand']).freeze
  BLOCKED_BYTES = (['void'] + UNSAFE_GROUNDS).map { |key| SURFACE_CODES.fetch(key).ord }.freeze
  STYLES = {
    'grass' => ['Herbe', 'grass'], 'mountain' => ['Montagne', 'rock'],
    'snow' => ['Neige', 'snow'], 'volcano' => ['Volcanique', 'volcanic'],
    'desert' => ['Désert — grès', 'desert'], 'forest' => ['Forêt — racines', 'roots'],
    'ruins' => ['Ruines anciennes', 'ruins'], 'crystal' => ['Cristal', 'crystal'],
    'industrial' => ['Industrielle', 'metal'], 'wood' => ['Bois', 'wood'],
    'swamp' => ['Marécage', 'mud'], 'arena' => ['Arène de combat', 'arena']
  }.transform_values(&:freeze).freeze
  # Keep the first four IDs from protocol 7; append all new styles.
  STYLE_KEYS = %w[mountain grass snow volcano desert forest ruins crystal industrial wood swamp arena].freeze
  RETIRED_STYLES = ['arena'].freeze
  VISIBLE_STYLES = (STYLE_KEYS - RETIRED_STYLES).freeze
  STYLE_BYTES = STYLE_KEYS.each_index.map { |i| ALPHABET[i].ord }.freeze
  module_function
  def valid_surface?(grid)
    grid.is_a?(String) && grid.bytesize == 10000 && grid.bytes.all? { |b| SURFACE_BYTES.include?(b) }
  end

  def ground_at(surface, x, y)
    return nil unless x.between?(0, 99) && y.between?(0, 99)
    SURFACE_CODES.key(surface[y * 100 + x])
  end

  def traversable?(surface, x, y, mode = :walk)
    ground = ground_at(surface, x, y)
    return false unless ground && ground != 'void'
    return mode == :surf if SURF_GROUNDS.include?(ground)
    !BLOCKED_GROUNDS.include?(ground)
  end
end

module ArenaRelief
  SIZE = 100
  DIRECTIONS = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }.freeze
  CODES = [0, 1, 2, 4, 6, 8].freeze
  STYLES = ArenaMaterials::STYLE_KEYS
  module_function

  def valid_styles?(styles, relief)
    return false unless styles.is_a?(String) && styles.bytesize == SIZE * SIZE && styles.bytes.all? { |b| ArenaMaterials::STYLE_BYTES.include?(b) }
    return false unless relief.is_a?(String) && relief.bytesize == SIZE * SIZE
    styles.bytes.each_with_index.all? { |byte, i| byte == 48 || relief.getbyte(i) != 48 }
  end

  def blocked_surface?(surface, x, y)
    return true unless x.between?(0, SIZE - 1) && y.between?(0, SIZE - 1)
    ArenaMaterials::BLOCKED_BYTES.include?(surface.getbyte(y * SIZE + x))
  end

  # 0: ground, 1: platform, 2/4/6/8: stair ascending in that direction.
  def at(grid, x, y)
    return nil unless x.between?(0, SIZE - 1) && y.between?(0, SIZE - 1)
    grid.getbyte(y * SIZE + x).to_i - 48
  end

  def step?(grid, x, y, nx, ny)
    a, b = at(grid, x, y), at(grid, nx, ny)
    return false unless a && b
    return false if wall?(grid, x, y) || wall?(grid, nx, ny)
    return true if [x, y] == [nx, ny]
    direction = DIRECTIONS.key([nx - x, ny - y])
    return false unless direction
    # Parallel stair segments form a wider staircase without internal rails.
    return true if a > 1 && a == b && direction != a && direction != 10 - a
    return false if a > 1 && direction != a && direction != 10 - a
    return false if b > 1 && direction != b && direction != 10 - b
    from = a > 1 ? (direction == a ? 1 : 0) : a
    to = b > 1 ? (10 - direction == b ? 1 : 0) : b
    from == to
  end

  # The south face occupies a separate lower cell, never a walkable summit.
  def wall?(grid, x, y)
    at(grid, x, y) == 0 && at(grid, x, y - 1) == 1
  end

  def valid?(grid, surface, reserved = [], placements = [])
    return false unless grid.is_a?(String) && grid.bytesize == SIZE * SIZE &&
                        grid.match?(/\A[012468]{10000}\z/)
    return false unless surface.is_a?(String) && surface.bytesize == SIZE * SIZE
    grid.bytes.each_with_index do |byte, i|
      code = byte - 48
      if wall?(grid, i % SIZE, i / SIZE)
        return false if reserved.include?([i % SIZE, i / SIZE]) ||
                        placements.any? { |p| p[-2] == i % SIZE && p[-1] == i / SIZE }
      end
      next if code == 0
      water_top = code == 1 && ArenaMaterials::CASCADE_GROUNDS.include?(ArenaMaterials.ground_at(surface, i % SIZE, i / SIZE))
      return false if blocked_surface?(surface, i % SIZE, i / SIZE) && !water_top
      x, y = i % SIZE, i / SIZE
      return false if reserved.include?([x, y])
      next if code == 1
      dx, dy = DIRECTIONS.fetch(code)
      return false unless at(grid, x + dx, y + dy) == 1 &&
                          at(grid, x - dx, y - dy) == 0
      lx, ly = x - dx, y - dy
      return false if !lx.between?(0, SIZE - 1) || !ly.between?(0, SIZE - 1) ||
                      blocked_surface?(surface, lx, ly)
      return false if wall?(grid, lx, ly)
      return false if placements.any? { |p| p[-2] == x && p[-1] == y }
    end
    true
  end
end
