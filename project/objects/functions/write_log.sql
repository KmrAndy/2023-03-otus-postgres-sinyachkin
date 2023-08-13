-- функция логирования
drop function if exists project_schema.write_log;
create or replace function project_schema.write_log(p_message    project_schema.logs.message%type
                                                  , p_stacktrace project_schema.logs.stacktrace%type default null)
returns void
as
$body$
begin
  insert into project_schema.logs(message, stacktrace) values (p_message, p_stacktrace);
end;
$body$
language  plpgsql;
