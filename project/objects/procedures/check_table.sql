create or replace procedure maintenance_schema.check_table(in  i_table_owner        varchar
                                                         , in  i_table_name         varchar
                                                         , out o_partitioning_type  varchar
                                                         , out o_is_table_supported boolean)
as
$body$
declare
  v_rec record;
begin
  select p.partstrat
    into o_partitioning_type
    from pg_catalog.pg_class c
    join pg_catalog.pg_namespace n on c.relnamespace = n.oid
    join pg_partitioned_table p on p.partrelid = c.oid
   where n.nspname = i_table_owner
     and c.relname = i_table_name;
  
  -- Работаем только с Range и List
  if o_partitioning_type not in ('r', 'l') then
    o_is_table_supported := false;
  else
    o_is_table_supported := true;
  end if;
end;
$body$
language  plpgsql;