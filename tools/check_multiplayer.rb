# frozen_string_literal: true

# Run with the project's native Ruby and GEM_HOME set by local-multiplayer.ps1.
# No credentials or account data are printed or persisted.
$stdout.sync = true
puts "Ruby: #{RUBY_DESCRIPTION}"
puts "Gem home: #{Gem.dir}"
require "bcrypt"
puts "bcrypt #{Gem.loaded_specs.fetch('bcrypt').version}: checking native hashing"
password = "arena-local-diagnostic"
hash = BCrypt::Password.create(password, cost: 12)
abort "bcrypt verify failed" unless hash == password && !(hash == "incorrect")
puts "bcrypt hash and verification: PASS"
require "pg"
require "sequel"
db = Sequel.connect(ENV.fetch("DATABASE_URL"), connect_timeout: 5)
puts "PostgreSQL connection: PASS (schema #{db[:schema_info].get(:version)})"
db.disconnect
