# Real-time expedition allowance and lifecycle. This companion file deliberately
# lives beside each profile's save so loading an older save cannot renew an outing.

module ArenaDemo
  class OutingLedger
    FREE_LIMIT = 3
    WINDOW = 24 * 60 * 60
    DURATION = 20 * 60
    class LimitReached < StandardError; end
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def data
      return @data if @data
      parsed = if File.file?(@path)
                 File.open(@path, 'rb') { |file| Marshal.load(file) }
               else
                 { 'version' => 1, 'bonus' => 0, 'entries' => {} }
               end
      unless parsed.is_a?(Hash) && parsed['version'] == 1 &&
             parsed['bonus'].is_a?(Integer) && parsed['bonus'] >= 0 && parsed['entries'].is_a?(Hash)
        raise IOError, 'Invalid expedition allowance record'
      end
      parsed['entries'].each do |id, entry|
        unless id.is_a?(String) && entry.is_a?(Hash) &&
               entry['started_at'].is_a?(Numeric) && entry['started_at'].finite? &&
               entry['deadline'].is_a?(Numeric) && entry['deadline'].finite? &&
               entry['deadline'] >= entry['started_at'] &&
               ['free', 'bonus'].include?(entry['source']) &&
               [true, false].include?(entry['ended'])
          raise IOError, 'Invalid expedition session record'
        end
      end
      @data = parsed
    rescue TypeError, ArgumentError, EOFError => error
      raise IOError, "Unreadable expedition allowance record: #{error.message}"
    end

    def change
      updated = Marshal.load(Marshal.dump(data))
      result = yield updated
      temporary = @path + '.tmp'
      File.open(temporary, 'wb') { |file| Marshal.dump(updated, file); file.flush }
      File.rename(temporary, @path)
      @data = updated
      result
    end

    def free_remaining(now)
      used = data['entries'].values.count { |entry| entry['source'] == 'free' && entry['started_at'] > now - WINDOW }
      [FREE_LIMIT - used, 0].max
    end
    def bonus; data['bonus']; end
    def available?(now); free_remaining(now) > 0 || bonus > 0; end
    def next_free_at(now)
      starts = data['entries'].values.select { |entry| entry['source'] == 'free' && entry['started_at'] > now - WINDOW }
      starts.map { |entry| entry['started_at'] + WINDOW }.min
    end
    def session(id); data['entries'][id]; end

    def start(id, now)
      raise ArgumentError, 'Outing already recorded' if session(id)
      raise LimitReached, 'No outings available' unless available?(now)
      source = free_remaining(now) > 0 ? 'free' : 'bonus'
      change do |updated|
        updated['bonus'] -= 1 if source == 'bonus'
        updated['entries'][id] = { 'started_at' => now, 'deadline' => now + DURATION,
                                   'source' => source, 'ended' => false }
      end
      session(id)
    end

    def cancel(id)
      entry = session(id)
      return unless entry
      change do |updated|
        updated['entries'].delete(id)
        updated['bonus'] += 1 if entry['source'] == 'bonus'
      end
    end
    def finish(id)
      return unless session(id) && !session(id)['ended']
      change { |updated| updated['entries'][id]['ended'] = true }
    end

    # Extension point for future purchased/reward outings. No checkout, pricing,
    # currency deductions or player-facing purchase button exists in this build.
    def credit(count)
      raise ArgumentError, 'Outing credit must be a positive integer' unless count.is_a?(Integer) && count > 0
      change { |updated| updated['bonus'] += count }
    end
  end

  module Outings
    module_function
    def now; Time.now.to_f; end
    def ledger_path; SaveData::FILE_PATH + '.expeditions.dat'; end
    def ledger
      @ledgers ||= {}
      path = File.expand_path(ledger_path)
      @ledgers[path] ||= OutingLedger.new(path)
    end
    def world; Expeditions.state; end
    def active?; Expeditions.active?; end

    def allowance_text
      "#{ledger.free_remaining(now)}/#{OutingLedger::FREE_LIMIT} free outings available (24 hours)" +
        (ledger.bonus > 0 ? "; #{ledger.bonus} extra" : '')
    end
    def departure_allowed?
      return true if ledger.available?(now)
      next_at = ledger.next_free_at(now)
      text = 'You have used your three free outings in the last 24 hours.'
      text += " Next free outing: #{Time.at(next_at).strftime('%d/%m %H:%M')}." if next_at
      pbMessage(text)
      false
    rescue IOError, SystemCallError => error
      pbMessage("Cannot read the outing record. Check your save folder. #{error.message}")
      false
    end

    def start(plan)
      id = "#{plan['seed']}-#{(now * 1_000_000).to_i}"
      entry = ledger.start(id, now)
      plan['outing_id'], plan['deadline'] = id, entry['deadline']
      id
    end
    def cancel(id); ledger.cancel(id) if id; end

    def ensure_session
      return nil unless active?
      if !world['outing_id']
        # Stable migration identity means reloading the same pre-limit save
        # cannot repeatedly receive a fresh twenty-minute grace period.
        id = "legacy-#{world['seed']}"
        entry = ledger.session(id)
        entry = ledger.start(id, now) if !entry && ledger.available?(now)
        world['outing_id'] = id
        world['deadline'] = entry ? entry['deadline'] : now
      end
      ledger.session(world['outing_id'])
    end

    def remaining
      return 0 unless active?
      entry = ensure_session
      return 0 unless entry && !entry['ended'] && !world['outing_ended']
      deadline = [entry['deadline'], world['deadline'] || entry['deadline']].min
      [deadline - now, 0].max
    end
    def expired?
      active? && remaining <= 0
    rescue IOError, SystemCallError
      true # An unreadable allowance record cannot silently grant a new session.
    end
    def time_text
      seconds = remaining.ceil
      format('%02d:%02d', seconds / 60, seconds % 60)
    end

    def close_current
      return unless world && world['outing_id']
      world['outing_ended'] = true
      ledger.finish(world['outing_id'])
    rescue IOError, SystemCallError
      # The saved absolute deadline still bounds this outing if a close write
      # fails. Do not interrupt a completed battle/blackout with a filesystem error.
      nil
    end

    def safe_to_return?
      return false unless defined?(Scene_Map) && $scene.is_a?(Scene_Map) && $game_temp && $game_player
      return false if $game_temp.in_battle || $game_temp.in_menu || $game_temp.message_window_showing
      return false if defined?(pbMapInterpreterRunning?) && pbMapInterpreterRunning?
      return false if $game_player.moving?
      return false if $game_temp.respond_to?(:player_transferring) && $game_temp.player_transferring
      return false if defined?(VisibleWild) && VisibleWild.instance_variable_get(:@busy)
      true
    end

    def tick
      return if @returning || !active? || !expired? || !safe_to_return?
      @returning = true
      begin
        VisibleWild.clear if defined?(VisibleWild)
        Controls.cancel_menu if defined?(Controls)
        ArenaDemo.transfer_to(TOWN_MAP_ID, 16, 20, 8)
        unless active?
          close_current
          pbMessage('Your outing has ended. You have returned to Arena Village.')
        end
      ensure
        @returning = false
      end
    end
  end

