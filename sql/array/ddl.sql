#!/usr/bin/env dbcli runsql
-- http://sequel.jeremyevans.net/rdoc-plugins/files/lib/sequel/extensions/pg_array_rb.html
-- ARRAY constructor syntax   ARRAY[e1, e2] # 注： 大小写不敏感！！！
-- array-literal syntax       '{1, 2}'

CREATE TABLE sal_emp (
  name            text,
  pay_by_quarter  integer[],
  schedule        text[][]
);

