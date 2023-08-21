create or replace function maintenance_schema.get_table_partitions(i_table_owner        varchar
                                                                 , i_table_name         varchar
                                                                 , i_partitioning_type  varchar
                                                                 , i_search_type        integer
                                                                 , i_search_direction   varchar
                                                                 , i_search_date        date)
returns setof maintenance_schema.partition_params
as
$body$
declare
  v_partitions_params maintenance_schema.partition_params[];
  v_date_key          integer;
begin
  if i_partitioning_type = 'r' then
    return query
    with t1 as
    (
     select trim('''' from regexp_substr(p.partition_expr, '''.*?''', 1, 2))::date partition_value
          , p.partition_name
          , p.table_owner
          , p.table_name
          , p.tablepace_name
          , p.partition_expr
       from (select pg_get_expr(tp.relpartbound, i.inhrelid, true) partition_expr
                  , nsp.nspname table_owner
                  , t.relname   table_name
                  , tp.relname  partition_name
                  , tbs.spcname tablepace_name
               from pg_catalog.pg_inherits i
               join pg_catalog.pg_class t on i.inhparent = t.oid
               join pg_catalog.pg_namespace nsp on t.relnamespace = nsp.oid
               join pg_catalog.pg_class tp on i.inhrelid = tp.oid
               left join pg_catalog.pg_tablespace tbs on tbs.oid = tp.reltablespace 
              where nsp.nspname = i_table_owner
                and t.relname   = i_table_name) p
             where p.partition_expr != 'DEFAULT'
             order by p.table_name)
    select t1.partition_name::varchar(128)
         , t1.table_owner::varchar(128)
         , t1.table_name::varchar(128)
         , t1.partition_value::varchar(128)
         , t1.tablepace_name::varchar(128)
         , t1.partition_expr::varchar(128)
      from t1
     where (i_search_type = 1  and (   (i_search_direction = 'PREV' and t1.partition_value <=  i_search_date)
                                    or (i_search_direction = 'NEXT' and t1.partition_value > i_search_date)))
        or (i_search_type = 2)
     order by t1.partition_value;
    
  elsif i_partitioning_type = 'l' then
    v_date_key := to_char(date_trunc('month', i_search_date), 'yyyymmdd');
    
    return query
    with t1 as
    (
     select trim(regexp_substr(p.partition_expr, '\d+')) partition_value
          , p.partition_name
          , p.table_owner
          , p.table_name
          , p.tablepace_name
          , p.partition_expr
       from (select pg_get_expr(tp.relpartbound, i.inhrelid, true) partition_expr
                  , nsp.nspname table_owner
                  , t.relname   table_name
                  , tp.relname  partition_name
                  , tbs.spcname tablepace_name
               from pg_catalog.pg_inherits i
               join pg_catalog.pg_class t on i.inhparent = t.oid
               join pg_catalog.pg_namespace nsp on t.relnamespace = nsp.oid
               join pg_catalog.pg_class tp on i.inhrelid = tp.oid
               left join pg_catalog.pg_tablespace tbs on tbs.oid = tp.reltablespace 
              where nsp.nspname = i_table_owner
                and t.relname   = i_table_name) p
             where p.partition_expr != 'DEFAULT')
    select t1.partition_name::varchar(128)
         , t1.table_owner::varchar(128)
         , t1.table_name::varchar(128)
         , t1.partition_value::varchar(128)
         , t1.tablepace_name::varchar(128)
         , t1.partition_expr::varchar(128)
      from t1
     where translate(t1.partition_value, '*0123456789', '*') = ''
       and (   (    i_search_type = 1
                and length(partition_value) = 8 -- Пока считаем что ключ list партиций для дат состоит из 8 символов в формате yyyymmdd
                and (   (i_search_direction = 'PREV' and t1.partition_value::integer < v_date_key)
                     or (i_search_direction = 'NEXT' and t1.partition_value::integer >= v_date_key)))
            or (    i_search_type = 2))
     order by t1.partition_value::integer;
  end if;
end;
$body$
language  plpgsql;