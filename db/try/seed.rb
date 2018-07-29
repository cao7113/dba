#!/usr/bin/env dbcli runsqlet
db = sequel_db

db[:users].insert(name: 'admin')
db[:blogs].insert(title: 'test blog')
