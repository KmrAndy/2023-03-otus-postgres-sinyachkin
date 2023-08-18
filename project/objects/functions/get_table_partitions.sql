create or replace function maintenance_schema.get_table_partitions(i_table_owner        varchar(128)
                                                                 , i_table_name         varchar(128)
                                                                 , i_partitioning_type  varchar(1)
                                                                 , i_search_type        integer
                                                                 , i_search_direction   varchar(4)
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
     select trim('''' from regexp_substr(p.partition_value, '''.*?''', 1, 2))::date - 1 to_date_interval
          , p.partition_name
          , p.table_owner
          , p.table_name
       from (select pg_get_expr(tp.relpartbound, i.inhrelid, true) partition_value
                  , nsp.nspname table_owner
                  , t.relname   table_name
                  , tp.relname  partition_name
               from pg_catalog.pg_inherits i
               join pg_catalog.pg_class t on i.inhparent = t.oid
               join pg_catalog.pg_namespace nsp on t.relnamespace = nsp.oid
               join pg_catalog.pg_class tp on i.inhrelid = tp.oid
              where nsp.nspname = i_table_owner 
                and t.relname   = i_table_name) p
             where p.partition_value != 'DEFAULT'
             order by p.table_name)
    select t1.partition_name::varchar(128)
         , t1.table_owner::varchar(128)
         , t1.table_name::varchar(128)
      from t1
     where (i_search_type = 1  and (   (i_search_direction = 'PREV' and t1.to_date_interval <  i_search_date)
                                    or (i_search_direction = 'NEXT' and t1.to_date_interval >= i_search_date)))
        or (i_search_type = 2)
     order by t1.to_date_interval;
  elsif i_partitioning_type = 'l' then
    v_date_key := to_char(date_trunc('month', i_search_date), 'yyyymmdd');
    
    return query
    with t1 as
    (
     select trim(regexp_substr(p.partition_value, '\d+')) part_key
          , p.partition_name
          , p.table_owner
          , p.table_name
          , p.partition_value
       from (select pg_get_expr(tp.relpartbound, i.inhrelid, true) partition_value
                  , nsp.nspname table_owner
                  , t.relname   table_name
                  , tp.relname  partition_name
               from pg_catalog.pg_inherits i
               join pg_catalog.pg_class t on i.inhparent = t.oid
               join pg_catalog.pg_namespace nsp on t.relnamespace = nsp.oid
               join pg_catalog.pg_class tp on i.inhrelid = tp.oid
              where nsp.nspname = i_table_owner
                and t.relname   = i_table_name) p
             where p.partition_value != 'DEFAULT')
    select t1.partition_name::varchar(128)
         , t1.table_owner::varchar(128)
         , t1.table_name::varchar(128)
      from t1
     where translate(t1.part_key, '*0123456789', '*') = ''
       and (   (    i_search_type = 1
                and length(part_key) = 8
                and (   (i_search_direction = 'PREV' and t1.part_key::integer < v_date_key)
                     or (i_search_direction = 'NEXT' and t1.part_key::integer >= v_date_key)))
            or (    i_search_type = 2))
     order by t1.part_key::integer;
  end if;
end;
$body$
language  plpgsql;