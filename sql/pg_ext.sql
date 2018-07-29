#!/usr/bin/env dbcli runsql
-- ext home dir:
-- /usr/local/opt/postgresql@9.6/share/postgresql@9.6/extension

-- \dx
create extension pg_buffercache;
select distinct reldatabase from pg_buffercache; 
--\! oid2name; --just work in psql session
