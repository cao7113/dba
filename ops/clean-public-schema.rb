#!/usr/bin/env dbcli runsqlet
require 'byebug'

db = conn.sequel_db
schema = ENV['SCHEMA'] || :public
db.search_path = schema

reserved_tables = %i(
ar_internal_metadata
schema_migrations
)

## stats
tables = db.tables - reserved_tables
puts "==reserver #{reserved_tables.size} tables in schema: #{schema}"
puts reserved_tables.map(&:to_s).join(' ')

puts "==will archive #{tables.size} tables"
tables.sort.each_with_index do |t, idx|
  puts [idx + 1, t, db.from(t).count].join ' '
end

## archiv db
# pga fork starup_production xxx/agentcloud_legacy201808 --dump-opts='--schema public'

## danage!! clean tables
