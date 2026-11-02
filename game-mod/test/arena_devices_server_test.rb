require_relative 'field_state_server_test'

class ArenaDevicesServerTest < FieldStateServerTest
  def test_directional_spark_blocks_until_button_but_coil_stays_solid
    host = connect
    snapshot = room(host, [[0, 'ARENA_TESLA_D', 51, 52], [0, ArenaDevices::BUTTON, 50, 53]])
    position(host, 100, 49, 53)
    position(host, 100, 50, 53)
    send_frame(host, type: :pos, map: 100, x: 51, y: 53)
    assert_equal [50, 53], until_type(host, :pos_correct).values_at(:x, :y)
    send_frame(host, type: :arena_device_request, room: snapshot[:room], slot: 1)
    assert_equal [0], until_type(host, :arena_field_state)[:disabled_devices]
    position(host, 100, 51, 53)
    send_frame(host, type: :pos, map: 100, x: 51, y: 52)
    assert_equal [51, 53], until_type(host, :pos_correct).values_at(:x, :y)
  end

  def test_only_paired_teleporter_allows_nonadjacent_presence
    host = connect
    snapshot = room(host, [[0, ArenaDevices::TELEPORT, 50, 53], [0, ArenaDevices::TELEPORT, 58, 53], [0, ArenaDevices::WEB, 57, 53]])
    position(host, 100, 49, 53)
    position(host, 100, 50, 53)
    position(host, 100, 58, 53)
    position(host, 100, 57, 53)
    send_frame(host, type: :pos, map: 100, x: 50, y: 53)
    assert_equal [57, 53], until_type(host, :pos_correct).values_at(:x, :y)
  end

  def test_button_state_is_shared_with_hub_and_resets_only_when_room_empty
    host, guest = connect, connect
    snapshot = room(host, [[0, ArenaDevices::COIL, 51, 53], [0, ArenaDevices::BUTTON, 50, 53]])
    position(host, 100, 49, 53)
    position(host, 100, 50, 53)
    send_frame(host, type: :pos, map: 100, x: 51, y: 53)
    assert_equal [50, 53], until_type(host, :pos_correct).values_at(:x, :y)
    send_frame(host, type: :arena_device_request, room: snapshot[:room], slot: 1)
    assert_equal [0], until_type(host, :arena_field_state)[:disabled_devices]
    send_frame(host, type: :pos, map: 100, x: 51, y: 53)
    assert_equal [50, 53], until_type(host, :pos_correct).values_at(:x, :y)
    join(host, guest, snapshot)
    assert_equal [0], position(guest, 100, 49, 53)[:disabled_devices]
    position(host, 102, 7, 3)
    assert_equal [0], position(host, 100, 49, 53)[:disabled_devices]
    position(host, 102, 7, 3)
    position(guest, 102, 7, 3)
    assert_equal [], until_type(host, :arena_field_state)[:disabled_devices]
  end

  def test_unpaired_objects_are_refused
    host = connect
    surface = '1' * 10000
    send_frame(host, type: :arena_open, objects: [], layout: 0, difficulty: 1,
      placements: [[0, ArenaDevices::TELEPORT, 50, 53]], surface: surface,
      relief: '0' * 10000, styles: '0' * 10000)
    assert_equal :arena_error, receive(host)[:type]
  end
end
