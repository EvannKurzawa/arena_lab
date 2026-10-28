# frozen_string_literal: true
require 'minitest/autorun'

# Menu edit regression checks without starting RGSS.
module MenuHandlers
  def self.add(menu, key, entry); (@entries ||= {})[[menu, key]] = entry; end
  def self.entry(menu, key); @entries[[menu, key]]; end
end
module EventHandlers
  def self.add(event, key, handler); (@handlers ||= {})[[event, key]] = handler; end
end
module PEMK
  module Auth
    class << self
      attr_accessor :logged_in
      def logged_in?; @logged_in; end
    end
  end
  module Remotes
    def self.players; @players ||= {}; end
  end
  module BattleSetup
    class << self
      attr_accessor :sent_to
      def launch_pending?; false; end
      def send_team(id); @sent_to = id; end
    end
  end
  module BattleNet
    def self.set_host(value); @host = value; end
  end
  def self.client; $arena_client; end
  def self.self_id; 10; end
  def self.send_message(message); $arena_sent << message; $arena_send_success; end
  def self.plain_name(name); name.to_s.gsub(/[\\<>]/, ''); end
end
def _INTL(text, *args)
  args.each_with_index { |value, i| text = text.gsub("{#{i + 1}}", value.to_s) }
  text
end
class Scene_Map; end
class Game_Map
  attr_accessor :map_id, :events
  def setup(*); end
end
class TestPlayerPosition
  attr_reader :x, :y
  attr_accessor :direction
  def initialize(x, y); @x, @y, @direction = x, y, 8; end
  def moveto(*); raise 'Customization must not teleport the player'; end
end
def pbMessage(message, choices = nil, cancel = 0, *)
  $arena_messages << message
  return nil unless choices
  selection = $arena_choices.shift
  selection == :escape ? (cancel > 0 ? cancel - 1 : cancel) : selection
end
def pbConfirmMessage(*); $arena_accept; end
require_relative '../Plugins/ArenaDemo/001_ArenaDemo'
require_relative '../../upstream/pokemon-essentials-mmo-kit/Plugins/PEMK/005_Battle/001_Challenge'
require_relative '../Plugins/ArenaDemo/003_PlayerInteraction'
def ArenaDemo.transfer_to(*point); $arena_transfers << point; end

