--logs
insert into project_schema.logs (log_date, username, pid, message, stacktrace)  
select '2023-01-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 1000000) f(i);
  
insert into project_schema.logs (log_date, username, pid, message, stacktrace) 
select '2023-02-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 1100000) f(i);

insert into project_schema.logs (log_date, username, pid, message, stacktrace) 
select '2023-03-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 1500000) f(i);

insert into project_schema.logs (log_date, username, pid, message, stacktrace) 
select '2023-04-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 500000) f(i);

insert into project_schema.logs (log_date, username, pid, message, stacktrace) 
select '2023-05-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 600000) f(i);

insert into project_schema.logs (log_date, username, pid, message, stacktrace) 
select '2023-06-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 800000) f(i);

insert into project_schema.logs (log_date, username, pid, message, stacktrace) 
select '2023-07-01 00:00:00'::timestamp, i::varchar, i, i::varchar, null::varchar from generate_series(1, 900000) f(i);

-- list_table
insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230101'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 1000000) f(i);

insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230201'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 1100000) f(i);

insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230301'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 1500000) f(i);

insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230401'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 500000) f(i);

insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230501'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 600000) f(i);

insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230601'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 800000) f(i);

insert into project_schema.list_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, to_char('20230701'::date + interval '1 month - 1 day', 'yyyymmdd')::int, statement_timestamp() , i::varchar, i::integer from generate_series(1, 900000) f(i);

-- list_table_growthkey
insert into project_schema.list_table_growthkey (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, trunc(random() * 10)::int + 1, statement_timestamp() , i::varchar, i::integer from generate_series(1, 1000000) f(i);

-- list_year_table
insert into project_schema.list_year_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, 20221231, statement_timestamp() , i::varchar, i::integer from generate_series(1, 1000000) f(i);

insert into project_schema.list_year_table (field_id , field_partkey , field_1, field_2, field_3) 
select i::bigint, 20231231, statement_timestamp() , i::varchar, i::integer from generate_series(1, 1000000) f(i);


