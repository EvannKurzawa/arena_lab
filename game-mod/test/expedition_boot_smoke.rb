# Run with Ruby --disable-gems. This simulates an embedded runtime without
# json/fileutils while exercising the actual plugin ledger code at startup.
module EventHandlers
  def self.add(*); end
end

module Kernel
  def require(name)
    raise LoadError, "Unexpected startup dependency: #{name}"
  end
end

load File.expand_path('../Plugins/ArenaDemo/018_ExpeditionLimits.rb', __dir__)
path = File.join(Dir.pwd, 'arena_outing_boot_smoke.dat')
begin
  ledger = ArenaDemo::OutingLedger.new(path)
  ledger.start('smoke', 1000.5)
  reloaded = ArenaDemo::OutingLedger.new(path)
  raise 'Outing was not persisted' unless reloaded.session('smoke')['deadline'] == 2200.5
  raise 'Allowance was not persisted' unless reloaded.free_remaining(1001) == 2
  reloaded.finish('smoke')
  raise 'Ended outing reopened' unless ArenaDemo::OutingLedger.new(path).session('smoke')['ended']
  puts 'Embedded startup and outing persistence: OK'
ensure
  File.delete(path) if File.file?(path)
  File.delete(path + '.tmp') if File.file?(path + '.tmp')
end