class ArenaCustomizationTest < Minitest::Test
  def setup
    if defined?(ArenaDemo::Visits)
      ArenaDemo::Visits.instance_variables.each { |variable| ArenaDemo::Visits.remove_instance_variable(variable) }
    end
    PEMK::Auth.logged_in = false
    $PokemonGlobal = PokemonGlobalMetadata.new
    $PokemonGlobal.arena_demo_objects = ArenaDemo::OBJECTS.first(3)
    $game_map = Game_Map.new
    $game_map.map_id = ArenaDemo::MAP_ID
    $game_map.events = {}
    $game_player = TestPlayerPosition.new(11, 16)
    $arena_choices = []
    $arena_messages = []
    $arena_transfers = []
    $arena_sent = []
    $arena_send_success = true
    $arena_client = Struct.new(:connected?).new(true)
    $game_temp = Struct.new(:in_menu, :in_battle).new(false, false)
    $player = Struct.new(:able_pokemon_count, :name).new(1, 'Alice')
    $scene = Scene_Map.new
    PEMK::Remotes.players.clear
    PEMK::BattleSetup.sent_to = nil
    [:@incoming, :@outgoing, :@partner, :@pending_message].each do |variable|
      PEMK::Challenge.instance_variable_set(variable, nil)
    end
  end

  def test_manager_edits_preserve_player_position
    $arena_choices = [1, 2, 0, 0, 2]
    ArenaDemo.choose_layout
    ArenaDemo.choose_preset
    ArenaDemo.remove_object
    ArenaDemo.add_object
    ArenaDemo.choose_difficulty
    assert_equal [11, 16], [$game_player.x, $game_player.y]
    assert_equal 'Slalom', $PokemonGlobal.arena_demo_layout
    assert_equal 6, ArenaDemo.objects.length
    assert_equal 2, $PokemonGlobal.arena_demo_difficulty
  end

  def test_layout_overlap_is_rejected_without_changing_selection
    $game_player = TestPlayerPosition.new(8, 6)
    $arena_choices = [1]
    ArenaDemo.choose_layout
    assert_nil $PokemonGlobal.arena_demo_layout
    assert_match(/Step aside/, $arena_messages.last)
  end

  def test_preset_overlap_is_rejected
    $PokemonGlobal.arena_demo_objects = []
    $game_player = TestPlayerPosition.new(5, 6)
    $arena_choices = [2]
    ArenaDemo.choose_preset
    assert_empty ArenaDemo.objects
  end

  def test_adding_on_player_is_rejected
    $PokemonGlobal.arena_demo_objects = []
    $game_player = TestPlayerPosition.new(5, 6)
    $arena_choices = [0]
    ArenaDemo.add_object
    assert_empty ArenaDemo.objects
  end

  def test_cancel_does_not_change_layout
    $arena_choices = [3]
    ArenaDemo.choose_layout
    assert_nil $PokemonGlobal.arena_demo_layout
  end

  def test_online_edits_are_rejected_without_mutating_saved_layout
    PEMK::Auth.logged_in = true
    before = ArenaDemo.objects.dup
    $arena_choices = [2]
    ArenaDemo.choose_preset
    ArenaDemo.remove_object
    assert_equal before, ArenaDemo.objects
    assert_match(/visitors/, $arena_messages.last)
  end

  def test_online_obstacles_match_for_different_personal_saves
    event_class = Struct.new(:x, :y, :transparent, :through) do
      def moveto(x, y); self.x, self.y = x, y; end
    end
    $game_map.events = Hash[(3..8).map { |id| [id, event_class.new] }]
    $PokemonGlobal.arena_demo_objects = []
    $PokemonGlobal.arena_demo_layout = 'Slalom'
    PEMK::Auth.logged_in = true
    ArenaDemo.refresh_objects
    $game_map.events.values.each_with_index do |event, index|
      assert_equal ArenaDemo::LAYOUTS['Sidelines'][index], [event.x, event.y]
      refute event.transparent
      refute event.through
    end
    assert_empty ArenaDemo.objects
    assert_equal 'Slalom', $PokemonGlobal.arena_demo_layout
  end

  def test_escape_and_close_do_not_leave_the_arena
    $PokemonGlobal.arena_demo_return = [3, 25, 6, 2]
    [:escape, 4].each do |choice|
      $arena_choices = [choice]
      ArenaDemo.open
      assert_empty $arena_transfers
    end
    $arena_choices = [3]
    ArenaDemo.open
    assert_equal [[ArenaDemo::ENTRANCE_MAP_ID, 7, 3, 2]], $arena_transfers
  end

  def test_offline_room_path_and_online_exit
    ArenaDemo.enter_entrance
    ArenaDemo.enter_training_room
    ArenaDemo.exit_training_room
    assert_equal [ArenaDemo::ENTRANCE_MAP_ID, 7, 10, 8], $arena_transfers[0]
    assert_equal ArenaDemo::MAP_ID, $arena_transfers[1][0]
    assert_equal [ArenaDemo::ENTRANCE_MAP_ID, 7, 3, 2], $arena_transfers[2]
    $PokemonGlobal.arena_demo_return = [3, 25, 6, 2]
    PEMK::Auth.logged_in = true
    ArenaDemo.exit_training_room
    assert_equal [ArenaDemo::ENTRANCE_MAP_ID, 7, 3, 2], $arena_transfers.last
  end

  def test_escape_in_all_customization_menus_has_no_effect
    before = ArenaDemo.objects.dup
    [:manage_objects, :choose_layout, :choose_preset, :choose_difficulty,
     :add_object, :remove_object].each do |method|
      $arena_choices = [:escape]
      ArenaDemo.send(method)
      assert_equal before, ArenaDemo.objects
      assert_nil $PokemonGlobal.arena_demo_layout
      assert_nil $PokemonGlobal.arena_demo_difficulty
    end
    PEMK::Auth.logged_in = true
    $arena_choices = [:escape]
    ArenaDemo.manage_objects  # must not attempt to heal on Escape
    assert_empty $arena_transfers
  end

  def add_peer(x = 11, y = 15, map = 100)
    peer = Struct.new(:player_id, :player_name, :x, :y, :map).new(20, 'Bob', x, y, Struct.new(:map_id).new(map))
    PEMK::Remotes.players[20] = peer
    PEMK::Auth.logged_in = true
    peer
  end

  def test_facing_interaction_sends_a_battle_request_and_uses_upstream_acceptance
    add_peer
    $arena_choices = [0]
    ArenaDemo.interact_with_facing_player
    assert_equal [{ type: :challenge, from: 10, name: 'Alice', to: 20 }], $arena_sent
    refute $game_temp.in_menu
    assert_nil PEMK::BattleSetup.sent_to
    PEMK::Challenge.on_message(type: :challenge_accept, from: 99, to: 10)
    assert_nil PEMK::BattleSetup.sent_to
    PEMK::Challenge.on_message(type: :challenge_accept, from: 20, to: 10)
    assert_equal 20, PEMK::BattleSetup.sent_to
    assert PEMK::Challenge.agreed_with?(20)
  end

  def test_player_dialog_escape_sends_nothing
    add_peer
    $arena_choices = [:escape]
    ArenaDemo.interact_with_facing_player
    assert_empty $arena_sent
    refute $game_temp.in_menu
  end

  def test_same_tile_and_player_list_interactions
    add_peer(11, 16)
    $arena_choices = [0]
    ArenaDemo.interact_with_facing_player
    assert_equal 20, $arena_sent.last[:to]
    $arena_sent.clear
    $game_temp.in_menu = true
    $arena_choices = [0, 0]
    ArenaDemo.players_menu
    assert_equal 20, $arena_sent.last[:to]
    assert $game_temp.in_menu, 'Preserve the outer pause menu state'
  end

  def test_offline_distant_and_other_map_peers_do_not_interact
    peer = add_peer(20, 12)
    ArenaDemo.interact_with_facing_player
    assert_empty $arena_messages
    peer.x, peer.y, peer.map.map_id = 11, 15, 2
    ArenaDemo.interact_with_facing_player
    assert_empty $arena_messages
    PEMK::Auth.logged_in = false
    ArenaDemo.interact_with_facing_player
    assert_empty $arena_sent
  end

  def test_request_revalidates_peer_connection_and_team
    peer = add_peer
    PEMK::Remotes.players.clear
    refute PEMK::Challenge.request_from_arena(20)
    PEMK::Remotes.players[20] = peer
    $player.able_pokemon_count = 0
    refute PEMK::Challenge.request_from_arena(20)
    $player.able_pokemon_count = 1
    $arena_client = nil
    refute PEMK::Challenge.request_from_arena(20)
    assert_empty $arena_sent
  end

  def test_failed_send_clears_pending_request
    add_peer
    $arena_send_success = false
    refute PEMK::Challenge.request_from_arena(20)
    assert_nil PEMK::Challenge.instance_variable_get(:@outgoing)
  end

  def test_incoming_challenge_requires_acceptance_before_team_exchange
    add_peer
    $arena_accept = false
    PEMK::Challenge.on_message(type: :challenge, from: 20, to: 10, name: 'Bob')
    PEMK::Challenge.update_ui
    assert_equal :challenge_decline, $arena_sent.last[:type]
    assert_nil PEMK::BattleSetup.sent_to
    $arena_accept = true
    PEMK::Challenge.on_message(type: :challenge, from: 20, to: 10, name: 'Bob')
    PEMK::Challenge.update_ui
    assert_equal :challenge_accept, $arena_sent.last[:type]
    assert_equal 20, PEMK::BattleSetup.sent_to
  end
end
