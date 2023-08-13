do
$$
declare r record;
begin
    select 1/0;
exception
  when others then
    declare
      v_stacktrace project_schema.logs.stacktrace%type;
    begin
      get stacked diagnostics v_stacktrace = pg_exception_context;

      perform write_log('test2'::varchar, v_stacktrace);
      commit;
    end;
    raise;
end$$;