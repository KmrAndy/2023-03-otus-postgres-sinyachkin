create or replace procedure maintenance_schema.create_table_partitions(i_table_owner               varchar
                                                                     , i_table_name                varchar
                                                                     , i_stored_partition_quantity integer
                                                                     , i_search_type               integer
                                                                     , i_partitioning_type         varchar
                                                                     , i_partition_interval        varchar
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
                                               , i_search_direction   => 'NEXT'
                                               , i_search_date        => i_current_date);
  
  -- Если нечего создавать - выходим
  if i_stored_partition_quantity - coalesce(array_length(v_partitions_params, 1), 0) <= 0 then
    call project_schema.write_log('Не нужно создавать партиции у таблицы ' || i_table_owner || '.' || i_table_name);
    return;
  end if;
   
  -- Берём последнюю созданную партцию, от неё будет создавать следующие
  v_last_partition_params := v_partitions_params[array_upper(v_partitions_params, 1)];
  
  for p in 1 .. i_stored_partition_quantity - array_length(v_partitions_params, 1)
  loop
	-- Родительская таблица у партиций одна и та же
	v_new_partition_params.table_owner := v_last_partition_params.table_owner;
    v_new_partition_params.table_name  := v_last_partition_params.table_name;
   
  	-- TO DO:
	-- По идее, должен быть справочник с масками имени партиций и формирования ключа, но это достаточно долгий процесс
	-- Пока будем рабоать только с датами в range и list партициях
	if i_partitioning_type = 'r' then
	  if i_partition_interval = 'DAY' then
	    v_new_partition_params.partition_value := ((v_last_partition_params.partition_value::date + interval '1 day')::date)::varchar; 
	    v_new_partition_params.partition_name  := v_last_partition_params.table_name || '_' || to_char(v_last_partition_params.partition_value::date, 'yyyymmdd');
	    
	  elsif i_partition_interval = 'MONTH' then
	    v_new_partition_params.partition_value := ((v_last_partition_params.partition_value::date + interval '1 month')::date)::varchar;
	    v_new_partition_params.partition_name  := v_last_partition_params.table_name || '_' || to_char(v_last_partition_params.partition_value::date, 'yyyymm');
	   
	  elsif i_partition_interval = 'YEAR' then
	    v_new_partition_params.partition_value := ((v_last_partition_params.partition_value::date + interval '1 year')::date)::varchar;
	    v_new_partition_params.partition_name  := v_last_partition_params.table_name || '_' || to_char(v_last_partition_params.partition_value::date, 'yyyy');
	  end if;
	 
	  -- Вычисляем новое табличное пространство.
	  -- В моем случае есть только месячные табличные пространства tblspace******
	  if v_last_partition_params.tablespace_name like 'tblspace%' then
	    select coalesce(max(spcname), 'pg_default')
	      into v_new_partition_params.tablespace_name
	      from pg_tablespace
	     where spcname like 'tblspace%'
	       and right(spcname, 6)::integer = to_char(v_last_partition_params.partition_value::date, 'yyyymm')::integer;
	  else
	    v_new_partition_params.tablespace_name := 'pg_default';
	  end if;
	  
	  -- default_tablespace нужен, чтобы индексы, если они есть на родительской таблице, создались в том же табличном пространстве, что и новая партиция
      execute format('set default_tablespace = %s', v_new_partition_params.tablespace_name);
	  
	  execute format('create table %s.%s partition of %s.%s for values from(%L) to (%L) tablespace %s', v_new_partition_params.table_owner
                                                                                                      , v_new_partition_params.partition_name
                                                                                                      , v_new_partition_params.table_owner
                                                                                                      , v_new_partition_params.table_name
                                                                                                      , v_last_partition_params.partition_value
                                                                                                      , v_new_partition_params.partition_value
                                                                                                      , v_new_partition_params.tablespace_name);
      execute format('reset default_tablespace');
	 
	elsif i_partitioning_type = 'l' then
	  if i_partition_interval = 'DAY' then
	    v_new_partition_params.partition_value := to_char(v_last_partition_params.partition_value::date + interval '1 day', 'yyyymmdd');
	    v_new_partition_params.partition_name  := v_last_partition_params.table_name || '_' || v_new_partition_params.partition_value;
	    
	  elsif i_partition_interval = 'MONTH' then
	    v_new_partition_params.partition_value := to_char(date_trunc('month', v_last_partition_params.partition_value::date + interval '1 month') + interval '1 month - 1 day', 'yyyymmdd');
	    v_new_partition_params.partition_name  := v_last_partition_params.table_name || '_' || v_new_partition_params.partition_value;
	   
	  elsif i_partition_interval = 'YEAR' then
	    v_new_partition_params.partition_value := to_char(date_trunc('year', v_last_partition_params.partition_value::date + interval '1 year') + interval '1 year - 1 day', 'yyyymmdd');
	    v_new_partition_params.partition_name  := v_last_partition_params.table_name || '_' || to_char(v_new_partition_params.partition_value::date, 'yyyy');
	  end if;
	  
	  -- Вычисляем новое табличное пространство.
	  -- В моем случае есть только месячные табличные пространства tblspace******
	  if v_last_partition_params.tablespace_name like 'tblspace%' then
	    select coalesce(max(spcname), 'pg_default')
	      into v_new_partition_params.tablespace_name
	      from pg_tablespace
	     where spcname like 'tblspace%'
	       and right(spcname, 6)::integer = substr(v_new_partition_params.partition_value, 1, 6)::integer;
	  else
	    v_new_partition_params.tablespace_name := 'pg_default';
	  end if;
	 
	  -- default_tablespace нужен, чтобы индексы, если они есть на родительской таблице, создались в том же табличном пространстве, что и новая партиция
      execute format('set default_tablespace = %s', v_new_partition_params.tablespace_name);
     
	  execute format('create table %s.%s partition of %s.%s for values in(%s) tablespace %s', v_new_partition_params.table_owner
                                                                                            , v_new_partition_params.partition_name
                                                                                            , v_new_partition_params.table_owner
                                                                                            , v_new_partition_params.table_name
                                                                                            , v_new_partition_params.partition_value
                                                                                            , v_new_partition_params.tablespace_name);
      execute format('reset default_tablespace');
	end if;

    call project_schema.write_log('Партиция ' || v_new_partition_params.partition_name ||
                                  ' таблицы ' || v_new_partition_params.table_owner || '.' || v_new_partition_params.table_name || ' создана');
    
    -- Теперь последняя партиция - только что созданная
    v_last_partition_params := v_new_partition_params;
  end loop;
  
exception
  when others then
    execute format('reset default_tablespace');
    raise notice 'Ошибка: %', sqlerrm;
    raise;
end;
$body$
language  plpgsql;