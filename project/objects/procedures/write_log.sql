-- функция логирования
drop procedure if exists project_schema.write_log;
create or replace procedure project_schema.write_log(i_message    project_schema.logs.message%type
                                                   , i_stacktrace project_schema.logs.stacktrace%type default null)
as
$body$
begin
  insert into project_schema.logs(message, stacktrace) values (i_message, i_stacktrace);
end;
$body$
language  plpgsql;
