#!/usr/bin/env dbcli runsqlet
# sort by db size, \l+ in psql

db = sequel_db
#pg_size_pretty()
sql = <<-SQL
  SELECT pg_database_size('#{conn.dbname}');
SQL
sql = db.fetch(sql).sql
puts sql

byebug
db.fetch(sql) do |row|
  puts row
end
