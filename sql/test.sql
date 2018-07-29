-- Hub::ProjectAssociation.where(source_type: 'athena').left_outer_joins(:hub_project).limit(3).pluck('hub_products.id as hpid')

SELECT
  company_id        AS source_id,
  'athena'          AS source_type,
  json_agg ((
    description,
    CASE
      fundings.cached_round_list
      WHEN 'seed' THEN 1
      WHEN 'angel' THEN 2
      WHEN 'f' THEN 15
      WHEN 'g' THEN 15 ELSE 100
    END,
    business_model,
    market_analysis
    )) AS collections
FROM
  fundings  GROUP BY company_id limit 3;

--导出表结构
SELECT n.nspname as "系统名",
  c.relname as "表名",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "大小",
  pg_catalog.obj_description(c.oid, 'pg_class') as "中文名",
  c.reltuples AS "条数"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
      AND n.nspname !~ '^pg_toast'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1 DESC,2;

select distinct(table_schema) from information_schema.columns;

-- https://stackoverflow.com/questions/343138/retrieving-comments-from-a-postgresql-db

SELECT c.table_schema,c.table_name,c.column_name,pgd.description
FROM pg_catalog.pg_statio_all_tables as st
  inner join pg_catalog.pg_description pgd on (pgd.objoid=st.relid)
  inner join information_schema.columns c on (pgd.objsubid=c.ordinal_position
    and  c.table_schema=st.schemaname and c.table_name=st.relname);

-- 数据库所有表列表
select table_schema || '.' || table_name as tblname from information_schema.tables where table_schema in ('stat') order by tblname ;    
    
-- select 
-- 含英文
select count(*) from (
  select name, hub_id from data.hub_project_associations 
  where source_type = 'athena' 
  group by hub_id, name having count(*) = 1 and name ~ '^[a-zA-Z]') as n;

-- in 语法
--value IN (value1,value2,...);
--value IN (SELECT value FROM tbl_name);
SELECT first_name, last_name FROM customer 
  WHERE customer_id IN (
    SELECT customer_id FROM rental 
    WHERE CAST (return_date AS DATE) = '2005-05-27');
    
-- subquery http://www.postgresqltutorial.com/postgresql-subquery/
SELECT
 first_name, last_name
FROM customer
WHERE
 EXISTS (
 SELECT 1 FROM payment WHERE
   payment.customer_id = customer.customer_id
 );

--- delete
-- 剩下的是可以安全刪除的名字
delete from data.hub_product_members where name like '%|%';

--- update
update data.hub_product_news 
  set unique_key = 'old/' || md5(random() :: text || random() :: text) 
  where unique_key is null;

update data.hub_invests 
  set round = btrim(round, E'\r\n\t ');

-- 需要被更新的名字
update data.hub_product_members 
  set name = substring(name from '#"%#"#|%' for '#')
  where id in (
    select id
    from data.hub_product_members as t1
    where name like '%|%'
    and substring(name from '#"%#"#|%' for '#') not in (
        select name from data.hub_product_members
        where name = substring(t1.name from '#"%#"#|%' for '#')
        and product_id = t1.product_id
    )
);

-- 正则表达式(pg)
select id, report_url, report_from, report_title 
  from data.hub_invests 
  where report_url is not null and report_url !~ '^https?://' and report_url != '';

select id, title, name from data.hub_product_members 
  where title ~ '\d+';

-- 数组元素

select id, sector_id, sector_ids from data.hub_products 
where cardinality(sector_ids) != cardinality(array_remove(sector_ids, null)) limit 3;

select count(*) from data.hub_products 
where cardinality(sector_ids) != cardinality(array_remove(sector_ids, null));

update data.hub_products 
set sector_ids = array_remove(sector_ids, null) 
where cardinality(sector_ids) != cardinality(array_remove(sector_ids, null));

-- group by， 分组统计
-- 同名用户数统计
select name, count(id) as cnt 
  from users group by name having count(id) > 1 
  order by cnt desc;

-- 查询feed数最多的top10人
select feeder_id, count(id) as c 
  from feeds group by feeder_id 
  order by c desc limit 10;

-- 历史融资表中 对项目分组统计最新融资
select hic.project_id, hic.id 
  from data.hub_invest_cases hic, 
  (select project_id , max(date) max_date 
    from data.hub_invest_cases 
    where soft_deleted = false and project_id is not null
    group by project_id) gic 
   where hic.project_id = gic.project_id and hic.date = gic.max_date;
   
-- 通表中分组排序取头部的经典案例
-- 支持distinct on的db（如pg）更好的实现方式
select distinct on (project_id) project_id, id
  from data.hub_invest_cases 
  where soft_deleted = false and project_id is not null
  order by project_id, date desc;

-- 元数据管理
-- 在指定数据中查看特定名字的数据列(mysql)
select table_name, column_name 
  from information_schema.columns 
  where table_schema='tianji' and column_name like '%cent%';
  
-- pg 表大小查询
SELECT 
  t.tbl table_name, ct.reltuples row_count,
  pg_total_relation_size(t.tbl) size,
  pg_size_pretty(pg_total_relation_size(t.tbl)) pretty_size
FROM (
  SELECT table_name tbl
    FROM information_schema.tables
    WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
) t
join (
  SELECT 
    relname, reltuples
  FROM pg_class C
    LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE 
    nspname NOT IN ('pg_catalog', 'information_schema') 
      AND relkind='r' 
) ct 
on t.tbl = ct.relname order by size desc ;

-- mysql
SELECT 
  TABLE_NAME, table_rows, data_length, index_length,  
  round(((data_length + index_length) / 1024 / 1024),2) 'Size in MB' 
FROM information_schema.TABLES 
WHERE table_schema = 'mysql' and TABLE_TYPE='BASE TABLE' 
ORDER BY data_length DESC;
