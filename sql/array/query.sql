#!/usr/bin/env dbcli runsql
-- http://sequel.jeremyevans.net/rdoc-plugins/files/lib/sequel/extensions/pg_array_rb.html
-- ARRAY constructor syntax   ARRAY[e1, e2] # 注： 大小写不敏感！！！
-- array-literal syntax       '{1, 2}'

INSERT INTO sal_emp VALUES ('Bill', '{10000, 10000, 10000, 10000}',
       '{{"meeting", "lunch"}, {"training", "presentation"}}');

INSERT INTO sal_emp VALUES ('Bill', '{10000, 10000, 10000, 10000}', null);
INSERT INTO sal_emp VALUES ('Bill', '{10000, 10000, 10000, 10000}', '{}');
-- INSERT INTO sal_emp VALUES ('Bill', '{10000, 10000, 10000, 10000}', ARRAY[]);

select array_length(ARRAY[1, 2, 3], 1);
select cardinality(ARRAY[1, 2, 3]);

select * from sal_emp where cardinality(schedule) = 0;
-- error
-- select * from sal_emp where array_length(schedule, 1) = 0;

-- 注意数组元素下标从1开始计数，而不是0
SELECT name FROM sal_emp WHERE pay_by_quarter[1] <> pay_by_quarter[2];

-- conditional query
SELECT * FROM sal_emp WHERE 10000 = ANY (pay_by_quarter);
SELECT * FROM sal_emp WHERE 10000 = ALL (pay_by_quarter);

-- 数组不包含某元素, 注意不是any哦！
select * from sal_emp where 10000 != all(pay_by_quarter);
SELECT * FROM
   (SELECT pay_by_quarter, generate_subscripts(pay_by_quarter, 1) AS s
           FROM sal_emp) AS foo
   WHERE pay_by_quarter[s] = 10000;

-- null special
SELECT n FROM unnest(ARRAY[NULL,1,2,3,4,5]) n WHERE n = NULL;
SELECT n, CASE WHEN n = NULL THEN 'NULL' ELSE 'NOT NULL' END FROM unnest(ARRAY[NULL,1,2,3,4,5]) n;

-- select id, name, sector_id, sector_ids from data.hub_products where cardinality(sector_ids) != cardinality(array_remove(sector_ids, null)) limit 10;
-- select count(*) from data.hub_products where cardinality(sector_ids) != cardinality(array_remove(sector_ids, null));
