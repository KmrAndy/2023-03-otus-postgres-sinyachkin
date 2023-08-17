create or replace procedure maintenance_schema.drop_table_partitions(i_table_owner               varchar
                                                                   , i_table_name                varchar
                                                                   , i_stored_partition_quantity integer
                                                                   , i_search_type               integer
                                                                   , i_partitioning_type         varchar
                                                                   , i_current_date              date default null)
as
$body$
begin
  null;
end;
$body$
language  plpgsql;