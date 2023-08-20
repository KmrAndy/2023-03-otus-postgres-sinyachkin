do
$$
declare
  v_result  integer;
  v_message varchar(255);
begin
  call maintenance_schema.set_parameter(i_module => 'table_maintenance'
                                      , i_param  => 'maintenance enabled'
                                      , i_value  => 'Y');
  raise notice 'Флаг обслуживания партиций таблиц поднят';
  --
  
  call maintenance_schema.drop_old_table_partitions(o_result  => v_result
                                                  , o_message => v_message);
  raise notice 'Удаление партиций - результат: %, сообщение: %', v_result, v_message;
  --
  
  call maintenance_schema.archive_old_table_partitions(o_result  => v_result
                                                     , o_message => v_message);
  raise notice 'Архивация партиций - результат: %, сообщение: %', v_result, v_message;
  --

  call maintenance_schema.create_new_table_partitions(o_result  => v_result
                                                    , o_message => v_message);
  raise notice 'Создание партиций - результат: %, сообщение: %', v_result, v_message;
  --

  call maintenance_schema.set_parameter(i_module => 'table_maintenance'
                                      , i_param  => 'maintenance enabled'
                                      , i_value  => 'N');
  raise notice 'Флаг обслуживания партиций таблиц снят';
end;
$$
language  plpgsql;

select *
  from maintenance_schema.get_table_partitions(i_table_owner        => 'project_schema'
                                             , i_table_name         => 'arch_logs'
                                             , i_partitioning_type  => 'r'
                                             , i_search_type        => 2
                                             , i_search_direction   => 'PREV'
                                             , i_search_date        => current_date);


select * from project_schema.logs l order by l.log_id;

select * from project_schema.archive_table_partitions;

select relname, reltablespace  from pg_class where schemaname = 'project_schema';

select * from pg_partition_tree('project_schema.list_year_table');

select * from maintenance_schema.
     
select * from pg_indexes where tablename = 'logs_202303'