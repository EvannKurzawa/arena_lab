require_relative 'arena_visit_harness'

class FieldStateServerTest < Minitest::Test
  include ArenaVisitTestSupport
  OBJECTS = [[0, 'ARENA_FURNITURE_TREE', 50, 53], [0, 'ARENA_FURNITURE_ROCK', 51, 53],
             [0, 'ARENA_FURNITURE_BOULDER', 50, 54]].freeze

  def room(host, placements = OBJECTS, surface: nil, relief: nil)
    surface ||= '0' * 40000
    (37..61).each { |y| (37..61).each { |x| surface.setbyte(y * 200 + x, 49) } } if surface.count('1') == 0
    send_frame(host, type: :arena_open, objects: [], layout: 0, difficulty: 1,
      placements: placements, surface: surface, relief: relief || '0' * 40000, styles: '0' * 40000)
    until_type(host, :arena_state)
  end

  def position(socket, map, x, y)
    send_frame(socket, type: :pos, map: map, x: x, y: y)
    send_frame(socket, type: :ping, t: 5)
    frames = []
    loop do
      frame = receive(socket)
      break if frame[:type] == :pong
      frames << frame
    end
    refute frames.any? { |f| f[:type] == :pos_correct }, frames.inspect
    frames.find { |f| f[:type] == :arena_field_state }
  end

  def act(socket, room, slot, move, direction, revision)
    @request = @request.to_i + 1
    send_frame(socket, type: :arena_field_request, room: room[:room], slot: slot,
      move: move, direction: direction, field_revision: revision, request: @request)
    loop do
      response = until_type(socket, :arena_field_state)
      return response if response[:request] == @request
    end
  end

  def test_both_players_must_leave_and_both_hidden_and_pushed_objects_reset
    host, guest = connect, connect
    snapshot = room(host)
    join(host, guest, snapshot)
    assert_equal({}, position(host, 100, 49, 53)[:field_states])
    position(guest, 100, 49, 53)
    cut = act(host, snapshot, 0, :CUT, 6, 0)
    assert_equal({0 => nil}, cut[:field_states])
    assert_equal cut[:field_states], until_type(guest, :arena_field_state)[:field_states]
    position(host, 100, 50, 53) # Removed object no longer blocks authority.
    smash = act(host, snapshot, 1, :ROCKSMASH, 6, 1)
    assert_equal({0 => nil, 1 => nil}, smash[:field_states])
    until_type(guest, :arena_field_state)
    pushed = act(host, snapshot, 2, :STRENGTH, 2, 2)
    assert_equal({0 => nil, 1 => nil, 2 => [50, 55]}, pushed[:field_states])
    until_type(guest, :arena_field_state)
    position(host, 100, 50, 54)
    send_frame(host, type: :pos, map: 100, x: 50, y: 55)
    assert_equal [50, 54], until_type(host, :pos_correct).values_at(:x, :y)
    position(host, 102, 7, 3)
    returned = position(host, 100, 49, 53)
    assert_equal pushed[:field_states], returned[:field_states], 'one player leaving and returning must not reset'
    position(host, 102, 7, 3)
    position(guest, 102, 7, 3)
    reset = until_type(host, :arena_field_state)
    assert_equal({}, reset[:field_states])
    assert_equal 4, reset[:field_revision]
    assert_equal({}, position(host, 100, 49, 53)[:field_states])
    assert_equal({}, position(guest, 100, 49, 53)[:field_states])
  end

  def test_hub_and_late_join_receive_current_state_without_changing_base_layout
    host, guest = connect, connect
    snapshot = room(host)
    position(host, 100, 49, 53)
    cut = act(host, snapshot, 0, :CUT, 6, 0)
    position(host, 100, 50, 53)
    pushed = act(host, snapshot, 2, :STRENGTH, 2, 1)
    joined = join(host, guest, snapshot)
    assert_equal OBJECTS, joined[:placements], 'canonical layout stays untouched'
    assert_equal pushed[:field_states], joined[:field_states], 'joining from hub receives prior actions'
    assert_equal pushed[:field_states], position(guest, 100, 49, 53)[:field_states]
    position(guest, 102, 7, 3)
    # Host is still in the room. Re-entering receives exactly the same overlay.
    assert_equal pushed[:field_states], position(guest, 100, 49, 53)[:field_states]
    assert_equal 1, cut[:field_revision]
  end

  def test_simultaneous_pushes_and_stale_requests_cannot_move_twice
    host, guest = connect, connect
    snapshot = room(host, [OBJECTS.last])
    join(host, guest, snapshot)
    [host, guest].each { |s| position(s, 100, 49, 53); position(s, 100, 50, 53) }
    [host, guest].each_with_index do |s, i|
      send_frame(s, type: :arena_field_request, room: snapshot[:room], slot: 0,
        move: :STRENGTH, direction: 2, field_revision: 0, request: 20 + i)
    end
    responses = [host, guest].map do |s|
      frames = []
      send_frame(s, type: :ping, t: 8)
      loop do
        frame = receive(s)
        break if frame[:type] == :pong
        frames << frame if frame[:type] == :arena_field_state
      end
      frames
    end.flatten
    assert responses.any? { |f| f[:rejected] }
    assert responses.all? { |f| f[:field_states] == {0 => [50, 55]} && f[:field_revision] == 1 }
  end

  def test_invalid_actions_and_hub_actions_are_refused
    host, guest = connect, connect
    snapshot = room(host, [OBJECTS.last])
    join(host, guest, snapshot)
    assert act(host, snapshot, 0, :STRENGTH, 2, 0)[:rejected], 'hub cannot operate objects'
    position(host, 100, 49, 53)
    assert act(host, snapshot, 0, :STRENGTH, 6, 0)[:rejected], 'must face the object'
    position(host, 100, 50, 53)
    [[-1, :STRENGTH, 2, 0], [0, :CUT, 2, 0], [0, :STRENGTH, 3, 0], [0, :STRENGTH, 2, 99]].each do |args|
      frame = act(host, snapshot, *args)
      assert frame[:rejected]
      assert_empty frame[:field_states]
    end
    position(guest, 100, 49, 53)
    [[50, 53], [51, 53], [51, 54], [51, 55], [50, 55]].each { |x, y| position(guest, 100, x, y) }
    assert act(host, snapshot, 0, :STRENGTH, 2, 0)[:rejected], 'cannot push into another player'
  end

  def test_ice_steps_reach_the_edge_without_a_snapback_and_field_move_stays_adjacent
    host, guest = connect, connect
    surface = '0' * 40000
    (37..61).each { |y| (37..61).each { |x| surface.setbyte(y * 200 + x, 49) } }
    (50..54).each { |x| surface.setbyte(53 * 200 + x, ArenaMaterials::SURFACE_CODES.fetch('ice').ord) }
    surface.setbyte(53 * 200 + 55, 48)
    snapshot = room(host, [[0, 'ARENA_FURNITURE_TREE', 54, 54]], surface: surface)
    join(host, guest, snapshot)
    position(host, 100, 49, 53)
    position(guest, 100, 49, 53)
    # No idle frames or ordinary player-step callback between forced ice steps.
    (50..54).each { |x| send_frame(host, type: :pos, map: 100, x: x, y: 53, mode: :run) }
    position(host, 100, 54, 53)
    send_frame(host, type: :pos, map: 100, x: 55, y: 53)
    assert_equal [54, 53], until_type(host, :pos_correct).values_at(:x, :y), 'void is rejected at the edge, never at the slide start'
    cut = act(host, snapshot, 0, :CUT, 2, 0)
    refute cut[:rejected]
    assert_equal({0 => nil}, cut[:field_states])
    assert_equal cut[:field_states], until_type(guest, :arena_field_state)[:field_states]
  end

  def test_last_occupant_disconnect_resets_for_the_player_in_hub
    host, guest = connect, connect
    snapshot = room(host, [OBJECTS.last])
    join(host, guest, snapshot)
    position(host, 100, 49, 53)
    position(host, 100, 50, 53)
    position(guest, 100, 49, 53)
    act(host, snapshot, 0, :STRENGTH, 2, 0)
    until_type(guest, :arena_field_state)
    position(host, 102, 7, 3)
    guest.close
    assert_equal({}, until_type(host, :arena_field_state)[:field_states])
    assert_equal({}, position(host, 100, 49, 53)[:field_states])
  end
end
