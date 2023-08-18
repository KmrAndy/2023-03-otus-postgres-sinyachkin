do
$$
declare r record;
begin
    select 1/0;
exception
  when others then
    declare
      v_stacktrace project_schema.logs.stacktrace%type;
    begin
      get stacked diagnostics v_stacktrace = pg_exception_context;

      perform write_log('test2'::varchar, v_stacktrace);
      commit;
    end;
    raise;
end$$;

do
$$
declare
  v_result  integer;
  v_message varchar(255);
begin
  call maintenance_schema.drop_old_table_partitions(o_result  => v_result
                                                  , o_message => v_message);
  raise notice 'dropping partition - result: %, message: %', v_result, v_message;
end;
$$
language  plpgsql;


select * from project_schema.logs l order by l.log_id desc;

select * from pg_tables where schemaname = 'project_schema';

select * from project_schema.drop_table_partitions;

project_schema.list_table_growthkey
20230101

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
              where nsp.nspname = 'project_schema'
                and t.relname   = 'list_table_growthkey') p
             where p.partition_value != 'DEFAULT')
    select t1.partition_name::varchar(128)
         , t1.table_owner::varchar(128)
         , t1.table_name::varchar(128)
      from t1
     where translate(t1.part_key, '*0123456789', '*') = ''
       and (   (    2 = 1
                and length(part_key) = 8
                and (   ('PREV' = 'PREV' and t1.part_key::integer < 1)
                     or ('PREV' = 'NEXT' and t1.part_key::integer >= 1)))
            or (    2 = 2))
     order by t1.part_key::integer