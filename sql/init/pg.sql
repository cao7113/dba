#!/usr/bin/env dbcli runsql

-- init local pg cluster
create user dbauser with superuser;
create user dbuser with password 'dbuser';
