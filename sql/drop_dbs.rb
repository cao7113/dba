#!/usr/bin/env dbcli runsqlet

prompt = TTY::Prompt.new
prefix = prompt.ask('DB pattern to delete:', default: ENV['db_prefix'])

db = conn.sequel_db

sql = 'select datname from pg_database;'
db.fetch(sql) do |r|
  dbname = r[:datname]
  if dbname =~ /^#{prefix}/
    puts "==delete database: #{dbname}"
    db.run "drop database #{dbname};"
  end
end

puts db.fetch(sql).map{|r| r[:datname] }
