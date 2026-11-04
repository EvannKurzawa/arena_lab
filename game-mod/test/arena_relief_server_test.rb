# Real PEMK reactor, wire codec, zones and socket relay; fixture authentication.
require_relative 'arena_visit_harness'

class ArenaReliefServerTest < Minitest::Test
  include ArenaVisitTestSupport
  def test_every_cascade_material_is_preserved_in_raised_room_snapshot
    host, guest = connect, connect
    payload = relief_payload
    ArenaMaterials::CASCADE_GROUNDS.each_with_index do |ground, i|
      payload[:surface].setbyte(51 * 200 + 50 + i, ArenaMaterials::SURFACE_CODES.fetch(ground).ord)
      payload[:relief].setbyte(51 * 200 + 50 + i, 49)
    end
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    joined = join(host, guest, room)
    assert_equal payload[:surface], joined[:surface]
    assert_equal payload[:relief], joined[:relief]
  end
  def test_water_on_platform_relays_height_and_blocks_waterfall_face
    host, guest = connect, connect
    payload = relief_payload
    payload[:surface].setbyte(51 * 200 + 51, ArenaMaterials::SURFACE_CODES.fetch('water').ord)
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    joined = join(host, guest, room)
    assert_equal payload[:surface], joined[:surface]
    assert_equal payload[:relief], joined[:relief]
    [[49, 53], [50, 53], [50, 52], [50, 51]].each do |x, y|
      send_frame(host, type: :pos, map: 100, x: x, y: y)
      # Synchronize via ping without relying on remote map interest.
      send_frame(host, type: :ping, t: 4)
      until_type(host, :pong)
    end
    send_frame(host, type: :pos, map: 100, x: 51, y: 51, mode: :walk)
    assert_equal [50, 51], until_type(host, :pos_correct).values_at(:x, :y)
    send_frame(host, type: :pos, map: 100, x: 51, y: 51, mode: :surf)
    send_frame(host, type: :ping, t: 5)
    until_type(host, :pong)
    send_frame(host, type: :pos, map: 100, x: 51, y: 52, mode: :surf)
    assert_equal [51, 51], until_type(host, :pos_correct).values_at(:x, :y)
  end
  def connect
    socket = TCPSocket.new('127.0.0.1', @backend.reactor.port)
    @clients << socket
    send_frame(socket, type: :arena_hello)
    assert_equal 15, receive(socket)[:version]
    send_frame(socket, type: :pos, map: 102, x: 4, y: 6)
    send_frame(socket, type: :ping, t: 1)
    assert_equal 15, until_type(socket, :pong)[:arena_visits]
    socket
  end
  def relief_payload
    surface = '0' * 40000
    (37..61).each { |y| (37..61).each { |x| surface.setbyte(y * 200 + x, 49) } }
    relief = '0' * 40000
    relief.setbyte(51 * 200 + 50, 49)
    relief.setbyte(51 * 200 + 51, 49)
    relief.setbyte(52 * 200 + 50, 56)
    { type: :arena_open, objects: [], layout: 0, difficulty: 1,
      surface: surface, relief: relief, styles: '0' * 40000, placements: [] }
  end
  def test_relief_snapshot_relay_and_authoritative_stair_collisions
    host, guest = connect, connect
    payload = relief_payload
    payload[:surface].setbyte(51 * 200 + 50, 54)
    payload[:styles].setbyte(51 * 200 + 50, 50)
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    assert_equal payload[:relief], room[:relief]
    joined = join(host, guest, room)
    assert_equal payload.values_at(:surface, :relief), joined.values_at(:surface, :relief)
    assert_equal payload[:styles], joined[:styles]
    send_frame(guest, type: :pos, map: 100, x: 49, y: 53)
    send_frame(guest, type: :ping, t: 2)
    until_type(guest, :pong)
    # Enter at the reserved ground spawn, then approach the raised edge sideways.
    [[49, 53], [49, 52]].each do |x, y|
      send_frame(host, type: :pos, map: 100, x: x, y: y)
      assert_equal [x, y], until_type(guest, :pos).values_at(:x, :y)
    end
    send_frame(host, type: :pos, map: 100, x: 50, y: 52)
    assert_equal [49, 52], until_type(host, :pos_correct).values_at(:x, :y)
    # Use the stairs from below; then descend along the same route.
    [[49, 53], [50, 53], [50, 52], [50, 51], [51, 51]].each do |x, y|
      send_frame(host, type: :pos, map: 100, x: x, y: y)
      assert_equal [x, y], until_type(guest, :pos).values_at(:x, :y)
    end
    send_frame(host, type: :pos, map: 100, x: 51, y: 52)
    assert_equal [51, 51], until_type(host, :pos_correct).values_at(:x, :y), 'South wall is not summit'
    [[50, 51], [50, 52], [50, 53], [51, 53]].each do |x, y|
      send_frame(host, type: :pos, map: 100, x: x, y: y)
      assert_equal [x, y], until_type(guest, :pos).values_at(:x, :y)
    end
    send_frame(host, type: :pos, map: 100, x: 51, y: 52)
    assert_equal [51, 53], until_type(host, :pos_correct).values_at(:x, :y), 'Ground cannot enter wall'
    send_frame(host, type: :arena_close)
    assert_equal :closed, until_type(guest, :arena_state)[:phase]
  end
  def test_relief_server_rejects_malformed_or_unsupported_layouts
    host = connect
    payload = relief_payload
    [nil, 'x' * 40000, '2' * 40000].each do |invalid|
      send_frame(host, payload.merge(styles: invalid))
      assert_equal :arena_error, receive(host)[:type]
    end
    [nil, '1', 'x' * 40000].each do |invalid|
      send_frame(host, payload.merge(relief: invalid))
      assert_equal :arena_error, receive(host)[:type]
    end
    broken = payload[:relief].dup
    broken.setbyte(51 * 200 + 50, 48)
    send_frame(host, payload.merge(relief: broken))
    assert_equal :arena_error, receive(host)[:type]
    send_frame(host, payload.merge(placements: [[0, 'ARENA_FURNITURE_ROCK', 50, 52]]))
    assert_equal :arena_error, receive(host)[:type]
    send_frame(host, payload.merge(placements: [[0, 'ARENA_FURNITURE_ROCK', 50, 51]]))
    assert_equal :arena_state, receive(host)[:type]
  end
  def test_lava_rejects_movement_placements_and_stair_landings_while_volcano_syncs
    host, guest = connect, connect
    payload = relief_payload
    payload[:surface].setbyte(53 * 200 + 48, 56)
    payload[:surface].setbyte(51 * 200 + 50, 55)
    payload[:styles].setbyte(51 * 200 + 50, 51)
    bad_spawn = payload[:surface].dup
    bad_spawn.setbyte(53 * 200 + 49, 56)
    send_frame(host, payload.merge(surface: bad_spawn))
    assert_equal :arena_error, receive(host)[:type]
    bad_landing = payload[:surface].dup
    bad_landing.setbyte(53 * 200 + 50, 56)
    send_frame(host, payload.merge(surface: bad_landing))
    assert_equal :arena_error, receive(host)[:type]
    send_frame(host, payload.merge(placements: [[0, 'ARENA_FURNITURE_ROCK', 48, 53]]))
    assert_equal :arena_error, receive(host)[:type]
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    joined = join(host, guest, room)
    assert_equal payload.values_at(:surface, :styles), joined.values_at(:surface, :styles)
    send_frame(guest, type: :pos, map: 100, x: 49, y: 53)
    send_frame(guest, type: :ping, t: 5)
    until_type(guest, :pong)
    send_frame(host, type: :pos, map: 100, x: 49, y: 53)
    until_type(guest, :pos)
    send_frame(host, type: :pos, map: 100, x: 48, y: 53)
    assert_equal [49, 53], until_type(host, :pos_correct).values_at(:x, :y)
    [[50, 53], [50, 52], [50, 51]].each do |x, y|
      send_frame(host, type: :pos, map: 100, x: x, y: y)
      assert_equal [x, y], until_type(guest, :pos).values_at(:x, :y)
    end
  end
  def test_water_and_new_material_codes_relay_and_block_water_on_foot
    host, guest = connect, connect
    payload = relief_payload
    ArenaMaterials::FLOORS.each_key.with_index do |key, i|
      payload[:surface].setbyte(40 * 200 + 37 + i % 25 + (i / 25) * 100, ArenaMaterials::SURFACE_CODES[key].ord)
    end
    payload[:surface].setbyte(53 * 200 + 48, ArenaMaterials::SURFACE_CODES['water'].ord)
    payload[:styles].setbyte(51 * 200 + 50, ArenaMaterials::ALPHABET[ArenaRelief::STYLES.index('arena')].ord)
    invalid = payload[:surface].dup
    invalid.setbyte(53 * 200 + 49, ArenaMaterials::SURFACE_CODES['water'].ord)
    send_frame(host, payload.merge(surface: invalid))
    assert_equal :arena_error, receive(host)[:type]
    send_frame(host, payload.merge(placements: [[0, 'ARENA_FURNITURE_ROCK', 48, 53]]))
    assert_equal :arena_error, receive(host)[:type]
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    joined = join(host, guest, room)
    assert_equal payload.values_at(:surface, :styles), joined.values_at(:surface, :styles)
    send_frame(guest, type: :pos, map: 100, x: 49, y: 53)
    send_frame(guest, type: :ping, t: 8)
    until_type(guest, :pong)
    send_frame(host, type: :pos, map: 100, x: 49, y: 53)
    until_type(guest, :pos)
    send_frame(host, type: :pos, map: 100, x: 48, y: 53)
    assert_equal [49, 53], until_type(host, :pos_correct).values_at(:x, :y)
  end

  def test_surf_toxic_and_quicksand_return_are_validated_against_room_layout
    host, guest = connect, connect
    payload = relief_payload
    payload[:relief] = '0' * 40000
    { [48, 53] => 'marsh_water', [48, 52] => 'toxic', [50, 53] => 'quicksand' }.each do |(x, y), ground|
      payload[:surface].setbyte(y * 200 + x, ArenaMaterials::SURFACE_CODES.fetch(ground).ord)
    end
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    joined = join(host, guest, room)
    assert_equal payload[:surface], joined[:surface]
    send_frame(guest, type: :pos, map: 100, x: 49, y: 53)
    send_frame(guest, type: :ping, t: 1)
    until_type(guest, :pong)
    send_frame(host, type: :pos, map: 100, x: 49, y: 53)
    until_type(guest, :pos)
    send_frame(host, type: :pos, map: 100, x: 48, y: 53, mode: :walk)
    assert_equal [49, 53], until_type(host, :pos_correct).values_at(:x, :y)
    send_frame(host, type: :pos, map: 100, x: 48, y: 53, mode: :surf)
    assert_equal [48, 53, :surf], until_type(guest, :pos).values_at(:x, :y, :mode)
    send_frame(host, type: :pos, map: 100, x: 48, y: 52, mode: :surf)
    assert_equal [48, 53], until_type(host, :pos_correct).values_at(:x, :y)
    send_frame(host, type: :pos, map: 100, x: 49, y: 53, mode: :walk)
    until_type(guest, :pos)
    send_frame(host, type: :pos, map: 100, x: 50, y: 53)
    assert_equal [50, 53], until_type(guest, :pos).values_at(:x, :y)
    send_frame(host, type: :pos, map: 100, x: 51, y: 53)
    assert_equal [50, 53], until_type(host, :pos_correct).values_at(:x, :y), 'Trap cannot be walked out of'
    send_frame(host, type: :pos, map: 100, x: 49, y: 53)
    assert_equal [49, 53], until_type(guest, :pos).values_at(:x, :y)
    # A second, distant trap exercises the nonadjacent return exception.
    send_frame(host, type: :arena_close)
    until_type(guest, :arena_state)
    until_type(host, :arena_state)
    payload[:surface].setbyte(53 * 200 + 51, ArenaMaterials::SURFACE_CODES.fetch('quicksand').ord)
    payload[:surface].setbyte(53 * 200 + 50, 49)
    send_frame(host, type: :pos, map: 102, x: 4, y: 6)
    send_frame(host, type: :ping, t: 3)
    until_type(host, :pong)
    send_frame(guest, type: :pos, map: 102, x: 8, y: 10)
    send_frame(guest, type: :ping, t: 3)
    until_type(guest, :pong)
    send_frame(host, payload)
    room = until_type(host, :arena_state)
    join(host, guest, room)
    send_frame(guest, type: :pos, map: 100, x: 49, y: 53)
    send_frame(guest, type: :ping, t: 2)
    until_type(guest, :pong)
    [[49, 53], [50, 53], [51, 53], [49, 53]].each do |x, y|
      send_frame(host, type: :pos, map: 100, x: x, y: y)
      assert_equal [x, y], until_type(guest, :pos).values_at(:x, :y)
    end
    send_frame(host, type: :pos, map: 100, x: 52, y: 53)
    assert_equal [49, 53], until_type(host, :pos_correct).values_at(:x, :y), 'No arbitrary teleport on ordinary ground'
  end
end
