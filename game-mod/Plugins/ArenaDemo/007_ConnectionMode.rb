# Local progression remains authoritative; PEMK handles identity/presence/PvP.
module ArenaDemo
  module ConnectionMode
    module_function
    def local_world?; true; end
    def offline?; @mode != :online; end
    def authenticating?; !!@authenticating; end
    def host_mode?; !!@host_mode; end
    def base_save; @base_save ||= SaveData::FILE_PATH; end
    def offline_save
      path = base_save
      File.join(File.dirname(path), File.basename(path, File.extname(path)) + '_offline' + File.extname(path))
    end
    def select_mode(value)
      raise ArgumentError, 'Unknown mode' unless [:online, :offline].include?(value)
      original, target = base_save, offline_save
      if !File.exist?(target) && File.file?(original)
        begin
          bytes = File.binread(original)
          File.open(target, File::WRONLY | File::CREAT | File::EXCL | File::BINARY) { |file| file.write(bytes) }
        rescue Errno::EEXIST
        end
      end
      if SaveData::FILE_PATH != target
        SaveData.send(:remove_const, :FILE_PATH)
        SaveData.const_set(:FILE_PATH, target)
      end
      @mode = value
    end
    def stop_connection
      PEMK::Auth.abort_login!
      PEMK::Auth.instance_variable_set(:@account_id, nil)
      PEMK.set_self_id(nil)
      PEMK.shutdown
      PEMK::Sync.reset
      if defined?(PEMK::NetStatus)
        { :reconnect_at => nil, :terminal => false, :notices => [], :shown => {},
          :backoff => PEMK::NetStatus::RECONNECT_BASE }.each do |key, value|
          PEMK::NetStatus.instance_variable_set("@#{key}", value)
        end
      end
      if defined?(PEMK::Checkpoint)
        { :pending => nil, :push_pending => false, :backed_up => false, :terminating => false }.each do |key, value|
          PEMK::Checkpoint.instance_variable_set("@#{key}", value)
        end
      end
      Visits.reset
      PEMK::Remotes.clear_all
      @host = nil
      @host_mode = false
      @mode = :offline
    end
    def choose_at_title
      stop_connection
      Visits.instance_variable_set(:@return_home, nil)
      $player = nil
      select_mode(:offline)
    end
    def reset_progression_gates
      peer_mode = PEMK::PeerPokemon.mode if defined?(PEMK::PeerPokemon)
      PEMK::Sync.reset
      PEMK::PeerPokemon.adopt_mode(peer_mode) if defined?(PEMK::PeerPokemon)
    end
    def valid_host?(value)
      return false unless value.is_a?(String)
      parts = value.split('.', -1)
      parts.length == 4 && parts.all? { |part| part.match?(/\A(?:0|[1-9][0-9]{0,2})\z/) && part.to_i <= 255 } &&
        parts[0].to_i.between?(1, 223)
    end
    def request_host
      directory = ENV['ARENA_CONTROL_DIR']
      unless directory && File.directory?(directory)
        pbMessage("Use Play-Arena.bat so the game can manage hosting.")
        return false
      end
      id = Array.new(24) { rand(16).to_s(16) }.join
      request = File.join(directory, 'host.request')
      File.binwrite(request + '.tmp', id)
      File.rename(request + '.tmp', request)
      deadline = Visits.now + 45
      response = File.join(directory, 'host.response')
      while Visits.now < deadline
        if File.file?(response)
          fields = File.binread(response).split("\n", 3)
          if fields[0] == id
            @host_information = fields[2].to_s
            pbMessage(@host_information) unless fields[1] == 'OK'
            return fields[1] == 'OK'
          end
        end
        Graphics.update
        Input.update
      end
      pbMessage("The host service did not answer. Check tools/runtime/desktop-server logs and try again.")
      false
    rescue SystemCallError, IOError => error
      pbMessage("Could not request hosting: #{error.message}")
      false
    end
    def connect(host, host_mode = false)
      unless $game_map && $game_map.map_id == ENTRANCE_MAP_ID && !Visits.locked? && !$game_temp.in_battle
        pbMessage("Connect from the arena entrance after closing any active visit.")
        return false
      end
      return false unless valid_host?(host)
      unless Game.save
        pbMessage("The game could not be saved. You remain offline.")
        return false
      end
      stop_connection
      select_mode(:online)
      @host = host
      @host_mode = host_mode
      PEMK.instance_variable_set(:@settings, PEMK.settings.merge(:host => host, :port => 9998, :email => nil, :password => nil))
      @authenticating = true
      PEMK::Auth.login_blocking
      @authenticating = false
      unless PEMK::Auth.logged_in?
        stop_connection
        pbMessage("Not connected. Your game is still offline; your progress has not changed.")
        return false
      end
      PEMK::Auth.clear_pending
      [:pending_econ, :pending_inv, :pending_mon_evict].each { |name| PEMK::Auth.instance_variable_set("@#{name}", nil) }
      reset_progression_gates
      deadline = Visits.now + 8
      until Visits.ready? || !ArenaDemo.connected? || Visits.now >= deadline
        Visits.pump
        Graphics.update
        Input.update
      end
      unless Visits.ready?
        stop_connection
        pbMessage("The host does not provide the current arena service. Your game stays offline.")
        return false
      end
      PEMK::Presence.emit_now(:pos) if defined?(PEMK::Presence)
      pbMessage("Connected to the arena service. Your character and progress stay on this device.")
      true
    ensure
      @authenticating = false
    end
    def disconnect
      if Visits.locked? && !Visits.request_pending? && ArenaDemo.connected?
        return false unless Visits.close_arena
        deadline = Visits.now + 5
        while Visits.locked? && !Visits.instance_variable_get(:@return_home) && ArenaDemo.connected? && Visits.now < deadline
          Graphics.update
          Input.update
        end
        if Visits.locked? && !Visits.instance_variable_get(:@return_home) && ArenaDemo.connected?
          pbMessage("The visit is still closing. Please wait and try again.")
          return false
        end
      end
      return false unless Game.save
      stop_connection
      pbMessage("Offline. Keep playing with the same character and save.")
      true
    end
    def status
      return "Offline" if offline? || !PEMK::Auth.logged_in? || !ArenaDemo.connected?
      return "Visiting" if Visits.guest?
      return "Hosting" if Visits.hosting?
      "Connected"
    end

    def find_arena_to_visit
      pbMessage("Searching for arenas on your local network...")
      hosts = ArenaDemo::LanDiscovery.discover
      if hosts.empty?
        pbMessage("No arena was found. Make sure the host has chosen Host online and both computers are on the same network.")
        return false
      end
      host = if hosts.length == 1
               hosts.first
             else
               choices = hosts.map { |entry| "Arena on #{entry[:name]}" } + ["Cancel"]
               selected = pbMessage("Choose an arena on your network.", choices, -1)
               return false unless selected && selected >= 0 && selected < hosts.length
               hosts[selected]
             end
      choice = pbMessage("Arena found on #{host[:name]}.", ["Request to visit", "Cancel"], -1)
      return false unless choice == 0
      return false unless connect(host[:address], false)
      Visits.request_visit
      true
    rescue SystemCallError, IOError => error
      pbMessage("Could not find arenas on the local network: #{error.message}")
      false
    end
    def attendant
      unless $game_map && $game_map.map_id == ENTRANCE_MAP_ID
        pbMessage("Talk to the attendant in the arena entrance to host, join or go offline.")
        return false
      end
      ArenaDemo.with_player_dialog do
        if offline? || !PEMK::Auth.logged_in?
          choice = pbMessage("Status: Offline. Connecting keeps your world and character.", ["Host online", "Find an arena to visit", "Back"], -1)
          if choice == 0
            if request_host && connect('127.0.0.1', true)
              Visits.open_arena
            end
          elsif choice == 1
            find_arena_to_visit
          end
        else
          choice = pbMessage("Status: #{status}", ["Arena visits", "Disconnect", "Back"], -1)
          Visits.attendant if choice == 0
          disconnect if choice == 1
        end
      end
      false
    end
    def credential_file(path)
      return path if !@host || @host == '127.0.0.1'
      path + '.' + @host.tr('.', '_')
    end
  end