end

if defined?(Scene_Map)
  class Scene_Map
    alias arena_outing_base_update update
    def update
      ArenaDemo::Outings.tick
      arena_outing_base_update
      ArenaDemo::Outings.tick
    end
  end
end
EventHandlers.add(:on_enter_map, :arena_close_outing, proc { |old_id|
  if ArenaDemo::ExpeditionLayout.map?(old_id) && !ArenaDemo::ExpeditionLayout.map?($game_map.map_id)
    ArenaDemo::Outings.close_current
  end
})

if defined?(Sprite)
  class ArenaOutingTimer < Sprite
    def initialize(viewport)
      super(viewport)
      self.bitmap = Bitmap.new(236, 38)
      pbSetSystemFont(self.bitmap)
      self.x = Graphics.width - 244
      self.y = 8
      self.z = 99999
      update
    end
    def update
      super
      return if disposed?
      self.visible = ArenaDemo::Outings.active? && !$game_temp.in_battle && !$game_temp.in_menu &&
                     !$game_temp.message_window_showing
      return unless self.visible
      text = ArenaDemo::Outings.expired? ? 'Outing finished' : "Outing: #{ArenaDemo::Outings.time_text}"
      return if text == @last_text
      @last_text = text
      self.bitmap.clear
      self.bitmap.fill_rect(0, 0, 236, 38, Color.new(16, 26, 32, 192))
      pbDrawTextPositions(self.bitmap, [[text, 12, 2, 0, Color.new(248, 248, 240), Color.new(48, 56, 64)]])
    end
    def dispose
      self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
      super
    end
  end
end
EventHandlers.add(:on_new_spriteset_map, :arena_outing_timer, proc { |spriteset, viewport|
  if defined?(ArenaOutingTimer) && spriteset.map == $game_map && ArenaDemo::Outings.active?
    spriteset.addUserSprite(ArenaOutingTimer.new(viewport))
  end
})
