#!/usr/bin/env dbcli runsqlet

db = conn.sequel_db

puts "user schemas:"
puts db.user_schemata.join(' ')

puts "total tables"
puts db.tables.size
