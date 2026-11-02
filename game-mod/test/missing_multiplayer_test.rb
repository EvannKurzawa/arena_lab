require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'

class MissingMultiplayerTest < Minitest::Test
  def test_missing_pemk_keeps_offline_and_rejects_connection_before_save_or_discovery
    plugin = File.expand_path('../Plugins/ArenaDemo/007_ConnectionMode.rb', __dir__)
    code = <<~'RUBY'
      module ArenaDemo
        module Visits
          def self.reset; @reset = true; end
        end
      end
      $messages = []
      def pbMessage(message); $messages << message; end
      load ARGV.fetch(0)
      mode = ArenaDemo::ConnectionMode
      mode.instance_variable_set(:@mode, :online)
      mode.instance_variable_set(:@host_mode, true)
      mode.stop_connection
      raise 'Not offline' unless mode.offline? && !mode.host_mode?
      raise 'Incorrect status' unless mode.status == 'Offline'
      # Game.save, LanDiscovery and the player dialogue are deliberately absent.
      raise 'Connected without PEMK' unless mode.connect('127.0.0.1') == false
      raise 'Discovery without PEMK' unless mode.find_arena_to_visit == false
      raise 'Attendant without PEMK' unless mode.attendant == false
      raise 'Missing repair guidance' unless $messages.length == 3 && $messages.all? { |m| m.include?('Play-Arena.bat') }
    RUBY
    Dir.mktmpdir('arena-no-pemk-') do |directory|
      script = File.join(directory, 'probe.rb')
      File.write(script, code)
      output, error, status = Open3.capture3(RbConfig.ruby, '--disable-gems', script, plugin)
      assert status.success?, output + error
    end
  end
end
