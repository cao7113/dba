#!/usr/bin/env dbcli runsqlet
# self is Dba::ScriptRunner (lib/dba/script_runner.rb)
# conn is current Dba::ConnectionBuilder

def say_hi
  puts "Hi sqlet from self: #{self}!"
  puts "current conn url: #{conn.url}"
end
say_hi

r = conn.run_sql <<-SQL
  select datname from pg_database;
SQL
puts "sql result: #{r.output}" 

__END__
## use Sequel(http://sequel.jeremyevans.net/documentation.html)
# sdb = conn.sequel_db
# sdb.run 'select current_user'
