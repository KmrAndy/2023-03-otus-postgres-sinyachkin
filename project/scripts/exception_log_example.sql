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

with recursive inh as (
   select i.inhrelid, null::text as parent
   from pg_catalog.pg_inherits i
     join pg_catalog.pg_class cl on i.inhparent = cl.oid
     join pg_catalog.pg_namespace nsp on cl.relnamespace = nsp.oid
   where nsp.nspname = 'project_schema'          ---<< change table schema here
     and cl.relname = 'logs'   ---<< change table name here
   union all
   select i.inhrelid, (i.inhparent::regclass)::text
   from inh
   join pg_catalog.pg_inherits i on (inh.inhrelid = i.inhparent)
)
select c.relname as partition_name,
        n.nspname as partition_schema,
        pg_get_expr(c.relpartbound, c.oid, true) as partition_expression,
        pg_get_expr(p.partexprs, c.oid, true) as sub_partition,
        parent,
        case p.partstrat
          when 'l' then 'LIST'
          when 'r' then 'RANGE'
        end as sub_partition_strategy
from inh
   join pg_catalog.pg_class c on inh.inhrelid = c.oid
   join pg_catalog.pg_namespace n on c.relnamespace = n.oid
   left join pg_partitioned_table p on p.partrelid = c.oid
order by n.nspname, c.relname