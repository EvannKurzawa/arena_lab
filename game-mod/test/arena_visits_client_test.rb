# frozen_string_literal: true
require_relative 'arena_customization_test'
require_relative '../Plugins/ArenaDemo/005_ArenaVisits'
require_relative '../../upstream/pokemon-essentials-mmo-kit/Plugins/PEMK/008_World/003_PosCorrect'

module PEMK
  def self.plain_text(text, max); text.is_a?(String) ? text[0, max] : nil; end
end

class ArenaVisitsClientTest < Minitest::Test
  def setup
    ArenaCustomizationTest.new('fixture').setup
    @visits = ArenaDemo::Visits
    PEMK::Auth.logged_in = true
    @visits.receive(type: :arena_ready, version: 2)
  end
  def state(role = :host)
    { type: :arena_state, phase: :open, room: 'room-one', role: role,
      host: 10, guest: role == :guest ? 20 : nil,
      objects: [1, 4], layout: 2, difficulty: 2 }
  end
  def test_open_locks_before_the_request_and_close_waits_for_confirmation
    $game_map.map_id = ArenaDemo::ENTRANCE_MAP_ID
    PEMK.stub(:send_message, ->(message) {
      assert @visits.locked?, 'Lock must precede the network request'
      assert_equal :arena_open, message[:type]
      true
    }) { assert @visits.open_arena }
    assert ArenaDemo.customization_locked?
    @visits.receive(state)
    assert @visits.locked?
    assert @visits.close_arena
    assert @visits.locked?, 'A close request alone must not unlock editing'
    @visits.receive(type: :arena_state, phase: :closed)
    refute @visits.locked?
  end
  def test_failed_open_and_refused_open_restore_the_editable_state
    $game_map.map_id = ArenaDemo::ENTRANCE_MAP_ID
    $arena_send_success = false
    refute @visits.open_arena
    refute @visits.locked?
    $arena_send_success = true
    assert @visits.open_arena
    @visits.receive(type: :arena_error, reason: 'Rejected')
    refute @visits.locked?
  end
  def test_all_mutators_reject_a_hosting_session_and_an_outside_map
    before = ArenaDemo.objects.dup
    @visits.receive(state)
    [:add_object, :remove_object, :choose_layout, :choose_preset, :choose_difficulty].each do |method|
      ArenaDemo.send(method)
    end
    assert_equal before, ArenaDemo.objects
    assert_nil $PokemonGlobal.arena_demo_layout
    assert_nil $PokemonGlobal.arena_demo_difficulty
    @visits.receive(type: :arena_state, phase: :closed)
    $game_map.map_id = ArenaDemo::TOWN_MAP_ID
    ArenaDemo.choose_difficulty
    assert_nil $PokemonGlobal.arena_demo_difficulty
  end
  def test_visitor_layout_and_collisions_do_not_overwrite_the_personal_save
    event_class = Struct.new(:x, :y, :transparent, :through) do
      def moveto(x, y); self.x, self.y = x, y; end
    end
    $game_map.events = Hash[(3..8).map { |id| [id, event_class.new] }]
    $PokemonGlobal.arena_demo_layout = 'Slalom'
    personal = ArenaDemo.objects.dup
    @visits.receive(state(:guest))
    ArenaDemo.refresh_objects
    $game_map.events.each do |id, event|
      assert_equal ArenaDemo::LAYOUTS['Training ring'][id - 3], [event.x, event.y]
      assert_equal ![4, 7].include?(id), event.through
    end
    assert_equal personal, ArenaDemo.objects
    assert_equal 'Slalom', $PokemonGlobal.arena_demo_layout
    refute @visits.allow_travel?(101)
    refute @visits.allow_travel?(103)
    assert @visits.allow_travel?(100)
    assert @visits.allow_travel?(102)
    @visits.receive(type: :arena_state, phase: :closed)
    assert @visits.locked?, 'Keep editing locked until the guest returns home'
    @visits.update_world
    assert_equal [102, 7, 10, 8], $arena_transfers.last
    refute @visits.locked?
    assert_equal personal, ArenaDemo.effective_layout[:objects]
  end
  def test_disconnect_defers_return_while_in_battle
    @visits.receive(state(:guest))
    $game_temp.in_battle = true
    @visits.reset
    @visits.update_world
    assert_empty $arena_transfers
    assert @visits.locked?
    $game_temp.in_battle = false
    @visits.update_world
    assert_equal [102, 7, 10, 8], $arena_transfers.last
    refute @visits.ready?
  end
  def test_malformed_layout_and_expired_invitation_are_not_applied
    @visits.receive(state.merge(objects: [99]))
    assert_nil @visits.snapshot
    @visits.receive(type: :arena_invitation, host: 20, room: 'expired')
    @visits.instance_variable_get(:@invitation)[:expires] = -1
    $arena_choices = [:escape]
    @visits.attendant
    assert_nil @visits.instance_variable_get(:@invitation)
    refute @visits.accept_invitation
  end

  def test_customization_menu_is_hidden_and_difficulty_rechecks_after_its_prompt
    condition = MenuHandlers.entry(:pause_menu, :arena_customize)['condition']
    assert condition.call
    ArenaDemo.stub(:pbMessage, ->(*_args) {
      @visits.instance_variable_set(:@phase, :opening)
      2
    }) { ArenaDemo.choose_difficulty }
    assert_nil $PokemonGlobal.arena_demo_difficulty
    refute condition.call
    @visits.receive(state(:guest))
    refute condition.call
    @visits.receive(type: :arena_state, phase: :closed)
    refute condition.call, 'Return home before allowing personal customization'
    @visits.update_world
    $game_map.map_id = ArenaDemo::ENTRANCE_MAP_ID
    refute condition.call
  end

  def test_closing_a_visit_drops_pending_corrections_from_the_old_room
    @visits.receive(state(:guest))
    PEMK::PosCorrect.request(100, 12, 16)
    assert PEMK::PosCorrect.instance_variable_get(:@pending)
    @visits.receive(type: :arena_state, phase: :closed)
    assert_nil PEMK::PosCorrect.instance_variable_get(:@pending)
  end
end
