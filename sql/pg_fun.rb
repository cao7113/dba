#!/usr/bin/env dbcli runsql

# https://www.postgresql.org/docs/9.6/static/functions-info.html#//apple_ref/cpp/Function/current_schemas
# System Information Functions
SELECT current_date + s.a AS dates FROM generate_series(0,14,7) AS s(a);
