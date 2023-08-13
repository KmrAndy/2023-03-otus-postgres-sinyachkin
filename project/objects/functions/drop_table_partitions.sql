create or replace function maintenance_schema.drop_table_partitions(p_table_owner               varchar
                                                                  , p_table_name                varchar
                                                                  , p_stored_partition_quantity integer
                                                                  , p_search_type               integer
                                                                  , p_partitioning_type         varchar
                                                                  , p_current_date              date default null)
returns void
as
$body$
begin
  null;
end;
$body$
language  plpgsql;