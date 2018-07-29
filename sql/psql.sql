#!/usr/bin/env psql -f
-- shell: psql -a -f _this_file
-- shell: psql -a -c '\l' 

-- test change user in psql context
select "current_user"();
create user user1;
\c postgres user1; 
select "current_user"();
\c postgres postgres;  
drop user user1;
select "current_user"();

/*
-- help and .psqlrc settings
https://www.digitalocean.com/community/tutorials/how-to-customize-the-postgresql-prompt-with-psqlrc-on-ubuntu-14-04
3 levels of config:
1) system-wide:  `pg_config --sysconfdir`
2) user wide:    ~/.psqlrc
3) version wide: ~/.psql-9.4

\set PROMPT1 '%M:%> %n@%/%R%#%x '
\set search_path to public, data
\timing
\dx -- list pg extensions
\dn
\du+
\conninfo
\c db1 user1 -- 切换数据库和用户
\e
\h
\?
\h create table
\password postgres -- 设置用户密码
\x   --Expanded display 竖行显示, 对于宽表显示很有帮助
\ddp -- view default privileges, pgcli not support
\dp+
\i /path/to/a/sql.sql
-- on psql client
\copy xxx
-- on pg server
-- copy (select * from hogetable where basedate between '20070101' and '20070131') TO '/tmp/1month.sql';
-- copy hogetable from '/tmp/1month.sql';

show search_path;
show shared_buffers;
show all;

run shell command in psql session:
\! echo this line is a shell command

in shell
psql -d $db_url -XAt -c "select count(*) from public.schema_migrations";
psql < xxx_sql_file.sql
*/

-- echo "select 'drop table data.'||tablename||';' from pg_tables where tablename like 'it_%'" | psql postgres://pass:'dbnopass#fUiP'@abc.com/adb -t | psql postgres://pass:'dbnopass#fUiP'@abc.com/adb

