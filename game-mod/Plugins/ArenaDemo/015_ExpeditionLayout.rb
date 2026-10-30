# Pure Ruby expedition plans. Only primitive values enter PokemonGlobal saves.
module ArenaDemo
  module ExpeditionLayout
    VERSION = 2
    SIDE = 4
    SIZE = 64
    FIRST_MAP = 110
    HOME = 13
    # Percent per independently rolled region. The home region is always grass.
    # name, chance, habitat types, visual theme
    BIOMES = {
      'grassland' => ['Grassland', 52, [:NORMAL, :GRASS, :FLYING], :green],
      'forest' => ['Dense Forest', 12, [:BUG, :GRASS, :FLYING], :green],
      'desert' => ['Desert', 5, [:GROUND, :ROCK], :sand],
      'volcano' => ['Volcanic Fields', 4, [:FIRE, :ROCK, :GROUND], :rock],
      'snow' => ['Snow Peaks', 4, [:ICE], :snow],
      'lake' => ['Lake District', 4, [:WATER], :green],
      'swamp' => ['Misty Swamp', 3, [:POISON, :WATER, :BUG], :mud],
      'canyon' => ['Rocky Canyon', 3, [:ROCK, :GROUND, :FIGHTING], :sand],
      'crystal' => ['Crystal Caverns', 2, [:ROCK, :STEEL, :PSYCHIC, :DRAGON], :crystal],
      'ruins' => ['Ancient Ruins', 2, [:GHOST, :PSYCHIC, :GROUND], :ruins],
      'meadow' => ['Flower Meadow', 3, [:FAIRY, :GRASS, :BUG], :green],
      'storm' => ['Storm Plains', 2, [:ELECTRIC, :FLYING], :green],
      'coast' => ['Coast and Islands', 2, [:WATER, :FLYING], :sand],
      'bamboo' => ['Bamboo Grove', 1, [:GRASS, :FIGHTING, :DARK], :green],
      'power' => ['Abandoned Power Station', 1, [:ELECTRIC, :STEEL, :GHOST], :metal]
    }.freeze

    # A private, versioned PRNG avoids consuming Essentials' battle/network RNG.
    class RNG
      def initialize(seed); @value = seed & 0xffffffff; end
      def rand(limit)
        @value = (1664525 * @value + 1013904223) & 0xffffffff
        ((@value >> 8) * limit) >> 24
      end
    end

    # Smooth value noise with independent octave seeds. Domain warping bends
    # contours, avoiding the grid-aligned circles and stripes of the old layout.
    # Method references and implementation boundaries: docs/EXPEDITION_GENERATION.md.
    class Field
      def initialize(seed); @seed = seed; @lattice = {}; end
      def lattice(x, y, salt)
        @lattice[[x, y, salt]] ||= begin
          value = (x * 374761393 + y * 668265263 + @seed + salt * 1442695041) & 0xffffffff
          value = ((value ^ (value >> 13)) * 1274126177) & 0xffffffff
          ((value ^ (value >> 16)) & 0xffffff).to_f / 0xffffff
        end
      end
      def sample(x, y, scale, salt = 0)
        x, y = x / scale, y / scale
        ix, iy = x.floor, y.floor
        tx, ty = x - ix, y - iy
        tx = tx * tx * tx * (tx * (tx * 6 - 15) + 10)
        ty = ty * ty * ty * (ty * (ty * 6 - 15) + 10)
        a, b = lattice(ix, iy, salt), lattice(ix + 1, iy, salt)
        c, d = lattice(ix, iy + 1, salt), lattice(ix + 1, iy + 1, salt)
        (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
      end
      def fractal(x, y, scale, salt = 0)
        (sample(x, y, scale, salt) + 0.45 * sample(x, y, scale / 2, salt + 1) +
          0.2 * sample(x, y, scale / 4, salt + 2)) / 1.65
      end
    end

    class Frontier
      def initialize; @heap = []; end
      def push(priority, position)
        item = [priority, position]
        i = @heap.length
        @heap << item
        while i > 0
          parent = (i - 1) / 2
          break if @heap[parent][0] <= priority
          @heap[i] = @heap[parent]
          i = parent
        end
        @heap[i] = item
      end
      def pop
        return nil if @heap.empty?
        result = @heap[0][1]
        last = @heap.pop
        unless @heap.empty?
          i = 0
          while (child = i * 2 + 1) < @heap.length
            child += 1 if child + 1 < @heap.length && @heap[child + 1][0] < @heap[child][0]
            break if last[0] <= @heap[child][0]
            @heap[i] = @heap[child]
            i = child
          end
          @heap[i] = last
        end
        result
      end
    end
    module_function

    def map?(id); id.is_a?(Integer) && id.between?(FIRST_MAP, FIRST_MAP + SIDE * SIDE - 1); end
    def index(id); id - FIRST_MAP; end
    def biome_at_roll(roll)
      raise ArgumentError, 'Biome roll must be between 0 and 99' unless roll.between?(0, 99)
      BIOMES.each do |key, data|
        return key if roll < data[1]
        roll -= data[1]
      end
      raise ArgumentError, 'Biome roll must be between 0 and 99'
    end

    def neighbor(region, direction)
      x, y = region % SIDE, region / SIDE
      case direction
      when 2 then y < SIDE - 1 ? region + SIDE : nil
      when 4 then x > 0 ? region - 1 : nil
      when 6 then x < SIDE - 1 ? region + 1 : nil
      when 8 then y > 0 ? region - SIDE : nil
      end
    end

    def build(seed)
      rng = RNG.new(seed)
      biomes = Array.new(SIDE * SIDE) { |i| i == HOME ? 'grassland' : biome_at_roll(rng.rand(100)) }
      regions = biomes.each_with_index.map do |biome, i|
        result = build_region(biome, RNG.new(seed ^ (i + 1) * 2654435761), i)
        yield(i + 1, biomes.length) if block_given?
        result
      end
      { 'version' => VERSION, 'seed' => seed, 'regions' => regions }
    end

    def build_region(biome, rng, region)
      field = Field.new(rng.rand(0x7fffffff))
      cells = 'b' * (SIZE * SIZE)
      heights, moisture, costs = [], [], []
      SIZE.times do |y|
        SIZE.times do |x|
          wx = x + (field.sample(x, y, 27.0, 20) - 0.5) * 14
          wy = y + (field.sample(x, y, 27.0, 21) - 0.5) * 14
          pos = y * SIZE + x
          h = heights[pos] = field.fractal(wx, wy, 24.0, 1)
          m = moisture[pos] = field.fractal(wx, wy, 15.0, 8)
          costs[pos] = 1 + field.fractal(x, y, 18.0, 14) * 4
        end
      end
      sorted_h, sorted_m = heights.sort, moisture.sort
      low = sorted_h[(sorted_h.length * (biome == 'swamp' ? 0.18 : 0.3)).to_i]
      high_fraction = { 'snow' => 0.68, 'canyon' => 0.7, 'crystal' => 0.7, 'volcano' => 0.8 }.fetch(biome, 0.94)
      high = sorted_h[(sorted_h.length * high_fraction).to_i]
      grass_line = sorted_m[(sorted_m.length * (['forest', 'bamboo', 'desert'].include?(biome) ? 0.82 : 0.72)).to_i]
      SIZE.times do |y|
        SIZE.times do |x|
          pos = y * SIZE + x
          h, m = heights[pos], moisture[pos]
          kind = m > grass_line ? 'g' : 'b'
          if kind == 'b' && BIOMES.fetch(biome)[3] == :green && h > sorted_h[(sorted_h.length * 0.66).to_i]
            kind = 'a' # Auto-tiled low vegetation, separate from encounter grass.
          end
          kind = 'o' if h > high
          case biome
          when 'lake', 'swamp'
            kind = 'w' if h < low
          when 'coast'
            kind = 'w' if x.to_f / SIZE + (h - 0.5) * 0.8 > 0.58
          when 'volcano'
            kind = 'l' if h < sorted_h[(sorted_h.length * 0.22).to_i]
          end
          cells.setbyte(pos, kind.ord)
        end
      end
      smooth(cells, [111, 119, 108], 2)
      remove_small_patches(cells, [111, 119, 108, 103], 12)
      # Regional architecture is a reserved motif; terrain and roads are built
      # around it. No full map is copied or rotated, so cliffs keep their facing.
      if ['ruins', 'power'].include?(biome)
        (15..28).each do |y|
          (12..28).each do |x|
            wall = [15, 28].include?(y) || [12, 28].include?(x)
            cells.setbyte(y * SIZE + x, (wall ? 'o' : 'b').ord)
          end
        end
        (19..21).each { |x| cells.setbyte(28 * SIZE + x, 'p'.ord) }
      end
      SIZE.times do |n|
        [n, (SIZE - 1) * SIZE + n, n * SIZE, n * SIZE + SIZE - 1].each { |pos| cells.setbyte(pos, 111) }
      end
      nodes = [[SIZE / 2, SIZE / 2]]
      [2, 4, 6, 8].each do |direction|
        next unless neighbor(region, direction)
        nodes << case direction
                 when 2 then [32, SIZE - 1]
                 when 4 then [0, 32]
                 when 6 then [SIZE - 1, 32]
                 when 8 then [32, 0]
                 end
      end
      nodes << [32, SIZE - 7] if region == HOME
      nodes << [20 + rng.rand(24), 20 + rng.rand(24)]
      # Prim's minimum spanning tree connects exits and a local clearing. A*
      # routes each link around water and ridges using a smooth cost field.
      connected, pending = [nodes.shift], nodes
      until pending.empty?
        from, to = connected.product(pending).min_by { |a, b| (a[0] - b[0])**2 + (a[1] - b[1])**2 }
        distance = (from[0] - to[0]).abs + (from[1] - to[1]).abs
        if distance >= 24
          bend = rng.rand(17) - 8
          mx = ((from[0] + to[0]) / 2 + (from[1] == to[1] ? 0 : bend)).clamp(4, SIZE - 5)
          my = ((from[1] + to[1]) / 2 + (from[0] == to[0] ? 0 : bend)).clamp(4, SIZE - 5)
          options = (my - 3..my + 3).flat_map { |y| (mx - 3..mx + 3).map { |x| [x, y] } }
          midpoint = options.min_by { |x, y| (x - mx)**2 + (y - my)**2 + (blocked?(cells.getbyte(y * SIZE + x)) ? 100 : 0) }
          carve_route(cells, costs, heights, from, midpoint)
          carve_route(cells, costs, heights, midpoint, to)
        else
          carve_route(cells, costs, heights, from, to)
        end
        connected << to
        pending.delete(to)
      end
      # Open exactly the shared three-tile crossing at each sector edge.
      [2, 4, 6, 8].each do |direction|
        next unless neighbor(region, direction)
        (-1..1).each do |offset|
          x = direction == 4 ? 0 : (direction == 6 ? SIZE - 1 : SIZE / 2 + offset)
          y = direction == 8 ? 0 : (direction == 2 ? SIZE - 1 : SIZE / 2 + offset)
          cells.setbyte(y * SIZE + x, 'p'.ord)
        end
      end
      if region == HOME
        (SIZE - 9..SIZE - 4).each { |y| (30..34).each { |x| cells.setbyte(y * SIZE + x, 112) } }
      end
      decorations = []
      wooded = ['forest', 'bamboo'].include?(biome)
      target = wooded ? 180 : 32
      candidates = (3...SIZE - 3).flat_map { |y| (3...SIZE - 3).map { |x| [x, y] } }
      (candidates.length - 1).downto(1) do |i|
        j = rng.rand(i + 1)
        candidates[i], candidates[j] = candidates[j], candidates[i]
      end
      candidates.each do |x, y|
        break if decorations.length >= target
        next unless (-1..1).all? { |dy| (-1..1).all? { |dx| [97, 98].include?(cells.getbyte((y + dy) * SIZE + x + dx)) } }
        next if decorations.any? { |entry| (entry[0] - x).abs < (wooded ? 2 : 4) && (entry[1] - y).abs < (wooded ? 2 : 3) }
        next if wooded && moisture[y * SIZE + x] < 0.35
        character = ['forest', 'bamboo', 'grassland', 'meadow', 'storm', 'swamp', 'lake'].include?(biome) ? 'Object tree 1' : 'Object boulder'
        cells.setbyte(y * SIZE + x, 98)
        decorations << [x, y, character]
      end
      occupied = decorations.to_h { |x, y, _| [y * SIZE + x, true] }
      reachable = reachable_cells(cells, occupied)
      cells.bytes.each_with_index { |code, pos| cells.setbyte(pos, 98) if code == 103 && !reachable[pos] }
      # Every sector gets an accessible encounter clearing even when its moisture
      # field is unusually dry. This is a small authored rule, not noise speckle.
      if cells.count('g') < 24
        (26..30).each do |y|
          (28..34).each do |x|
            pos = y * SIZE + x
            cells.setbyte(pos, 103) if reachable[pos] && cells.getbyte(pos) == 98 && !occupied[pos]
          end
        end
      end
      { 'biome' => biome, 'cells' => cells, 'decorations' => decorations, 'style' => VERSION }
    end

    def smooth(cells, kinds, passes)
      passes.times do
        original = cells.dup
        (1...SIZE - 1).each do |y|
          (1...SIZE - 1).each do |x|
            neighbors = [-1, 0, 1].flat_map { |dy| [-1, 0, 1].map { |dx| original.getbyte((y + dy) * SIZE + x + dx) } }
            winner, count = neighbors.tally.max_by { |_kind, n| n }
            cells.setbyte(y * SIZE + x, winner) if count >= 6 && kinds.include?(winner)
          end
        end
      end
    end

    def remove_small_patches(cells, kinds, minimum)
      seen = {}
      cells.bytes.each_with_index do |kind, start|
        next if seen[start] || !kinds.include?(kind)
        queue, cursor = [start], 0
        seen[start] = true
        while cursor < queue.length
          pos = queue[cursor]
          cursor += 1
          neighbors(pos).each do |next_pos|
            next if seen[next_pos] || cells.getbyte(next_pos) != kind
            seen[next_pos] = true
            queue << next_pos
          end
        end
        queue.each { |pos| cells.setbyte(pos, 98) } if queue.length < minimum
      end
    end

    def neighbors(pos)
      x, y = pos % SIZE, pos / SIZE
      result = []
      result << pos - 1 if x > 0
      result << pos + 1 if x < SIZE - 1
      result << pos - SIZE if y > 0
      result << pos + SIZE if y < SIZE - 1
      result
    end

    def carve_route(cells, costs, heights, from, to)
      start, goal = from[1] * SIZE + from[0], to[1] * SIZE + to[0]
      frontier = Frontier.new
      frontier.push(0, start)
      costs_so_far, previous, closed = { start => 0 }, { start => nil }, {}
      while (pos = frontier.pop)
        next if closed[pos]
        closed[pos] = true
        break if pos == goal
        neighbors(pos).each do |next_pos|
          x, y = next_pos % SIZE, next_pos / SIZE
          next if (x == 0 || y == 0 || x == SIZE - 1 || y == SIZE - 1) && next_pos != goal
          code = cells.getbyte(next_pos)
          cost = (code == 112 ? 0.8 : costs[next_pos]) + (heights[next_pos] - heights[pos]).abs * 12
          cost += 80 if blocked?(code)
          total = costs_so_far[pos] + cost
          next if costs_so_far.key?(next_pos) && costs_so_far[next_pos] <= total
          costs_so_far[next_pos], previous[next_pos] = total, pos
          heuristic = ((to[0] - x).abs + (to[1] - y).abs) * 0.8
          frontier.push(total + heuristic, next_pos)
        end
      end
      raise 'Expedition route could not be connected' unless previous.key?(goal)
      pos = goal
      while pos
        x, y = pos % SIZE, pos / SIZE
        # Bridges preserve a water/lava crossing's visual identity. Widen dry
        # paths only on dry land, avoiding the old excavated cross-shaped roads.
        cells.setbyte(pos, [108, 119].include?(cells.getbyte(pos)) ? 118 : 112)
        neighbors(pos).each do |near|
          nx, ny = near % SIZE, near / SIZE
          next if nx == 0 || ny == 0 || nx == SIZE - 1 || ny == SIZE - 1
          cells.setbyte(near, 112) unless blocked?(cells.getbyte(near)) || cells.getbyte(near) == 118
        end
        pos = previous[pos]
      end
    end

    def blocked?(code); [111, 119, 108].include?(code); end # cliff, water, lava

    def reachable_cells(cells, occupied = {})
      start = (SIZE / 2) * SIZE + SIZE / 2
      seen = { start => true }
      queue = [start]
      cursor = 0
      while cursor < queue.length
        pos = queue[cursor]
        cursor += 1
        x, y = pos % SIZE, pos / SIZE
        [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]].each do |nx, ny|
          next unless nx.between?(0, SIZE - 1) && ny.between?(0, SIZE - 1)
          next_pos = ny * SIZE + nx
          next if seen[next_pos] || occupied[next_pos] || blocked?(cells.getbyte(next_pos))
          seen[next_pos] = true
          queue << next_pos
        end
      end
      seen
    end
  end
end
