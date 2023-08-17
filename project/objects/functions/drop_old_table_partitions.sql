create or replace procedure maintenance_schema.drop_old_table_partitions(out o_result  integer
                                                                       , out o_message varchar)
as
$body$
declare
  v_partitioning_type  varchar(1);
  v_is_table_supported boolean;
  v_rec record;
begin
  o_result  := 1;
  o_message := 'Удаление старых партиций таблиц выполнено успешно';
 
  for v_rec in (select table_owner, table_name, stored_partition_quantity, search_type 
                  from project_schema.drop_table_partitions
                 where enabled = 'Y')
  loop
	call write_log('Начинаем удаление партиций таблицы ' || v_rec.table_owner || '.' || v_rec.table_name);

  	perform check_table(i_table_owner        => v_rec.table_owner
  	                  , i_table_name         => v_rec.table_name
  	                  , o_partitioning_type  => v_partitioning_type
  	                  , o_is_table_supported => v_is_table_supported);
  	
  	if not o_is_table_supported then
  	  call write_log('Таблица ' || v_rec.table_owner || '.' || v_rec.table_name || ' не поддерживается');
  	 
  	  o_result  := 2;
  	  o_message := 'Удаление старых партиций таблиц выполнено с предупреждением';
  	  
  	  continue;
  	else
  	  call write_log('Таблица ' || v_rec.table_owner || '.' || v_rec.table_name || ' поддерживается');
    end if;
    
    call drop_table_partitions(i_table_owner               => v_rec.table_owner
                             , i_table_name                => v_rec.table_name
                             , i_stored_partition_quantity => v_rec.stored_partition_quantity
                             , i_search_type               => v_rec.search_type
                             , i_partitioning_type         => v_partitioning_type
                             , i_current_date              => current_date);
  end loop;

exception
  when others then
    o_result  := 0;
    o_message := 'Произошла ошибка при удалении старых партиций таблиц';

    declare
      v_stacktrace project_schema.logs.stacktrace%type;
    begin
      get stacked diagnostics v_stacktrace = pg_exception_context;

      call write_log(o_message, v_stacktrace);
      commit;
    end;
end;
$body$
language  plpgsql;
