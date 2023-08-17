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

do
$$
declare
  v_partitions_params partition_params[];
begin
  select array_agg((partition_name, table_owner, table_name)::partition_params)
  into v_partitions_params
  from maintenance_schema.get_table_partitions(i_table_owner        => 'project_schema'
                                                               , i_table_name         => 'logs'
                                                               , i_partitioning_type  => 'r'
                                                               , i_search_type        => 1
                                                               , i_search_direction   => 'PREV'
                                                               , i_search_date        => current_date);
  
end;
$$
language  plpgsql;

select array_agg((partition_name, table_owner, table_name)::partition_params) from maintenance_schema.get_table_partitions(i_table_owner        => 'project_schema'
                                                               , i_table_name         => 'logs'
                                                               , i_partitioning_type  => 'r'
                                                               , i_search_type        => 1
                                                               , i_search_direction   => 'PREV'
                                                               , i_search_date        => current_date);
                                                              
                                                              with tab as (
  values
    ((1, 'dog')::rt),
    ((2, 'cat')::rt),
    ((3, 'ant')::rt))
select array_agg(column1 order by column1) as arr
from tab;

select * from project_schema.logs;

commit;

CREATE TABLE cities (
    city_id      bigserial not null,
    name         text not null,
    population   bigint
) PARTITION BY LIST (population);

CREATE TABLE cities_1
    PARTITION OF cities (
    CONSTRAINT city_id_nonzero CHECK (city_id != 0)
) FOR VALUES IN (1);


CREATE TABLE cities_2
    PARTITION OF cities (
    CONSTRAINT city_id_nonzero CHECK (city_id != 0)
) FOR VALUES in (2);

drop table cities;