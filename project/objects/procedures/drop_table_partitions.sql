create or replace procedure maintenance_schema.drop_table_partitions(i_table_owner               varchar
                                                                   , i_table_name                varchar
                                                                   , i_stored_partition_quantity integer
                                                                   , i_search_type               integer
                                                                   , i_partitioning_type         varchar
                                                                   , i_current_date              date default null)
as
$body$
declare
  v_partitions_params maintenance_schema.partition_params[];
  v_partition_not_archieved boolean;
begin
  -- Собираем партиции таблицы
  select array_agg((partition_name
                  , table_owner
                  , table_name
                  , partition_value
                  , tablespace_name
                  , partition_expr)::maintenance_schema.partition_params)
    into v_partitions_params
    from maintenance_schema.get_table_partitions(i_table_owner        => i_table_owner
                                               , i_table_name         => i_table_name
                                               , i_partitioning_type  => i_partitioning_type
                                               , i_search_type        => i_search_type
                                               , i_search_direction   => 'PREV'
                                               , i_search_date        => i_current_date);
  
  -- Если нечего удалять - выходим
  if coalesce(array_length(v_partitions_params, 1), 0) - i_stored_partition_quantity <= 0 then
    call project_schema.write_log('Не нужно удалять партиции у таблицы ' || i_table_owner || '.' || i_table_name);
    return;
  end if;
  
  -- Удаляем подходящие партиции
  for p in array_lower(v_partitions_params, 1) .. array_upper(v_partitions_params, 1) - i_stored_partition_quantity
  loop
	-- Архивные партиции можем удалять только после переноса в архив
	if v_partitions_params[p].table_name like 'arch_%' then
	  select count(1) > 0
	    into v_partition_not_archieved
	    from project_schema.archiever_queue q
	   where q.process_flag   = 1
	     and q.table_owner    = v_partitions_params[p].table_owner
	     and q.table_name     = v_partitions_params[p].table_name
	     and q.partition_name = v_partitions_params[p].partition_name;
	  
	  if v_partition_not_archieved then
	    call project_schema.write_log('Партиция ' || v_partitions_params[p].partition_name ||
                                      ' таблицы ' || v_partitions_params[p].table_owner || '.' || v_partitions_params[p].table_name || ' ещё не перенесена в архивную БД!');
	    continue;
	  end if;
	end if;

    execute format('drop table %I.%I', v_partitions_params[p].table_owner, v_partitions_params[p].partition_name);
   
    call project_schema.write_log('Партиция ' || v_partitions_params[p].partition_name ||
                                  ' таблицы ' || v_partitions_params[p].table_owner || '.' || v_partitions_params[p].table_name || ' удалена');
  end loop;
end;
$body$
language  plpgsql;