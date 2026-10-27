# frozen_string_literal: true
# Inspect only local client logs; never read saves, sessions, or credentials.
game = File.expand_path('runtime/essentials-v21.1-base', __dir__)
$stdout.sync = true
%w[errorlog.txt mmo.log mmo_guest.log mkxp.log arena-boot.log native-ruby-stack.log mkxp.json].each do |name|
  next if !ARGV.empty? && !ARGV.include?(name)
  path = File.join(game, name)
  next unless File.file?(path)
  puts "--- #{name} (#{File.mtime(path)}) ---"
  File.open(path, 'rb') do |file|
    file.seek([file.size - 16_000, 0].max)
    text = file.read.to_s.force_encoding('UTF-8').scrub
    lines = text.lines.reject { |line| line.match?(/password|token|email/i) }
    puts lines.last(65)
  end
end
