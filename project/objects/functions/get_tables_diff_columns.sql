create or replace function maintenance_schema.get_tables_diff_columns(i_table_owner        varchar
                                                                    , i_main_table_name    varchar
                                                                    , i_except_table_name  varchar)
returns int
as
$body$
declare
  v_cnt int;
begin
  select count(1)
    into v_cnt
  from (select attnum
             , attname
             , format_type(atttypid, atttypmod) as type
             , attlen
             , atttypmod
             , attnotnull
          from pg_attribute mt
         where attrelid = (i_table_owner || '.' || i_main_table_name)::regclass
           and attnum > 0
        except 
        select attnum
             , attname
             , format_type(atttypid, atttypmod) as type
             , attlen
             , atttypmod
             , attnotnull
          from pg_attribute mt
         where attrelid = (i_table_owner || '.' || i_except_table_name)::regclass
           and attnum > 0) t;
  return v_cnt;
end;
$body$
language  plpgsql;