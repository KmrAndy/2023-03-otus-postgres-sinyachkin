create or replace function maintenance_schema.drop_old_table_partitions(out p_result integer
                                                                      , out p_message varchar)
returns record
as
$body$
declare
  v_rec record;
begin
  for v_rec in (select table_owner, table_name, stored_partition_quantity, search_type 
                  from project_schema.drop_table_partitions
                 where enabled = 'Y')
  loop
  	null;
  end loop;
 
  p_result  := 1;
  p_message := 'Удаления старых партиций таблиц выполнено успешно';
exception
  when others then
    p_result  := 0;
    p_message := 'Произошла ошибка при удалении старых партиций таблиц';

    declare
      v_stacktrace project_schema.logs.stacktrace%type;
    begin
      get stacked diagnostics v_stacktrace = pg_exception_context;

      perform write_log(p_message, v_stacktrace);
      commit;
    end;
end;
$body$
language  plpgsql;