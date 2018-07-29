#!/usr/bin/env dbcli runsqlet

db = sequel_db
begin
  migtable = db[:schema_migrations]
  colname = migtable.columns.first
  last_mig = migtable.order(Sequel.desc(colname)).first
  puts "last schema migration:"
  puts last_mig[colname]
rescue Sequel::DatabaseError => e
  if e.message =~ /^PG::UndefinedTable: ERROR:  relation/
    #warn e.message
    nil
  else
    raise
  end
end
