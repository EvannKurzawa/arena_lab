require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

module SaveData
  FILE_PATH = 'unused.rxdata'
end
module MenuHandlers
  def self.add(*); end
end
module ArenaDemo
  ENTRANCE_MAP_ID = 102
  def self.connected?; PEMK::Auth.logged_in? && PEMK.client && PEMK.client.connected?; end
  def self.with_player_dialog; yield; end
  module Visits
    class << self
      attr_accessor :locked, :ready, :guest, :opened
      def locked?; !!@locked; end
      def ready?; !!@ready; end
      def guest?; !!@guest; end
      def reset; @locked = @ready = @guest = @opened = false; end
      def now; @clock = (@clock || 0) + 0.1; end
      def pump; @ready = $service_ready && ArenaDemo.connected?; end
      def close_arena; @locked = false if $close_ack; true; end
      def open_arena; @locked = @opened = true; end
      def attendant; $visit_menu_shown = true; end
    end
  end
end
module PEMK
  class << self
    attr_reader :client, :self_id, :starts
    def settings; @settings ||= { host: '127.0.0.1', port: 9998 }; end
    def ensure_started; @starts = (@starts || 0) + 1; @client = Struct.new(:connected?).new(true); end
    def shutdown; @client = nil; end
    def set_self_id(id); @self_id = id; end
  end
  module Auth
    class << self
      attr_reader :received_reply
      def logged_in?; !!@logged_in; end
      def abort_login!; @logged_in = false; end
      def clear_pending; @pending_state = nil; end
      def login_blocking
        PEMK.ensure_started
        apply_login(type: :login_ok, account_id: 70, _body: 'historical server world', econ: { money: 999 }, inv: [1]) if $login_success
        true
      end
      def apply_login(reply)
        @received_reply = reply
        @logged_in = true
        @account_id = reply[:account_id]
        PEMK.set_self_id(@account_id)
        PEMK::PeerPokemon.adopt_mode(:on)
        true
      end
      def token_file; 'session.dat'; end
      def account_file; 'account.dat'; end
    end
  end
  module Sync
    def self.reset; PEMK::PeerPokemon.reset; end
    def self.tick; raise 'Local world must not sync MMO progression'; end
    def self.flush_event(*); raise 'Local world must not flush MMO progression'; end
    def self.push_blob(*); raise 'Local world must not overwrite an account save'; end
  end
  module PeerPokemon
    def self.reset; @mode = :off; end
    def self.mode; @mode; end
    def self.adopt_mode(mode); @mode = mode; end
  end
  module Remotes
    def self.clear_all; end
  end
  module NetStatus
    RECONNECT_BASE = 5
  end
  module Checkpoint; end
  module Presence
    def self.emit_now(*); $presence_sent = true; end
  end
end
module Game
  def self.save
    return false if $save_fails
    $saved_paths << SaveData::FILE_PATH
    File.binwrite(SaveData::FILE_PATH, 'local progress')
    PEMK::Sync.push_blob(SaveData::FILE_PATH) if PEMK::Auth.logged_in?
    true
  end
  def self.load(*); raise 'Connecting must never load another world'; end
  def self.set_up_system; :initialized; end
end
module Graphics
  def self.update; $on_frame.call if $on_frame; end
end
module Input
  def self.update; end
end
class PokemonLoadScreen
  attr_reader :save_data
  def initialize(_scene)
    @save_data = File.file?(SaveData::FILE_PATH) ? File.binread(SaveData::FILE_PATH) : nil
  end
end
def _INTL(text); text; end
def pbMessage(text, choices = nil, *)
  $messages << text
  choices ? $choices.shift : nil
end
def pbMessageFreeText(*); $host_input; end
require_relative '../Plugins/ArenaDemo/007_ConnectionMode'

class LiveConnectionTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('arena-live-')
    @base = File.join(@dir, 'Game_guest.rxdata')
    SaveData.send(:remove_const, :FILE_PATH)
    SaveData.const_set(:FILE_PATH, @base)
    @mode = ArenaDemo::ConnectionMode
    @mode.instance_variables.each { |variable| @mode.remove_instance_variable(variable) }
    @mode.stop_connection
    @mode.select_mode(:offline)
    PEMK.instance_variable_set(:@starts, 0)
    PEMK.instance_variable_set(:@settings, { host: '127.0.0.1', port: 9998 })
    $messages, $choices, $saved_paths = [], [], []
    $login_success, $service_ready, $close_ack = true, true, true
    $save_fails, $on_frame, $presence_sent = false, nil, false
    $player = Struct.new(:id, :party).new(5000, [:caught_offline])
    $game_map = Struct.new(:map_id).new(102)
    $game_temp = Struct.new(:in_battle, :title_screen_calling).new(false, false)
    @old_control, @old_ready = ENV.values_at('ARENA_CONTROL_DIR', 'ARENA_READY_FILE')
    ENV.delete('ARENA_CONTROL_DIR')
    ENV.delete('ARENA_READY_FILE')
  end
  def teardown
    ENV['ARENA_CONTROL_DIR'], ENV['ARENA_READY_FILE'] = @old_control, @old_ready
    FileUtils.remove_entry(@dir)
  end

  def test_every_boot_is_offline_even_when_a_token_or_server_exists
    File.binwrite(@base, "legacy\x00\xff\n".b)
    PokemonLoadScreen.new(nil)
    PEMK::Auth.login_blocking
    PEMK.ensure_started
    assert @mode.offline?
    refute PEMK::Auth.logged_in?
    assert_nil PEMK.client
    assert_equal 0, PEMK.starts
    assert_equal "legacy\x00\xff\n".b, File.binread(SaveData::FILE_PATH)
  end

  def test_live_connect_and_disconnect_keep_the_same_character_world_and_file
    actor, world, path = $player, $game_map, SaveData::FILE_PATH
    File.binwrite(@base, 'preserved legacy cache')
    assert @mode.connect('127.0.0.1')
    assert_equal actor, $player
    assert_equal 5000, $player.id
    assert_equal [:caught_offline], $player.party
    assert_same world, $game_map
    assert_equal path, SaveData::FILE_PATH
    assert $presence_sent
    refute $game_temp.title_screen_calling
    assert_nil PEMK::Auth.received_reply[:_body]
    assert_nil PEMK::Auth.received_reply[:econ]
    assert_nil PEMK::Auth.received_reply[:inv]
    assert_equal :on, PEMK::PeerPokemon.mode
    assert @mode.disconnect
    assert @mode.offline?
    assert_nil PEMK.client
    assert_same actor, $player
    assert_same world, $game_map
    assert_equal path, SaveData::FILE_PATH
    assert_equal 'preserved legacy cache', File.binread(@base)
    assert_equal [path, path], $saved_paths
  end

  def test_progress_sync_is_disabled_but_local_saving_remains_available
    assert @mode.connect('127.0.0.1')
    PEMK::Sync.tick
    PEMK::Sync.flush_event(:save)
    assert_equal :unchanged, PEMK::Sync.push_blob(SaveData::FILE_PATH)
    assert Game.save
    assert_equal 'local progress', File.binread(SaveData::FILE_PATH)
  end

  def test_failed_login_and_missing_arena_service_stay_offline_without_world_change
    actor = $player
    $login_success = false
    refute @mode.connect('127.0.0.1')
    assert @mode.offline?
    assert_same actor, $player
    $login_success, $service_ready = true, false
    refute @mode.connect('127.0.0.1')
    assert @mode.offline?
    assert_same actor, $player
    assert_nil PEMK.client
  end

  def test_location_visit_save_and_address_guards
    $game_map.map_id = 101
    refute @mode.connect('127.0.0.1')
    $game_map.map_id = 102
    ArenaDemo::Visits.locked = true
    refute @mode.connect('127.0.0.1')
    ArenaDemo::Visits.locked = false
    $save_fails = true
    refute @mode.connect('127.0.0.1')
    assert_equal 0, PEMK.starts
    ['0.0.0.0', '255.255.255.255', '224.0.0.1', '127.0.0.1;bad', '', '192.168.01.2'].each { |ip| refute @mode.valid_host?(ip) }
    assert @mode.valid_host?('127.0.0.1')
    assert @mode.valid_host?('192.168.1.10')
  end

  def test_joining_a_remote_host_never_starts_a_local_server
    $choices = [1]
    $host_input = '192.168.1.10'
    @mode.stub(:request_host, -> { raise 'Join must not start a server' }) { @mode.attendant }
    assert_equal '192.168.1.10', PEMK.settings[:host]
    assert_equal 9998, PEMK.settings[:port]
    assert_equal 'session.dat.192_168_1_10', PEMK::Auth.token_file
    assert_equal 'account.dat.192_168_1_10', PEMK::Auth.account_file
  end

  def test_host_selection_starts_the_service_then_connects_and_opens_the_arena
    $choices = [0]
    requested = false
    @mode.stub(:request_host, -> { requested = true; true }) { @mode.attendant }
    assert requested
    assert ArenaDemo::Visits.opened
    assert_equal '127.0.0.1', PEMK.settings[:host]
  end

  def test_host_ipc_correlates_replies_and_does_not_accept_an_old_reply
    ENV['ARENA_CONTROL_DIR'] = @dir
    response = File.join(@dir, 'host.response')
    File.binwrite(response, "stale\nOK\nOld")
    $on_frame = -> {
      id = File.binread(File.join(@dir, 'host.request'))
      assert_match(/\A[0-9a-f]{24}\z/, id)
      File.binwrite(response, "#{id}\nOK\nHost ready")
    }
    assert @mode.request_host
    assert_equal 'Host ready', @mode.instance_variable_get(:@host_information)
  end

  def test_disconnect_waits_for_an_active_visit_to_close
    assert @mode.connect('127.0.0.1')
    ArenaDemo::Visits.locked = true
    $close_ack = false
    refute @mode.disconnect
    assert PEMK::Auth.logged_in?
    $close_ack = true
    assert @mode.disconnect
    refute PEMK::Auth.logged_in?
  end

  def test_ready_signal_is_written_after_system_initialization
    ENV['ARENA_READY_FILE'] = File.join(@dir, 'ready')
    assert_equal :initialized, Game.set_up_system
    assert_equal Process.pid.to_s, File.binread(ENV['ARENA_READY_FILE'])
  end
end
