create or replace procedure maintenance_schema.set_parameter(i_module project_schema.parameters.module%type
                                                           , i_param  project_schema.parameters.param%type
                                                           , i_value  project_schema.parameters.value%type)
as
$body$
declare
  v_cnt int;
begin
  merge into project_schema.parameters p
  using (select i_module as module
              , i_param  as param
              , i_value  as value) np
     on p.module = np.module and p.param = np.param
when matched then
  update set value = np.value
when not matched then
  insert (module,    param,    value)
  values (np.module, np.param, np.value);
end;
$body$
language  plpgsql;