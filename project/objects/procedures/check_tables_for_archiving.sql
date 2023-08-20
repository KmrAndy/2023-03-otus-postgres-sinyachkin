create or replace procedure maintenance_schema.check_tables_for_archiving(in  i_table_owner          varchar
                                                                        , in  i_table_name           varchar
                                                                        , in  i_archive_table_name   varchar
                                                                        , out o_partitioning_type    varchar
                                                                        , out o_are_tables_supported boolean)
as
$body$
declare
  v_arch_partitioning_type varchar(1);
begin
  call maintenance_schema.check_table(i_table_owner        => i_table_owner
  	                                , i_table_name         => i_table_name
  	                                , o_partitioning_type  => o_partitioning_type
  	                                , o_is_table_supported => o_are_tables_supported);
  	                               
  if not o_are_tables_supported then
    return;
  end if;
  
  call maintenance_schema.check_table(i_table_owner        => i_table_owner
  	                                , i_table_name         => i_archive_table_name
  	                                , o_partitioning_type  => v_arch_partitioning_type
  	                                , o_is_table_supported => o_are_tables_supported);
  	                               
  if not o_are_tables_supported or o_partitioning_type != v_arch_partitioning_type then
    o_are_tables_supported := false;
    return;
  end if;
  
  -- Проверим свойства колонок у архивной и основной таблицы:
  if   maintenance_schema.get_tables_diff_columns(i_table_owner, i_table_name, i_archive_table_name) > 0
    or maintenance_schema.get_tables_diff_columns(i_table_owner, i_table_name, i_archive_table_name) > 0
  then
    o_are_tables_supported := false;
    call project_schema.write_log('Колонки у ' || i_table_owner || '.' || i_table_name || ' и ' || 
                                                  i_table_owner || '.' || i_archive_table_name || ' не совпадают');
    return;
  end if;
end;
$body$
language  plpgsql;