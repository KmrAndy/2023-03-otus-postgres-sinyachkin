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
  raise notice 'dropping partitions - result: %, message: %', v_result, v_message;
	
  call maintenance_schema.create_new_table_partitions(o_result  => v_result
                                                    , o_message => v_message);
  raise notice 'creating partitions - result: %, message: %', v_result, v_message;
end;
$$
language  plpgsql;


select * from project_schema.logs l order by l.log_id desc;

select * from project_schema.archive_table_partitions;

select relname, reltablespace  from pg_class where schemaname = 'project_schema';

select * from pg_partition_tree('project_schema.list_year_table');

with t1 as
    (
     select trim(regexp_substr(p.partition_value, '\d+')) partition_value
          , p.partition_name
          , p.table_owner
          , p.table_name
          , p.tablepace_name
       from (select pg_get_expr(tp.relpartbound, i.inhrelid, true) partition_value
                  , nsp.nspname table_owner
                  , t.relname   table_name
                  , tp.relname  partition_name
                  , tbs.spcname tablepace_name
               from pg_catalog.pg_inherits i
               join pg_catalog.pg_class t on i.inhparent = t.oid
               join pg_catalog.pg_namespace nsp on t.relnamespace = nsp.oid
               join pg_catalog.pg_class tp on i.inhrelid = tp.oid
               left join pg_catalog.pg_tablespace tbs on tbs.oid = tp.reltablespace 
              where nsp.nspname = 'project_schema'
                and t.relname   = 'list_year_table') p
             where p.partition_value != 'DEFAULT')
    select t1.partition_name::varchar(128)
         , t1.table_owner::varchar(128)
         , t1.table_name::varchar(128)
         , t1.partition_value::varchar(128)
         , t1.tablepace_name::varchar(128)
      from t1
      
      select *  from pg_catalog.pg_indexes  where tablename = 'list_year_table_2024'
