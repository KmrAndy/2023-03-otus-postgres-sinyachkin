create or replace procedure maintenance_schema.archive_table_partitions(i_table_owner               varchar
                                                                      , i_table_name                varchar
                                                                      , i_archive_table_name        varchar
                                                                      , i_stored_partition_quantity integer
                                                                      , i_search_type               integer
                                                                      , i_partitioning_type         varchar
                                                                      , i_current_date              date default null)
as
$body$
declare
  v_partitions_params      maintenance_schema.partition_params[];
  v_last_partition_params  maintenance_schema.partition_params;
  v_new_partition_params   maintenance_schema.partition_params;
begin
  -- Собираем партиции таблицы
  -- Массив отсортирован по возрастанию
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
  
  -- Если нечего архивировать - выходим
  if coalesce(array_length(v_partitions_params, 1), 0) - i_stored_partition_quantity <= 0 then
    call project_schema.write_log('Не нужно архивировать партиции у таблицы ' || i_table_owner || '.' || i_table_name);
    return;
  end if;
  
  -- Отцепляем подходящие архивные партиции и прицепляем к архивной таблице
  for p in array_lower(v_partitions_params, 1) .. array_upper(v_partitions_params, 1) - i_stored_partition_quantity
  loop
	-- Нельзя сделать DETACH CONCURRENTLY внутри функции, ограничение POSTGRES.
	-- По хорошему нужно переводить на микросервисную архитектуру
    execute format('alter table %I.%I detach partition %I.%I', i_table_owner
                                                             , i_table_name
                                                             , i_table_owner
                                                             , v_partitions_params[p].partition_name);
    
    execute format('alter table %I.%I attach partition %I.%I %s', i_table_owner
                                                                , i_archive_table_name
                                                                , i_table_owner
                                                                , v_partitions_params[p].partition_name
                                                                , v_partitions_params[p].partition_expr);
    
    -- Делаем вставку в очередь для переноса в архивную БД
    call maintenance_schema.queue_to_archive(i_table_owner    => i_table_owner
                                           , i_table_name     => i_archive_table_name
                                           , i_partition_name => v_partitions_params[p].partition_name);
   
    call project_schema.write_log('Партиция ' || v_partitions_params[p].partition_name || ' таблицы ' || i_table_owner || '.' || i_table_name ||
                                                                    ' перенесена в архивную таблицу ' || i_table_owner || '.' || i_archive_table_name);
  end loop;
  
exception
  when others then
    raise notice 'Ошибка: %', sqlerrm;
    raise;
end;
$body$
language  plpgsql;