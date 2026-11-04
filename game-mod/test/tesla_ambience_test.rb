require 'minitest/autorun'
require 'ostruct'
require 'tmpdir'
require 'open3'
require 'rbconfig'
require_relative '../Plugins/ArenaDemo/000_ArenaDeviceRules'

module ArenaDemo
  MAP_ID = 100
  module FieldObstacles
    def self.scope; :solo; end
  end
  class << self
    attr_accessor :placements
    def custom_placements; placements; end
    def device_wire(values); values; end
  end
end
module EventHandlers
  @handlers = {}
  def self.add(event, key, handler); @handlers[[event,key]] = handler; end
  def self.trigger(event); @handlers.each { |(name,_),handler| handler.call if name == event }; end
end
class DarknessSprite; end
class Scene_Map
  def disposeSpritesets; :disposed; end
end
class Game_Map
  X_SUBPIXELS = Y_SUBPIXELS = 4
end
module Graphics
  def self.width; 512; end
  def self.height; 384; end
end
module FileTest
  def self.audio_exist?(path); !$missing_audio; end
end
AudioFile = Struct.new(:name, :volume, :pitch)
class FakeGameSystem
  attr_reader :playing_bgs, :calls
  def initialize; @calls = []; end
  def bgs_play(value); @playing_bgs = value&.clone; @calls << @playing_bgs; end
end
def pbBGSPlay(name, volume, pitch); $game_system.bgs_play(AudioFile.new(name, volume, pitch)); end
def pbSEPlay(*); end
require_relative '../Plugins/ArenaDemo/097_ArenaDevices'
require_relative '../Plugins/ArenaDemo/098_TeslaAmbience'

class TeslaAmbienceTest < Minitest::Test
  Audio = ArenaDemo::DeviceAmbience
  Devices = ArenaDemo::Devices
  def setup
    [Audio, Devices].each { |mod| mod.instance_variables.each { |name| mod.remove_instance_variable(name) } }
    ArenaDemo.instance_variable_set(:@custom_mode_active, false)
    ArenaDemo.placements = [[0,'ARENA_TESLA_R',5,5],[0,ArenaDevices::BUTTON,6,6]]
    $game_map = OpenStruct.new(map_id: 100, display_x: 0, display_y: 0)
    $game_temp = OpenStruct.new(in_battle: false)
    $scene = Scene_Map.new
    $game_system = FakeGameSystem.new
    $missing_audio = false
  end
  def track_name; $game_system.playing_bgs&.name; end

  def test_one_loop_for_multiple_visible_coils_without_frame_restarts
    ArenaDemo.placements << [0,'ARENA_TESLA_L',8,8]
    20.times { Audio.update }
    assert_equal 'Arena Tesla Hum', track_name
    assert_equal 1, $game_system.calls.length
    Devices.apply_disabled([0])
    assert_equal 'Arena Tesla Hum', track_name
    Devices.apply_disabled([0,2])
    assert_nil track_name
  end

  def test_camera_rectangle_and_partial_coil_body
    [[-32,0,false],[-31,0,true],[511,0,true],[512,0,false],
     [0,-32,false],[0,-31,true],[0,415,true],[0,416,false]].each do |x,y,visible|
      $game_map.display_x = (160-x)*4
      $game_map.display_y = (160-y)*4
      Audio.update
      assert_equal visible, track_name == 'Arena Tesla Hum', "screen body at #{x},#{y}"
    end
  end

  def test_disabled_slots_ignore_non_furniture_and_room_reset_reactivates
    ArenaDemo.placements.unshift([1,'TRAINER',1,1])
    Audio.update
    Devices.apply_disabled([0])
    assert_nil track_name
    Devices.clear
    Audio.update
    assert_equal 'Arena Tesla Hum', track_name
  end

  def test_prior_ambience_restored_on_leaving_view
    $game_system.bgs_play(AudioFile.new('Rain',40,90))
    Audio.update
    $game_map.display_x = 10000
    Audio.update
    assert_equal AudioFile.new('Rain',40,90), $game_system.playing_bgs
  end

  def test_magnet_and_tesla_coexist_then_restore_map_ambience
    $game_system.bgs_play(AudioFile.new('Rain',40,90))
    Audio.update
    Devices.instance_variable_set(:@transport_kind,:magnet)
    Audio.update
    assert_equal 'Arena Magnet Tesla', track_name
    Devices.apply_disabled([0])
    assert_equal 'Arena Magnet', track_name
    Devices.apply_disabled([])
    assert_equal 'Arena Magnet Tesla', track_name
    Devices.end_transport
    assert_equal 'Arena Tesla Hum', track_name
    Devices.clear
    assert_equal 'Rain', track_name
  end

  def test_external_bgs_is_not_overwritten_when_stopping
    Audio.update
    $game_system.bgs_play(AudioFile.new('New map wind',80,100))
    EventHandlers.trigger(:on_leave_map)
    assert_equal 'New map wind', track_name
  end

  def test_battle_transition_stays_silent_and_resumes_after_battle
    Audio.update
    EventHandlers.trigger(:on_start_battle)
    Audio.update
    assert_nil track_name
    $game_temp.in_battle = true
    Audio.update
    assert_nil track_name
    EventHandlers.trigger(:on_end_battle)
    $game_temp.in_battle = false
    Audio.update
    assert_equal 'Arena Tesla Hum', track_name
  end

  def test_editor_other_map_and_scene_teardown_stop_loop
    Audio.update
    ArenaDemo.instance_variable_set(:@custom_mode_active,true)
    Audio.update
    assert_nil track_name
    ArenaDemo.instance_variable_set(:@custom_mode_active,false)
    Audio.update
    assert_equal :disposed, $scene.disposeSpritesets
    assert_nil track_name
    Audio.update
    $game_map.map_id = 101
    Audio.update
    assert_nil track_name
  end

  def test_missing_asset_does_not_replace_map_audio
    $game_system.bgs_play(AudioFile.new('Rain',40,90))
    $missing_audio = true
    Audio.update
    assert_equal 'Rain', track_name
  end

  def test_generated_loops_are_audible_unclipped_and_have_no_seam_spike
    Dir.mktmpdir('tesla-audio-', File.expand_path('../../tools/runtime',__dir__)) do |root|
      script = File.expand_path('../tools/build_device_audio.rb',__dir__)
      output, status = Open3.capture2e(RbConfig.ruby, script, root, root)
      assert status.success?, output
      ['Arena Tesla Hum','Arena Magnet Tesla'].each do |track|
        wav = File.binread(File.join(root,'Audio/BGS',track+'.wav'))
        assert_equal 'RIFF', wav[0,4]
        samples = wav[44..-1].unpack('s<*')
        assert_equal 22050*4, samples.length
        assert_operator samples.map(&:abs).max, :<, 32767
        rms = Math.sqrt(samples.sum { |v| v*v }.to_f/samples.length)
        assert_operator rms, :>, 1500
        max_step = samples.each_cons(2).map { |a,b| (a-b).abs }.max
        assert_operator (samples.first-samples.last).abs, :<=, max_step
      end
    end
  end
end
