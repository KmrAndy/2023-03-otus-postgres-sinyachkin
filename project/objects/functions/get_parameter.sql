create or replace function maintenance_schema.get_parameter(i_module project_schema.parameters.module%type
                                                          , i_param  project_schema.parameters.param%type)
returns project_schema.parameters.value%type
as
$body$
declare
  v_value project_schema.parameters.value%type;
begin
  select value
    into v_value
    from project_schema.parameters p
   where p.module = i_module
     and p.param  = i_param;
  
  return v_value;
end;
$body$
language  plpgsql;