# frozen_string_literal: true
require "sequel"
Sequel.extension :migration
server = File.expand_path(ARGV.fetch(0))
db = Sequel.connect(ENV.fetch("DATABASE_URL"), connect_timeout: 5)
Sequel::Migrator.run(db, File.join(server, "db", "migrate"))
puts "Database schema: #{db[:schema_info].get(:version)}"
db.disconnect
