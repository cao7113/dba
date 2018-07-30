#!/usr/bin/env dbcli runsql

-- pg server version
select version();
select CURRENT_USER;
-- select CURRENT_TIME;
SHOW data_directory;
-- select now();

-- User & Roles
-- user list
select usename from pg_catalog.pg_user;
-- select "current_user"();
select current_user;
-- SELECT rolname from pg_roles;
-- alter user user1 with superuser;
-- grant select on db1 to user1;
-- grant select table t1 to repoerting & grant reporting to reporter1; # reporter1具有select权限

-- ## Database 
select current_database();
-- rename db (it should now have zero clients)
-- ALTER DATABASE old_dbname RENAME TO new_dbname;
-- copy db 
-- create database new_dbname with template old_dbname;
-- database list 
select datname from pg_catalog.pg_database;
-- drop database if exists xxxdb;

-- ## Schema
select "current_schema"();
-- grant all on all tables in schema schema1 to user1;
-- 为将来创建的表赋以权限
-- alter default privileges in schema schema1 grant all on tables to user1;
-- CREATE SCHEMA IF NOT EXISTS test AUTHORIZATION joe;
-- ALTER SCHEMA name RENAME TO new_name
-- ALTER SCHEMA name OWNER TO { new_owner | CURRENT_USER | SESSION_USER }
-- 删除模式及其所有对象，请使用级联删除
-- DROP SCHEMA mystuff CASCADE;
-- list all schemas
-- select schema_name from information_schema.schemata;
-- select nspname from pg_catalog.pg_namespace;

-- ## table
-- CREATE TABLE tmp1 (id serial, name text);
-- insert into tmp1(name) values ('abc'), ('b');
-- insert into users(name) select generate_series(6, 10);
-- insert into users(name) select s.a from generate_series(6, 10) as s(a);
-- INSERT INTO articles (x, y) SELECT 12, id FROM table_name WHERE name = 'string';
-- copy table
-- https://www.postgresql.org/docs/9.0/static/sql-createtableas.html
-- CREATE TABLE films2 AS TABLE films;
-- CREATE TABLE films_recent AS SELECT * FROM films WHERE date_prod >= '2002-01-01';


-- ## Stat & Monitor
-- pghero
-- list current connected sessions (client apps)
select * from pg_stat_activity;
-- select datname, pid, usename, application_name, client_addr, client_hostname, client_port backend_start, query from pg_stat_activity;

-- ## Ops
-- vacuum tbl;

-- alter pg_database system table to disallow new connections to specific database
-- UPDATE pg_database SET datallowconn = FALSE WHERE datname = 'xxxdbname';
-- UPDATE pg_database SET datallowconn = TRUE WHERE datname = 'xxxdbname';

-- find table filesystem path
-- select pg_relation_filepath('emp');
