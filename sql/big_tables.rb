#!/usr/bin/env dbcli runsqlet
# sort by table size, \dt+ in psql

require "active_support"
require "active_support/core_ext/numeric"

db = sequel_db
 
limit = (ENV['LIMIT'] || 50).to_i
if ENV['SCHEMA']
  schemas = ENV['SCHEMA'].to_s.split(',').map{|s| s.strip }
else
  schemas = db.user_schemata.map(&:to_s)
end
puts "schemas: #{schemas}"

# SELECT pg_size_pretty( pg_database_size('dbname') );
# SELECT pg_size_pretty( pg_total_relation_size('tablename') );
sql = <<-SQL
  select table_schema || '.' || table_name as tbl, pg_total_relation_size(quote_ident(table_name)) 
    from information_schema.tables where table_schema in ? 
    order by 2 desc limit #{limit};
SQL
sql = db.fetch(sql, schemas).sql

result = {}
db.fetch(sql) do |row|
  tbl, size = row.values
  result["#{tbl}"] = size
end

#puts sql
result.sort_by{|k, v| v }.reverse.to_a[0...limit].to_h.each_with_index do |(n, s), idx|
  size = s.to_i.to_s(:human_size)
  puts "#{idx + 1}: #{n} #{size}"
end
