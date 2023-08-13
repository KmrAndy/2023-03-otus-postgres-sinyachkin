create or replace function maintenance_schema.check_table(in  p_table_owner          varchar
                                                        , in  p_table_name           varchar
                                                        , out p_partitioning_type    varchar
                                                        , out p_subpartitioning_type varchar
                                                        , out is_table_supported     boolean)
returns record
as
$body$
declare
  v_rec record;
begin
  null;
end;
$body$
language  plpgsql;