end

if defined?(PEMK::Auth) && defined?(SaveData)
  module ArenaDemo::ExplicitConnectionStart
    def ensure_started
      return if ArenaDemo::ConnectionMode.offline?
      super
    end
  end
  PEMK.singleton_class.prepend(ArenaDemo::ExplicitConnectionStart)
  module ArenaDemo::LocalConnectionLogin
    def login_blocking
      return true unless ArenaDemo::ConnectionMode.authenticating?
      super
    end
    def apply_login(reply)
      # Historical online saves remain on the server and are never deserialized
      # or adopted into this local character.
      super(reply.merge(:_body => nil, :econ => nil, :inv => nil, :mon_evict => nil))
    end
    def relogin(client)
      result = super
      ArenaDemo::ConnectionMode.reset_progression_gates if result == :ok
      result
    end
    def token_file
      ArenaDemo::ConnectionMode.credential_file(super)
    end
    def account_file
      ArenaDemo::ConnectionMode.credential_file(super)
    end
  end
  PEMK::Auth.singleton_class.prepend(ArenaDemo::LocalConnectionLogin)
  module ArenaDemo::LocalConnectionLoad
    def initialize(scene)
      ArenaDemo::ConnectionMode.choose_at_title
      super
    end
  end
  PokemonLoadScreen.prepend(ArenaDemo::LocalConnectionLoad)
  module ArenaDemo::LocalWorldSync
    def tick; end
    def flush_event(*); end
    # Checkpoint still writes the current local save, with no cloud upload.
    def push_blob(*args, **kwargs); :unchanged; end
  end
  PEMK::Sync.singleton_class.prepend(ArenaDemo::LocalWorldSync)
  module ArenaDemo::DesktopReady
    def set_up_system
      result = super
      path = ENV['ARENA_READY_FILE']
      File.binwrite(path, Process.pid.to_s) if path && !path.empty?
      result
    end
  end
  Game.singleton_class.prepend(ArenaDemo::DesktopReady)
end
