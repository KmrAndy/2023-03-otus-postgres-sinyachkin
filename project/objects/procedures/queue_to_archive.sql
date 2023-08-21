-- функция постановки в очередь задания на перенос в архивную БД
drop procedure if exists maintenance_schema.queue_to_archive;
create or replace procedure maintenance_schema.queue_to_archive(i_table_owner    project_schema.archiever_queue.table_owner%type
                                                              , i_table_name     project_schema.archiever_queue.table_name%type
                                                              , i_partition_name project_schema.archiever_queue.partition_name%type)
as
$body$
begin
  insert into project_schema.archiever_queue(table_owner,   table_name,   partition_name,   process_flag)
                                     values (i_table_owner, i_table_name, i_partition_name, 1);
end;
$body$
language  plpgsql;