# frozen_string_literal: true
require 'fileutils'

server_root = File.expand_path(ARGV.fetch(0))
log_path = File.expand_path(ARGV.fetch(1))
FileUtils.mkdir_p(File.dirname(log_path))
log = File.open(log_path, 'a')
log.sync = true
$stdout.sync = true
# Native extension crashes write to stderr. Preserve their diagnostics as well
# as normal server messages, without touching upstream code.
$stderr.reopen(log)
$stderr.sync = true
$LOAD_PATH.unshift(File.join(server_root, 'lib'), File.expand_path('../protocol', server_root))
logger = lambda do |message|
  line = "#{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')} #{message}"
  puts line
  log.puts line
end
begin
  require 'pemk'
  logger.call("launcher: root=#{File.expand_path('..', __dir__)} ruby=#{RUBY_DESCRIPTION}")
  PEMK::Server.new(logger: logger).run
rescue Interrupt
  logger.call('launcher: server stopped')
rescue Exception => error
  logger.call("launcher: FAILED #{error.class}: #{error.message}")
  log.puts(error.backtrace || [])
  exit 1
ensure
  log&.flush
end
