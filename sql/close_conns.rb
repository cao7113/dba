#!/usr/bin/env dbcli runsqlet

# Query pg_stat_activity and get the pid values you want to kill, then issue SELECT pg_terminate_backend(pid int) to them, apply 9.2+
sql = <<-SQL
  SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '#{conn.dbname}' AND pid <> pg_backend_pid();
  select pid, usename, application_name, client_addr, client_hostname, client_port, backend_start from pg_stat_activity where datname = '#{conn.dbname}';
SQL
r = conn.run_sql 
puts r.output

__END__
https://www.postgresql.org/docs/9.6/static/functions-admin.html
pg_cancel_backend(pid)     # cancel current query
pg_terminate_backend(pid)  # close connection
